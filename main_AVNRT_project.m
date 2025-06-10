%% AVNRT PROJECT
% 
clear;
close;
clc;

%------

main_path = "D:\Desktop\ANDREA\Universita\Progetti esterni\AVNRT_project\AVNRT_project"; % Add your path here
src_path = main_path + "\src"; % Make sure that the src_path exists
addpath(src_path)

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

%% Loading trace and feature extraction
clc;

    % --- OPTIONS OF EXTRACTION ---
% Envelope features
main_ambient.feature_extraction_opt.envelope.N_env_points=30;               % number of points used to evaluate the envelope
main_ambient.feature_extraction_opt.envelope.evalutaion_method='rms';       % method of evaluation
main_ambient.feature_extraction_opt.envelope.SmoothPoints=[50,100];         % number of smooting points for the movmean [smoothing envelope, smoothing derivative]
main_ambient.feature_extraction_opt.envelope.time_window=[0.17,0.6];        % time window of interest [start, end] in [ms]
main_ambient.feature_extraction_opt.envelope.mult_factor=[0.002,50*0.002];  % factor to define the derivative thresholding [positive slope, negativ slope]
main_ambient.feature_extraction_opt.envelope.factor_K=2.75;                 % factor to define the significance of a detected peak during time thrsholds cleaning (K*noise_std)

% Template matching features
main_ambient.feature_extraction_opt.TemplateMatching.template_names=["Simple","Complex"];
main_ambient.feature_extraction_opt.TemplateMatching.template_duration=0.05;
main_ambient.feature_extraction_opt.TemplateMatching.smoothing_window=5;

% loop:
    % get trace
    % get features

    % Implementare prima funzioni delle features, poi get features (con
    % parametri di default e personalizzabili sui parametri delle features)
trace=get_trace(main_ambient,"A",1,1);
features=get_features(trace,main_ambient);

%% Feature visualization
% Boxplots of features distribution
% feature position and value for a signal received as input from the user




