%% PCB_Model_2Fish_BI_1
% Adapted from Fiore bayes_main (3fish version)
% This script runs a standard bayesian model on the 2 fish task.
% It generates a .mat file (2fish_BI_S1_group.mat) containing the 
% best_set (nsx4) matrix of the likelihood_normal_distribution parameter
% associated with the linear (:,1) and log (:,3). Typically, we use the
% log (:,3) parameter for visualizing the dynamic curve.
% the error associated with each are on the adjacent columns

% takes group as an input for file saving. eg ('HC')
function PCB_Model_2fish_BI_1(data_folder, root_folder, day, group)

cd (data_folder)

subdirs = dir('*.mat');
n_subjects=length(subdirs);

% number of parameters to test
n_iter=1000;                                                  

n_fish=2;
n_trials=15;
start_trial=1;
n_blocks=10;     

par_names{1}='likelihood_normal_distribution';
prmtn=length(par_names);

%% get subject list
for i=1:n_subjects 
    subj{i,1} = subdirs(i).name;
    likely1{i}=zeros(n_iter,n_blocks);
    likely2{i}=zeros(n_iter,n_blocks);
end

best_set=zeros(n_subjects,prmtn*2+2);

tic
for agent=1:n_subjects
    cd (data_folder) % added not sure if needed
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
        % parameter range set [0.5, 1]
        parameters{agent}(iter,1)=rand(1)*1/2+1/2;
        lambda1=parameters{agent}(iter,1);
        
        m=lambda1;    
        s=1-lambda1;
        fishp=[0 1; 1 0]*s + eye(2)*m;
        
        for blocki=1:n_blocks
            clear fish_disp
            clear real_choices
            
            pondp{blocki}=ones(n_trials,n_fish)/n_fish;
            fish_disp=all_data{agent}{blocki}(:,5);
            real_choices=all_data{agent}{blocki}(:,1);

            for triali=start_trial:length(fish_disp)
                
                if triali==start_trial
                    prob=pondp{blocki}(triali,:);
                else
                    prob=pondp{blocki}(triali-1,:);
                end
                %Bayesian update
                den=sum(prob.*fishp(fish_disp(triali),:));
                pondp{blocki}(triali,:)=(fishp(fish_disp(triali),:).*prob)/den;

                distro=pondp{blocki}(triali,:);
                
                pondp{blocki}(triali,:)=max(0.05, pondp{blocki}(triali,:));
                pondp{blocki}(triali,:)=pondp{blocki}(triali,:)/sum(pondp{blocki}(triali,:));


                %comparison
                if real_choices(triali)>0
                    choice_selections=choice_selections+1;

                    errors(iter,blocki)= 1-distro(real_choices(triali));
                    likely1{agent}(iter,blocki)=likely1{agent}(iter,blocki)+ errors(iter,blocki);
                    likely2{agent}(iter,blocki)=likely2{agent}(iter,blocki)+ min(3, abs(log(distro(real_choices(triali)))));                    
                end

                if max(pondp{blocki}(triali,:))==0.05
                    error ('check')
                end

            end
        end
    end
    sum_likely1{agent}=sum(likely1{agent},2);
    sum_likely2{agent}=sum(likely2{agent},2);
    [val1, pos1]=min(sum_likely1{agent});
    [val2, pos2]=min(sum_likely2{agent});
    
    best_set(agent,1:prmtn)=parameters{agent}(pos1,:);
    best_set(agent,prmtn+1)=val1*100/choice_selections;
    best_set(agent,(prmtn+2):(prmtn*2+1))=parameters{agent}(pos2,:);
    best_set(agent,prmtn*2+2)=val2;
    
    disp(best_set(agent,:));
    % cd(root_folder)
    % save('partial_fish_optimization', 'best_set');
end

mean_bs=mean(best_set(1:n_subjects,:));
std_bs=std(best_set(1:n_subjects,:));

cd (root_folder)
filename = [day '_2fish_BI_1_' group '.mat'];
save(filename, 'best_set', 'mean_bs', 'std_bs', 'par_names', 'all_data','IDs');

figure
scatter(ones(length(best_set(:,1)),1),best_set(:,1))
hold on
scatter(ones(length(best_set(:,1)),1)+1,best_set(:,3))
axis([0 3 0 1.1])
