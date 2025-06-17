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
[env_features_vector,env_fetures_names]=get_envelope_features(trace,trace_envelope,main_ambient);

%% Template matching features
[template_matching_feature_vector,template_matching_features_names]=get_template_matching_features(trace, main_ambient);

%% STFT based features
[stft_features_vector, stft_features_names]=get_STFT_features(trace,trace_envelope,main_ambient);

%% Literature based features
[literature_feature_vector,literature_feature_names]=get_literature_inspired_features(trace, main_ambient);

%% Saving features
%   |trace points|features|class|
env_table = array2table(env_features_vector, 'VariableNames', cellstr(env_fetures_names));
template_table = array2table(template_matching_feature_vector, 'VariableNames', cellstr(template_matching_features_names));
stft_table = array2table(stft_features_vector, 'VariableNames', cellstr(stft_features_names));
literature_table = array2table(literature_feature_vector, 'VariableNames', cellstr(literature_feature_names));
%% OUTPUT
trace_features = [table({trace}, 'VariableNames', {'trace'}), env_table, template_table, stft_table, literature_table, table(class)];

end
