% PCB_bayes_function_probs_3fish_BI_D4
function sum_likely = PCB_fmin_function_probs_3fish_BI_D4(pars, data, upperbound, linlog)

alpha=pars(1);
beta =pars(2);

n_blocks=10;
n_fish=3;
n_trials=length(data{1}(:,1));
start_trial=1;

choice_selections=0;

likely=zeros(1,n_blocks);
errors=zeros(1,n_blocks);
pondp = cell(n_blocks,1);

if alpha<=0 || beta<=0 || alpha>=upperbound || beta>=upperbound
    likely=ones(1,n_blocks)*1000;
elseif pars(3)<1/3 || pars(3)>1
    likely=ones(1,n_blocks)*1000;
elseif pars(4)<1/3 || pars(4)>1
    likely=ones(1,n_blocks)*1000;
else

    th1=abs(pars(4)-pars(3));
    th2=pars(3);      
    if pars(4)<pars(3)
        eta=0;
    else
        eta=1;
    end

    for blocki=1:n_blocks
        clear fish_disp
        clear real_probs

        pondp{blocki}=ones(n_trials,n_fish)/n_fish;

        fish_disp=data{blocki}(:,5);
        % real_choices=data{blocki}(:,1);
        real_probs=data{blocki}(:,1:3);

        for triali=start_trial:length(fish_disp)

            if triali==start_trial
                prob=pondp{blocki}(triali,:);
                distro=pondp{blocki}(triali,:);
            else
                prob=pondp{blocki}(triali-1,:);
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
            pondp{blocki}(triali,:)=(fishpW(fish_disp(triali),:).*prob)/den;

            distro=pondp{blocki}(triali,:);

            pondp{blocki}(triali,:)=max(0.05, pondp{blocki}(triali,:));
            pondp{blocki}(triali,:)=pondp{blocki}(triali,:)/sum(pondp{blocki}(triali,:));

            %comparison

            choice_selections=choice_selections+1;

            % errors(blocki)= 1-distro(real_probs(triali));
            % average difference between real probs
            errors(blocki)= sum(abs(distro - real_probs(triali,:)))/3;
            % overall similarity to real probs (a number between 0-1)
            % close to 1 = very similar, close to 0 = very dissimilar
            Osim = 1 - errors(blocki);

            if strcmp(linlog,'lin')
                likely(blocki)=likely(blocki)+ errors(blocki);
            elseif strcmp(linlog,'log')
                likely(blocki)=likely(blocki)+ min(3, abs(log(Osim)));
            end


            if max(pondp{blocki}(triali,:))==0.05
                error ('check')
            end
        end
    end
end

sum_likely=sum(likely);