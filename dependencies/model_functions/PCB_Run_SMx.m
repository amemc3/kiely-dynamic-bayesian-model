%% PCB_Run_SMx
% This function runs the softmax on a given best_set for (BI_D4, BI_1, H_1) 
% on one or more tasks (3slot, 3fish)
function PCB_Run_SMx(model,tasks,tau)

root_folder = 'C:\Users\amcla\Documents\Neuroscience\Fiore\Projects\PLOS_CB\Processed_Data';
raw_folder = 'C:\Users\amcla\Documents\Neuroscience\Fiore\Projects\PLOS_CB\Raw_Data';

% Create the dynamic function name to call the model wrapper
funcName = ['PCB_SMx_Wrapper_', model];
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
    end
    data_file = ['2025-10-10_',TASK, '_', model, '_HC_F.mat'];
    data_folder = [raw_folder,'\2025-10-10_',TASK,'_HC_F'];
    model_function(data_file, root_folder, data_folder, '2025-10-10', 'HC_F', task, tau)
end
end