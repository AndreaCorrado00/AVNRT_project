function new_time_thresholds = clean_time_thresholds(rov_signal, time_th, fc, K)
    % CLEAN_TIME_THRESHOLDS Refines time thresholds by iteratively removing
    % non-significant peaks based on a dynamic threshold approach.
    %
    % This function processes the time thresholds of active areas detected 
    % from a signal and removes any non-significant peaks (areas with 
    % peak values lower than a noise-based threshold). It works iteratively 
    % to ensure that only the most relevant peaks are retained. If all peaks 
    % are found to be non-significant, the threshold multiplier K is halved 
    % and the process is restarted with the original thresholds.
    %
    % Parameters:
    %   rov_signal (array)  - The roving signal (raw signal from which the 
    %                          time thresholds are to be cleaned).
    %   time_th (matrix)    - A matrix containing the time threshold pairs 
    %                          for each detected active area. Each row 
    %                          contains the start and end index for the 
    %                          active area.
    %   fc (double)         - The frequency of the signal (sampling rate).
    %   K (double)          - The scaling factor for the threshold 
    %                          (controls the sensitivity to noise).
    %
    % Output:
    %   new_time_thresholds (matrix) - A matrix of the updated time 
    %                                   thresholds with non-significant 
    %                                   peaks removed.
    %
    % Example:
    %   new_time_thresholds = clean_time_thresholds(rov_signal, time_th, fc, K);
    
    [N, ~] = size(time_th);

    %% Iterative process to assess true peak presence
    stop = false;
    % Initialization 
    start_time = round(fc * 0.10); % Initial time of evaluation of peaks
    end_time = round(fc * 0.7);    % End time
    N_start = N;                    % Initial number of active areas detected
    time_th_start = time_th;        % Initial time thresholds

    while ~stop
        % Create mask to exclude active areas
        mask = true(size(rov_signal)); 
        for i = 1:N_start
            mask(time_th_start(i, 1):time_th_start(i, 2)) = false;
        end

        % Inactive signal
        signal_inactive_phase = rov_signal(start_time:end_time); 
        signal_inactive_phase = signal_inactive_phase(mask(start_time:end_time));

        % Threshold definition based on noise
        std_noise_estimated = std(signal_inactive_phase);
        Threshold = K * std_noise_estimated; 
        % disp(std_noise_estimated)

        % Check for non-significant peaks
        not_significative_peaks_positions = zeros(N_start, 1);
        for i = 1:N_start
            if max(abs(rov_signal(time_th_start(i, 1):time_th_start(i, 2)))) < Threshold
                % Peak is not significant, label it for removal
                not_significative_peaks_positions(i) = 1;
                % fprintf("--> Active area %.d will be removed \n",i)
            end
        end

        % Remove non-significant peaks
        time_th_start(not_significative_peaks_positions == 1, :) = [];
        N_start = size(time_th_start, 1); % Update the number of active peaks

        % Check if all peaks are removed
        if N_start == 0
            % Show warning and reduce K
            warning('All peaks have been removed! Reducing K from %.2f to %.2f.', K, K / 2);
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

    [N_end, ~] = size(time_th_start);
    % disp("  Have been removed "+num2str(N-N_end)+" peaks out of "+num2str(N))

    % Final output
    new_time_thresholds = time_th_start;
end
