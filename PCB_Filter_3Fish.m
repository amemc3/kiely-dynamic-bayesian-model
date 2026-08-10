%% PCB_Filter_3Fish
% filters subjects based on performance criteria
% generates a folder of .mat session data for subjects meeting crieteria
% Excludes anyone with > 5% no response trials.
% CFth = the color following threshold for inclusion: (.95) = exclude
% anyone with > 95% color following.

% 2025-10-10: ProlificID_66316ac602a513e2e74d5bdc 2Fish has corrupt data
% filter was added to remove this session

function PCB_Filter_3Fish(sourceFolder, finalFolder, CFth)

cd(sourceFolder)
% Get a list of all .mat files in the source folder
fileList = dir(fullfile(sourceFolder, '*.mat'));
ns = length(fileList);

% Make final Folder
if ~isfolder(finalFolder)
    mkdir(finalFolder);
    disp('Folder created successfully.');
else
    disp('Folder already exists.');
    return; % Exits the function immediately
end

% task structure
n_blocks=10;
n_trials=15;

% Loop through each file in the source folder
for iS = 1:ns
    clear data
    clear fileName

    fileName = fileList(iS).name;
    % load task data
    load(fileName, 'data')

    % preallocate no-response & color-following % 
    NR = zeros(n_blocks,1);
    CF = zeros(n_blocks,1);

    % Corrupt data check: number of fish_disp = 0
    CD = zeros(n_blocks,1);

    for iB = 1:n_blocks
        % load block data
        fish_disp=data{iB}(:,5);
        real_choices=data{iB}(:,1);

        % percentage of no-response trials for this block
        NR(iB) = sum(real_choices ==0)/n_trials;
        % percentage of color matching trials for this block
        CF(iB) = sum(fish_disp == real_choices)/n_trials;

        % Corrupt data check: number of fish_disp = 0
        CD(iB) = sum(fish_disp == 0);

    end

    % Average no response percentage
    total_NR = sum(NR)/n_blocks;
    % Average color matching percentage
    total_CF = sum(CF)/n_blocks;

    % corrupt data check: total number of fish_disp = 0
    total_CD = sum(CD);

    if total_NR < .05 && total_CF <= CFth && total_CD <= 0
        % Construct full file paths
        sourceFilePath = fullfile(sourceFolder, fileName);
        finalFilePath = fullfile(finalFolder, fileName);

        % Copy the file to the destination folder
        copyfile(sourceFilePath, finalFilePath);
    end
end
