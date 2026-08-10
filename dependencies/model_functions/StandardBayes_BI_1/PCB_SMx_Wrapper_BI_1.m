%% PCB_SMx_Wrapper_BI_1
% this is the wrapper function which re-generates sum_likely for given
% best_set parameters using softmax filter

function PCB_SMx_Wrapper_BI_1(data_file, root_folder, data_folder, day, group, task, tau)

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
PARS = best_set(:,3);

mxb=1; %max value for h    

% Create the dynamic function name
funcName = ['PCB_fmin_function_', task, '_BI_1_SMx'];
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
    best_set(agent,2) = fminsearch_function(pars, DATA.data, mxb,'lin', tau);
    best_set(agent,4) = fminsearch_function(pars, DATA.data, mxb,'log', tau);    
    disp(best_set(agent,:));
end

cd(root_folder)
filename = [day '_' task '_BI_1_sm_' group '.mat'];
save(filename, 'best_set');
end

