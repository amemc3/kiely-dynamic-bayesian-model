%% PCB_simulation_probs_3slot_BI_D4

% Generates a .mat file in the same format as real subjects
% for a set of pars

function simData = PCB_simulation_probs_3slot_BI_D4(pars)

% load the simulation environment
cd C:\Users\amcla\MATLAB\PLOS_CB\dependencies\get_functions
load("enviro_3Slot.mat","enviro")

alpha=pars(1);
beta =pars(2);
th1=abs(pars(4)-pars(3));
th2=pars(3);

n_blocks=10;
n_slots=3;
n_trials=15;
start_trial=2;

simData = cell(n_blocks,1);

if pars(4)<pars(3)
    eta=0;
else
    eta=1;
end

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

        %Bayesian update
        x1=(max(distro)-1/3)*3/2;
        if eta==0
            m1=th2-betainc(x1,alpha,beta)*th1;         %decreasing
        elseif eta==1
            m1=th2+betainc(x1,alpha,beta)*th1;         %increasing
        end

        lambda1=m1;
        s1=(1-lambda1)/2;
        m2=s1/(m1*2+s1);
        s2=m1/(m1*2+s1);
        % if outcome was a win
        matW=[0 1 1
            1 0 1
            1 1 0]*s1 + eye(3)*m1;
        % if outcome was a loss
        matL=[0 1 1
            1 0 1
            1 1 0]*s2 + eye(3)*m2;

        %Normal and Bimodal
        
        if outcomes(triali-1)==100
            denN100=sum(prob.*matW(sim_choice(triali-1),:));
            slotp(triali,:)=(matW(sim_choice(triali-1),:).*slotp(triali-1,:))/denN100;
        elseif  outcomes(triali-1)==10
            denN100=sum(prob.*matL(sim_choice(triali-1),:));
            slotp(triali,:)=(matL(sim_choice(triali-1),:).*slotp(triali-1,:))/denN100;
        elseif  outcomes(triali-1)==0
            denN100=sum(prob.*matL(sim_choice(triali-1),:));
            slotp(triali,:)=(matL(sim_choice(triali-1),:).*slotp(triali-1,:))/denN100;
        end

        distro=slotp(triali,:);

        slotp(triali,:)=max(0.05, slotp(triali,:));
        slotp(triali,:)=slotp(triali,:)/sum(slotp(triali,:));

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
    simData{blocki}(:,6:8) = slotp;
end