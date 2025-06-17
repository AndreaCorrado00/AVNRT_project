function save_feature_set_in_json(features_table, main_ambient)
% Conversion into a struct
features_struct = table2struct(features_table, 'ToScalar', false);

% Json filebuilding and saving
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