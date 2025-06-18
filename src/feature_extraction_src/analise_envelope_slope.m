function [map_upper, map_lower] = analise_envelope_slope(example_env, mult_factor, fc)
% analise_envelope_slope - Analyzes the slope of the envelope of a signal to detect areas of significant 
%                          change, producing thresholded maps for further processing.
%
% Syntax:
%   [map_upper, map_lower] = analise_envelope_slope(example_env, mult_factor, fc)
%
% Input Arguments:
%   example_env  - A vector representing the envelope of the signal to be analyzed.
%   mult_factor  - A multiplier factor used to scale the upper and lower thresholds.
%   fc           - The sampling frequency of the signal in Hz.
%
% Output Arguments:
%   map_upper    - A binary map where values represent regions where the derivative of the envelope exceeds
%                  the upper threshold, indicating significant positive slope areas.
%   map_lower    - A binary map where values represent regions where the derivative of the envelope is below
%                  the lower threshold, indicating significant negative slope areas.
%
% Description:
%   This function processes the input envelope signal (`example_env`) by computing its derivative and applying
%   thresholds to detect areas of significant slope change. These areas are defined as the "active" regions and are
%   marked using binary maps (`map_upper` and `map_lower`). The function performs the following steps:
%
%   1. **Smoothing**: The envelope is first smoothed using a moving average filter to reduce noise and improve
%      the derivative calculation.
%   2. **Derivative Computation**: The first derivative of the envelope is computed to capture slope changes.
%   3. **Edge Removal**: A portion of the signal at the start and end is removed to avoid edge artifacts.
%   4. **Thresholding**: The derivative signal is thresholded to create two maps (`map_upper` and `map_lower`) that 
%      represent significant positive and negative slope regions, respectively.
%   5. **Map Correction**: The binary maps are processed to merge adjacent "runs" (continuous regions) to ensure
%      consistency in detecting active areas.
%
%   The resulting maps are used to highlight regions of interest where the envelope's slope is either significantly
%   positive or negative, typically corresponding to key phases in the signal (e.g., atrial or ventricular phases).
%
% Example:
%   [map_upper, map_lower] = analise_envelope_slope(example_env, 0.1, 1000);

% Smoothing the envelope
example_env = movmean(example_env, 50);  % Apply moving average filter

% Computing the derivative of the envelope
d_env = diff(example_env);
d_env = [d_env; nan];  % Ensure same length as original
d_env = movmean(d_env, 100);  % Smoothing the derivative

% Edge removal to avoid artifacts
d_env(1:round(0.17 * fc)) = nan;  % Removing early part of the signal
d_env(round(0.6 * fc):end) = nan;  % Removing later part of the signal

% Removing mean from derivative to center the signal
d_env = d_env - mean(d_env, "omitnan");

%% Threshold definition
% Define the upper and lower thresholds based on the maximum and minimum values of the derivative
th_upper = abs(max(d_env, [], "omitnan"));
th_upper = th_upper * mult_factor;  % Scale by multiplier factor

th_lower = min(d_env, [], "omitnan");
th_lower = th_lower * mult_factor * 50;  % Scale lower threshold by a larger factor

%% Map creation
% Generate binary maps based on the thresholds
map_upper = d_env > th_upper;  % Active regions with positive slope
map_lower = d_env < th_lower;  % Active regions with negative slope

%% Map correction
% Merge runs in the binary maps to ensure continuity
[map_upper, map_lower] = merge_runs(map_upper, map_lower);

end
