%% PCB_Model_Wrapper_BI_D4_sm
% this is the wrapper function which runs the 
% dynamic bayesian model (BI_D4) for a given task

% uses softmax

function PCB_Model_Wrapper_BI_D4_sm(data_folder, root_folder, day, group, task)

cd (data_folder)

% structure with .mat file information
subdirs = dir('*.mat');
% number of subjects
n_subjects=length(subdirs);

mxb=25; %max value for Alpha and Beta      

par_names{1}='alpha shape';
par_names{2}='beta shape';
par_names{3}='range_u';
par_names{4}='range_c';

prmtn=length(par_names);

%% preallocate
subj = cell(n_subjects,1);
best_set = nan(n_subjects,prmtn*2+2);
IDs=cell(n_subjects,1);
all_data=cell(n_subjects,1);
all_t_data=cell(n_subjects,1);
all_cond3=cell(n_subjects,1);

for i=1:n_subjects 
    subj{i,1} = subdirs(i).name;
end

tic
for agent=1:n_subjects
    cd (data_folder)
    clear data
    clear t_data
    clear cond2
    disp(agent);
    toc
    %load data series per each agent
    % cond is a matlab function - need to load DATA so we can interact with
    % cond as a structure variable - AEM
    DATA = load(subj{agent});
    IDs{agent,1}=subj{agent}(1:(end-4));

    %load real choice selections
    all_data{agent,1}=DATA.data;
    all_t_data{agent,1}=DATA.t_data;
    all_cond3{agent,1}=DATA.cond;
    
    % Create the dynamic function name
    funcName = ['PCB_fmin_function_', task, '_BI_D4_SMx'];
    
    % Create function handle dynamically
    fminsearch_function = str2func(funcName);
    
    % replaced with AEM version of bayes_function
    [lambdalin,fvalin] = fminsearch(@(pars) fminsearch_function(pars, DATA.data, mxb,'lin'), [5 5 0.8 0.8]);%[best_set(agent,1:4)]);
    [lambdalog,fvalog] = fminsearch(@(pars) fminsearch_function(pars, DATA.data, mxb,'log'), [5 5 0.8 0.8]);%[best_set(agent,6:9)]);

    best_set(agent,1:prmtn)=lambdalin;
    best_set(agent,prmtn+1)=fvalin;
    best_set(agent,(prmtn+2):(prmtn*2+1))=lambdalog;
    best_set(agent,prmtn*2+2)=fvalog;
    
    disp(best_set(agent,:));
end

mean_bs=mean(best_set(1:n_subjects,:));
std_bs=std(best_set(1:n_subjects,:));

cd(root_folder)
filename = [day '_' task '_BI_D4_sm_' group '.mat'];
save(filename, 'best_set', 'mean_bs', 'std_bs', 'par_names',...
    'all_data', 'all_t_data', 'all_cond3', 'IDs');


% figure
% scatter(ones(length(best_set(:,1)),1),best_set(:,1))
% hold on
% scatter(ones(length(best_set(:,1)),1)+0.1,best_set(:,2))
% scatter(ones(length(best_set(:,1)),1)+0.2,best_set(:,3))
% scatter(ones(length(best_set(:,1)),1)+0.3,best_set(:,4))
% 
% scatter(ones(length(best_set(:,1)),1)+1,best_set(:,6))
% scatter(ones(length(best_set(:,1)),1)+1.1,best_set(:,7))
% scatter(ones(length(best_set(:,1)),1)+1.2,best_set(:,8))
% scatter(ones(length(best_set(:,1)),1)+1.3,best_set(:,9))
end

