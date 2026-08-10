%% PCB_Filter_Fish_ID
% Identifies subjects based on performance criteria
% 
% flags anyone with > 5% no response trials.
% CFth = the color following threshold for inclusion: (.95) = flag
% flags anyone with > 95% color following.

% 2025-10-10: ProlificID_66316ac602a513e2e74d5bdc 2Fish has corrupt data
% filter was added to remove this session

function D = PCB_Filter_Fish_ID(sourceFolder, CFth)

cd(sourceFolder)
% Get a list of all .mat files in the source folder
fileList = dir(fullfile(sourceFolder, '*.mat'));
ns = length(fileList);

% prealocate D.No_Response, D.
D.PID = cell(ns,1);
D.No_Response = zeros(ns,1);
D.Color_Following = zeros(ns,1);
D.Corrupt_Data = zeros(ns,1);
D.Under_Performance = zeros(ns,1);

% task structure
n_blocks=10;
n_trials=15;



% Loop through each file in the source folder
for iS = 1:ns
    clear data
    clear fileName

    fileName = fileList(iS).name;
    % PID
    D.PID{iS} = fileName(12:35);
    % load task data
    load(fileName, 'data')

    % preallocate no-response & color-following & correct
    NR = zeros(n_blocks,1);
    CF = zeros(n_blocks,1);
    C = zeros(n_blocks,1);

    % Corrupt data check: number of fish_disp = 0
    CD = zeros(n_blocks,1);

    for iB = 1:n_blocks
        % load block data
        fish_disp=data{iB}(:,5);
        real_choices=data{iB}(:,1);
        correct_choices=data{iB}(:,3);

        % percentage of no-response trials for this block
        NR(iB) = sum(real_choices ==0)/n_trials;
        % percentage of color matching trials for this block
        CF(iB) = sum(fish_disp == real_choices)/n_trials;
        % percentage of correct trials
        if contains(sourceFolder(end-10:end), 'Neg')
            C(iB) = sum(correct_choices == 0)/n_trials;
        else 
            C(iB) = sum(correct_choices == 100)/n_trials;
        end

        % Corrupt data check: number of fish_disp = 0
        CD(iB) = sum(fish_disp == 0);

    end

    % Average no response percentage
    total_NR = sum(NR)/n_blocks;
    % Average color matching percentage
    total_CF = sum(CF)/n_blocks;
    % Average performance
    total_C = sum(C)/n_blocks;

    % corrupt data check: total number of fish_disp = 0
    total_CD = sum(CD);

    if total_NR >= .05
        % Flag No Response
        D.No_Response(iS) = 1;
    end
    if total_CF > CFth
        % Flag Color Following
        D.Color_Following(iS) = 1;
    end
    if total_CD > 0
        % Flag corrupt data
        D.Corrupt_Data(iS) = 1;
    end
    if total_C <= 0.5
        % Flag performance
        D.Under_Performance(iS) = 1;
    end

end
