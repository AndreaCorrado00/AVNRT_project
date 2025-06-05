function [trace_features,new_main_ambient]=get_features(trace,main_ambient)

%% Adding path to feature extraction functions folder
main_path=main_ambient.Folders(strcmp(main_ambient.Folders(:,1),"\main"),2);
addpath(main_path+"\src\feature_extraction_src");

%% Preparing trace
class=trace(end);
trace=str2double(trace(1:end-1));

%% Preparing ambient
new_main_ambient=main_ambient;

%% Envelope based features 
N=30;
method='rms';

trace_envelope=get_envelope(trace,N,method); % to be defined 
env_features_tab=get_envelope_features(trace_envelope); % to be defined 

% saving envelope options 
new_main_ambient.feature_extraction_opt.envelope.N=N;
new_main_ambient.feature_extraction_opt.envelope.method=method;

%% Template matching features

%% STFT based features

%% Literature based features

%% Saving features
%   |trace points|features|class|

trace_features=[env_features_tab,class];