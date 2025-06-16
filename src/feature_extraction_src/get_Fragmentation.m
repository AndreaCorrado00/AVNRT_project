function Fragmentation = get_Fragmentation(example_rov, th, fc)
% compute_fragmentation_value - Computes the fragmentation value based on the number of peaks 
%                              exceeding a threshold in the rectified signal.
%
% Syntax:
%   Fragmentation = compute_fragmentation_value(example_rov, th, fc)
%
% Input Arguments:
%   example_rov  - A vector representing the signal (e.g., raw or processed ROV signal).
%   th           - A threshold multiplier used to scale the median absolute deviation for peak detection.
%   fc           - The sampling frequency of the signal in Hz.
%
% Output Arguments:
%   Fragmentation - The number of peaks in the rectified signal that exceed a dynamic threshold, indicating 
%                   the degree of fragmentation in the signal.
%
% Description:
%   The fragmentation value is calculated by detecting the number of peaks in the rectified version of the input
%   signal (`example_rov`) that exceed a dynamically computed threshold. This threshold is based on the median 
%   absolute deviation (MAD) of the rectified signal, scaled by the input multiplier (`th`). The function follows
%   these steps:
%
%   1. **Rectification**: The signal is rectified by taking its absolute value.
%   2. **Windowing**: A portion of the rectified signal is selected, based on the input sampling frequency (`fc`), 
%      starting at 15% and ending at 65% of the signal's length. This ensures the analysis focuses on the central portion.
%   3. **Threshold Calculation**: A dynamic threshold is calculated using the MAD of the rectified signal, scaled 
%      by the input `th` parameter.
%   4. **Peak Detection**: The `findpeaks` function is used to detect peaks in the rectified signal that exceed the 
%      calculated threshold, and the number of such peaks is counted.
%
% Author: Andrea Corrado

%% Rectifying the signal (taking absolute value)
rectified_rov = abs(example_rov);

%% Selecting a portion of the signal (15% to 65% of the total length)
rectified_rov = rectified_rov(round(fc * 0.15):round(0.65 * fc));

%% Calculating the threshold based on MAD (Median Absolute Deviation)
T = th * mad(rectified_rov);

%% Detecting peaks above the threshold and counting them
Fragmentation = length(findpeaks(rectified_rov, "MinPeakHeight", T));

end
