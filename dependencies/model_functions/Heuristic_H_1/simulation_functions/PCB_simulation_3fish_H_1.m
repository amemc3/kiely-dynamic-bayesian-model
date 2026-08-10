%% PCB_simulation_3fish_BI_D4

% Generate a .mat file in the same format as the real subjects

function simData = PCB_simulation_3fish_H_1(pars)

% load the simulation environment
cd C:\Users\amcla\MATLAB\PLOS_CB\dependencies\get_functions
load("enviro_3Fish.mat","enviro")


h=pars(1);

n_blocks=10;
n_fish=3;
n_trials=15;
start_trial=1;

simData = cell(n_blocks,1);

for blocki=1:n_blocks
    clear fish_disp
    clear sim_choice

    % probability associated with chosing each pond
    pondp=ones(n_trials,n_fish)/n_fish;

    fish_disp=enviro{blocki}(:,1);
    sim_choice = zeros(n_trials,1);

    for triali=start_trial:length(fish_disp)
        
        % retrieve prior
        if triali==start_trial
            prob=pondp(triali,:);
            distro=prob;
        else
            prob=pondp(triali-1,:);
        end

        % Heuristic update
        pondp(triali,fish_disp(triali))=prob(fish_disp(triali))+h;
        if fish_disp(triali)==1
            pondp(triali,2)=prob(2)-h/2;
            pondp(triali,3)=prob(3)-h/2;
        elseif fish_disp(triali)==2
            pondp(triali,1)=prob(1)-h/2;
            pondp(triali,3)=prob(3)-h/2;
        elseif  fish_disp(triali)==3
            pondp(triali,1)=prob(1)-h/2;
            pondp(triali,2)=prob(2)-h/2;
        end

        % 2025/09 update: implement [0,1] pondp range & normalize
        % before distro
        pondp(triali,:) = max(0, min(1,pondp(triali,:)));
        pondp(triali,:)=pondp(triali,:)/sum(pondp(triali,:));
        % distro: a local copy of pondp before any boundary
        % limits/normalization
        distro=pondp(triali,:);
        % % bound each posterior by 0.05 then normalize
        % pondp(triali,:)=max(0.05, pondp(triali,:));
        % pondp(triali,:)=pondp(triali,:)/sum(pondp(triali,:));

        % simulate choice
        % make probabalistic choice based on distro
        A = distro(1);
        B = distro(1)+distro(2);
        % generate random number between 0-1
        rn = rand;
        if rn <= A
            chosen_index = 1;
        elseif rn > A && rn <= B
            chosen_index = 2;
        elseif rn > B
            chosen_index = 3;
        end
        % save the choice as simulated choice
        sim_choice(triali) = chosen_index;
    end
    simData{blocki} = sim_choice;
    simData{blocki,1}(:,5) = fish_disp;
end