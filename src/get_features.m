function trace_features=get_features(trace,main_ambient)

%% Adding path to feature extraction functions folder
main_path=main_ambient.Folders(strcmp(main_ambient.Folders(:,1),"\main"),2);
addpath(main_path+"\src\feature_extraction_src");

%% Preparing trace
class=trace(end);
trace=str2double(trace(1:end-1));

%% Envelope based features 

% Defining options of extraction
N=main_ambient.feature_extraction_opt.envelope.N_env_points;
method=main_ambient.feature_extraction_opt.envelope.evalutaion_method;

[trace_envelope, ~] = envelope(trace, N,method);
env_features_vector=get_envelope_features(trace,trace_envelope,main_ambient);

%% Template matching features

%% STFT based features

%% Literature based features

%% Saving features
%   |trace points|features|class|

% trace_features=[env_features_vector,class];
end
