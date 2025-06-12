function [original_env_peaks_val_pos,original_rov_peaks_val_pos]=get_envelope_peaks(example_rov,example_env,time_th,fc)
[N,~]=size(time_th);
% Peaks of active areas extraction
original_env_peaks_val_pos = nan(max([3, N]), 2);
original_rov_peaks_val_pos = nan(max([3, N]), 2);

for i = 1:min([N, 3])
    [max_val, max_pos] = max(example_env(time_th(i, 1):time_th(i, 2)), [], "omitnan");
    original_env_peaks_val_pos(i, :) = [max_val, (max_pos + time_th(i, 1)) / fc];

    [max_val, max_pos] = max(abs(example_rov(time_th(i, 1):time_th(i, 2))), [], "omitnan");
    original_rov_peaks_val_pos(i, :) = [max_val, (max_pos + time_th(i, 1)) / fc];
end
