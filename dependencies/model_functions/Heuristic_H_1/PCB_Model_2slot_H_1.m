%% PCB_Model_2Slot_H_1
% Adapted from Fiore bayes_main (3fish version)
% This script runs a heuristic model on the 2 slot task.
% It generates a .mat file (2slot_H_1_group.mat) containing the 
% best_set (nsx4) matrix of the likelihood_normal_distribution parameter
% associated with the linear (:,1) and log (:,3). Typically, we use the
% log (:,3) parameter for visualizing the dynamic curve.
% the error associated with each are on the adjacent columns

% takes group as an input for file saving. eg ('HC')
function PCB_Model_2slot_H_1(data_folder, root_folder, day, group)

cd (data_folder)

% structure with .mat file information
subdirs = dir('*.mat');

% number of subjects
n_subjects=length(subdirs);

% number of parameters to test
n_iter=1000;    

% task structure information
n_slots=2;
n_trials=15;
start_trial=2;
n_blocks=10;    

% this bayesian model fits a single parameter
par_names{1}='H factor';
prmtn=length(par_names);

%% pre-allocate result storage
for i=1:n_subjects 
    subj{i,1} = subdirs(i).name;
    % likely1 will accumulate error measure (probability)
    likely1{i}=zeros(n_iter,n_blocks);
    % likely2 will accumulate negative log likelihood log(probability)
    likely2{i}=zeros(n_iter,n_blocks);
end
% best_set will store the best-fitting parameter
best_set=zeros(n_subjects,prmtn*2+2);

tic
for agent=1:n_subjects
    cd (data_folder) % ensure correct folder
    clear data
    clear cond2
    disp(agent);
    toc
    %load data series per each agent
    % load(subj{agent})
    % cond is a matlab function - need to load DATA so we can interact with
    % cond as a structure variable - AEM
    DATA = load(subj{agent});
    IDs{agent,1}=subj{agent}(1:(end-4));

    %load real choice selections
    all_data{agent,1}=DATA.data;
    all_IDs{agent,1}=subj{agent};

    for iter=1:n_iter
        
        choice_selections=0;
        errors=zeros(n_iter,n_blocks);

        % sample parameter from [0, 1]
        parameters{agent}(iter,1)=rand(1);
        % store the random parameter for this iteration
        h=parameters{agent}(iter,1);

        % updating posterior and compute likelihood
        for blocki=1:n_blocks
            clear real_choices
            clear outcomes
            % starting prior for each trial in the block
            slotpN100{blocki}=ones(n_trials,n_slots)/n_slots;
            % the fish that was displayed
            outcomes = all_data{agent}{blocki}(:,2);
            % the subjects pond choice
            real_choices = all_data{agent}{blocki}(:,1);

            for triali=start_trial:length(outcomes)
                
                % retrieve prior
                prob=slotpN100{blocki}(triali-1,:);

                % Heuristic update
                if real_choices(triali-1) == 1
                    if outcomes(triali-1) == 100 % if win
                        slotpN100{blocki}(triali,1) = prob(1)+h;
                        slotpN100{blocki}(triali,2) = prob(2)-h;
                    elseif outcomes(triali-1) == 10 || outcomes(triali-1) == 0 % if loss
                        slotpN100{blocki}(triali,1) = prob(1)-h;
                        slotpN100{blocki}(triali,2) = prob(2)+h;
                    end
                elseif real_choices(triali-1) == 2
                    if outcomes(triali-1) == 100 % if win
                        slotpN100{blocki}(triali,1) = prob(1)-h;
                        slotpN100{blocki}(triali,2) = prob(2)+h;
                    elseif outcomes(triali-1) == 10 || outcomes(triali-1) == 0 % if loss
                        slotpN100{blocki}(triali,1) = prob(1)+h;
                        slotpN100{blocki}(triali,2) = prob(2)-h;
                    end
                else
                    slotpN100{blocki}(triali,:)=(prob + ones(1,2)/2)/2;
                end

                % bound each posterior by 0.05 then normalize
                slotpN100{blocki}(triali,:)=max(0.05, slotpN100{blocki}(triali,:));
                slotpN100{blocki}(triali,:)=slotpN100{blocki}(triali,:)/sum(slotpN100{blocki}(triali,:));

                distro=slotpN100{blocki}(triali,:);

                % "error" and "likelihood" computations
                if real_choices(triali)>0
                    choice_selections=choice_selections+1;

                    % 1 - models probability
                    errors(iter,blocki)= 1-distro(real_choices(triali));
                    % sum of the total error accumulation
                    likely1{agent}(iter,blocki)=likely1{agent}(iter,blocki)+ errors(iter,blocki);

                    % negative log-likelihood measure (capped at 3)
                    likely2{agent}(iter,blocki)=likely2{agent}(iter,blocki)+ min(3, abs(log(distro(real_choices(triali)))));                    
                end

                if max(slotpN100{blocki}(triali,:))==0.05
                    error ('check')
                end

            end
        end
    end

    % total the error measures across all blocks
    sum_likely1{agent}=sum(likely1{agent},2);
    sum_likely2{agent}=sum(likely2{agent},2);
    
    % find the best fitting parameter based on each measure
    [val1, pos1]=min(sum_likely1{agent});
    [val2, pos2]=min(sum_likely2{agent});
    
    % store the parameter and associated error in best_set
    best_set(agent,1:prmtn)=parameters{agent}(pos1,:);
    best_set(agent,prmtn+1)=val1*100/choice_selections;
    best_set(agent,(prmtn+2):(prmtn*2+1))=parameters{agent}(pos2,:);
    best_set(agent,prmtn*2+2)=val2;
    
    disp(best_set(agent,:));
end

mean_bs=mean(best_set(1:n_subjects,:));
std_bs=std(best_set(1:n_subjects,:));

cd (root_folder)
filename = [day '_2slot_H_1_' group '.mat'];
save(filename, 'best_set', 'mean_bs', 'std_bs', 'par_names', 'all_data','IDs');

figure
scatter(ones(length(best_set(:,1)),1),best_set(:,1))
hold on
scatter(ones(length(best_set(:,1)),1)+1,best_set(:,3))
axis([0 3 0 1.1])
