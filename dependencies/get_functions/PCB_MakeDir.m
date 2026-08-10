%% PCB_MakeDir
% generates a folder of .mat session data for subjects of interest (group)

function PCB_MakeDir(D, group, sourceFolder, finalFolder)

% group indecies
CI = find(group);

nc = length(CI);
IDs = cell(nc,1);

for iS = 1:nc
    iC = CI(iS);
    IDs{iS} =  D.prolific_pid{iC};
end
% Remove leading spaces from each ID in the cell array
for i = 1:length(IDs)
    IDs{i} = strtrim(IDs{i});
end

if ~isfolder(finalFolder)
    mkdir(finalFolder);
    disp('Folder created successfully.');
else
    disp('Folder already exists.');
end

% Get a list of all .mat files in the source folder
fileList = dir(fullfile(sourceFolder, '*.mat'));


% Loop through each ID in the cell array
for iS = 1:length(IDs)
    currentID = IDs{iS};
    fileFound = false;  % Initialize a flag to check if any file is found
    % Loop through each file in the source folder
    for j = 1:length(fileList)
        fileName = fileList(j).name;
        
        % Check if the file name contains the current ID
        if contains(fileName, currentID)
            % Construct full file paths
            sourceFilePath = fullfile(sourceFolder, fileName);
            finalFilePath = fullfile(finalFolder, fileName);
            
            % Copy the file to the destination folder
            copyfile(sourceFilePath, finalFilePath);

            fileFound = true;
        end
    end
    % If no file was found for the current ID, display a message
    if ~fileFound
        fprintf('No file found containing ID: %s\n', currentID);
    end
end
end
