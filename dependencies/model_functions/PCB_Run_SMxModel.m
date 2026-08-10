%% PCB_Run_SMxModel
% This function runs the softmax version of a model (BI_D4, BI_1, H_1) on one
% or more tasks (3slot, 3fish)
function PCB_Run_SMxModel(model,tasks)

root_folder = 'C:\Users\amcla\Documents\Neuroscience\Fiore\Projects\PLOS_CB\Processed_Data';
raw_folder = 'C:\Users\amcla\Documents\Neuroscience\Fiore\Projects\PLOS_CB\Raw_Data';

% Create the dynamic function name to call the model wrapper
funcName = ['PCB_Model_Wrapper_', model,'_sm'];
% Create function handle dynamically
model_function = str2func(funcName);

for iT = 1:length(tasks)
    task = tasks{iT};
    switch task
        case '2slot'
            TASK = '2Slot';
        case '3slot'
            TASK  = '3Slot';
        case 'Neg3slot'
            TASK = '3SlotNeg';
        case '2fish'
            TASK = '2Fish';
        case '3fish'
            TASK = '3Fish';
        case 'Neg3fish'
            TASK = '3FishNeg';
        case 'temp_2fish'
            TASK = 'temp_2Fish';
    end
    data_folder = [raw_folder,'\2025-10-10_',TASK,'_HC_F'];
    if strcmp(task,'3fish') && strcmp(model,'RL_KF1')
        PCB_Model_Wrapper_RL_KF2(data_folder, root_folder, '2025-10-29', 'HC_F', task)
    elseif strcmp(task,'temp_2fish')
        model_function(data_folder, root_folder, '2025-10-29', 'HC_F', '2fish')
    else
        model_function(data_folder, root_folder, '2025-10-29', 'HC_F', task)
    end
end
end