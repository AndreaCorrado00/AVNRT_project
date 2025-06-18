function time_th = define_time_th(map_upper, map_lower)
    % define_time_th - Determines the active region in the signal based on the 
    %                  upper and lower threshold maps.
    %
    % Syntax:
    %   time_th = define_time_th(map_upper, map_lower)
    %
    % Input Arguments:
    %   map_upper - Binary vector representing the upper threshold map (1s indicate
    %               active regions above the upper threshold).
    %   map_lower - Binary vector representing the lower threshold map (1s indicate
    %               active regions below the lower threshold).
    %
    % Output:
    %   time_th   - A matrix where each row represents an active region with two 
    %               columns: the start time and the end time of the region.
    %
    % Description:
    %   This function identifies active regions in a signal based on two binary 
    %   vectors, `map_upper` and `map_lower`, which indicate regions above the 
    %   upper threshold and below the lower threshold, respectively. It pairs 
    %   consecutive "upper" and "lower" threshold regions (where the "lower" run 
    %   starts after the "upper" run ends) and appends the corresponding start 
    %   and end times to the output matrix `time_th`.
    %
    % Steps:
    %   1. Identify the consecutive runs of 1s in `map_upper` and `map_lower`.
    %   2. Pair the corresponding upper and lower runs, ensuring that the lower 
    %      run starts after the upper run.
    %   3. Store the start and end times of valid pairs in `time_th`.

    % Initialize output matrix to store time intervals
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
end

% Helper function to find consecutive runs of 1s in a binary vector
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
