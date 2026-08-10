%% PCB_Model_3Fish_BI_1
% Adapted from Fiore bayes_main (3fish version)
% This script runs a standard bayesian model on the 3 fish task.
% It generates a .mat file (3fish_BI_1_group.mat) containing the 
% best_set (nsx4) matrix of the likelihood_normal_distribution parameter
% associated with the linear (:,1) and log (:,3). Typically, we use the
% log (:,3) parameter for visualizing the dynamic curve.
% the error associated with each are on the adjacent columns

% takes group as an input for file saving. eg ('HC')
function PCB_Model_3fish_BI_1(data_folder, root_folder, day, group)

cd (data_folder)

% structure with .mat file information
subdirs = dir('*.mat');

% number of subjects
n_subjects=length(subdirs);

% number of parameters to test
n_iter=1000;    

% task structure information
n_fish=3;
n_trials=15;
start_trial=1;
n_blocks=10;    

% this bayesian model fits a single parameter
par_names{1}='likelihood_normal_distribution';
prmtn=length(par_names);

%% pre-allocate result storage
subj = cell(n_subjects,1);
likely1 = cell(n_subjects,1);
likely2 = cell(n_subjects,1);
for i=1:n_subjects 
    subj{i,1} = subdirs(i).name;
    % likely1 will accumulate error measure (probability)
    likely1{i}=zeros(n_iter,n_blocks);
    % likely2 will accumulate negative log likelihood log(probability)
    likely2{i}=zeros(n_iter,n_blocks);
end
% best_set will store the best-fitting parameter
best_set=zeros(n_subjects,prmtn*2+2);

IDs = cell(n_subjects,1);
all_data = cell(n_subjects,1);
parameters = cell(n_subjects,1);

sum_likely1 = cell(n_subjects,1);
sum_likely2 = cell(n_subjects,1);

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

    % subject pid
    IDs{agent,1}=subj{agent}(1:(end-4));
    % load real choice selections
    all_data{agent,1}=DATA.data;

    for iter=1:n_iter
        
        choice_selections=0;
        errors=zeros(n_iter,n_blocks);

        % sample parameter from [1/3, 1]
        parameters{agent}(iter,1)=rand(1)*2/3+1/3;
        % store the random parameter for this iteration
        lambda1=parameters{agent}(iter,1);

        % pond prior
        pondp = cell(n_blocks,1);
        
        % construct choice matrix
        m=lambda1;    
        s=(1-lambda1)/2;
        fishp=[0 1 1
               1 0 1
               1 1 0]*s + eye(3)*m;
        
        % updating posterior and compute likelihood
        for blocki=1:n_blocks
            clear fish_disp
            clear real_choices
            
            % starting prior for each trial in the block
            pondp{blocki}=ones(n_trials,n_fish)/n_fish;
            % the fish that was displayed
            fish_disp=all_data{agent}{blocki}(:,5);
            % the subjects pond choice
            real_choices=all_data{agent}{blocki}(:,1);

            for triali=start_trial:length(fish_disp)
                
                % retrieve prior
                if triali==start_trial
                    prob=pondp{blocki}(triali,:);
                else
                    prob=pondp{blocki}(triali-1,:);
                end

                % Bayesian update
                % denominator: sum(prior x likelihood)
                den=sum(prob.*fishp(fish_disp(triali),:));
                % posterior: prior x likelihood / denominator
                pondp{blocki}(triali,:)=(fishp(fish_disp(triali),:).*prob)/den;

                % distro: a local copy of pondp before any boundary
                % limits/normalization
                distro=pondp{blocki}(triali,:);
                
                % bound each posterior by 0.05 then normalize
                pondp{blocki}(triali,:)=max(0.05, pondp{blocki}(triali,:));
                pondp{blocki}(triali,:)=pondp{blocki}(triali,:)/sum(pondp{blocki}(triali,:));


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

                if max(pondp{blocki}(triali,:))==0.05
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
filename = [day '_3fish_BI_1_' group '.mat'];
save(filename, 'best_set', 'mean_bs', 'std_bs', 'par_names', 'all_data','IDs');

figure
scatter(ones(length(best_set(:,1)),1),best_set(:,1))
hold on
scatter(ones(length(best_set(:,1)),1)+1,best_set(:,3))
axis([0 3 0 1.1])
