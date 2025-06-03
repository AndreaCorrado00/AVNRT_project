%% AVNRT PROJECT
% 
%------
main_path = "D:\Desktop\ANDREA\Universita\Progetti esterni\AVNRT_project\AVNRT_project"; % Add your path here
src_path = main_path + "\src"; % Make sure that the src_path exists
addpath(src_path)

%% Parameter Settings
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


