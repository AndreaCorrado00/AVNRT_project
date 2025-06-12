function STFT_peaks_positions=get_STFT_peaks(trace,time_th,fc,STFT_time)

%% Areas of interest definition: time thresholds on STFT
[N,~]=size(time_th);

% Peaks of active areas evaluation 
original_rov_peaks_val_pos=nan(max([3,N]),4);
for i=1:min([N,3])
    % Find the peak value, peak instant, and active area boundaries: start
    % and stop.
    [max_val,max_pos]=max(abs(trace(time_th(i,1):time_th(i,2))),[],"omitnan");
    original_rov_peaks_val_pos(i,:)=[max_val,(max_pos+time_th(i,1))/fc,time_th(i,1)/fc,time_th(i,2)/fc];
end

% Define the time threshold indices in the STFT based on the previously computed time thresholds
% |peak value|peak position|start time|end time|start idx|end idx|zeros|zeros|
STFT_peaks_positions=[original_rov_peaks_val_pos,zeros(size(original_rov_peaks_val_pos))];
for i = 1:size(time_th, 1)
    [~, idx_start] = min(abs(STFT_time - STFT_peaks_positions(i, 3))); % Start index of the active region 
    [~, idx_end] = min(abs(STFT_time - STFT_peaks_positions(i, 4)));   % End index of the active region
    STFT_peaks_positions(i, 5:6) = [round(idx_start), round(idx_end)];
end

end