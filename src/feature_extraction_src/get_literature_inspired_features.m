function [feature_vector,feature_names]=get_literature_inspired_features(trace, main_ambient)
%--------------------------------------------------------------------------
% Function: get_literature_inspired_features
%
% Description:
%   Extracts a set of features inspired by existing literature on
%   physiological or biomechanical signal analysis. The function computes
%   the Apparent Power (App) and a Fragmentation metric, which are commonly
%   used to describe signal regularity and complexity.
%
% Inputs:
%   - trace         : 1-D array containing the raw time-domain signal.
%   - main_ambient  : Struct containing necessary metadata and options:
%                     * main_ambient.fc                         : Sampling frequency (Hz)
%                     * main_ambient.feature_extraction_opt     : Struct with:
%                          - Literature.Frag_th                : Threshold value for
%                                                                 Fragmentation computation
%
% Outputs:
%   - feature_vector : Row vector containing the extracted features.
%   - feature_names  : Cell array with names corresponding to each feature
%                      in the same order as `feature_vector`.
%
% Features Extracted:
%   1. App (Apparent Power)       - Captures signal energy over time.
%   2. Fragmentation              - Quantifies the degree of discontinuity or
%                                   instability in the signal.
%
% Notes:
%   - Ensure the signal `trace` is properly filtered or preprocessed if needed.
%   - Thresholds should be validated for the specific application domain.
%
% Author: Andrea Corrado 

%% Preparation
fc=main_ambient.fc;
th_frag=main_ambient.feature_extraction_opt.Literature.Frag_th;

feature_vector=[];
feature_names=[];
%% Feature 1: App
App=get_App(trace,main_ambient);
feature_vector=[feature_vector,App];
feature_names=[feature_names,"App"];

%% Feature 2: Fragmentation
Fragmentation = get_Fragmentation(trace, th_frag, fc);
feature_vector=[feature_vector,Fragmentation];
feature_names=[feature_names,"Fragmentation"];

%% Final output
feature_vector=string(feature_vector);
