%% PCB_Get_BIC
% This function generates BIC scores for a given task and group on all 5 models
% order: standard = [BID4, BI1, H1, RLKF1, RL1], reverse = oposite.

% original: use version 1
% updated 10/2025: BIC scores for ALL tasks include softmax - use version 2
function [bic, aic] = PCB_Get_BIC(date, task, group, order,version)

cd C:\Users\amcla\Documents\Neuroscience\Fiore\Projects\PLOS_CB\Processed_Data

% number of models
nm = 5;

if version == 1 || version == 3
    BI_D4 = load([date,'_',task,'_BI_D4_', group,'.mat'],"best_set");
    BI_1 = load([date,'_',task,'_BI_1_', group,'.mat'],"best_set");
    H_1 = load([date,'_',task,'_H_1_', group,'.mat'],"best_set");
elseif version == 2
    BI_D4 = load([date,'_',task,'_BI_D4_sm_', group,'.mat'],"best_set");
    BI_1 = load([date,'_',task,'_BI_1_sm_', group,'.mat'],"best_set");
    H_1 = load([date,'_',task,'_H_1_sm_', group,'.mat'],"best_set");
elseif version == 4
    BI_D4s = load([date,'_3slot_BI_D4_', group,'.mat'],"best_set");
    BI_1s = load([date,'_3slot_BI_1_', group,'.mat'],"best_set");
    H_1s = load([date,'_3slot_H_1_', group,'.mat'],"best_set");
    RL_KF1s = load([date,'_3slot_RL_KF1_', group,'.mat'],"best_set");
    RL_1s = load([date,'_3slot_RL_1_', group,'.mat'],"best_set");

    BI_D4f = load([date,'_3fish_BI_D4_', group,'.mat'],"best_set");
    BI_1f = load([date,'_3fish_BI_1_', group,'.mat'],"best_set");
    H_1f = load([date,'_3fish_H_1_', group,'.mat'],"best_set");
    RL_KF1f = load([date,'_3fish_RL_KF2_', group,'.mat'],"best_set");
    RL_1f = load([date,'_3fish_RL_1_', group,'.mat'],"best_set");

    BI_D4.best_set = [BI_D4f.best_set;BI_D4s.best_set];
    BI_1.best_set = [BI_1f.best_set;BI_1s.best_set];
    H_1.best_set = [H_1f.best_set;H_1s.best_set];
    RL_KF1.best_set = [RL_KF1f.best_set;RL_KF1s.best_set];
    RL_1.best_set = [RL_1f.best_set;RL_1s.best_set];
elseif version == 5
    BI_D4s = load([date,'_2slot_BI_D4_', group,'.mat'],"best_set");
    BI_1s = load([date,'_2slot_BI_1_', group,'.mat'],"best_set");
    H_1s = load([date,'_2slot_H_1_', group,'.mat'],"best_set");
    RL_KF1s = load([date,'_2slot_RL_KF1_', group,'.mat'],"best_set");
    RL_1s = load([date,'_2slot_RL_1_', group,'.mat'],"best_set");

    BI_D4f = load([date,'_2fish_BI_D4_', group,'.mat'],"best_set");
    BI_1f = load([date,'_2fish_BI_1_', group,'.mat'],"best_set");
    H_1f = load([date,'_2fish_H_1_', group,'.mat'],"best_set");
    RL_KF1f = load([date,'_2fish_RL_KF2_', group,'.mat'],"best_set");
    RL_1f = load([date,'_2fish_RL_1_', group,'.mat'],"best_set");

    BI_D4.best_set = [BI_D4f.best_set;BI_D4s.best_set];
    BI_1.best_set = [BI_1f.best_set;BI_1s.best_set];
    H_1.best_set = [H_1f.best_set;H_1s.best_set];
    RL_KF1.best_set = [RL_KF1f.best_set;RL_KF1s.best_set];
    RL_1.best_set = [RL_1f.best_set;RL_1s.best_set];
elseif version == 6
    BI_D4s = load([date,'_Neg3slot_BI_D4_', group,'.mat'],"best_set");
    BI_1s = load([date,'_Neg3slot_BI_1_', group,'.mat'],"best_set");
    H_1s = load([date,'_Neg3slot_H_1_', group,'.mat'],"best_set");
    RL_KF1s = load([date,'_Neg3slot_RL_KF1_', group,'.mat'],"best_set");
    RL_1s = load([date,'_Neg3slot_RL_1_', group,'.mat'],"best_set");

    BI_D4f = load([date,'_Neg3fish_BI_D4_', group,'.mat'],"best_set");
    BI_1f = load([date,'_Neg3fish_BI_1_', group,'.mat'],"best_set");
    H_1f = load([date,'_Neg3fish_H_1_', group,'.mat'],"best_set");
    RL_KF1f = load([date,'_Neg3fish_RL_KF2_', group,'.mat'],"best_set");
    RL_1f = load([date,'_Neg3fish_RL_1_', group,'.mat'],"best_set");

    BI_D4.best_set = [BI_D4f.best_set;BI_D4s.best_set];
    BI_1.best_set = [BI_1f.best_set;BI_1s.best_set];
    H_1.best_set = [H_1f.best_set;H_1s.best_set];
    RL_KF1.best_set = [RL_KF1f.best_set;RL_KF1s.best_set];
    RL_1.best_set = [RL_1f.best_set;RL_1s.best_set];
elseif version == 7
    BI_D4S = load([date,'_3slot_BI_D4_', group,'.mat'],"best_set");
    BI_1S = load([date,'_3slot_BI_1_', group,'.mat'],"best_set");
    H_1S = load([date,'_3slot_H_1_', group,'.mat'],"best_set");
    RL_KF1S = load([date,'_3slot_RL_KF1_', group,'.mat'],"best_set");
    RL_1S = load([date,'_3slot_RL_1_', group,'.mat'],"best_set");

    BI_D4F = load([date,'_3fish_BI_D4_', group,'.mat'],"best_set");
    BI_1F = load([date,'_3fish_BI_1_', group,'.mat'],"best_set");
    H_1F = load([date,'_3fish_H_1_', group,'.mat'],"best_set");
    RL_KF1F = load([date,'_3fish_RL_KF2_', group,'.mat'],"best_set");
    RL_1F = load([date,'_3fish_RL_1_', group,'.mat'],"best_set");

    BI_D4NS = load([date,'_Neg3slot_BI_D4_', group,'.mat'],"best_set");
    BI_1NS = load([date,'_Neg3slot_BI_1_', group,'.mat'],"best_set");
    H_1NS = load([date,'_Neg3slot_H_1_', group,'.mat'],"best_set");
    RL_KF1NS = load([date,'_Neg3slot_RL_KF1_', group,'.mat'],"best_set");
    RL_1NS = load([date,'_Neg3slot_RL_1_', group,'.mat'],"best_set");

    BI_D4NF = load([date,'_Neg3fish_BI_D4_', group,'.mat'],"best_set");
    BI_1NF = load([date,'_Neg3fish_BI_1_', group,'.mat'],"best_set");
    H_1NF = load([date,'_Neg3fish_H_1_', group,'.mat'],"best_set");
    RL_KF1NF = load([date,'_Neg3fish_RL_KF2_', group,'.mat'],"best_set");
    RL_1NF = load([date,'_Neg3fish_RL_1_', group,'.mat'],"best_set");

    BI_D4s = load([date,'_2slot_BI_D4_', group,'.mat'],"best_set");
    BI_1s = load([date,'_2slot_BI_1_', group,'.mat'],"best_set");
    H_1s = load([date,'_2slot_H_1_', group,'.mat'],"best_set");
    RL_KF1s = load([date,'_2slot_RL_KF1_', group,'.mat'],"best_set");
    RL_1s = load([date,'_2slot_RL_1_', group,'.mat'],"best_set");

    BI_D4f = load([date,'_2fish_BI_D4_', group,'.mat'],"best_set");
    BI_1f = load([date,'_2fish_BI_1_', group,'.mat'],"best_set");
    H_1f = load([date,'_2fish_H_1_', group,'.mat'],"best_set");
    RL_KF1f = load([date,'_2fish_RL_KF2_', group,'.mat'],"best_set");
    RL_1f = load([date,'_2fish_RL_1_', group,'.mat'],"best_set");

    BI_D4.best_set = [BI_D4F.best_set;BI_D4S.best_set;BI_D4NF.best_set;BI_D4NS.best_set;BI_D4f.best_set;BI_D4s.best_set];
    BI_1.best_set = [BI_1F.best_set;BI_1S.best_set;BI_1NF.best_set;BI_1NS.best_set;BI_1f.best_set;BI_1s.best_set];
    H_1.best_set = [H_1F.best_set;H_1S.best_set;H_1NF.best_set;H_1NS.best_set;H_1f.best_set;H_1s.best_set];
    RL_KF1.best_set = [RL_KF1F.best_set;RL_KF1S.best_set;RL_KF1NF.best_set;RL_KF1NS.best_set;RL_KF1f.best_set;RL_KF1s.best_set];
    RL_1.best_set = [RL_1F.best_set;RL_1S.best_set;RL_1NF.best_set;RL_1NS.best_set;RL_1f.best_set;RL_1s.best_set];
elseif version == 8 % RL_2
    BI_D4 = load([date,'_',task,'_BI_D4_', group,'.mat'],"best_set");
    BI_1 = load([date,'_',task,'_BI_1_', group,'.mat'],"best_set");
    H_1 = load([date,'_',task,'_H_1_', group,'.mat'],"best_set");
    if strcmp(task, '3fish') || strcmp(task, '2fish') || strcmp(task, 'Neg3fish')
        RL_KF1 = load([date,'_',task,'_RL_KF2_', group,'.mat'],"best_set");
    else
        RL_KF1 = load([date,'_',task,'_RL_KF1_', group,'.mat'],"best_set");
    end
    RL_1 = load([date,'_',task,'_RL_2_', group,'.mat'],"best_set");
end

if version < 4 
    if strcmp(task, '3fish') || strcmp(task, '2fish') || strcmp(task, 'Neg3fish')
        RL_KF1 = load([date,'_',task,'_RL_KF2_', group,'.mat'],"best_set");
    else
        RL_KF1 = load([date,'_',task,'_RL_KF1_', group,'.mat'],"best_set");
    end
    RL_1 = load([date,'_',task,'_RL_1_', group,'.mat'],"best_set");
end


%% Calculate AIC/BIC of these models for each subject
ns = length(BI_1.best_set);

aic = nan(ns,nm);
bic = nan(ns,nm);

% extract the negative log-likelihood from each best_set
% this is typically the last column

for iS = 1:ns
    if version < 8
        if strcmp(order, 'standard')
            LogL = [-BI_D4.best_set(iS,10);-BI_1.best_set(iS,4); -H_1.best_set(iS,4);...
                -RL_KF1.best_set(iS,4); -RL_1.best_set(iS,4)];
            numParam = [4;1;1;1;1];
        elseif strcmp(order,'reverse')
            LogL = [-RL_1.best_set(iS,4);-RL_KF1.best_set(iS,4); -H_1.best_set(iS,4);...
                -BI_1.best_set(iS,4); -BI_D4.best_set(iS,10)];
            numParam = [1;1;1;1;4];
        end
    else
        if strcmp(order, 'standard')
            LogL = [-BI_D4.best_set(iS,10);-BI_1.best_set(iS,4); -H_1.best_set(iS,4);...
                -RL_KF1.best_set(iS,4); -RL_1.best_set(iS,6)];
            numParam = [4;1;1;1;2];
        elseif strcmp(order,'reverse')
            LogL = [-RL_1.best_set(iS,6);-RL_KF1.best_set(iS,4); -H_1.best_set(iS,4);...
                -BI_1.best_set(iS,4); -BI_D4.best_set(iS,10)];
            numParam = [2;1;1;1;4];
        end
    end
    % adding the n changes everything
    % [aic(iS,:),bic(iS,:)] = aicbic(LogL,numParam,150);
    if version == 1
        [aic(iS,:),bic(iS,:)] = aicbic(LogL,numParam);
    else
        [aic(iS,:),bic(iS,:)] = aicbic(LogL,numParam,150);
    end
end
end
% % basic boxplot
% boxplot(bic)
% xticklabels({'BI_D4','BI_1','H_1','RL_KF1','RL_1'})
% title(task);
% ylabel('bic score');
% ylim([0,400])
