%% load all model best_set data for 3 fish
cd C:\Users\amcla\Documents\Neuroscience\Fiore\Projects\PLOS_CB\Processed_Data

task = '3slot';
% number of models
nm = 5;

BI_D4 = load(['2025-03-03_',task,'_BI_D4_HC.mat'],"best_set");
BI_1 = load(['2025-03-03_',task,'_BI_1_HC.mat'],"best_set");
H_1 = load(['2025-03-03_',task,'_H_1_HC.mat'],"best_set");

RL_KF1 = load(['2025-03-19_',task,'_RL_KF1_HC.mat'],"best_set");
RL_1 = load(['2025-03-19-10_',task,'_RL_1_HC.mat'],"best_set");



%% Calculate AIC/BIC of these models for each subject
ns = length(BI_1.best_set);

aic = nan(ns,nm);
bic = nan(ns,nm);

% extract the negative log-likelihood from each best_set
% this is typically the last column

for iS = 1:ns
    LogL = [-BI_D4.best_set(iS,10);-BI_1.best_set(iS,4); -H_1.best_set(iS,4);...
        -RL_KF1.best_set(iS,4); -RL_1.best_set(iS,4)];
    numParam = [4;1;1;1;1];
    [aic(iS,:),bic(iS,:)] = aicbic(LogL,numParam);
end
%% basic boxplot
boxplot(bic)
xticklabels({'BI_D4','BI_1','H_1','RL_KF1','RL_1'})
title(task);
ylabel('bic score');
ylim([0,400])
