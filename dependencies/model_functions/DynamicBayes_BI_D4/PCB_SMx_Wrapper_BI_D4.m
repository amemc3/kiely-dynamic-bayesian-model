%% PCB_SMx_Wrapper_BI_D4
% this is the wrapper function which re-generates sum_likely for given
% best_set parameters using softmax filter

function PCB_SMx_Wrapper_BI_D4(data_file, root_folder, data_folder, day, group, task, tau)

% raw behavior files
cd (data_folder)

% structure with .mat file information
subdirs = dir('*.mat');
% number of subjects
n_subjects=length(subdirs);

cd (root_folder)
% pre-determined best_set
load(data_file, 'best_set')
% best_set pars for all subjects
PARS = best_set(:,6:9);

mxb=25; %max value for Alpha and Beta      

% Create the dynamic function name
funcName = ['PCB_fmin_function_', task, '_BI_D4_SMx'];
% Create function handle dynamically
fminsearch_function = str2func(funcName);

subj = cell(n_subjects,1);
for i=1:n_subjects 
    subj{i,1} = subdirs(i).name;
end

for agent=1:n_subjects
    cd (data_folder)
    clear data

    disp(agent);
    toc
    % load data series per each agent
    DATA = load(subj{agent});
    pars = PARS(agent,:);
    
    % sum_likely for each subject's best_set parameters
    best_set(agent,5) = fminsearch_function(pars, DATA.data, mxb,'lin', tau);
    best_set(agent,10) = fminsearch_function(pars, DATA.data, mxb,'log', tau);    
    disp(best_set(agent,:));
end

cd(root_folder)
filename = [day '_' task '_BI_D4_sm_' group '.mat'];
save(filename, 'best_set');
end

