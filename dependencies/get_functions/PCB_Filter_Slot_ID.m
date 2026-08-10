%% PCB_Filter_Slot_ID
% Identifies subjects based on performance criteria
% 
% flags anyone with > 5% no response trials.
% CFth = the WSLS threshold for inclusion: (.95) = flag
% flags anyone with > 95% WSLS.

function D = PCB_Filter_Slot_ID(sourceFolder, CFth)

cd(sourceFolder)
% Get a list of all .mat files in the source folder
fileList = dir(fullfile(sourceFolder, '*.mat'));
ns = length(fileList);

% prealocate D.No_Response, D.
D.PID = cell(ns,1);
D.No_Response = zeros(ns,1);
D.WSLS = zeros(ns,1);
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

    % preallocate no-response & wsls & correct %
    NR = zeros(n_blocks,1);
    WSLS = zeros(n_blocks,1);
    C = zeros(n_blocks,1);

    % win value
    if ~contains(sourceFolder(end-10:end), 'Neg')
        winVal = 100;
    else
        winVal = 0;
    end

    % number of data columns
    nCol = size(data{1},2);

    for iB = 1:n_blocks
        % load block data
        real_choices=data{iB}(:,1);
        reward_outcomes=data{iB}(:,2);
        wsls = zeros(n_trials,1);
        correct = zeros(n_trials,1);

        % percentage of no-response trials for this block
        NR(iB) = sum(real_choices ==0)/n_trials;
        % percentage of WSLS trials for this block
        
        for iT = 2:n_trials
            % past reward
            reward = reward_outcomes(iT-1);
            % if win
            if reward == winVal
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
            choiceCol = real_choices(iT)+2;
            % check size
            if choiceCol <= nCol
                if data{iB}(iT,choiceCol) == 1
                    correct(iT) = 1;
                end
            end
        end

        % wsls % for this block
        WSLS(iB) = sum(wsls(2:end))/(n_trials-1);

        % percentage of correct trials
        C(iB) = sum(correct)/(n_trials-1);

    end

    % Average no response percentage
    total_NR = sum(NR)/n_blocks;
    % Average color matching percentage
    total_WSLS = sum(WSLS)/n_blocks;
    % Average performance
    total_C = sum(C)/n_blocks;

    if total_NR >= .05
        % Flag No Response
        D.No_Response(iS) = 1;
    end
    if total_WSLS > CFth
        % Flag Color Following
        D.WSLS(iS) = 1;
    end
    if total_C <= 0.4
        % Flag performance
        D.Under_Performance(iS) = 1;
    end

end
