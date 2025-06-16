function dataset_overview=get_dataset_properties(dataset)
%GET_DATASET_PROPERTIES Generate an overview table of a structured dataset.
%
%   dataset_overview = GET_DATASET_PROPERTIES(dataset) returns a table
%   summarizing the number of roving traces available for each subject
%   across different maps in the dataset.
%
%   The input 'dataset' is expected to be a struct where each field
%   corresponds to a map (e.g., MAP_A, MAP_B, ...), and each map contains
%   subfields named with subject identifiers (e.g., MAP_A1, MAP_A2, ...),
%   each of which includes a field named 'rov_trace'.
%
%   The output 'dataset_overview' is a table where:
%     - Each row corresponds to a map.
%     - Each column corresponds to a subject.
%     - Each entry represents the number of roving traces (i.e., the
%       second dimension of 'rov_trace') available for the given
%       map-subject pair.
%
%   This function assumes consistent naming conventions across the dataset
%   and extracts subject indices from the field names using a split
%   operation.
%
%   Author: Andrea Corrado


%% MAP names
maps=string(fieldnames(dataset));

%% Subjects extraction
% As saved into the datased: e.e., MAP_A1...
sub_names=string(fieldnames(dataset.(maps(1))));

single_subjects_idx=[];
for i=1:length(sub_names)
    single_subject_parts=split(sub_names(i),"A");
    single_subjects_idx=[single_subjects_idx;single_subject_parts(end)];
end

%% Dataset overview
% Basically, a table with the cardinality of each map-subject pair (roving
% trace)

% Number of traces extraction 
%      |    sub 1    | sub 2 |...|sub N|
% MAP A| # rov traces|
% MAP B|
% MAP C|

dataset_overview=nan(length(maps),length(single_subjects_idx));
for i = 1:length(maps)
    for j=1:length(single_subjects_idx)
        dataset_overview(i,j)=size(dataset.(maps(i)).(maps(i)+single_subjects_idx(j)).rov_trace,2);
    end
end
dataset_overview=array2table(dataset_overview);
dataset_overview.Properties.VariableNames=cellstr(single_subjects_idx);
dataset_overview.Properties.RowNames =cellstr(maps);
end
