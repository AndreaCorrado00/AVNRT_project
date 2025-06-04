function main_ambient=set_main_parameters(main_path)
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
fprintf("\n - Folders have been added to the main path ...\n")

%% Requesting the dataset
dataset_number=input("\n      Decleare which dataset you'll use (1->3): ","s");
main_ambient.dataset="dataset_"+dataset_number;
fprintf(" - Saved the dataset number ...\n")

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
