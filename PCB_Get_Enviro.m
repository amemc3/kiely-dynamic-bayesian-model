%% get 3-Fish Environment
% load sample 3-fish data
cd C:\Users\amcla\Documents\Neuroscience\Fiore\Projects\PLOS_CB\Raw_Data\2024-11-11_3Fish_HC
load("ProlificID_5dd31871c5faa232d3c20365.mat",'data')

% number of blocks
nB = length(data);

% this is the block structure for the 3-fish task
% each cell in enviro is a block.
% each block contains the fish displayed on each of the 15 trials.
enviro = cell(nB,1);

for iB = 1:length(data)
    enviro{iB} = data{iB}(:,5);
end

% save enviro
cd C:\Users\amcla\MATLAB\PLOS_CB\dependencies\get_functions
save('enviro_3Fish.mat','enviro')