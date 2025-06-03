%% AVNRT PROJECT
% 
%------
main_path="D:\Desktop\ANDREA\Universita\Progetti esterni\AVNRT_project\AVNRT_project"; %add your path
src_path=main_path+"\src"; % be sure that the src_path exists
addpath(src_path)

%% Parameters setting
% Expected the following folders hierarchy:
    % main folder
        %--src (MUST be present with inside set_main_parameters.m)
        %--Data
            %--Original
            %--Processed
        %--Documentation
        %--Figure
% NB: if not garanteed, the function builds the structure starting from the
% main path and the SRC path
main_ambient=set_main_parameters(main_path);

