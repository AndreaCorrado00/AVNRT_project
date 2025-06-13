function dataset_overview=get_dataset_properties(dataset)

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
