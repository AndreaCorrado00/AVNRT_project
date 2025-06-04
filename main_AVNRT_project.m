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

% loop:
    % get trace
    % get features

    % Implementare prima funzioni delle features, poi get features (con
    % parametri di default e personalizzabili sui parametri delle features)
trace=get_trace(main_ambient,"A",1,1);


%% Feature visualization
% Boxplots of features distribution
% feature position and value for a signal received as input from the user




