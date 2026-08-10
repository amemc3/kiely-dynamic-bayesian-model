% PCB_bayes_function_3slot_H_1
function sum_likely = PCB_fmin_function_3slot_H_1_SMx(pars, data, upperbound, linlog, tau)

h=pars(1);

% task structure information
n_blocks=10;
n_slots=3;
n_trials=length(data{1}(:,1));
start_trial=2;

choice_selections=0;

% pre-allocate result storage
likely=zeros(1,n_blocks);
errors=zeros(1,n_blocks);
slotp = cell(n_blocks,1);

if h>=upperbound || h<= 0
    likely=ones(1,n_blocks)*1000;
else

    for blocki=1:n_blocks
        clear real_choices
        clear outcomes
        % starting prior for each trial in the block
        slotp{blocki}=ones(n_trials,n_slots)/n_slots;

        % the reward that was displayed
        outcomes = data{blocki}(:,2);
        % the subjects slot choice
        real_choices=data{blocki}(:,1);

        for triali=start_trial:length(outcomes)

            % retrieve prior
            prob=slotp{blocki}(triali-1,:);

            %% Heuristic update
            if real_choices(triali-1) == 1
                if outcomes(triali-1) == 100 % if win
                    slotp{blocki}(triali,1) = prob(1)+h;
                    slotp{blocki}(triali,2) = prob(2)-h/2;
                    slotp{blocki}(triali,3) = prob(3)-h/2;
                elseif outcomes(triali-1) == 10 || outcomes(triali-1) == 0 % if loss
                    slotp{blocki}(triali,1) = prob(1)-h;
                    slotp{blocki}(triali,2) = prob(2)+h/2;
                    slotp{blocki}(triali,3) = prob(3)+h/2;
                end
            elseif real_choices(triali-1) == 2
                if outcomes(triali-1) == 100 % if win
                    slotp{blocki}(triali,1) = prob(1)-h/2;
                    slotp{blocki}(triali,2) = prob(2)+h;
                    slotp{blocki}(triali,3) = prob(3)-h/2;
                elseif outcomes(triali-1) == 10 || outcomes(triali-1) == 0 % if loss
                    slotp{blocki}(triali,1) = prob(1)+h/2;
                    slotp{blocki}(triali,2) = prob(2)-h;
                    slotp{blocki}(triali,3) = prob(3)+h/2;
                end
            elseif real_choices(triali-1) == 3
                if outcomes(triali-1) == 100 % if win
                    slotp{blocki}(triali,1) = prob(1)-h/2;
                    slotp{blocki}(triali,2) = prob(2)-h/2;
                    slotp{blocki}(triali,3) = prob(3)+h;
                elseif outcomes(triali-1) == 10 || outcomes(triali-1) == 0 % if loss
                    slotp{blocki}(triali,1) = prob(1)+h/2;
                    slotp{blocki}(triali,2) = prob(2)+h/2;
                    slotp{blocki}(triali,3) = prob(3)-h;
                end
            else
                slotp{blocki}(triali,:)=(prob + ones(1,3)/3)/2;
            end
            
            % 2025/09 update: implement [0,1] pondp range & normalize
            % before distro
            slotp{blocki}(triali,:) = max(0, min(1,slotp{blocki}(triali,:)));            
            slotp{blocki}(triali,:)=slotp{blocki}(triali,:)/sum(slotp{blocki}(triali,:));
            
            % softmax 2.0
            distro= exp(slotp{blocki}(triali,:)/tau)/sum(exp(slotp{blocki}(triali,:)/tau));

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

            if max(slotp{blocki}(triali,:))==0.05
                error ('check')
            end
        end
    end
end
sum_likely=sum(likely);