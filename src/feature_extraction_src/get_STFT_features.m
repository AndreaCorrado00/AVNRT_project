function [stft_features_vector, features_names]=get_STFT_features(trace,trace_envelope,main_ambient)

%% Extraction of STFT feature extraction options
fc=main_ambient.fc;
% STFT computation parameters
win_length = main_ambient.feature_extraction_opt.STFT.win_length;
overlap = round(win_length/main_ambient.feature_extraction_opt.STFT.overlap_ratio);
window = hamming(win_length, 'periodic');
nfft = main_ambient.feature_extraction_opt.STFT.nfft;

% Frequency sub-bands
Low_band=main_ambient.feature_extraction_opt.STFT.Low_band;
Medium_band=main_ambient.feature_extraction_opt.STFT.Medium_band; %Hz
High_band=main_ambient.feature_extraction_opt.STFT.High_band; % Hz

%% Features names vector initialization
stft_features_vector=[];
features_names=[];

%% Spectrogram evaluation
[S, F, T, STFT] = spectrogram(trace, window, overlap, nfft, fc);

% Frequency vector subdivision
idx_Low_band = F >= Low_band(1) & F <= Low_band(2);
idx_Medium_band = F > Medium_band(1) & F <= Medium_band(2);
idx_High_band = F > High_band(1) & F <= High_band(2);

idx_sub_bands=[idx_Low_band,idx_Medium_band,idx_High_band];

%% STFT peaks evaluation
% Based on envelope analysis
time_th = get_time_thresholds(trace,trace_envelope,main_ambient);

STFT_peaks_positions=get_STFT_peaks(trace,time_th,fc,T);

%% FIRST BLOCK: peaks are evaluate in order of magnitude
STFT_peaks_positions=sortrows(STFT_peaks_positions,1,"descend","MissingPlacement","last");

% Feature 1.1: mean of regions
avg_power_into_subbands=get_STFT_subbands_values("mean",STFT,idx_sub_bands,STFT_peaks_positions);
% saving
stft_features_vector=avg_power_into_subbands(:);
features_names=["Dominant_AvgPowLF", "Dominant_AvgPowMF", "Dominant_AvgPowHF", ...
    "Subdominant_AvgPowLF", "Subdominant_AvgPowMF", "Subdominant_AvgPowHF", "Minor_AvgPowLF", ...
    "Minor_AvgPowMF", "Minor_AvgPowHF"];

%% SECOND BLOCK: peaks are evaluate in order of occurrence
STFT_peaks_positions=sortrows(STFT_peaks_positions,2,"ascend","MissingPlacement","last");

% Feature 2.1: mean of regions
avg_power_into_subbands=get_STFT_subbands_values("mean",STFT,idx_sub_bands,STFT_peaks_positions);
% saving
stft_features_vector= [stft_features_vector;avg_power_into_subbands(:)];
features_names=[features_names,"First_AvgPowLF", "First_AvgPowMF", "First_AvgPowHF", ...
    "Second_AvgPowLF", "Second_AvgPowMF", "Second_AvgPowHF", "Third_AvgPowLF", ...
    "Third_AvgPowMF", "Third_AvgPowHF"];

% Feature 2.2: max of regions
max_power_into_subbands=get_STFT_subbands_values("max",STFT,idx_sub_bands,STFT_peaks_positions);
% saving
stft_features_vector= [stft_features_vector;max_power_into_subbands(:)];
features_names=[features_names,"First_Active_Area_max_Power_HF","First_Active_Area_max_Power_MF","First_Active_Area_max_Power_LF", ...
    "Second_Active_Area_max_Power_HF","Second_Active_Area_max_Power_MF","Second_Active_Area_max_Power_LF", ...
    "Third_Active_Area_max_Power_HF","Third_Active_Area_max_Power_MF","Third_Active_Area_max_Power_LF"];

% Feature 2.3: min of regions
min_power_into_subbands=get_STFT_subbands_values("min",STFT,idx_sub_bands,STFT_peaks_positions);
% saving
stft_features_vector= [stft_features_vector;min_power_into_subbands(:)];
features_names=[features_names,"First_Active_Area_min_Power_HF","First_Active_Area_min_Power_MF","First_Active_Area_min_Power_LF", ...
    "Second_Active_Area_min_Power_HF","Second_Active_Area_min_Power_MF","Second_Active_Area_min_Power_LF", ...
    "Third_Active_Area_min_Power_HF","Third_Active_Area_min_Power_MF","Third_Active_Area_min_Power_LF"];

% Feature 2.4: std of regions
std_power_into_subbands=get_STFT_subbands_values("std",STFT,idx_sub_bands,STFT_peaks_positions);
% saving
stft_features_vector= [stft_features_vector;std_power_into_subbands(:)];
features_names=[features_names,"First_Active_Area_Power_std_HF","First_Active_Area_Power_std_MF","First_Active_Area_Power_std_LF", ...
    "Second_Active_Area_Power_std_HF","Second_Active_Area_Power_std_MF","Second_Active_Area_Power_std_LF", ...
    "Third_Active_Area_Power_std_HF","Third_Active_Area_Power_std_MF","Third_Active_Area_Power_std_LF"];

%% Final output
stft_features_vector=stft_features_vector';

end