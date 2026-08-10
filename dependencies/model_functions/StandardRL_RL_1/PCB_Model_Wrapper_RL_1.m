%% PCB_Model_Wrapper_RL_1
% this is the wrapper function which runs the 
% standard RL model (RL_1) for a given task

function PCB_Model_Wrapper_RL_1(data_folder, root_folder, day, group, task)

cd (data_folder)

% structure with .mat file information
subdirs = dir('*.mat');
% number of subjects
n_subjects=length(subdirs);

mxb=1; %max value for alpha 

% this RL model fits a single parameter
par_names{1}='alpha';

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
    funcName = ['PCB_fmin_function_', task, '_RL_1'];
    
    % Create function handle dynamically
    fminsearch_function = str2func(funcName);
    
    % replaced with AEM version of bayes_function
    [lambdalin,fvalin] = fminsearch(@(pars) fminsearch_function(pars, DATA.data, mxb, 'lin'), 0.75);
    [lambdalog,fvalog] = fminsearch(@(pars) fminsearch_function(pars, DATA.data, mxb, 'log'), 0.75);

    best_set(agent,1:prmtn)=lambdalin;
    best_set(agent,prmtn+1)=fvalin;
    best_set(agent,(prmtn+2):(prmtn*2+1))=lambdalog;
    best_set(agent,prmtn*2+2)=fvalog;
    
    disp(best_set(agent,:));
end

mean_bs=mean(best_set(1:n_subjects,:));
std_bs=std(best_set(1:n_subjects,:));

cd(root_folder)
filename = [day '_' task '_RL_1_' group '.mat'];
save(filename, 'best_set', 'mean_bs', 'std_bs', 'par_names',...
    'all_data', 'all_t_data', 'all_cond3', 'IDs');
end

