%% PCB_simulation_3fish_BI_D4

% Generate a .mat file in the same format as the real subjects

function simData = PCB_simulation_3fish_BI_D4(pars)

% load the simulation environment
cd C:\Users\amcla\MATLAB\PLOS_CB\dependencies\get_functions
load("enviro_3Fish.mat","enviro")


alpha=pars(1);
beta =pars(2);
th1=abs(pars(4)-pars(3));
th2=pars(3);

n_blocks=10;
n_fish=3;
n_trials=15;
start_trial=1;

simData = cell(n_blocks,1);


if pars(4)<pars(3)
    eta=0;
else
    eta=1;
end

for blocki=1:n_blocks
    clear fish_disp
    clear sim_choice

    % probability associated with chosing each pond
    pondp=ones(n_trials,n_fish)/n_fish;

    fish_disp=enviro{blocki}(:,1);
    sim_choice = zeros(n_trials,1);

    for triali=start_trial:length(fish_disp)

        if triali==start_trial
            prob=pondp(triali,:);
            distro=prob;
        else
            prob=pondp(triali-1,:);
        end

        %Bayesian update
        x1=(max(distro)-1/3)*3/2;
        if eta==0
            m=th2-betainc(x1,alpha,beta)*th1; %decreasing
        elseif eta==1
            m=th2+betainc(x1,alpha,beta)*th1; %increasing
        end

        s=(1-m)/2;
        fishpW=[0 1 1
            1 0 1
            1 1 0]*s + eye(3)*m;

        den=sum(prob.*fishpW(fish_disp(triali),:));
        pondp(triali,:)=(fishpW(fish_disp(triali),:).*prob)/den;

        distro=pondp(triali,:);

        pondp(triali,:)=max(0.05, pondp(triali,:));
        pondp(triali,:)=pondp(triali,:)/sum(pondp(triali,:));

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