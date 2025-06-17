function save_feature_set_in_json(features_table, main_ambient)
% save_feature_set_in_json Saves a table of features to a JSON file.
%
% This function converts the input features table into a struct format suitable
% for JSON encoding, then serializes and writes it to a JSON file named
% 'features_set.json' in the specified output directory.
%
% Inputs:
%   features_table - A table containing extracted features to be saved.
%   main_ambient   - Configuration structure containing the output path for saving the file.
%
% The function throws an error if the file cannot be opened for writing.
% Upon successful save, it displays the full path of the saved JSON file.
%
% Author: Andrea Corrado
%% Conversion into a struct
features_struct = table2struct(features_table, 'ToScalar', false);

%% Json filebuilding and saving
json_features_struct = jsonencode(features_struct);
saving_path=main_ambient.outputPath;
filename = fullfile(saving_path, 'features_set.json');

fid = fopen(filename, 'w');
if fid == -1
    error('Unale to open the struct');
end
fprintf(fid, '%s', json_features_struct);
fclose(fid);

disp(['File saved into: ', filename]);