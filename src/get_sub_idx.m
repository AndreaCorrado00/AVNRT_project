function single_subjects_idx=get_sub_idx(dataset)

%--------------------------------------------------------------------------
% Function: get_sub_idx
%
% Description:
%   Extracts the subject indices from a dataset structure where subject data
%   is stored under field names following a specific pattern (e.g., "MAP_A1", 
%   "MAP_A2", etc.). It assumes that subject identifiers are encoded at the 
%   end of the field names after the character 'A'.
%
% Inputs:
%   - dataset : A struct containing subject-specific data organized under
%               a subfield named 'MAP_A', where field names encode subject IDs.
%
% Outputs:
%   - single_subjects_idx : String array containing the extracted subject indices
%                           as substrings following the 'A' character.
%
% Example:
%   If dataset.MAP_A contains fields: 'MAP_A1', 'MAP_A2', 'MAP_A10',
%   the output will be: ["1", "2", "10"]
%
% Assumptions:
%   - The field names in dataset.MAP_A follow the format: 'MAP_A<SubjectID>'.
%   - SubjectID can be any alphanumeric string following 'A'.
%
% Author: Andrea Corrado

%% Subjects extraction
% As saved into the datased: e.e., MAP_A1...
sub_names=string(fieldnames(dataset.MAP_A));

single_subjects_idx=[];
for i=1:length(sub_names)
    single_subject_parts=split(sub_names(i),"A");
    single_subjects_idx=[single_subjects_idx;single_subject_parts(end)];
end

