% PCB_bayes_function_3fish_H_1
function sum_likely = PCB_fmin_function_3fish_H_1(pars, data, upperbound, linlog)

h=pars(1);

% task structure information
n_blocks=10;
n_fish=3;
n_trials=length(data{1}(:,1));
start_trial=1;

choice_selections=0;

% pre-allocate result storage
likely=zeros(1,n_blocks);
errors=zeros(1,n_blocks);
pondp = cell(n_blocks,1);

if h>=upperbound || h<= 0
    likely=ones(1,n_blocks)*1000;
else
    for blocki=1:n_blocks
        clear fish_disp
        clear real_choices

        pondp{blocki}=ones(n_trials,n_fish)/n_fish;

        fish_disp=data{blocki}(:,5);
        real_choices=data{blocki}(:,1);

        for triali=start_trial:length(fish_disp)

            % retrieve prior
            if triali==start_trial
                prob=pondp{blocki}(triali,:);
            else
                prob=pondp{blocki}(triali-1,:);
            end

            %% Heuristic update
            pondp{blocki}(triali,fish_disp(triali))=prob(fish_disp(triali))+h;
            if fish_disp(triali)==1
                pondp{blocki}(triali,2)=prob(2)-h/2;
                pondp{blocki}(triali,3)=prob(3)-h/2;
            elseif fish_disp(triali)==2
                pondp{blocki}(triali,1)=prob(1)-h/2;
                pondp{blocki}(triali,3)=prob(3)-h/2;
            elseif  fish_disp(triali)==3
                pondp{blocki}(triali,1)=prob(1)-h/2;
                pondp{blocki}(triali,2)=prob(2)-h/2;
            end
            
            % 2025/09 update: implement [0,1] pondp range & normalize
            % before distro
            pondp{blocki}(triali,:) = max(0, min(1,pondp{blocki}(triali,:)));
            pondp{blocki}(triali,:)=pondp{blocki}(triali,:)/sum(pondp{blocki}(triali,:));
            %% 
            % distro: a local copy of pondp before any boundary
            % limits/normalization
            distro=pondp{blocki}(triali,:);
            % % bound each posterior by 0.05 then normalize
            % pondp{blocki}(triali,:)=max(0.05, pondp{blocki}(triali,:));
            % pondp{blocki}(triali,:)=pondp{blocki}(triali,:)/sum(pondp{blocki}(triali,:));

            %comparison
            if real_choices(triali)>0
                choice_selections=choice_selections+1;

                % 1 - models probability
                errors(blocki)= 1-distro(real_choices(triali));

                if strcmp(linlog,'lin') % sum of the total error accumulation
                    likely(blocki)=likely(blocki)+ errors(blocki);
                elseif strcmp(linlog,'log') % negative log-likelihood measure (capped at 3)
                    likely(blocki)=likely(blocki)+ min(3, abs(log(distro(real_choices(triali)))));
                end
            end

            if max(pondp{blocki}(triali,:))==0.05
                error ('check')
            end
        end
    end
end
sum_likely=sum(likely);