%% PCB_Filter_3SlotNeg
% filters subjects based on performance criteria
% generates a folder of .mat session data for subjects meeting crieteria
% Excludes anyone with > 5% no response trials.
% TH = the win-stay-lose-shift threshold for inclusion: (.95) = exclude
% anyone with > 95% wsls.

function PCB_Filter_3SlotNeg(sourceFolder, finalFolder, TH)

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

    % preallocate no-response & wsls %
    NR = zeros(n_blocks,1);
    WSLS = zeros(n_blocks,1);

    for iB = 1:n_blocks
        % load block data
        real_choices=data{iB}(:,1);
        reward_outcomes=data{iB}(:,2);
        wsls = zeros(n_trials,1);

        % percentage of wsls trials for this block
        for iT = 2:n_trials
            % past reward
            reward = reward_outcomes(iT-1);
            % if win
            if reward == 0
                % and stay
                if real_choices(iT) == real_choices(iT-1)
                    wsls(iT) = 1;
                else % if switch
                    wsls(iT) = 0;
                end
                % if loss
            else
                % and stay
                if real_choices(iT) == real_choices(iT-1)
                    wsls(iT) = 0;
                else % if switch
                    wsls(iT) = 1;
                end
            end
        end
        % percentage of no-response trials for this block
        NR(iB) = sum(real_choices == 0)/n_trials;
        % wsls % for this block
        WSLS(iB) = sum(wsls(2:end))/(n_trials-1);
    end

    % Average no response percentage
    total_NR = sum(NR)/n_blocks;
    % Average wsls percentage
    total_WSLS = sum(WSLS)/n_blocks;

    if total_NR < .05 && total_WSLS <= TH
        % Construct full file paths
        sourceFilePath = fullfile(sourceFolder, fileName);
        finalFilePath = fullfile(finalFolder, fileName);

        % Copy the file to the destination folder
        copyfile(sourceFilePath, finalFilePath);
    end
end
