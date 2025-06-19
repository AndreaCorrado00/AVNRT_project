function time_th=get_time_thresholds(rov_signal,signal_env,main_ambient)
% GET_TIME_THRESHOLDS  Extracts active time regions from a signal envelope using derivative-based thresholding.
%
%   time_th = GET_TIME_THRESHOLDS(rov_signal, signal_env, main_ambient)
%
%   This function performs time-domain segmentation of a signal based on the dynamics
%   of its smoothed envelope. It identifies regions of interest (ROIs) where significant
%   signal activity occurs, by detecting positive and negative slopes in the first derivative 
%   of the envelope. A two-stage thresholding and correction mechanism ensures robustness 
%   against noise and missing transitions.
%
%   The pipeline includes:
%       - Smoothing of the envelope and its derivative
%       - Derivative-based thresholding to detect rising/falling edges
%       - Logical map construction and morphological correction
%       - Extraction of onset/offset times of active signal phases
%       - Iterative cleaning based on noise-adaptive amplitude thresholds
%
%   INPUTS:
%       rov_signal     - Raw signal vector (e.g., audio, biosignal)
%       signal_env     - Envelope of the signal (e.g., computed via Hilbert transform or rectification + low-pass)
%       main_ambient   - Configuration struct containing:
%                           .fc: sampling frequency
%                           .feature_extraction_opt.envelope:
%                               .SmoothPoints: [N_env, N_deriv] smoothing points
%                               .time_window: [t_start, t_end] in seconds
%                               .mult_factor: [upper, lower] threshold scaling
%                               .factor_K: multiplier for amplitude-based noise gating
%
%   OUTPUT:
%       time_th        - Nx2 matrix of time indices [start_idx, end_idx] corresponding 
%                        to detected active segments
%
%   Notes:
%   - The function is robust to missing or partially detected peaks by applying 
%     morphological corrections to the binary activity maps.
%   - Post-processing includes amplitude validation to discard low-SNR events 
%     via a dynamic noise threshold.
%
%   Dependencies:
%       - Requires helper function `find_runs` (defined below)
%
%   Author: Andrea Corrado


%% ########### ENVELOPE TIME THRESHOLDS EXTRACTION PIPELINE ########### %%
% Smoothing the envelope
[map_upper_2, map_lower_2,d_env_2,th_lower_2,th_upper_2]=analise_envelope_slope(signal_env,main_ambient.feature_extraction_opt.envelope.mult_factor(1),main_ambient.fc);

signal_env = movmean(signal_env, main_ambient.feature_extraction_opt.envelope.SmoothPoints(1));  % Apply moving average filter

% Computing the derivative of the envelope
d_env = diff(signal_env);
d_env = [d_env; nan];  % Ensure same length as original
d_env = movmean(d_env, main_ambient.feature_extraction_opt.envelope.SmoothPoints(2));  % Smoothing the derivative

% defining ROI of the signal
signal_start = round(main_ambient.feature_extraction_opt.envelope.time_window(1) * main_ambient.fc); % Signal start point
signal_end = round(main_ambient.feature_extraction_opt.envelope.time_window(2) * main_ambient.fc);    % Signal end point

% Edge removal to avoid artifacts
d_env(1:signal_start) = nan;  % Removing early part of the signal
d_env(signal_end:end) = nan;  % Removing later part of the signal

% Removing mean from derivative to center the signal
d_env = d_env - mean(d_env, "omitnan");

%% DERIVATIVE THRESHOLDING
% Define the upper and lower thresholds based on the maximum and minimum values of the derivative
th_upper = abs(max(d_env, [], "omitnan"));
th_upper = th_upper * main_ambient.feature_extraction_opt.envelope.mult_factor(1);  % Scale by multiplier factor

th_lower = min(d_env, [], "omitnan");
th_lower = th_lower * main_ambient.feature_extraction_opt.envelope.mult_factor(2);  % Scale lower threshold by a larger factor

%% Map evaluation
% Generate binary maps based on the thresholds
map_upper = d_env > th_upper;  % Active regions with positive slope
map_lower = d_env < th_lower;  % Active regions with negative slope



%% Map correction
% Merge runs in the binary maps to ensure continuity

% Identify runs of 1s in the logical vectors
upper_regions = regionprops(map_upper, 'PixelIdxList');
lower_regions = regionprops(map_lower, 'PixelIdxList');


% Handling possibility of peaks not fully detected
i = 1;
while i < numel(upper_regions)

    % End of the current run and start of the next run in map_upper
    end_current = upper_regions(i).PixelIdxList(end);
    start_next = upper_regions(i+1).PixelIdxList(1);

    % Check if there is no overlap with map_lower
    if all(~map_lower(end_current:start_next)) % no 1s in map_lower
        % assume that there is a descend in the middle between two
        % consecutive run upper (maybe not detected by the threshold)
        half_width=end_current+round((start_next-end_current)/2);

        map_lower(upper_regions(i).PixelIdxList(end)+1:half_width) = 1;
    else
        i = i + 1;
    end
end

% Merge consecutive runs of map_lower that are not followed by runs in map_upper
i = 2;
while i < numel(lower_regions)
    % End of the current run and start of the next run in map_lower
    end_current = lower_regions(i-1).PixelIdxList(end);
    start_next = lower_regions(i).PixelIdxList(1);
    % Check if there is no overlap with map_upper
    if all(~map_upper(end_current:start_next)) % no 1s in map_upper
        % assume that there is a descend in the middle between two
        % consecutive run upper (maybe not detected by the threshold)
        half_width=end_current+round((start_next-end_current)/2);
        map_upper(half_width:lower_regions(i).PixelIdxList(1)-1) = 1;
    else
        i = i + 1;
    end
end

% Identify runs of 1s in the logical vectors
upper_regions = regionprops(map_upper, 'PixelIdxList');
lower_regions = regionprops(map_lower, 'PixelIdxList');

% Add a positive run at the start if needed
if numel(lower_regions)>1 && lower_regions(1).PixelIdxList(1) < upper_regions(1).PixelIdxList(end) && lower_regions(1).PixelIdxList(1)>signal_start
    % Add a positive run before the first negative run
    map_upper(signal_start+round((lower_regions(1).PixelIdxList(1)-signal_start)/2):lower_regions(1).PixelIdxList(1) - 1) = 1;
end

% Add a negative run at the end if needed
if numel(upper_regions)>1 && upper_regions(end).PixelIdxList(end) > lower_regions(end).PixelIdxList(end) && upper_regions(end).PixelIdxList(end)<signal_end
    % Add a negative run after the last positive run
    map_lower(upper_regions(end).PixelIdxList(end) + 1:upper_regions(end).PixelIdxList(end)+round((signal_end-upper_regions(end).PixelIdxList(end)+1)/2)) = 1;
end

% Ensure the combined map starts with a run in map_upper
first_upper = find(map_upper, 1, 'first');
first_lower = find(map_lower, 1, 'first');

if isempty(first_upper) || (~isempty(first_lower) && first_lower < first_upper)
    % If map_lower starts before map_upper, set map_lower to 0 before the first map_upper
    map_lower(1:first_upper-1) = 0;
end

% Ensure the combined map ends with a run in map_lower
last_lower = find(map_lower, 1, 'last');
last_upper = find(map_upper, 1, 'last');

if isempty(last_lower) || (~isempty(last_upper) && last_upper > last_lower)
    % If map_upper ends after map_lower, set map_upper to 0 after the last map_lower
    map_upper(last_lower+1:end) = 0;
end





%% TIME THRESHOLDS DEFINITION

time_th = [];

% Find the consecutive runs of 1s in both maps
upper_runs = find_runs(map_upper);  % Runs of 1s in the upper map
lower_runs = find_runs(map_lower);  % Runs of 1s in the lower map

% Iterate through each pair of upper and lower runs
for i = 1:length(upper_runs)
    % Check if there is a corresponding lower run after the upper run
    if i <= length(lower_runs)
        % Extract the start and end times for the upper run
        upper_start = upper_runs{i}(1);
        upper_end = upper_runs{i}(end);

        % Extract the start and end times for the lower run
        lower_start = lower_runs{i}(1);
        lower_end = lower_runs{i}(end);

        % Ensure that the lower run starts after the upper run
        if lower_start > upper_end
            % Add the valid region (start of upper run, end of lower run) to the result
            time_th = [time_th; upper_start, lower_end];
        end
    end
end

%% Time thresholds iterative cleaning

[N, ~] = size(time_th);

% Iterative process to assess true peak presence
stop = false;
% Initialization
N_start = N;                    % Initial number of active areas detected
time_th_start = time_th;        % Initial time thresholds
K=main_ambient.feature_extraction_opt.envelope.factor_K;
while ~stop
    % Create mask to exclude active areas
    mask = true(size(rov_signal));
    for i = 1:N_start
        mask(time_th_start(i, 1):time_th_start(i, 2)) = false;
    end

    % Inactive signal
    signal_inactive_phase = rov_signal(signal_start:signal_end);
    signal_inactive_phase = signal_inactive_phase(mask(signal_start:signal_end));

    % Threshold definition based on noise
    std_noise_estimated = std(signal_inactive_phase);
    Threshold = K * std_noise_estimated;

    % Check for non-significant peaks
    not_significative_peaks_positions = zeros(N_start, 1);
    for i = 1:N_start
        if max(abs(rov_signal(time_th_start(i, 1):time_th_start(i, 2)))) < Threshold
            % Peak is not significant, label it for removal
            not_significative_peaks_positions(i) = 1;
        end
    end

    % Remove non-significant peaks
    time_th_start(not_significative_peaks_positions == 1, :) = [];
    N_start = size(time_th_start, 1); % Update the number of active peaks

    % Check if all peaks are removed
    if N_start == 0
        % Show warning and reduce K
        % warning('All peaks have been removed! Reducing K from %.2f to %.2f.', K, K / 2);
        K = K / 2;
        % Reset to initial time thresholds to retry
        time_th_start = time_th;
        N_start = size(time_th_start, 1);
        continue;
    end

    % Stop condition: no peaks were dropped in this iteration
    if sum(not_significative_peaks_positions) == 0
        stop = true;
    end
end
% Final output
time_th = time_th_start;
end


%% ------------------------------------------------------------------------

%% Helper function to find consecutive runs of 1s in a binary vector
function runs = find_runs(binary_map)
runs = {};  % Initialize cell array to store run indices
start_idx = NaN;  % Initialize variable to mark the start of a new run

% Loop through the binary map to identify consecutive runs of 1s
for i = 1:length(binary_map)
    if binary_map(i) == 1  % A 1 indicates the start of a run
        if isnan(start_idx)
            start_idx = i;  % Mark the start of a new run
        end
    elseif binary_map(i) == 0 && ~isnan(start_idx)  % A 0 indicates the end of a run
        runs{end + 1} = start_idx:i-1;  % Store the indices of the run
        start_idx = NaN;  % Reset start index for the next run
    end
end

% If the final run ends at the last index, store it as well
if ~isnan(start_idx)
    runs{end + 1} = start_idx:length(binary_map);
end
end