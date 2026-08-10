%% PCB_Simulation_Wrapper_BI_D4
% this is the wrapper function which simulates behavior based on the 
% dynamic bayesian model (BI_D4) for a given task

function PCB_Simulation_Wrapper_BI_1(finalFolder, realData, task, model)

% create folder for simulated data with NS subjects
% name: generate "PID" = modelcode_number (BID4_001.mat)
% data: nBx1 cell
% t_data: just copy data
% cond: block order = [6 7 8 1 2 4 3 9 5 10] & 'actual' pars [alpha beta ru rc]
processedData = 'C:\Users\amcla\Documents\Neuroscience\Fiore\Projects\PLOS_CB\Processed_Data';
cd(processedData)
load(realData,'best_set')

NS = size(best_set,1);

% make sure final folder exists
if ~isfolder(finalFolder)
    mkdir(finalFolder);
end
%%
sim_count = 1001;
for iS = 1:NS
    % generate "PID"
    simcount = num2str(sim_count);
    name = [model,'_',simcount,'.mat'];
    % % generate random parameter within range
    % % alpha [0 25]
    % pars(1) = round(25 * rand(), 3);
    % % beta [0 25]
    % pars(2) = round(25 * rand(), 3);
    % % ru [1/3 1]
    % pars(3) = round((1/3 + (1 - 1/3) * rand()), 3);
    % % rc [1/3 1]
    % pars(4) = round((1/3 + (1 - 1/3) * rand()), 3);
    
    % get real parameters from best_set
    pars = best_set(iS,6:9);

    % Create the dynamic function name
    funcName = ['PCB_simulation_', task, '_',model];
    % Create function handle dynamically
    simulation_function = str2func(funcName);

    % simulate choice behavior
    data = simulation_function(pars);

    % generate other data to fit real data format
    t_data = data;
    cond = {[6 7 8 1 2 4 3 9 5 10]; pars};

    % save data in same format as real data
    save(fullfile(finalFolder, name),'data','t_data','cond')

    % update counter
    sim_count = sim_count +1;
end
