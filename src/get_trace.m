function trace=get_trace(main_ambient,map_type,sub,trace_number)

%% dataset path extraction and dataset loading
%path building
dataset_path=main_ambient.Folders(strcmp(main_ambient.Folders(:,1),"\Processed"),2);
% dataset extraction
dataStruct=load(dataset_path+"\"+main_ambient.dataset);
dataset=dataStruct.final_data_by_sub;

%% trace extraction
% |trace time points|class|
map_type="MAP_"+map_type;
sub=map_type+num2str(sub);
class=get_class_name(map_type);

trace=[dataset.(map_type).(sub).rov_trace{:,trace_number};class];


