%% AVNRT PROJECT
%
clear;
close;
clc;

%------

main_path = "D:\Desktop\ANDREA\Universita\Progetti esterni\AVNRT_project\AVNRT_project"; % Add your path here
src_path = main_path + "\src"; % Make sure that the src_path exists
addpath(src_path,src_path+"\visualize_features_src")

%% Parameter Settings
clc;
% Expected folder hierarchy:
% main folder
%   ├── src (MUST be present and must contain set_main_parameters.m)
%   ├── Data
%   │   ├── Original
%   │   └── Processed
%   ├── Documentation
%   └── Figure
%
% NOTE: If the structure is not present, the function will create it starting
% from the main path and the SRC path
main_ambient = set_main_parameters(main_path);

%%  --- OPTIONS OF EXTRACTION ---
clc;
% Envelope features
main_ambient.feature_extraction_opt.envelope.N_env_points=30;               % number of points used to evaluate the envelope
main_ambient.feature_extraction_opt.envelope.evalutaion_method='rms';       % method of evaluation
main_ambient.feature_extraction_opt.envelope.SmoothPoints=[50,100];         % number of smooting points for the movmean [smoothing envelope, smoothing derivative]
main_ambient.feature_extraction_opt.envelope.time_window=[0.17,0.6];        % time window of interest [start, end] in [s]
main_ambient.feature_extraction_opt.envelope.mult_factor=[0.002,50*0.002];  % factor to define the derivative thresholding [positive slope, negativ slope]
main_ambient.feature_extraction_opt.envelope.factor_K=2.75;                 % factor to define the significance of a detected peak during time thrsholds cleaning (K*noise_std)

% Template matching features
main_ambient.feature_extraction_opt.TemplateMatching.template_names=["Simple","Complex"];   % Template types
main_ambient.feature_extraction_opt.TemplateMatching.time_window=[0.17,0.6];                % Time window of interest [start, end] in [s]
main_ambient.feature_extraction_opt.TemplateMatching.template_duration=0.05;                % Template duration
main_ambient.feature_extraction_opt.TemplateMatching.template_smoothing_window=5;           % Template smoothing window factor
main_ambient.feature_extraction_opt.TemplateMatching.corr_signal_smoothing_window=50;       % Correlation signal smoothing window factor

% STFT features
main_ambient.feature_extraction_opt.STFT.win_length = 64;                                   % length of the window (points): Hamming window
main_ambient.feature_extraction_opt.STFT.overlap_ratio= 3;                                  % 30% overlap between adjacent windows
main_ambient.feature_extraction_opt.STFT.nfft = 1048;                                       % Number of FFT points for frequency resolution

main_ambient.feature_extraction_opt.STFT.Low_band=[0,75]; %Hz
main_ambient.feature_extraction_opt.STFT.Medium_band=[75,150]; %Hz
main_ambient.feature_extraction_opt.STFT.High_band=[150,350]; % Hz

% Literature inspired features [Baldazzi et al., 2023]
main_ambient.feature_extraction_opt.Literature.Frag_th=0.750;                               % Threshold (%) for fragmentation computation (fixed as it is in the article)


%% ------------ FEATURE EXTRACTION ------------
% Initialization
trace_unique_idx=1;
features_set=table();
% saving?
save_features_set=false;

% Extraction
% for each map
    % for each subject
        % for each single rov trace

for i=1:length(main_ambient.dataset_overview.Properties.RowNames)
    for j=1:length(main_ambient.dataset_overview.Properties.VariableNames)
        for k=1:2% main_ambient.dataset_overview{i,j}
            trace=get_trace(main_ambient,main_ambient.dataset_overview.Properties.RowNames(i),main_ambient.dataset_overview.Properties.VariableNames(j),k);
            new_feature_row=get_features(trace,main_ambient);

            % saving feature vector
            features_set=[features_set;new_feature_row];
            trace_unique_idx=trace_unique_idx+1;
        end
    end
end

% cleaning
clear("i","j","k","features","trace_unique_idx")

% saving
if save_features_set
    save_feature_set_in_json(features_set, main_ambient)
end


%% Features distribution
% Boxplots of features distribution
visualize_feature_distribution(features_set)

%% Single trace features visualization 
% feature position and value for a signal received as input from the user

% declaring trace
map_type="MAP_A";
sub_num=8;
trace_num=1;
% getting trace and its features
trace=get_trace(main_ambient,map_type,sub_num,trace_num);
new_feature_row=get_features(trace,main_ambient);

%visualisation
main_title="Features examples for: subject "+num2str(sub_num)+", trace "+num2str(trace_num)+", "+get_class_name(map_type)+" class";
visualise_trace_features(trace,new_feature_row,main_title,main_ambient)
