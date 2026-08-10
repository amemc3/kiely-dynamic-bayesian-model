% PCB_bayes_function_Neg3slot_BI_D4
function [sum_likely, Xmax, Xchoice] = PCB_fmin_function_Neg3slot_BI_D4(pars, data, upperbound, linlog)

alpha=pars(1);
beta =pars(2);

n_blocks=10;
n_slots=3;
n_trials=length(data{1}(:,1));
start_trial=2;

choice_selections=0;

likely=zeros(1,n_blocks);
errors=zeros(1,n_blocks);
slotp = cell(n_blocks,1);

% 2025-10-10: added for confidence analysis
Xmax = zeros(n_blocks,n_trials);
Xchoice = zeros(n_blocks,n_trials);


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
        clear real_choices
        clear outcomes

        slotp{blocki}=ones(n_trials,n_slots)/n_slots;

        outcomes=data{blocki}(:,2);
        real_choices=data{blocki}(:,1);

        distro=slotp{blocki}(1,:);

        for triali=start_trial:length(real_choices)

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

            prob=slotp{blocki}(triali-1,:);
            %Normal and Bimodal
            if  real_choices(triali-1)>0
                if outcomes(triali-1)==0
                    denN100=sum(prob.*matW(real_choices(triali-1),:));
                    slotp{blocki}(triali,:)=(matW(real_choices(triali-1),:).*slotp{blocki}(triali-1,:))/denN100;
                elseif  outcomes(triali-1)==-90
                    denN100=sum(prob.*matL(real_choices(triali-1),:));
                    slotp{blocki}(triali,:)=(matL(real_choices(triali-1),:).*slotp{blocki}(triali-1,:))/denN100;
                elseif  outcomes(triali-1)==-100
                    denN100=sum(prob.*matL(real_choices(triali-1),:));
                    slotp{blocki}(triali,:)=(matL(real_choices(triali-1),:).*slotp{blocki}(triali-1,:))/denN100;
                end
            else
                slotp{blocki}(triali,:)=(prob + ones(1,3)/3)/2;
            end

            distro=slotp{blocki}(triali,:);
            % 2025-04-07: added for confidence analysis
            Xmax(blocki,triali)=(max(distro)-1/3)*1.5;
            if real_choices(triali) ~= 0
                Xchoice(blocki,triali) = distro(real_choices(triali));
            else
                Xchoice(blocki,triali) =(max(distro)-1/3)*1.5;
            end

            slotp{blocki}(triali,:)=max(0.05, slotp{blocki}(triali,:));
            slotp{blocki}(triali,:)=slotp{blocki}(triali,:)/sum(slotp{blocki}(triali,:));

            %comparison
            if real_choices(triali)>0
                choice_selections=choice_selections+1;

                errors(blocki)= 1-distro(real_choices(triali));

                if strcmp(linlog,'lin')
                    likely(blocki)=likely(blocki)+ errors(blocki);
                elseif strcmp(linlog,'log')
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