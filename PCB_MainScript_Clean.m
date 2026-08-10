%% PCB_MainScript_Clean
% % This documents all the clean primary code used in the PLOS_CB paper

% add PLOS_CB folder to path
addpath(genpath('C:\Users\amcla\MATLAB\PLOS_CB'));

%% Get D.mat
% [D, DSummary, ~, ~, ~, ~, ScreeningD] = PCB_Get_ProlificSummary;
% cd C:\Users\amcla\Documents\Neuroscience\Fiore\Projects\PLOS_CB\Processed_Data
% save('2025-10-10_D.mat')

% % Get Summary Table for all HC and their tasks
% HC = DSummary(DSummary.Control == 1,:);
% selectedColumns = {'PID', 'Screen_Date', 'Survey_Date', 'Fish2_Task', 'Fish3_Task', 'Slot2_Task', 'Slot3_Task', 'NegFish3_Task','NegSlot3_Task','Slot_Bug'};
% HC = HC(:, selectedColumns);
% cd C:\Users\amcla\Documents\Neuroscience\Fiore\Projects\PLOS_CB\Processed_Data
% writetable(HC, '2025-10-10_HCSummary.csv');
cd C:\Users\amcla\Documents\Neuroscience\Fiore\Projects\PLOS_CB\Processed_Data
load('2025-10-10_D.mat')

%% Generate Fs: lists of all HC subjects on a task and their filter failures

% 3Fish
sourceFolder = 'C:\Users\amcla\Documents\Neuroscience\Fiore\Projects\PLOS_CB\Raw_Data\2025-10-10_3Fish_HC';
F3F = PCB_Filter_Fish_ID(sourceFolder, 0.95);
% F3T = struct2table(F3F);
% reject = sum(F3T(:,2:5),2);

% 2Fish
sourceFolder = 'C:\Users\amcla\Documents\Neuroscience\Fiore\Projects\PLOS_CB\Raw_Data\2025-10-10_2Fish_HC';
F2F = PCB_Filter_Fish_ID(sourceFolder, 0.95);
% F2T = struct2table(F2F);
% reject = sum(F2T(:,2:5),2);

% NegFish
sourceFolder = 'C:\Users\amcla\Documents\Neuroscience\Fiore\Projects\PLOS_CB\Raw_Data\2025-10-10_3FishNeg_HC';
FNF = PCB_Filter_Fish_ID(sourceFolder, 0.95);
% FNT = struct2table(FNF);
% reject = sum(FNT(:,2:5),2);

% 3Slot
sourceFolder = 'C:\Users\amcla\Documents\Neuroscience\Fiore\Projects\PLOS_CB\Raw_Data\2025-10-10_3Slot_HC';
S3F = PCB_Filter_Slot_ID(sourceFolder, 0.95);
S3T = struct2table(S3F);
% reject = sum(S3T(:,2:4),2);
% sum(reject > 0)
% 2Slot
sourceFolder = 'C:\Users\amcla\Documents\Neuroscience\Fiore\Projects\PLOS_CB\Raw_Data\2025-10-10_2Slot_HC';
S2F = PCB_Filter_Slot_ID(sourceFolder, 0.95);
% S2T = struct2table(S2F);
% reject = sum(S2T(:,2:4),2);
% NegSlot
sourceFolder = 'C:\Users\amcla\Documents\Neuroscience\Fiore\Projects\PLOS_CB\Raw_Data\2025-10-10_3SlotNeg_HC';
SNF = PCB_Filter_Slot_ID(sourceFolder, 0.95);
% SNT = struct2table(SNF);
% reject = sum(SNT(:,2:4),2);
% sum(reject > 0)

%% Figure 1A: Show UpSet Plot for diagnostic
PCB_Show_UpSet(D)
% %% Figure 1B: Show UpSet Plot for tasks
% PCB_Show_UpSet_tasks(HC)

%% Figure 1B: Show UpSet Plot for final HC Tasks
% % Make F: a structure containing all task F structures
% F.F3F = F3F; F.S3F = S3F;
% F.F2F = F2F; F.S2F = S2F;
% F.FNF = FNF; F.SNF = SNF;
% % change each task column in HC to reflect HC_F
% HC_F = PCB_Get_Final(HC, F);
% generate upset
PCB_Show_UpSet_tasks(HC_F)

%% Create separate folders of task data for HC Subjects
rootFolder = 'C:\Users\amcla\Documents\Neuroscience\Fiore\Projects\PLOS_CB\Raw_Data';
groupName = 'HC';

% 3Slot: Healthy control & NO SLOT BUG
groupType = D.isControl & ~D.isSlot3Bug;

sourceFolder = [rootFolder,'\2025-10-10_3Slot'];
finalFolder = [sourceFolder, '_',groupName];
PCB_MakeDir(D, groupType, sourceFolder, finalFolder);
clear sourceFolder
clear finalFolder

% all other tasks: Healthy Control
groupType = D.isControl;

% 3Fish: Healthy Control
sourceFolder = [rootFolder,'\2025-10-10_3Fish'];
finalFolder = [sourceFolder, '_',groupName];
PCB_MakeDir(D, groupType, sourceFolder, finalFolder);
clear sourceFolder
clear finalFolder
% 2Slot
sourceFolder = [rootFolder,'\2025-10-10_2Slot'];
finalFolder = [sourceFolder, '_',groupName];
PCB_MakeDir(D, groupType, sourceFolder, finalFolder);
clear sourceFolder
clear finalFolder
% 2Fish
sourceFolder = [rootFolder,'\2025-10-10_2Fish'];
finalFolder = [sourceFolder, '_',groupName];
PCB_MakeDir(D, groupType, sourceFolder, finalFolder);
clear sourceFolder
clear finalFolder
% Neg3Fish
sourceFolder = [rootFolder,'\2025-10-10_3FishNeg'];
finalFolder = [sourceFolder, '_',groupName];
PCB_MakeDir(D, groupType, sourceFolder, finalFolder);
clear sourceFolder
clear finalFolder
% Neg3Slot
sourceFolder = [rootFolder,'\2025-10-10_3SlotNeg'];
finalFolder = [sourceFolder, '_',groupName];
PCB_MakeDir(D, groupType, sourceFolder, finalFolder);
clear sourceFolder
clear finalFolder

%% Filter Subjects by basic task performance

% 3-fish: remove anyone >95% color following & > 5% no-response trials
sourceFolder = 'C:\Users\amcla\Documents\Neuroscience\Fiore\Projects\PLOS_CB\Raw_Data\2025-10-10_3Fish_HC';
finalFolder = [sourceFolder, '_F'];
PCB_Filter_3Fish(sourceFolder, finalFolder, 0.95)
% Neg-3-fish
sourceFolder = 'C:\Users\amcla\Documents\Neuroscience\Fiore\Projects\PLOS_CB\Raw_Data\2025-10-10_3FishNeg_HC';
finalFolder = [sourceFolder, '_F'];
PCB_Filter_3Fish(sourceFolder, finalFolder, 0.95)

% 3-slot: remove anyone >95% WSLS & > 5% no-response trials
sourceFolder = 'C:\Users\amcla\Documents\Neuroscience\Fiore\Projects\PLOS_CB\Raw_Data\2025-10-10_3Slot_HC';
finalFolder = [sourceFolder, '_F'];
PCB_Filter_3Slot(sourceFolder, finalFolder, 0.95)
% Neg-3-slot
sourceFolder = 'C:\Users\amcla\Documents\Neuroscience\Fiore\Projects\PLOS_CB\Raw_Data\2025-10-10_3SlotNeg_HC';
finalFolder = [sourceFolder, '_F'];
PCB_Filter_3SlotNeg(sourceFolder, finalFolder, 0.95)

% Filter 2-option tasks by same performance measures
% 2025-10-10: ProlificID_66316ac602a513e2e74d5bdc 2Fish has corrupt data
% filter was added to remove this session
% 2-fish: remove anyone >95% color following & > 5% no-response trials
sourceFolder = 'C:\Users\amcla\Documents\Neuroscience\Fiore\Projects\PLOS_CB\Raw_Data\2025-10-10_2Fish_HC';
finalFolder = [sourceFolder, '_F'];
PCB_Filter_3Fish(sourceFolder, finalFolder, 0.95)
% 2-slot: remove anyone >95% WSLS & > 5% no-response trials
sourceFolder = 'C:\Users\amcla\Documents\Neuroscience\Fiore\Projects\PLOS_CB\Raw_Data\2025-10-10_2Slot_HC';
finalFolder = [sourceFolder, '_F'];
PCB_Filter_3Slot(sourceFolder, finalFolder, 0.95)

%% Table 2: Task Participation
rootFolder = 'C:\Users\amcla\Documents\Neuroscience\Fiore\Projects\PLOS_CB\Raw_Data';
taskNames = {'3Fish'; '2Fish'; '3FishNeg'; '3Slot'; '2Slot'; '3SlotNeg'};
totalSubjects = [sum(DSummary.Fish3_Task);
                 sum(DSummary.Fish2_Task);
                 sum(DSummary.NegFish3_Task);
                 sum(DSummary.Slot3_Task);
                 sum(DSummary.Slot2_Task);
                 sum(DSummary.NegSlot3_Task)];
hcSubjects = zeros(length(taskNames),1);
for iT = 1:length(taskNames)
    folderPath = [rootFolder, '\2025-10-10_', taskNames{iT},'_HC_F'];
    files = dir(fullfile(folderPath, '*.mat'));
    hcSubjects(iT) = numel(files);
end

T2 = table(taskNames, totalSubjects, hcSubjects, ...
           'VariableNames', {'Task', 'Total Subjects', 'HC Subjects'});

%% Figure 3A: Example range Parameters
Eteal = [66,182,195]./255;
Magenta = [0.95 0.45 0.95];
% example descending curve
PCB_Show_SimpleCurve([10,10,0.8,0.6],Eteal, 'bold');
hold on
% example ascending curve
PCB_Show_SimpleCurve([10,10,0.5,0.9],Magenta, 'bold');

%% Run all models on 3 option positive tasks
% tasks = {'2slot','3slot','Neg3slot','2fish','3fish','Neg3fish'};
tasks = {'3slot','3fish'};
% tasks = {'2fish'};
% tasks = {'temp_2fish'};
% Dynamic Bayesian (BI_D4)
PCB_Run_Model('BI_D4', tasks);
% Standard Bayesian (BI_1)
PCB_Run_Model('BI_1', tasks);
% Heuristic (H_1)
PCB_Run_Model('H_1', tasks);
% Kalman Filter RL (RL_KF1)
PCB_Run_Model('RL_KF1', tasks);
% Standard RL
PCB_Run_Model('RL_1', tasks);

%% Figure 4A(left): 3-option Fish Curve w/ optimal
cd C:\Users\amcla\Documents\Neuroscience\Fiore\Projects\PLOS_CB\Processed_Data
load('2025-10-10_3fish_BI_D4_HC_F.mat','best_set')
PCB_Show_LikelihoodCurve(best_set, 'fish3', false);
title('');
opCol = [0.0902    0.5294    0.4588]; % fish teal
% plot optimal curve
PCB_Show_SimpleCurve([25,5.9,1,0.66],opCol, 'dash');
ylim([0.4 1.1])
%% Figure 4A(right): 3-option Slot Curve w/ optimal
cd C:\Users\amcla\Documents\Neuroscience\Fiore\Projects\PLOS_CB\Processed_Data
load('2025-10-10_3slot_BI_D4_HC_F.mat','best_set')
PCB_Show_LikelihoodCurve(best_set, 'slot3', false);
title('');
hold on
opCol = [0.7686    0.1529    0.3490]; % slot berry
% plot optimal curve
PCB_Show_SimpleCurve([16.2,3,1,0.65],opCol, 'dash');
ylim([0.4 1.1])
%% Figure 4B(left): 3-option Fish Parameter Distributions
cd C:\Users\amcla\Documents\Neuroscience\Fiore\Projects\PLOS_CB\Processed_Data
load('2025-10-10_3fish_BI_D4_HC_F.mat','best_set')
subplot(1,2,1)
PCB_Show_ParameterDist(best_set, 'alphabeta','teal')
subplot(1,2,2)
PCB_Show_ParameterDist(best_set, 'rurc','teal')
%% Figure 4B(right): 3-option Slot Parameter Distributions
cd C:\Users\amcla\Documents\Neuroscience\Fiore\Projects\PLOS_CB\Processed_Data
load('2025-10-10_3slot_BI_D4_HC_F.mat','best_set')
subplot(1,2,1)
PCB_Show_ParameterDist(best_set, 'alphabeta','rasp')
subplot(1,2,2)
PCB_Show_ParameterDist(best_set, 'rurc','rasp')
%% Figure 5A(left): 2-option Fish Curve w/ optimal
cd C:\Users\amcla\Documents\Neuroscience\Fiore\Projects\PLOS_CB\Processed_Data
load('2025-10-10_2fish_BI_D4_HC_F.mat','best_set')
PCB_Show_LikelihoodCurve(best_set, 'fish3', false);
title('');
opCol = [0.0902    0.5294    0.4588]; % fish teal
% plot optimal curve
PCB_Show_SimpleCurve([25,2.2,1,0.77],opCol, 'dash');
ylim([0.6 1.1])
%% Figure 5A(right): 2-option Slot Curve w/ optimal
cd C:\Users\amcla\Documents\Neuroscience\Fiore\Projects\PLOS_CB\Processed_Data
load('2025-10-10_2slot_BI_D4_HC_F.mat','best_set')
PCB_Show_LikelihoodCurve(best_set, 'slot3', false);
title('');
opCol = [0.7686    0.1529    0.3490]; % slot berry
% plot optimal curve
PCB_Show_SimpleCurve([22.6,6.9,1,0.90],opCol, 'dash');
ylim([0.6 1.1])
%% Figure 5C(left): Negative Fish Curve w/ optimal & 3-option
cd C:\Users\amcla\Documents\Neuroscience\Fiore\Projects\PLOS_CB\Processed_Data
load('2025-10-10_Neg3fish_BI_D4_HC_F.mat','best_set')
PCB_Show_LikelihoodCurve(best_set, 'black', false);
hold on
cd C:\Users\amcla\Documents\Neuroscience\Fiore\Projects\PLOS_CB\Processed_Data
load('2025-10-10_3fish_BI_D4_HC_F.mat','best_set')
PCB_Show_LikelihoodCurve(best_set, 'fish3', false);
title('');
opCol = [0.0902    0.5294    0.4588]; % fish teal
% plot optimal curve
PCB_Show_SimpleCurve([25,5.9,1,0.66],opCol, 'dash');
ylim([0.4 1.1])
%% Figure 5C(right): Negative Slot Curve w/ optimal & 3-option
cd C:\Users\amcla\Documents\Neuroscience\Fiore\Projects\PLOS_CB\Processed_Data
load('2025-10-10_Neg3slot_BI_D4_HC_F.mat','best_set')
PCB_Show_LikelihoodCurve(best_set, 'black', false);
hold on
cd C:\Users\amcla\Documents\Neuroscience\Fiore\Projects\PLOS_CB\Processed_Data
load('2025-10-10_3slot_BI_D4_HC_F.mat','best_set')
PCB_Show_LikelihoodCurve(best_set, 'slot3', false);
title('');
opCol = [0.7686    0.1529    0.3490]; % slot berry
% plot optimal curve
PCB_Show_SimpleCurve([16.2,3,1,0.65],opCol, 'dash');
ylim([0.4 1.1])
%% run Ttest stats on parameter distributions
% alpha/beta
[~,pAB,~,~] = ttest(best_set(:,6),best_set(:,7));
differences = best_set(:,6) - best_set(:,7);  % alpha - beta
dAB = mean(differences) / std(differences);  % Cohen's d for paired samples
% ru/rc
[~,pUC,~,~] = ttest(best_set(:,8),best_set(:,9));
differences = best_set(:,8) - best_set(:,9);
dUC = mean(differences) / std(differences);  % Cohen's d for paired samples

% %% Run best_set for BI_D4, BI_1, and H_1 3-option tasks with softmax
% 
% % This old version reran entire model - generating new best set
% % %% Run BI_D4, BI_1, and H_1 models on 3 option positive tasks with softmax
% % % Needs modification - softmax results are identical to regular
% % tasks = {'3slot','3fish'};
% % % Dynamic Bayesian (BI_D4)
% % PCB_Run_SMxModel('BI_D4', tasks);
% % % Standard Bayesian (BI_1)
% % PCB_Run_SMxModel('BI_1', tasks);
% % % Heuristic (H_1)
% % PCB_Run_SMxModel('H_1', tasks);
% 
% % Only get new best_set(:,5) and best_set(:,10)
% tasks = {'3slot','3fish'};
% % tasks = {'3slot'};
% tau = 1;
% % Dynamic Bayesian (BI_D4)
% PCB_Run_SMx('BI_D4', tasks, tau);
% % Standard Bayesian (BI_1)
% PCB_Run_SMx('BI_1', tasks, tau);
% % Heuristic (H_1)
% PCB_Run_SMx('H_1', tasks, tau);
% 
% 
% %% BIC score comparison 3-opiton positive tasks
% % % original analysis: 3fish
% PCB_Show_BIC('2025-10-10','3fish','HC_F',1)
% % % original analysis: 3slot
% % PCB_Show_BIC('2025-10-10','3slot','HC_F',1)
% 
% %% updated with softmax added to BI_D4, BI_1, and H_1
% % 3fish
% PCB_Show_BIC('2025-10-10','3fish','HC_F',2)
% % 3slot
% % PCB_Show_BIC('2025-10-10','3slot','HC_F',2)



%% Figure 4D: Concatenated AIC score for 3-option fish and slot tasks
% task input is irrelevant here - it concatenates [3fish;3slot] best set
PCB_Show_BIC('2025-10-10','3slot','HC_F',4)
ylim([0,400])
yticks([0,200,400])
%% stats for concatenated AIC scores
[~, aic] = PCB_Get_BIC('2025-10-10','3slot','HC_F','standard',4);
% Paired t-tests between model pairs
model_names = {'BID4','BI1','H1','RLKF1','RL1'};

n_models = size(aic, 2);
pvals = nan(n_models);
tvals = nan(n_models);

for i = 1:n_models
    for j = 1:n_models
        if i ~= j
            [~, p, ~, stats] = ttest(aic(:,i), aic(:,j));
            pvals(i,j) = p;
            tvals(i,j) = stats.tstat;
        end
    end
end

% Multiple comparisons correction
alpha = 0.05;
alpha_bonferroni = alpha / 10;

%% run simulations for NS = 100: Confusion Matrix

rawData = 'C:\Users\amcla\Documents\Neuroscience\Fiore\Projects\PLOS_CB\Raw_Data';
% % 3-Fish
% BI_D4
finalFolder = [rawData,'\2025-10-10_3Fish_BID4_sim100'];
realData = '2025-10-10_3fish_BI_D4_HC_F.mat';
PCB_Simulation_Wrapper(finalFolder, realData, '3fish','BI_D4','CM')
% BI_1
finalFolder = [rawData,'\2025-10-10_3Fish_BI1_sim100'];
realData = '2025-10-10_3fish_BI_1_HC_F.mat';
PCB_Simulation_Wrapper(finalFolder, realData, '3fish','BI_1','CM')
% RL_1
finalFolder = [rawData,'\2025-10-10_3Fish_RL1_sim100'];
realData = '2025-10-10_3fish_RL_1_HC_F.mat';
PCB_Simulation_Wrapper(finalFolder, realData, '3fish','RL_1','CM')
% RL_KF1
finalFolder = [rawData,'\2025-10-10_3Fish_RLKF2_sim100'];
realData = '2025-10-10_3fish_RL_KF2_HC_F.mat';
PCB_Simulation_Wrapper(finalFolder, realData, '3fish','RL_KF2','CM')
% H_1
finalFolder = [rawData,'\2025-10-10_3Fish_H1_sim100'];
realData = '2025-10-10_3fish_H_1_HC_F.mat';
PCB_Simulation_Wrapper(finalFolder, realData, '3fish','H_1','CM')

% % 3 slot
% BI_D4
finalFolder = [rawData,'\2025-10-10_3Slot_BID4_sim100'];
realData = '2025-10-10_3slot_BI_D4_HC_F.mat';
PCB_Simulation_Wrapper(finalFolder, realData, '3slot','BI_D4','CM')
% BI_1
finalFolder = [rawData,'\2025-10-10_3Slot_BI1_sim100'];
realData = '2025-10-10_3slot_BI_1_HC_F.mat';
PCB_Simulation_Wrapper(finalFolder, realData, '3slot','BI_1','CM')
% RL_1
finalFolder = [rawData,'\2025-10-10_3Slot_RL1_sim100'];
realData = '2025-10-10_3slot_RL_1_HC_F.mat';
PCB_Simulation_Wrapper(finalFolder, realData, '3slot','RL_1','CM')
% RL_KF1
finalFolder = [rawData,'\2025-10-10_3Slot_RLKF1_sim100'];
realData = '2025-10-10_3slot_RL_KF1_HC_F.mat';
PCB_Simulation_Wrapper(finalFolder, realData, '3slot','RL_KF1','CM')
% H_1
finalFolder = [rawData,'\2025-10-10_3Slot_H1_sim100'];
realData = '2025-10-10_3slot_H_1_HC_F.mat';
PCB_Simulation_Wrapper(finalFolder, realData, '3slot','H_1','CM')

%% run models on simulated data - time consuming
rawData = 'C:\Users\amcla\Documents\Neuroscience\Fiore\Projects\PLOS_CB\Raw_Data';
root_folder = 'C:\Users\amcla\Documents\Neuroscience\Fiore\Projects\PLOS_CB\Processed_Data';

% data folder = data simulated based off DGP model
% group = the name of the data folder 

% Naming Convention for Simulated data: date, task, fitting model,
% data-generating model, sim N

date = '2025-10-10';
% change this for each task
% task = '3fish';
task = '3slot';

% model_names = {'BID4','BI1','H1','RLKF2','RL1'}; % for fish
model_names = {'BID4','BI1','H1','RLKF1','RL1'}; % for slot

% for each data-generating-model dataset
for i = 1:length(model_names)
    md = model_names{i};
    % Get the simulated data from the DGM
    % data_folder = [rawData,'\2025-10-10_3Fish_',md,'_sim100']; % change this for each task
    data_folder = [rawData,'\2025-10-10_3Slot_',md,'_sim100'];
    group = [md,'_sim100'];

    % dynamic bayesian
    PCB_Model_Wrapper_BI_D4(data_folder, root_folder, date, group, task)

    % standard Bayesian
    PCB_Model_Wrapper_BI_1(data_folder, root_folder, date, group, task)

    % standard RL
    PCB_Model_Wrapper_RL_1(data_folder, root_folder, date, group, task)

    % KF RL
    % PCB_Model_Wrapper_RL_KF2(data_folder, root_folder, date, group, task)
    PCB_Model_Wrapper_RL_KF1(data_folder, root_folder, date, group, task) % for slot

    % Heuristic
    PCB_Model_Wrapper_H_1(data_folder, root_folder, date, group, task)
end

%% Figure 6d: Confusion Matrix
PCB_Show_ConfusionMatrix('2025-10-10','3fish','standard')
%% Figure 7d: Confusion Matrix
PCB_Show_ConfusionMatrix('2025-10-10','3slot','standard')


%% Parameter correlations
% working in MATLAB>PLOS_CB>Parameter_correlations













%% Run BID4 model on 2-option and negative tasks
% tasks = {'2slot','Neg3slot','2fish','Neg3fish'};
tasks = {'Neg3slot','Neg3fish'};
% tasks = {'2slot','2fish'};
% Dynamic Bayesian (BI_D4)
PCB_Run_Model('BI_D4', tasks);


%%













%% Negative task analysis



%% Show likelihoodCurves for positive vs negative versions
% fish
Fish3 = load('2025-09-01_3fish_BI_D4_HC_F.mat','best_set');
FishNeg = load('2025-09-25_Neg3fish_BI_D4_HC_F.mat','best_set');
% Fish2 = load('2025-03-03_2fish_BI_D4_HC.mat','best_set');

figure(1)
PCB_Show_LikelihoodCurve(best_set, 'fish3', false);
hold on
load('2025-09-25_Neg3fish_BI_D4_HC_F.mat','best_set')
PCB_Show_LikelihoodCurve(best_set, 'black', false);
clear best_set
title('Fishing Tasks');
legend({'positive', 'negative'},'Location','southwest')

% slot
figure(2)
load('2025-09-25_3slot_BI_D4_HC_F.mat','best_set')
PCB_Show_LikelihoodCurve(best_set, 'slot3', false);
hold on
clear best_set
load('2025-09-25_Neg3slot_BI_D4_HC_F.mat','best_set')
PCB_Show_LikelihoodCurve(best_set, 'black', false);
clear best_set
title('Slot Tasks');
legend({'positive', 'negative'},'Location','southwest')

%% Show parameter distributions
% NegSlot
load('2025-09-25_Neg3slot_BI_D4_HC_F.mat','best_set')
figure(1)
PCB_Show_ParameterDist(best_set, 'alphabeta','rasp')
figure(2)
PCB_Show_ParameterDist(best_set, 'rurc','rasp')

%% NegFish
load('2025-09-25_Neg3fish_BI_D4_HC_F.mat','best_set')
figure(1)
PCB_Show_ParameterDist(best_set, 'alphabeta','teal')
figure(2)
PCB_Show_ParameterDist(best_set, 'rurc','teal')

%% run Ttest stats on parameter distributions
% NegSlot
load('2025-09-25_Neg3slot_BI_D4_HC_F.mat','best_set')
% alphabeta
[~,ap,~,~] = ttest(best_set(:,6),best_set(:,7));
differences = best_set(:,6) - best_set(:,7);  % alpha - beta
ad = mean(differences) / std(differences);  % Cohen's d for paired samples
clear differences
% rurc
[~,rp,~,~] = ttest(best_set(:,8),best_set(:,9));
differences = best_set(:,8) - best_set(:,9);
rd = mean(differences) / std(differences);  % Cohen's d for paired samples
clear differences

% NegFish
load('2025-09-25_Neg3fish_BI_D4_HC_F.mat','best_set')
% alphabeta
[~,ap,~,~] = ttest(best_set(:,6),best_set(:,7));
differences = best_set(:,6) - best_set(:,7);  % alpha - beta
ad = mean(differences) / std(differences);  % Cohen's d for paired samples
clear differences
% rurc
[~,rp,~,~] = ttest(best_set(:,8),best_set(:,9));
differences = best_set(:,8) - best_set(:,9);
rd = mean(differences) / std(differences);  % Cohen's d for paired samples
clear differences

%% Figure 6: show strategy split for 2Slot and NegSlot
% Run slot2analysis

% plot ascending and decending curves
PCB_Show_LikelihoodCurve(increasing, 'inc', false);
hold on
PCB_Show_LikelihoodCurve(decreasing, 'dec', false);
ylim([0.5,1])

%% generate histogram
decCol = [0.1 0.1 0.6];
incCol = [0.6 0.1 0.1];
% decreasing
histogram(de_conf, 20, 'Normalization', 'probability','FaceColor',decCol, 'FaceAlpha',0.5, 'EdgeAlpha',0)
xlabel('confidence (Xchoice)');
ylabel('proportion of trials');
title('Decreasing vs. Increasing Curves','FontSize',16);
ylim([0,0.6])
yticks([0,0.1,0.2,0.3,0.4,0.5,0.6])
hold on
% increasing
histogram(in_conf, 20, 'Normalization', 'probability', 'FaceColor',incCol, 'FaceAlpha',0.5, 'EdgeAlpha',0)
ylim([0,1])

%% Show all 2-slot
PCB_Show_LikelihoodCurve(best_set, 'slot3', false);
ylim([0.5,1])
title('');

%% histogram
opCol = [0.7686    0.1529    0.3490]; % slot berry
histogram(all_conf, 20, 'Normalization', 'probability','FaceColor',opCol, 'FaceAlpha',0.5, 'EdgeAlpha',0)
xlabel('confidence (Xchoice)');
ylabel('proportion of trials');
ylim([0,1])
title('');

%% Same thing but for negative slot
% Run slot2analysis
% plot ascending and decending curves
PCB_Show_LikelihoodCurve(increasing, 'inc', false);
hold on
PCB_Show_LikelihoodCurve(decreasing, 'dec', false);
ylim([0.3,1])

%% generate histogram
decCol = [0.1 0.1 0.6];
incCol = [0.6 0.1 0.1];
% decreasing
histogram(de_conf, 20, 'Normalization', 'probability','FaceColor',decCol, 'FaceAlpha',0.5, 'EdgeAlpha',0)
xlabel('confidence (Xchoice)');
ylabel('proportion of trials');
title('Decreasing vs. Increasing Curves','FontSize',16);
ylim([0,0.6])
yticks([0,0.1,0.2,0.3,0.4,0.5,0.6])
hold on
% increasing
histogram(in_conf, 20, 'Normalization', 'probability', 'FaceColor',incCol, 'FaceAlpha',0.5, 'EdgeAlpha',0)
ylim([0,1])




%%
opCol = [0 0 0]; % black
histogram(all_conf, 20, 'Normalization', 'probability','FaceColor',opCol, 'FaceAlpha',0.5, 'EdgeAlpha',0)
xlabel('confidence (Xchoice)');
ylabel('proportion of trials');
ylim([0,1])
title('');

%% SUPPLEMENTAL

%% Additional AIC Scores

% Individual AIC scores for Standard Tasks
% 3 fish
figure(1)
PCB_Show_BIC('2025-10-10','3fish','HC_F',3)
% ylim([0,300])
% yticks([0,150,300])
ylim([0,400])
yticks([0,200,400])
title('3-Fish');
% 3 slot
figure(2)
PCB_Show_BIC('2025-10-10','3slot','HC_F',3)
ylim([0,400])
yticks([0,200,400])
title('3-Slot');

%% stats for AIC scores
[~, aic] = PCB_Get_BIC('2025-10-10','3slot','HC_F','standard',3);
% Paired t-tests between model pairs
model_names = {'BID4','BI1','H1','RLKF1','RL1'};

n_models = size(aic, 2);
pvals = nan(n_models);
tvals = nan(n_models);

for i = 1:n_models
    for j = 1:n_models
        if i ~= j
            [~, p, ~, stats] = ttest(aic(:,i), aic(:,j));
            pvals(i,j) = p;
            tvals(i,j) = stats.tstat;
        end
    end
end

% Multiple comparisons correction
alpha = 0.05;
alpha_bonferroni = alpha / 10;


%% 2-option versions
%% Run all other models on 2 option tasks
% tasks = {'2slot','3slot','Neg3slot','2fish','3fish','Neg3fish'};
tasks = {'2slot','2fish'};
% Standard Bayesian (BI_1)
PCB_Run_Model('BI_1', tasks);
% Heuristic (H_1)
PCB_Run_Model('H_1', tasks);
% Kalman Filter RL (RL_KF1)
PCB_Run_Model('RL_KF1', tasks);
% Standard RL
PCB_Run_Model('RL_1', tasks);
%% Individual AIC scores for 2-option Tasks
% 2 fish
figure(1)
PCB_Show_BIC('2025-10-10','2fish','HC_F',3)
% ylim([0,300])
% yticks([0,150,300])
% ylim([0,400])
% yticks([0,200,400])
title('2-Fish');
% 2 slot
figure(2)
PCB_Show_BIC('2025-10-10','2slot','HC_F',3)
% ylim([0,400])
% yticks([0,200,400])
title('2-Slot');
%% stats for AIC scores
% change manually the task
[~, aic] = PCB_Get_BIC('2025-10-10','2fish','HC_F','standard',3);
% Paired t-tests between model pairs
model_names = {'BID4','BI1','H1','RLKF1','RL1'};

n_models = size(aic, 2);
pvals = nan(n_models);
tvals = nan(n_models);

for i = 1:n_models
    for j = 1:n_models
        if i ~= j
            [~, p, ~, stats] = ttest(aic(:,i), aic(:,j));
            pvals(i,j) = p;
            tvals(i,j) = stats.tstat;
        end
    end
end

% Multiple comparisons correction
alpha = 0.05;
alpha_bonferroni = alpha / 10;

%% Concatenated AIC score for 2-option fish and slot tasks
% task input is irrelevant here - it concatenates [2fish;2slot] best set
PCB_Show_BIC('2025-10-10','2slot','HC_F',5)
% ylim([0,400])
% yticks([0,200,400])
%% stats for AIC scores
% change manually the task
[~, aic] = PCB_Get_BIC('2025-10-10','2fish','HC_F','standard',5);
% Paired t-tests between model pairs
model_names = {'BID4','BI1','H1','RLKF1','RL1'};

n_models = size(aic, 2);
pvals = nan(n_models);
tvals = nan(n_models);

for i = 1:n_models
    for j = 1:n_models
        if i ~= j
            [~, p, ~, stats] = ttest(aic(:,i), aic(:,j));
            pvals(i,j) = p;
            tvals(i,j) = stats.tstat;
        end
    end
end

% Multiple comparisons correction
alpha = 0.05;
alpha_bonferroni = alpha / 10;

%% Negative versions
%% Run all other models on Negative tasks
% tasks = {'2slot','3slot','Neg3slot','2fish','3fish','Neg3fish'};
tasks = {'Neg3slot','Neg3fish'};
% Standard Bayesian (BI_1)
PCB_Run_Model('BI_1', tasks);
% Heuristic (H_1)
PCB_Run_Model('H_1', tasks);
% Kalman Filter RL (RL_KF1)
PCB_Run_Model('RL_KF1', tasks);
% Standard RL
PCB_Run_Model('RL_1', tasks);
%% Individual AIC scores for Negative Tasks
% 2 fish
figure(1)
PCB_Show_BIC('2025-10-10','Neg3fish','HC_F',3)
% ylim([0,300])
% yticks([0,150,300])
% ylim([0,400])
% yticks([0,200,400])
title('Neg-Fish');
% 2 slot
figure(2)
PCB_Show_BIC('2025-10-10','Neg3slot','HC_F',3)
% ylim([0,400])
% yticks([0,200,400])
title('Neg-Slot');
%% stats for AIC scores
% change manually the task
[~, aic] = PCB_Get_BIC('2025-10-10','Neg3slot','HC_F','standard',3);
% Paired t-tests between model pairs
model_names = {'BID4','BI1','H1','RLKF1','RL1'};

n_models = size(aic, 2);
pvals = nan(n_models);
tvals = nan(n_models);

for i = 1:n_models
    for j = 1:n_models
        if i ~= j
            [~, p, ~, stats] = ttest(aic(:,i), aic(:,j));
            pvals(i,j) = p;
            tvals(i,j) = stats.tstat;
        end
    end
end

% Multiple comparisons correction
alpha = 0.05;
alpha_bonferroni = alpha / 10;

%% Concatenated AIC score for Negative fish and slot tasks
% task input is irrelevant here - it concatenates [Neg3fish;Neg3slot] best set
PCB_Show_BIC('2025-10-10','Neg3slot','HC_F',6)
% ylim([0,400])
% yticks([0,200,400])
%% stats for AIC scores
% change manually the task
[~, aic] = PCB_Get_BIC('2025-10-10','Neg3fish','HC_F','standard',6);
% Paired t-tests between model pairs
model_names = {'BID4','BI1','H1','RLKF1','RL1'};

n_models = size(aic, 2);
pvals = nan(n_models);
tvals = nan(n_models);

for i = 1:n_models
    for j = 1:n_models
        if i ~= j
            [~, p, ~, stats] = ttest(aic(:,i), aic(:,j));
            pvals(i,j) = p;
            tvals(i,j) = stats.tstat;
        end
    end
end

% Multiple comparisons correction
alpha = 0.05;
alpha_bonferroni = alpha / 10;

%% Concatenated AIC score for ALL 6 tasks
% task input is irrelevant here - it concatenates [Neg3fish;Neg3slot] best set
PCB_Show_BIC('2025-10-10','Neg3slot','HC_F',7)
% ylim([0,400])
% yticks([0,200,400])
%% stats for AIC scores
% change manually the task
[~, aic] = PCB_Get_BIC('2025-10-10','Neg3fish','HC_F','standard',7);
% Paired t-tests between model pairs
model_names = {'BID4','BI1','H1','RLKF1','RL1'};

n_models = size(aic, 2);
pvals = nan(n_models);
tvals = nan(n_models);

for i = 1:n_models
    for j = 1:n_models
        if i ~= j
            [~, p, ~, stats] = ttest(aic(:,i), aic(:,j));
            pvals(i,j) = p;
            tvals(i,j) = stats.tstat;
        end
    end
end

% Multiple comparisons correction
alpha = 0.05;
alpha_bonferroni = alpha / 10;

%% Check AIC scores for decending vs ascending 
cd C:\Users\amcla\Documents\Neuroscience\Fiore\Projects\PLOS_CB\Processed_Data
% TASK = 'Neg3slot';
% TASK = 'Neg3fish';
TASK = '3slot';

load(['2025-10-10_',TASK,'_RL_KF1_HC_F.mat'], 'best_set')
% load(['2025-10-10_',TASK,'_RL_KF2_HC_F.mat'], 'best_set')
RLKF = best_set;
load(['2025-10-10_',TASK,'_BI_D4_HC_F.mat'], 'best_set')
BID4 = best_set;

% find increasing and decreasing curves
inc = BID4(:,8) < BID4(:,9);
dec = BID4(:,8) > BID4(:,9);

% Get AIC scores for neg slot task on all models
[~, aic] = PCB_Get_BIC('2025-10-10',TASK,'HC_F','standard',3);
% reduce to just BID4 and RLKF
AIC = [aic(:,1), aic(:,4)];

%% Show boxplot % pval of AIC scores for all subjects 
% colors
DBIblue = [0.3490 0.7412 1.0000]; % light blue
RLKFgreen = [0.6471 0.8118 0.4392]; % light green
% put colors in reverse order
Cols = [RLKFgreen;DBIblue];

%%
Task = '3 Slot';

figure(1)
bp = boxplot(AIC,"Colors","k");
h = findobj(gca,'Tag','Box');
for j=1:length(h)
    patch(get(h(j),'XData'),get(h(j),'YData'),Cols(j,:),'FaceAlpha',.75);
end
set(bp,'LineWidth',2)
set(gca,'children',flipud(get(gca,'children')))
% change outliar marker
set(bp,'Marker','.')
set(bp,'MarkerSize',6)
set(bp,'MarkerEdgeColor','k')
title([Task,': All Subjects'])
xticklabels({'BI_D4','RL_KF1'})

[~, p, ~, stats] = ttest(aic(:,1), aic(:,4));

% split by inc/dec
incAIC = AIC(inc,:);
decAIC = AIC(dec,:);

figure(2)
bp = boxplot(decAIC,"Colors","k");
h = findobj(gca,'Tag','Box');
for j=1:length(h)
    patch(get(h(j),'XData'),get(h(j),'YData'),Cols(j,:),'FaceAlpha',.75);
end
set(bp,'LineWidth',2)
set(gca,'children',flipud(get(gca,'children')))
% change outliar marker
set(bp,'Marker','.')
set(bp,'MarkerSize',6)
set(bp,'MarkerEdgeColor','k')
[~, pD, ~, ~] = ttest(decAIC(:,1), decAIC(:,2));
title([Task,': Decending (optimal) Curves']);
xticklabels({'BI_D4','RL_KF1'})

figure(3)
bp = boxplot(incAIC,"Colors","k");
h = findobj(gca,'Tag','Box');
for j=1:length(h)
    patch(get(h(j),'XData'),get(h(j),'YData'),Cols(j,:),'FaceAlpha',.75);
end
set(bp,'LineWidth',2)
set(gca,'children',flipud(get(gca,'children')))
% change outliar marker
set(bp,'Marker','.')
set(bp,'MarkerSize',6)
set(bp,'MarkerEdgeColor','k')
[~, pI, ~, ~] = ttest(incAIC(:,1), incAIC(:,2));
title([Task,': Ascending (inverted) Curves']);
xticklabels({'BI_D4','RL_KF1'})

%% Test fmin_function for 2 option slot task
cd C:\Users\amcla\Documents\Neuroscience\Fiore\Projects\PLOS_CB\Processed_Data
load('2025-10-10_2slot_RL_1_HC_F.mat', 'best_set')
% All best fit parameters = 0.9999

raw_folder = 'C:\Users\amcla\Documents\Neuroscience\Fiore\Projects\PLOS_CB\Raw_Data';
data_folder = [raw_folder,'\2025-10-10_2Slot_HC_F'];
cd (data_folder)
% structure with .mat file information
subdirs = dir('*.mat');
% number of subjects
n_subjects=length(subdirs);

subj = cell(n_subjects,1);
for i=1:n_subjects 
    subj{i,1} = subdirs(i).name;
end
%%
DATA = load(subj{2});
upperbound = 1;
pars = 0.34;

PCB_fmin_function_2slot_RL_1(pars, DATA.data, upperbound, 'log')

%% Run RL_2 on 2 option tasks (fits tau as a free parameter)
tasks = {'2slot','2fish'};
PCB_Run_Model('RL_1', tasks);

%% Run RL_2 on all other tasks (fits tau as a free parameter)
tasks = {'2slot','2fish','3slot','Neg3slot','3fish','Neg3fish'};
PCB_Run_Model('RL_2', tasks);
% MEAN TAU
% 2 slot: 16.1
% 3 slot: 10.5
% neg slot: 11.4
% 2 fish: 9.7
% 3 fish: 9.0
% neg fish: 8.5

%% Run RL_1 with updated tau
tasks = {'2slot','2fish','3slot','Neg3slot','3fish','Neg3fish'};
PCB_Run_Model('RL_1', tasks);

%%
PCB_Show_BIC('2025-10-10','2slot','HC_F',8)
