function corr_signal=get_correlation_signal(signal, template, main_ambient)
% GET_CORRELATION_SIGNAL - Computes the normalized and smoothed cross-correlation 
% between an input signal and a given template.
%
% Syntax:
%   corr_signal = get_correlation_signal(signal, template, main_ambient)
%
% Description:
%   This function performs template matching by computing the cross-correlation 
%   between a normalized input signal and a normalized template. Both signal and 
%   correlation output are smoothed using a moving average window defined in the 
%   configuration. The result is a correlation signal suitable for feature extraction.
%
% Inputs:
%   signal        - A numeric vector representing the signal to be analyzed.
%   template      - A numeric vector representing the template to match.
%   main_ambient  - A struct containing configuration parameters, including:
%                   * .feature_extraction_opt.TemplateMatching.corr_signal_smoothing_window
%
% Outputs:
%   corr_signal   - A numeric vector representing the smoothed cross-correlation 
%                   signal between the input signal and the template.
%
% Notes:
%   - Both the signal and the template are normalized to unit energy before 
%     computing the correlation.
%   - The correlation is computed via convolution with the flipped template 
%     and centered ('same' option).
%   - The output is further smoothed with a moving average using the same 
%     window size used on the input signal.
%
% Author: Andrea Corrado

%% Correlation signal options 
smoothing_window=main_ambient.feature_extraction_opt.TemplateMatching.corr_signal_smoothing_window;

%% Correlation signal evaluation
norm_signal = sqrt(sum(signal.^2));  % Signal normalization
signal = signal / norm_signal;  % Normalize the signal
signal = movmean(signal, smoothing_window);  % Smooth the signal

% Generate multiphasic template
norm_template = sqrt(sum(template.^2));  % Template normalization
template = template / norm_template;  % Normalize the template

% Compute cross-correlation between the signal and the template
corr = conv(signal, flip(template), 'same');  % Convolution (cross-correlation)

% Apply moving average to the correlation for smoothing
corr_signal = movmean(corr, smoothing_window);  % Store the result