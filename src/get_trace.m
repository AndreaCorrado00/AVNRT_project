function trace = get_trace(main_ambient, map_type, sub, trace_number)
%GET_TRACE Extracts a specific ROV trace from the structured dataset.
%
%   trace = GET_TRACE(main_ambient, map_type, sub, trace_number) returns a 
%   time series trace associated with a given subject and map type from the 
%   loaded dataset, along with its qualitative class label.
%
%   Inputs:
%       main_ambient (struct): Structure containing environment configuration, 
%           including paths and dataset name.
%
%       map_type (char or string): Suffix character indicating the map type 
%           ('A', 'B', or 'C'). The full identifier will be constructed as 
%           'MAP_A', 'MAP_B', or 'MAP_C'.
%
%       sub (integer): Subject number used to build the dynamic field name
%           (e.g., 1).
%
%       trace_number (integer): Index of the ROV trace to be extracted from the subject data.
%
%   Output:
%       trace (cell): A cell array containing:
%           - First row: trace data (e.g., time points or sensor values).
%           - Second row: the class label ('Indifferent', 'Effective', 'Dangerous').
%
%   Behavior:
%       - Loads the dataset from the "\Processed" folder defined in main_ambient.
%       - Accesses the trace from dataset.(map_type).(subject_name).rov_trace.
%       - Appends the corresponding class.
%
% Author: Andrea Corrado
% -------------------------------------------------------------------------


%% dataset path extraction and dataset loading
% path building
dataset_path=main_ambient.Folders(strcmp(main_ambient.Folders(:,1),"\Processed"),2);
% dataset extraction
dataStruct=load(dataset_path+"\"+main_ambient.dataset);
dataset=dataStruct.final_data_by_sub;

%% trace extraction
% |trace time points|class|
% map_type="MAP_"+map_type;
sub=string(map_type)+string(sub);
class=get_class_name(map_type);

%% output trace
trace=[dataset.(string(map_type)).(sub).rov_trace{:,trace_number};class];


