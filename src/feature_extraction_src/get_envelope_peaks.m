function [original_env_peaks_val_pos,original_rov_peaks_val_pos]=get_envelope_peaks(example_rov,example_env,time_th,fc)
%GET_ENVELOPE_PEAKS Extract peak values and positions from envelope and raw signals.
%
%   [env_peaks, rov_peaks] = GET_ENVELOPE_PEAKS(example_rov, example_env, time_th, fc)
%
%   Identifies the maximum peak values and their corresponding time positions
%   from both an envelope signal and a raw signal (typically rectified or oscillatory)
%   within specified time intervals.
%
%   INPUTS:
%       example_rov : Vector
%           Raw signal from which to extract absolute peak values (e.g., rectified EMG).
%       example_env : Vector
%           Envelope signal from which to extract peak values (e.g., smoothed EMG).
%       time_th     : Nx2 matrix
%           Each row defines a [start_idx, end_idx] range (in samples) within which to
%           search for peaks. A maximum of 3 intervals are processed.
%       fc          : Scalar
%           Sampling frequency in Hz. Used to convert sample indices to seconds.
%
%   OUTPUTS:
%       original_env_peaks_val_pos : max(N,3)x2 matrix
%           Each row contains [peak_value, time_position] for the envelope signal.
%           Time is in seconds.
%       original_rov_peaks_val_pos : max(N,3)x2 matrix
%           Each row contains [peak_value, time_position] for the raw signal.
%           Time is in seconds.
%
%   Notes:
%       - The function processes up to 3 time intervals, even if more are provided.
%       - NaN is used to fill unused rows if N < 3.
%       - All peak detections ignore NaNs within the signal segments.
%
%   Example usage:
%       [env_peaks, rov_peaks] = get_envelope_peaks(my_rov, my_env, [100 300; 400 600], 1000);
%
% Author: Andrea Corrado

%% Initialization
[N,~]=size(time_th);
%% Peaks of active areas extraction
original_env_peaks_val_pos = nan(max([3, N]), 2);
original_rov_peaks_val_pos = nan(max([3, N]), 2);

for i = 1:min([N, 3])
    [max_val, max_pos] = max(example_env(time_th(i, 1):time_th(i, 2)), [], "omitnan");
    original_env_peaks_val_pos(i, :) = [max_val, (max_pos + time_th(i, 1)) / fc];

    [max_val, max_pos] = max(abs(example_rov(time_th(i, 1):time_th(i, 2))), [], "omitnan");
    original_rov_peaks_val_pos(i, :) = [max_val, (max_pos + time_th(i, 1)) / fc];
end
