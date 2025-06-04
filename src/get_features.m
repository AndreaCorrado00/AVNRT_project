function [trace_features,new_main_ambient]=get_features(trace,main_ambient)

%% Adding path to feature extraction functions folder
main_path=main_ambient.Folders(strcmp(main_ambient.Folders(:,1),"\main"),2);
addpath(main_path+"\src\feature_extraction_src");

%% Preparing trace
class=trace(end);
trace=trace(1:end-1);

%% Envelope based features 
trace_envelope=get_envelope(trace); % to be defined 
env_features_tab=get_envelope_features(trace_envelope); % to be defined 


%% Template matching features

%% STFT based features

%% Literature based features

%% Saving features
%   |trace points|features|class|

trace_features=[env_features_tab,class];