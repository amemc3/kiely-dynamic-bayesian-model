%% PCB_Get_ProlificSummary
% This function generates a summary table of all the prolific participants, 
% their ID numbers, screening, survey, and task data.

% It can also be used to generate a sub-selection of participants based on
% diagnostic crieteria.

function [SurveyD, Summary, ExtraSlot2, ExtraSlot3, ExtraFish2, ExtraFish3, AllScreening] = PCB_Get_ProlificSummary

%% designate file paths for screening, survey, slot, and fish data
rawPath = 'C:\Users\amcla\Documents\Neuroscience\Fiore\Projects\PLOS_CB\Raw_Data';
ScreeningPath = fullfile(rawPath, '2025-10-10_Screening.csv');
SurveyPath = fullfile(rawPath, '2025-10-10_MainQuest.csv');
SlotPath3 = fullfile(rawPath, '2025-10-10_3Slot');
FishPath3 = fullfile(rawPath, '2025-10-10_3Fish');
SlotPath2 = fullfile(rawPath, '2025-10-10_2Slot');
FishPath2 = fullfile(rawPath, '2025-10-10_2Fish');
% 2025-09-25 added negative tasks
NegSlotPath3 = fullfile(rawPath, '2025-10-10_3SlotNeg');
NegFishPath3 = fullfile(rawPath, '2025-10-10_3FishNeg');

%% PCB_GetD is a function that generates SurveyD
% SurveyD = table of all survey outcomes and scores from main questionaire 
% It filters for attention checks, standardizes all prolific IDs, 
% and scores each of the surveys.
SurveyD = PCB_GetD(SurveyPath);

%% find and remove duplicate SurveyD.prolific_pid
SurveyD.isDup = nan(length(SurveyD.prolific_pid),1);
for iS = 1:length(SurveyD.prolific_pid)
    P = SurveyD.prolific_pid{iS};
    ind = find(strcmp(SurveyD.prolific_pid, P));
    if length(ind) > 1
        SurveyD.isDup(iS) = true;
    else
        SurveyD.isDup(iS) = false;
    end
end

% find the D indexes and PIDs for duplicates
dupIND = find(SurveyD.isDup == 1);
dupIDs = cell(length(dupIND),1);
for iD = 1:length(dupIND)
    dupIDs{iD} = SurveyD.prolific_pid{dupIND(iD)};
end

% remove the duplicate entry data (keep the first one)
Udups = unique(dupIDs);
SurveyD.keep = ones(length(SurveyD.prolific_pid),1);
for iD = 1:length(Udups)
    P = Udups{iD};
    ind = find(strcmp(SurveyD.prolific_pid, P));
    TS = SurveyD.prolific_id_timestamp(ind,:);
    toss = ind(TS == max(TS));
    SurveyD.keep(toss) = 0;
end

% Change faulty PID & remove problematic participant
for iS = 1:length(SurveyD.prolific_pid)
    P = SurveyD.prolific_pid{iS};
    % faulty PID
    if strcmp(P, 'ACVEFRSUAPSEQ')
        SurveyD.prolific_pid{iS} = '576017836442fa0006cfb7cd';
    end
    % problem participant
    if strcmp(P, '667e6da95ae0a25f225ae6e6')
        SurveyD.keep(iS) = 0;
    end
end

SurveyD = SurveyD(SurveyD.keep == 1, :);

%% Generate ScreeningD - a processed table of screening data for all
% prolific patient IDs contained in SurveyD.

ScreeningD = readtable(ScreeningPath);

% standardize prolificIDs
% remove spaces before ID
for i = 1:length(ScreeningD.prolific_pid)
    ScreeningD.prolific_pid{i} = strtrim(ScreeningD.prolific_pid{i});
end
% Remove extra symbols; mark short pids
goodFormat = ones(length(ScreeningD.record_id),1);
for i = 1:length(ScreeningD.prolific_pid)
    if size(ScreeningD.prolific_pid{i},2)>24
        ScreeningD.prolific_pid{i} = ScreeningD.prolific_pid{i}(1:24);
    end
    if size(ScreeningD.prolific_pid{i},2)<24
        goodFormat(i) = 0;
    end
end
% Filter ScreeningD to remove those with too short PID
ScreeningD = ScreeningD(goodFormat==1,:);

% Filter ScreeningD to those with PIDs from SurveyD
PIDmatch = nan(length(ScreeningD.record_id),1);

for iS = 1:length(ScreeningD.record_id)
    PID = ScreeningD.prolific_pid{iS};
    match = find(strcmp(SurveyD.prolific_pid, PID));
    if ~isempty(match)
        PIDmatch(iS) = 1;
    else
        PIDmatch(iS) = 0;
    end
end
AllScreening = ScreeningD;
ScreeningD = ScreeningD(PIDmatch==1,:);

%% find and remove duplicate ScreeningD.prolific_pid
ScreeningD.isDup = nan(length(ScreeningD.prolific_pid),1);
for iS = 1:length(ScreeningD.prolific_pid)
    P = ScreeningD.prolific_pid{iS};
    ind = find(strcmp(ScreeningD.prolific_pid, P));
    if length(ind) > 1
        ScreeningD.isDup(iS) = true;
    else
        ScreeningD.isDup(iS) = false;
    end
end
% find the D indexes and PIDs for duplicates
SdupIND = find(ScreeningD.isDup == 1);
SdupIDs = cell(length(SdupIND),1);
for iD = 1:length(SdupIND)
    SdupIDs{iD} = ScreeningD.prolific_pid{SdupIND(iD)};
end

%% remove the duplicate entry data (keep the first one)

SUdups = unique(SdupIDs);
ScreeningD.keep = ones(length(ScreeningD.prolific_pid),1);
for iD = 1:length(SUdups)
    P = SUdups{iD};
    ind = find(strcmp(ScreeningD.prolific_pid, P));
    TS = ScreeningD.demographics_timestamp(ind,:);
    % check if one screening is missing demographics data
    if sum(isnat(TS)) > 0 % if one is missing
        for iI = 1:length(ind)
            % toss the missing ones
            if isnat(TS(iI))
                ScreeningD.keep(ind(iI)) = 0;
            end
        end
    else % if not, toss the last one
        toss = ind(TS == max(TS));
        ScreeningD.keep(toss) = 0;
    end
end

ScreeningD = ScreeningD(ScreeningD.keep == 1, :);

%% Add main screening data to SurveyD for each subject 
ns = length(SurveyD.prolific_pid);
SurveyD.screen_date = NaT(ns,1); % screening Date
SurveyD.age = nan(ns,1); % age
SurveyD.sex = nan(ns,1); % sex
SurveyD.gender = nan(ns,1); % gender
SurveyD.education = nan(ns,1); % education
SurveyD.race = nan(ns,1); % race
SurveyD.state = nan(ns,1); % state
SurveyD.household_income = nan(ns,1); % household income
SurveyD.height_m = nan(ns,1); % height
SurveyD.weight = nan(ns,1); % weight
SurveyD.bmi = nan(ns,1); % bmi
SurveyD.isDup_screen = zeros(ns,1); % screening duplicate

for iS = 1:ns
    PID = SurveyD.prolific_pid{iS};
    sd = ScreeningD(strcmp(ScreeningD.prolific_pid, PID),:);
    if ~isempty(sd)
        SurveyD.screen_date(iS) = sd.demographics_timestamp; % screening Date
        SurveyD.age(iS) = sd.age; % age
        SurveyD.sex(iS) = sd.sex_assigned_at_birth; % sex
        SurveyD.gender(iS) = sd.gender; % gender
        SurveyD.education(iS) = sd.education; % education
        SurveyD.race(iS) = sd.race; % race
        SurveyD.state(iS) = sd.state; % state
        SurveyD.household_income(iS) = sd.household_income; % household income
        SurveyD.height_m(iS) = sd.height_m; % height
        SurveyD.weight(iS) = sd.weight_kg; % weight
        SurveyD.bmi(iS) = sd.bmi; % bmi
        SurveyD.isDup_screen(iS) = sd.isDup; % screening duplicate
    end
end

%% reformat datetimes
SurveyD.screen_date.Format = 'yyyy-MM-dd';
SurveyD.prolific_id_timestamp.Format = 'yyyy-MM-dd';

% %% Did they do the BDDQ? - not included for this study
% SurveyD.isBDDQ = ~isnan(SurveyD.bdd);

%% Do they have 3 Slot task Data?

cd(SlotPath3)

% Get a list of all .mat files in the source folder
fileList = dir(fullfile(SlotPath3, '*.mat'));

IDs = SurveyD.prolific_pid;
SurveyD.isSlot3 = nan(ns,1);
SurveyD.slotCond = cell(ns,1);

% Loop through each ID in the cell array
for iS = 1:ns
    currentID = IDs{iS};
    fileFound = false;  % Initialize a flag to check if any file is found
    % Loop through each file in the source folder
    for j = 1:length(fileList)
        fileName = fileList(j).name;      
        % Check if the file name contains the current ID
        if contains(fileName, currentID)
            fileFound = true;
            % get slot condition
            DATA = load(fileName);
            SurveyD.slotCond{iS} = DATA.cond;
        end
    end
    % If no file was found for the current ID, display a message
    if ~fileFound
        SurveyD.isSlot3(iS) = 0;
    else
        SurveyD.isSlot3(iS) = 1;
    end
end

%% Check if there is any 3 slot task data that doesnt have matching PID
% Loop through each file in data folder
ExtraSlot3 = cell(length(fileList),1);
for iS = 1:length(fileList)
    fileName = fileList(iS).name;
    fileFound = false;  % Initialize a flag to check if any file is found
    % Loop through each PID
    for j = 1:ns
        currentID = IDs{j};
        % Check if the file name contains the current ID
        if contains(fileName, currentID)
            fileFound = true;
        end
    end
    % If no PID was found for the current file, add to list
    if ~fileFound
        ExtraSlot3{iS} = fileName;
    end
end

ES = nan(length(ExtraSlot3),1);
for iE = 1:length(ExtraSlot3)
    ES(iE) = isempty(ExtraSlot3{iE});
end
ExtraSlot3 = ExtraSlot3(~ES);

%% Do they have the slot task bug?
SurveyD.isSlot3Bug = zeros(ns,1);
targetSequence = [3, 5, 9, 1, 2, 4, 10, 7, 8, 6];
for i = 1:ns
    % Check if the content of the current cell matches the target sequence
    if SurveyD.isSlot3(i) == 1
        if isequal(SurveyD.slotCond{i}, targetSequence)
            % If it matches, the bug is present
            SurveyD.isSlot3Bug(i) = 1;
        end
    end
end

%% Do they have 2 Slot task Data?

cd(SlotPath2)

% Get a list of all .mat files in the source folder
fileList = dir(fullfile(SlotPath2, '*.mat'));

IDs = SurveyD.prolific_pid;
SurveyD.isSlot2 = nan(ns,1);

% Loop through each ID in the cell array
for iS = 1:ns
    currentID = IDs{iS};
    fileFound = false;  % Initialize a flag to check if any file is found
    % Loop through each file in the source folder
    for j = 1:length(fileList)
        fileName = fileList(j).name;      
        % Check if the file name contains the current ID
        if contains(fileName, currentID)
            fileFound = true;
        end
    end
    % If no file was found for the current ID, display a message
    if ~fileFound
        SurveyD.isSlot2(iS) = 0;
    else
        SurveyD.isSlot2(iS) = 1;
    end
end

%% Check if there is any 2 slot task data that doesnt have matching PID
% Loop through each file in data folder
ExtraSlot2 = cell(length(fileList),1);
for iS = 1:length(fileList)
    fileName = fileList(iS).name;
    fileFound = false;  % Initialize a flag to check if any file is found
    % Loop through each PID
    for j = 1:ns
        currentID = IDs{j};
        % Check if the file name contains the current ID
        if contains(fileName, currentID)
            fileFound = true;
        end
    end
    % If no PID was found for the current file, add to list
    if ~fileFound
        ExtraSlot2{iS} = fileName;
    end
end

ES = nan(length(ExtraSlot2),1);
for iE = 1:length(ExtraSlot2)
    ES(iE) = isempty(ExtraSlot2{iE});
end
ExtraSlot2 = ExtraSlot2(~ES);

%% Do they have 3 fish task data?

cd(FishPath3)

% Get a list of all .mat files in the source folder
fileList = dir(fullfile(FishPath3, '*.mat'));

IDs = SurveyD.prolific_pid;
SurveyD.isFish3 = nan(ns,1);

% Loop through each ID in the cell array
for iS = 1:ns
    currentID = IDs{iS};
    fileFound = false;  % Initialize a flag to check if any file is found
    % Loop through each file in the source folder
    for j = 1:length(fileList)
        fileName = fileList(j).name;
        
        % Check if the file name contains the current ID
        if contains(fileName, currentID)
            fileFound = true;
        end
    end
    % If no file was found for the current ID, display a message
    if ~fileFound
        SurveyD.isFish3(iS) = 0;
    else
        SurveyD.isFish3(iS) = 1;
    end
end

%% Check if there is any 3 fish task data that doesnt have matching PID
% Loop through each file in data folder
ExtraFish3 = cell(length(fileList),1);
for iS = 1:length(fileList)
    fileName = fileList(iS).name;
    fileFound = false;  % Initialize a flag to check if any file is found
    % Loop through each PID
    for j = 1:ns
        currentID = IDs{j};
        % Check if the file name contains the current ID
        if contains(fileName, currentID)
            fileFound = true;
        end
    end
    % If no PID was found for the current file, add to list
    if ~fileFound
        ExtraFish3{iS} = fileName;
    end
end

EF = nan(length(ExtraFish3),1);
for iE = 1:length(ExtraFish3)
    EF(iE) = isempty(ExtraFish3{iE});
end
ExtraFish3 = ExtraFish3(~EF);

%% Do they have 2 fish task data?

cd(FishPath2)

% Get a list of all .mat files in the source folder
fileList = dir(fullfile(FishPath2, '*.mat'));

IDs = SurveyD.prolific_pid;
SurveyD.isFish2 = nan(ns,1);

% Loop through each ID in the cell array
for iS = 1:ns
    currentID = IDs{iS};
    fileFound = false;  % Initialize a flag to check if any file is found
    % Loop through each file in the source folder
    for j = 1:length(fileList)
        fileName = fileList(j).name;
        
        % Check if the file name contains the current ID
        if contains(fileName, currentID)
            fileFound = true;
        end
    end
    % If no file was found for the current ID, display a message
    if ~fileFound
        SurveyD.isFish2(iS) = 0;
    else
        SurveyD.isFish2(iS) = 1;
    end
end

%% Check if there is any 2 fish task data that doesnt have matching PID
% Loop through each file in data folder
ExtraFish2 = cell(length(fileList),1);
for iS = 1:length(fileList)
    fileName = fileList(iS).name;
    fileFound = false;  % Initialize a flag to check if any file is found
    % Loop through each PID
    for j = 1:ns
        currentID = IDs{j};
        % Check if the file name contains the current ID
        if contains(fileName, currentID)
            fileFound = true;
        end
    end
    % If no PID was found for the current file, add to list
    if ~fileFound
        ExtraFish2{iS} = fileName;
    end
end

EF = nan(length(ExtraFish2),1);
for iE = 1:length(ExtraFish2)
    EF(iE) = isempty(ExtraFish2{iE});
end
ExtraFish2 = ExtraFish2(~EF);

%% Do they have NEG 3 fish task data?

cd(NegFishPath3)

% Get a list of all .mat files in the source folder
fileList = dir(fullfile(NegFishPath3, '*.mat'));

IDs = SurveyD.prolific_pid;
SurveyD.isNegFish3 = nan(ns,1);

% Loop through each ID in the cell array
for iS = 1:ns
    currentID = IDs{iS};
    fileFound = false;  % Initialize a flag to check if any file is found
    % Loop through each file in the source folder
    for j = 1:length(fileList)
        fileName = fileList(j).name;
        
        % Check if the file name contains the current ID
        if contains(fileName, currentID)
            fileFound = true;
        end
    end
    % If no file was found for the current ID, display a message
    if ~fileFound
        SurveyD.isNegFish3(iS) = 0;
    else
        SurveyD.isNegFish3(iS) = 1;
    end
end

%% Do they have NEG 3 Slot task Data?

cd(NegSlotPath3)

% Get a list of all .mat files in the source folder
fileList = dir(fullfile(NegSlotPath3, '*.mat'));

IDs = SurveyD.prolific_pid;
SurveyD.isNegSlot3 = nan(ns,1);
SurveyD.slotCond = cell(ns,1);

% Loop through each ID in the cell array
for iS = 1:ns
    currentID = IDs{iS};
    fileFound = false;  % Initialize a flag to check if any file is found
    % Loop through each file in the source folder
    for j = 1:length(fileList)
        fileName = fileList(j).name;      
        % Check if the file name contains the current ID
        if contains(fileName, currentID)
            fileFound = true;
            % get slot condition
            DATA = load(fileName);
            SurveyD.slotCond{iS} = DATA.cond;
        end
    end
    % If no file was found for the current ID, display a message
    if ~fileFound
        SurveyD.isNegSlot3(iS) = 0;
    else
        SurveyD.isNegSlot3(iS) = 1;
    end
end


%% Generate Summary table of the prolific subjects 

% PID
PID = SurveyD.prolific_pid;
% Screening Date
Screen_Date = SurveyD.screen_date;
% Survey Date
Survey_Date = SurveyD.prolific_id_timestamp;
% Fish3
Fish3_Task = SurveyD.isFish3;
% Fish2
Fish2_Task = SurveyD.isFish2;
% Slot3
Slot3_Task = SurveyD.isSlot3;
% Slot2
Slot2_Task = SurveyD.isSlot2;
% NegFish3
NegFish3_Task = SurveyD.isNegFish3;
% NegSlot3
NegSlot3_Task = SurveyD.isNegSlot3;
% Slot Bug
Slot_Bug = SurveyD.isSlot3Bug;
% Control
Control = SurveyD.isControl;
% Sub clinical
Sub_Clinical = ~SurveyD.isControl & ~SurveyD.isDiagnostic;
% anxiety
Anxiety = SurveyD.GAD_score >9;
% depresison
Depression = SurveyD.CESD_score >9;
% OCD
OCD = SurveyD.OCI_score >20;
% BED
BED = SurveyD.BE_episodes >3;
% Alcohol
Alcohol = SurveyD.AUDIT_score >13;
% Nicotine
Nicotine = SurveyD.FTCD_score >=3;
% Cannabis
Cannabis = SurveyD.CUDIT_score >11;
% Gambling
Gambling = SurveyD.GSAS_score >20;
% Video Games
Video_Games = SurveyD.VGAQ_score >2;
% Social Media
Social_Media = SurveyD.SMAQ_score >2;
% % BDD - not included in this study
% BDD = nan(ns,1);
% for iS = 1:ns
%     if SurveyD.isBDDQ(iS) == 1
%         if SurveyD.BDD_score(iS) >12
%             BDD(iS,1) = 1;
%         else
%             BDD(iS,1) = 0;
%         end
%     end
% end

% Notes Section
Notes = cell(ns,1);
for iS = 1:ns
    temp = {};
    if SurveyD.isDup(iS) == 1
        temp = 'Duplicate Survey';
    end
    if SurveyD.isDup_screen(iS) == 1
        if isempty(temp)
            temp = 'Duplicate Screening';
        else
            temp = [temp, '; Duplicate Screening'];
        end
    end
    if isnat(SurveyD.screen_date(iS))
        if isempty(temp)
            temp = 'Missing Screening';
        else
            temp = [temp, '; Missing Screening'];
        end
    end
    % check if bot
    if strcmp(SurveyD.prolific_pid{iS}, '652044c7e76a0e2c9f6f5e94')
        if isempty(temp)
            temp = 'Probable BOT';
        else
            temp = [temp, '; Probable BOT'];
        end
    end
    % mark problematic PID
    if strcmp(SurveyD.prolific_pid{iS}, '667e6da95ae0a25f225ae6e6')
        if isempty(temp)
            temp = 'Problem Subject';
        else
            temp = [temp, '; Problem Subject'];
        end
    end
    Notes{iS} = temp;
end

Summary = table(PID, Screen_Date, Survey_Date, Control, Sub_Clinical,...
    Anxiety, Depression, OCD, BED, Alcohol, Nicotine, Cannabis, Gambling,...
    Video_Games, Social_Media, Fish2_Task, Fish3_Task, Slot2_Task, Slot3_Task,...
    NegFish3_Task,NegSlot3_Task,Slot_Bug, Notes);      

end