%% PCB_Simulation_Wrapper
% this is the wrapper function which simulates behavior based on a
% given model for a given task

% type OG = original exact parameters from real data
% type CM = NS =100 for confusion matrix

function PCB_Simulation_Wrapper(finalFolder, realData, task, model, type)

% create folder for simulated data with NS subjects
% name: generate "PID" = modelcode_number (BID4_001.mat)
% data: nBx1 cell
% t_data: just copy data
% cond: block order = [6 7 8 1 2 4 3 9 5 10] & 'actual' pars [alpha beta ru rc]
processedData = 'C:\Users\amcla\Documents\Neuroscience\Fiore\Projects\PLOS_CB\Processed_Data';
cd(processedData)
load(realData,'best_set')

% length of Best_set
BS = size(best_set,1);

% make sure final folder exists
if ~isfolder(finalFolder)
    mkdir(finalFolder);
end

% Create the dynamic function name
funcName = ['PCB_simulation_', task, '_',model];
% Create function handle dynamically
simulation_function = str2func(funcName);

%%
sim_count = 1001;
for iS = 1:BS
    % generate "PID"
    simcount = num2str(sim_count);
    name = [model,'_',simcount,'.mat'];

    % get real parameters from best_set
    if strcmp(model,'BI_D4')
        pars = best_set(iS,6:9);
    else
        pars = best_set(iS,3);
    end

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

if strcmp(type, 'CM')
    NS = 100;
    % additional subjects
    AS = NS - BS;
    for iS = 1:AS
        % generate "PID"
        simcount = num2str(sim_count);
        name = [model,'_',simcount,'.mat'];
        
        % randomly select a real parameter set from best_set
        iR = randi([1, BS]);
        if strcmp(model,'BI_D4')
            pars = best_set(iR,6:9);
        else
            pars = best_set(iR,3);
        end
        % alter parameters within +-10% 
        for iP = 1:length(pars)
            % random percent between -0.1 - 0.1
            change = (rand * 0.1) * 2 - 0.1;
            pars(iP) = pars(iP) * (1 + change);
        end

        % ensure new parameter is still within parameter ranges
        if strcmp(model,'BI_D4')
            for iP = 1:4
                % for alpha and beta [0:25]
                if iP < 3
                    if pars(iP) > 25
                        change = (rand * 0.1); % random percent between 0 - 0.1
                        pars(iP) = 25 *(1 - change);
                    elseif pars(iP) < 0
                        change = (rand * 0.1); % random number between 0 - 0.1
                        pars(iP) = change;
                    else
                    end
                % for ru and rc [1/3:1]    
                else
                    if pars(iP) > 1
                        change = (rand * 0.1); % random percent between 0 - 0.1
                        pars(iP) = 1 - change;
                    elseif pars(iP) < 1/3
                        change = (rand * 0.1); % random number between 0 - 0.1
                        pars(iP) = 1/3 * (1+change);
                    else
                    end
                end
            end
        % for all other models, ensure h [0:1]    
        else
            if pars > 1
                change = (rand * 0.1); % random percent between 0 - 0.1
                pars = 1 - change;
            elseif pars < 0
                change = (rand * 0.1); % random number between 0 - 0.1
                pars = change;
            end
        end

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
end



