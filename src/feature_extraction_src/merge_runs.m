function [map_upper, map_lower] = merge_runs(map_upper, map_lower)
% merge_runs
%
% This function processes and merges two logical vectors, `map_upper` and `map_lower`, that represent 
% regions of interest in a signal. The function attempts to merge consecutive runs of 1s in both vectors 
% based on specific conditions, such as ensuring there are no gaps between regions of `map_upper` and `map_lower`.
% It also adds positive or negative runs when necessary to smooth transitions between regions and guarantee
% that the combined map starts and ends with the appropriate region.
%
% Parameters:
%   - map_upper (logical vector): A logical vector representing regions of interest in the upper map (e.g., a positive threshold).
%   - map_lower (logical vector): A logical vector representing regions of interest in the lower map (e.g., a negative threshold).
%
% Returns:
%   - map_upper (logical vector): The modified logical vector representing the upper map after merging runs.
%   - map_lower (logical vector): The modified logical vector representing the lower map after merging runs.
%
% Functionality:
%   1. **Initial Setup:**
%      - Defines signal start and end points based on a sample size (2035).
%      - Ensures that `map_upper` and `map_lower` have the same length, otherwise it throws an error.
%
%   2. **Merge Runs in `map_upper`:**
%      - Identifies regions of consecutive 1s in `map_upper` and `map_lower` using the `regionprops` function.
%      - Merges consecutive runs of `map_upper` and `map_lower` if they are not separated by a gap and if the overlap is not present in `map_lower`.
%      - If there is no overlap in `map_lower`, it inserts a transitional region in `map_lower`.
%
%   3. **Merge Runs in `map_lower`:**
%      - Similar to the previous step, but this time it checks consecutive runs in `map_lower` and merges them with `map_upper` if necessary.
%      - A transitional region is inserted in `map_upper` if a gap is detected between consecutive runs of `map_lower` without overlapping `map_upper`.
%
%   4. **Adjust Boundaries:**
%      - Adds a positive run at the start of `map_upper` before the first negative run of `map_lower` if necessary.
%      - Adds a negative run at the end of `map_lower` after the last positive run of `map_upper` if necessary.
%
%   5. **Ensure Combined Map Starts and Ends Correctly:**
%      - Ensures the combined map starts with a run in `map_upper` and ends with a run in `map_lower` by adjusting the logical vectors accordingly.
%      - If `map_lower` starts before `map_upper`, it adjusts the beginning of `map_lower`.
%      - If `map_upper` ends after `map_lower`, it adjusts the end of `map_upper`.
%
% Example Usage:
%   [map_upper, map_lower] = merge_runs(map_upper, map_lower);
%
% The function is useful for smoothing and combining regions in the `map_upper` and `map_lower` logical vectors 
% based on specific conditions, and ensuring that transitions between regions are correctly handled.


signal_start = round(0.17 * 2035); % Signal start point
signal_end = round(0.6 * 2035);    % Signal end point
% Ensure map_upper and map_lower have the same length
if length(map_upper) ~= length(map_lower)
    error('map_upper and map_lower must have the same length.');
end


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
        % Remove the second run from the list
        % upper_regions(i+1) = [];
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
        % Remove the second run from the list
        % lower_regions(i+1) = [];
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
end