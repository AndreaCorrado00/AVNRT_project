function [trace_features,features_names]=get_features(trace,main_ambient)

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
[env_features_vector,env_fetures_names]=get_envelope_features(trace,trace_envelope,main_ambient);

%% Template matching features
[template_matching_feature_vector,template_matching_features_names]=get_template_matching_features(trace, main_ambient);

%% STFT based features
[stft_features_vector, features_names]=get_STFT_features(trace,trace_envelope,main_ambient);

%% Literature based features
[literature_feature_vector,literature_feature_names]=get_literature_inspired_features(trace, main_ambient);

%% Saving features
%   |trace points|features|class|

trace_features=[env_features_vector,template_matching_feature_vector,stft_features_vector,literature_feature_vector,class];
features_names=[env_fetures_names,template_matching_features_names,features_names,literature_feature_names,"class"];
% valutate le features andranno valutati i nome di esse. In quella fase
% bisogna gesitire un numero variabile di template, creando dei nomi che si
% adattano al numero degli stessi. 
end
