%% PCB_simulation_3slot_H_1

% Generate a .mat file in the same format as the real subjects

function simData = PCB_simulation_3slot_H_1(pars)

% load the simulation environment
cd C:\Users\amcla\MATLAB\PLOS_CB\dependencies\get_functions
load("enviro_3Slot.mat","enviro")

h=pars(1);

n_blocks=10;
n_slots=3;
n_trials=15;
start_trial=2;

simData = cell(n_blocks,1);


for blocki=1:n_blocks
    clear slotRank
    clear sim_choice
    clear outcomes
    
    % probability associated with chosing each slot
    slotp=ones(n_trials,n_slots)/n_slots;
    
    % for slot_choice (1,2,3) - what is their ranking 
    % [1 = best(100pt), 2 = mid(10pt), 3 = worst (0pt)]
    slotRank=enviro{blocki}(:,3:5);
    sim_choice = zeros(n_trials,1);
    outcomes = zeros(n_trials,1);

    distro=slotp(1,:);
    
    % for the first trial
    % randomly select a slot to start with
    sim_choice(1) = randi([1,3]);
    % create random number between 0-1
    rn = rand;
    % determine outcome based on slotRank
    if slotRank(1,sim_choice(1)) == 1
        if rn <= 0.8
            outcomes(1) = 100;
        elseif rn > 0.8 && rn <= 0.9
            outcomes(1) = 10;
        elseif rn > 0.9
            outcomes(1) = 0;
        end
    elseif slotRank(1,sim_choice(1)) == 2
        if rn <= 0.8
            outcomes(1) = 10;
        elseif rn > 0.8 && rn <= 0.9
            outcomes(1) = 100;
        elseif rn > 0.9
            outcomes(1) = 0;
        end
    elseif slotRank(1,sim_choice(1)) == 3
        if rn <= 0.8
            outcomes(1) = 0;
        elseif rn > 0.8 && rn <= 0.9
            outcomes(1) = 100;
        elseif rn > 0.9
            outcomes(1) = 10;
        end
    end

    for triali=start_trial:n_trials
        
        prob=slotp(triali-1,:);

        %% Heuristic update
        if sim_choice(triali-1) == 1
            if outcomes(triali-1) == 100 % if win
                slotp(triali,1) = prob(1)+h;
                slotp(triali,2) = prob(2)-h/2;
                slotp(triali,3) = prob(3)-h/2;
            elseif outcomes(triali-1) == 10 || outcomes(triali-1) == 0 % if loss
                slotp(triali,1) = prob(1)-h;
                slotp(triali,2) = prob(2)+h/2;
                slotp(triali,3) = prob(3)+h/2;
            end
        elseif sim_choice(triali-1) == 2
            if outcomes(triali-1) == 100 % if win
                slotp(triali,1) = prob(1)-h/2;
                slotp(triali,2) = prob(2)+h;
                slotp(triali,3) = prob(3)-h/2;
            elseif outcomes(triali-1) == 10 || outcomes(triali-1) == 0 % if loss
                slotp(triali,1) = prob(1)+h/2;
                slotp(triali,2) = prob(2)-h;
                slotp(triali,3) = prob(3)+h/2;
            end
        elseif sim_choice(triali-1) == 3
            if outcomes(triali-1) == 100 % if win
                slotp(triali,1) = prob(1)-h/2;
                slotp(triali,2) = prob(2)-h/2;
                slotp(triali,3) = prob(3)+h;
            elseif outcomes(triali-1) == 10 || outcomes(triali-1) == 0 % if loss
                slotp(triali,1) = prob(1)+h/2;
                slotp(triali,2) = prob(2)+h/2;
                slotp(triali,3) = prob(3)-h;
            end
        else
            slotp(triali,:)=(prob + ones(1,3)/3)/2;
        end

        % 2025/09 update: implement [0,1] pondp range & normalize
        % before distro
        slotp(triali,:) = max(0, min(1,slotp(triali,:)));
        slotp(triali,:)=slotp(triali,:)/sum(slotp(triali,:));
        %%
        distro=slotp(triali,:);
        % slotp(triali,:)=max(0.05, slotp(triali,:));
        % slotp(triali,:)=slotp(triali,:)/sum(slotp(triali,:));

        % simulate choice
        % make probabalistic choice based on distro
        A = distro(1);
        B = distro(1)+distro(2);
        % generate random number between 0-1
        rn = rand;
        if rn <= A
            chosen_index = 1;
        elseif rn <= B
            chosen_index = 2;
        elseif rn > B
            chosen_index = 3;
        end
        % save the choice as simulated choice
        sim_choice(triali) = chosen_index;

        % simulate outcome
        % create random number between 0-1
        rn = rand;
        % determine outcome based on slotRank
        if slotRank(triali,sim_choice(triali)) == 1
            if rn <= 0.8
                outcomes(triali) = 100;
            elseif rn > 0.8 && rn <= 0.9
                outcomes(triali) = 10;
            elseif rn > 0.9
                outcomes(triali) = 0;
            end
        elseif slotRank(triali,sim_choice(triali)) == 2
            if rn <= 0.8
                outcomes(triali) = 10;
            elseif rn > 0.8 && rn <= 0.9
                outcomes(triali) = 100;
            elseif rn > 0.9
                outcomes(triali) = 0;
            end
        elseif slotRank(triali,sim_choice(triali)) == 3
            if rn <= 0.8
                outcomes(triali) = 0;
            elseif rn > 0.8 && rn <= 0.9
                outcomes(triali) = 100;
            elseif rn > 0.9
                outcomes(triali) = 10;
            end
        end
    end
    simData{blocki}(:,1) = sim_choice;
    simData{blocki}(:,2) = outcomes;
    simData{blocki}(:,3:5) = slotRank;
end