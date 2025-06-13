function STFT_peaks_positions=get_STFT_peaks(trace,time_th,fc,STFT_time)
%GET_STFT_PEAKS Identify peak values and their positions within time-defined segments of a signal,
%              and associate them with time-frequency analysis windows.
%
%   STFT_peaks_positions = GET_STFT_PEAKS(trace, time_th, fc, STFT_time)
%
%   This function identifies the peak amplitude within user-defined time segments of
%   a 1D signal and returns both temporal and spectral (STFT-based) information related
%   to those peaks. It is typically used to associate peak activity in the time domain
%   with corresponding indices in the time-frequency domain (e.g., for EMG or audio signals).
%
%   INPUTS:
%       trace      : Vector
%           Input signal (e.g., rectified EMG or audio waveform) from which peaks will be extracted.
%
%       time_th    : Nx2 matrix
%           Matrix of time intervals (in sample indices) defining the regions of interest
%           for peak detection. Each row is a [start_idx, end_idx] pair. Up to 3 intervals
%           are processed; excess rows are ignored.
%
%       fc         : Scalar
%           Sampling frequency of the input signal, in Hz. Used to convert indices to seconds.
%
%       STFT_time  : Vector
%           Time vector corresponding to the STFT representation of the signal. Used to
%           map the time-domain peaks to STFT window indices.
%
%   OUTPUT:
%       STFT_peaks_positions : max(N,3)x8 matrix
%           Each row contains:
%               [1]  Peak value (absolute amplitude)
%               [2]  Peak time (in seconds)
%               [3]  Start of the time window (in seconds)
%               [4]  End of the time window (in seconds)
%               [5]  Index of the STFT frame closest to start time
%               [6]  Index of the STFT frame closest to end time
%               [7-8] Reserved (currently set to zero)
%
%   Notes:
%       - Only the first three time windows are processed; the result matrix always has
%         three rows (padded with NaNs if N < 3).
%       - NaNs in the signal do not interfere with peak detection (they are omitted).
%       - STFT time mapping is performed using nearest-neighbor matching to the provided STFT_time vector.
%
%   Example usage:
%       peaks = get_STFT_peaks(my_trace, [1000 1500; 2000 2500], 1000, STFT_time_vector);
%
% Author: Andrea Corrado

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