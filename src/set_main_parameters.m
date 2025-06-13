function main_ambient=set_main_parameters(main_path)
%SET_MAIN_PARAMETERS Initializes the working environment and paths.
%
%   main_ambient = SET_MAIN_PARAMETERS(main_path) sets up the folder
%   structure, adds necessary subdirectories to the MATLAB path, and prompts
%   the user to select a dataset and define an output path. The function 
%   returns a struct, main_ambient, containing relevant configuration data.
%
%   Input:
%       main_path (string or char): The root directory of the project where
%           folders such as \Data, \Documentation, and \Figure will be created
%           if they do not already exist.
%
%   Output:
%       main_ambient (struct): A structure containing the following fields:
%           - Folders: a cell array listing logical and physical paths of all added folders.
%           - dataset: a string identifying the dataset selected by the user (e.g., 'dataset_1').
%           - outputPath: full path to the directory where outputs will be saved.
%
%   Behavior:
%       - Ensures the existence of required project subdirectories and adds them to path.
%       - Creates additional subdirectories within \Data ('\Original' and '\Processed').
%       - Prompts the user to specify which dataset will be used.
%       - Allows the user to define a custom output path or use the default.
%
%   Notes:
%       - Folder paths are created only if they do not already exist.
%       - The function uses user input from the command window; avoid use in
%         batch scripts without modification.

% Author: Andrea Corrado
% -------------------------------------------------------------------------

main_ambient=struct();
fprintf("--- Building the work ambient ---")
%% Adding (or creating) paths to folders
folders_names=["\Data","\Documentation","\Figure"];
main_ambient.Folders=[];

for i=1:length(folders_names)
    folder_path = main_path+folders_names(i);
    if ~isfolder(folder_path)
        mkdir(folder_path);
    end
    addpath(folder_path);

    main_ambient.Folders=[main_ambient.Folders;[folders_names(i),folder_path]];

    if folders_names(i)=="\Data"
        data_sub_names=["\Original","\Processed"];
        % Adding (or creating) paths to folders
        for j=1:length(data_sub_names)
            data_sub_path = main_path+"\Data"+data_sub_names(j);
            if ~isfolder(data_sub_path)
                mkdir(data_sub_path);
            end
            addpath(data_sub_path);
            main_ambient.Folders=[main_ambient.Folders;[data_sub_names(j),data_sub_path]];
        end   
    end   
end
main_ambient.Folders=[["\main",main_path];main_ambient.Folders];
fprintf("\n - Folders have been added to the main path ...\n")

%% Requesting the dataset
dataset_number=input("\n      Decleare which dataset you'll use (1->3): ","s");
main_ambient.dataset="dataset_"+dataset_number;
main_ambient.fc=2035; %Hz

fprintf(" - Saved the dataset number ...\n")

% Dataset properties extractoin 
% path building
dataset_path=main_ambient.Folders(strcmp(main_ambient.Folders(:,1),"\Processed"),2);
% dataset extraction
dataStruct=load(dataset_path+"\"+main_ambient.dataset);
dataset=dataStruct.final_data_by_sub;

dataset_overview=get_dataset_properties(dataset);

main_ambient.dataset_overview=dataset_overview;

%% Declaring the output path
use_default=input("\n     Would you like to use the default output path? (Y/N): ","s");
if use_default=="Y"
    main_ambient.outputPath=main_path+"\Data\Processed";
    disp(" - Output will be available into: "+main_path+"\Data\Processed");
elseif use_default=="N"
    out_path=input("     Specify the FULL path for the output: ","s");
    main_ambient.outputPath=out_path;
    disp(" - Output will be available into: "+out_path);
else
    fprintf("       Error: Not a valid option, default will be used.\n")
    main_ambient.outputPath=main_path+"\Data\Processed";
    disp(" - Output will be available into: "+main_path+"\Data\Processed");
end
fprintf("\n - Saved the output path ...\n")
