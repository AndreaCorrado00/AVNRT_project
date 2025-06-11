function template=get_template(template_type,main_ambient)
% GET_TEMPLATE - Generates a predefined template waveform for correlation-based feature extraction.
%
% Syntax:
%   template = get_template(template_type, main_ambient)
%
% Description:
%   This function creates a time-domain template waveform based on the specified
%   template type. The waveform is generated with a fixed duration and optionally
%   smoothed using a Gaussian filter. It is intended for use in template matching
%   algorithms for signal analysis.
%
%   Two types of templates are currently supported:
%     - "Simple" : A symmetric biphasic waveform (positive-negative) with triangular shape
%     - "Complex": A multiphasic waveform with three peaks (positive-negative-positive) 
%                  and a return to baseline
%
% Inputs:
%   template_type - A string specifying the desired template type ('Simple' or 'Complex')
%   main_ambient  - A struct containing configuration parameters, including:
%                   * .feature_extraction_opt.TemplateMatching.template_duration (in seconds)
%                   * .feature_extraction_opt.TemplateMatching.template_smoothing_window
%                   * .fc (sampling frequency in Hz)
%
% Outputs:
%   template      - A 1D numeric vector representing the generated template signal
%
% Notes:
%   - The waveform duration is quantized to the nearest number of samples.
%   - A Gaussian smoothing is applied if the smoothing window is greater than zero.
%   - The template is used in conjunction with cross-correlation in downstream analysis.
%
% Author: Andrea Corrado
%% Template definition parameters extraction
duration=main_ambient.feature_extraction_opt.TemplateMatching.template_duration;
smoothing_window=main_ambient.feature_extraction_opt.TemplateMatching.template_smoothing_window;
Fs=main_ambient.fc;

%% Template definition
switch template_type
    case "Simple"
        % Adjust the duration to the nearest multiple of 1/Fs to ensure the signal fits within the desired length
        N = round(duration * Fs);       % Total number of samples

        % Calculate the number of samples for half the duration
        N_half = round(N / 2);

        % Generate the first half: ascending and descending (0 -> 1 -> 0)
        x1 = linspace(0, 1, round(N_half / 2));  % Ascending phase from 0 to 1
        x2 = flip(x1);  % Descending phase, flipped from x1 (from 1 back to 0)
        first_half = [x1, x2];  % Combine both ascending and descending phases

        % Generate the second half by reflecting (negating) the first half
        second_half = -first_half;  % Inverse of the first half (flipped vertically)

        % Combine both halves to form the complete biphasic template  
        template = [first_half(1:end-1), second_half];  % Ensure no overlap at the transition

    case "Complex"
        N = round(duration * Fs);

        % Define the multiphasic structure:
        % Segment 1: Positive peak (from 0 to 0.5)
        x1 = linspace(0, 0.5, round(N / 4));  % Linear transition from 0 to 0.5

        % Segment 2: Negative peak (from 0.5 to -1)
        x2 = linspace(0.5, -1, round(N / 4)); % Linear transition from 0.5 to -1

        % Segment 3: Second positive peak (from -1 to 0.5)
        x3 = linspace(-1, 0.5, round(N / 4)); % Linear transition from -1 to 0.5

        % Segment 4: Return to baseline (from 0.5 to 0)
        x4 = linspace(0.5, 0, N - length(x1) - length(x2) - length(x3));
        % Linear transition from 0.5 back to 0, filling the remaining length

        % Combine all segments to create the multiphasic signal
        template = [x1, x2, x3, x4];

end

% Smooth the entire signal using a Gaussian filter, if smoothing_window > 0
if smoothing_window > 0
    % Apply Gaussian smoothing with the specified window size
    template = smoothdata(template, 'gaussian', smoothing_window);
end

