% PCB_bayes_function_3fish_BI_D4_sm
% BI_D4 with a *choice* softmax used only for likelihood/BIC (posterior recursion unchanged)
function sum_likely = PCB_fmin_function_3fish_BI_D4_sm(pars, data, upperbound, linlog)

alpha = pars(1);
beta  = pars(2);
tau   = 10;          % NEW: decision temperature (like RL/KF)
% (larger tau => more random;  tau>0 )

n_blocks = 10;
n_fish   = 3;
n_trials = length(data{1}(:,1));
start_trial = 1;

choice_selections = 0;

likely = zeros(1,n_blocks);
errors = zeros(1,n_blocks);
pondp  = cell(n_blocks,1);   % will store *posteriors* only (unsoftmaxed)

% ----- basic parameter checks -----
if alpha<=0 || beta<=0 || alpha>=upperbound || beta>=upperbound
    likely = ones(1,n_blocks)*1000;
elseif pars(3) < 1/3 || pars(3) > 1
    likely = ones(1,n_blocks)*1000;
elseif pars(4) < 1/3 || pars(4) > 1
    likely = ones(1,n_blocks)*1000;
else
    % thresholds/direction params as before
    th1 = abs(pars(4)-pars(3));
    th2 = pars(3);
    if pars(4) < pars(3)
        eta = 0;
    else
        eta = 1;
    end

    for blocki = 1:n_blocks
        clear fish_disp
        clear real_choices

        pondp{blocki} = ones(n_trials,n_fish)/n_fish;

        fish_disp   = data{blocki}(:,5);
        real_choices= data{blocki}(:,1);

        for triali = start_trial:length(fish_disp)

            if triali == start_trial
                prob   = pondp{blocki}(triali,:);   % prior (uniform)
                post   = prob;                       % posterior after "virtual" first update
                % ---- choice layer for likelihood only ----
                % softmax over log-beliefs (equivalent to power with 1/tau)
                logits = log(max(1e-12, post)); % numerical safety
                sm     = exp(logits / tau);
                sm     = sm / sum(sm);

                distro = sm;                        % <-- use ONLY for likelihood
                % clamp just for numerical safety in the likelihood
                distro = max(0.05, distro);
                distro = distro / sum(distro);

            else
                % prior for this trial is previous *posterior* (unsoftmaxed)
                prob = pondp{blocki}(triali-1,:);

                % ---------- Bayesian update (unchanged) ----------
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


                % ---------- CHOICE LAYER (for likelihood only) ----------
                % Option A (matches RL form): softmax over log-beliefs with temperature tau
                logits = log(max(1e-12, post));
                sm     = exp(logits / tau);
                sm     = sm / sum(sm);

                % If you'd rather use inverse-temperature beta_smx:
                % beta_smx = 1/tau;
                % sm = post .^ beta_smx; sm = sm / sum(sm);

                distro = sm;   % likelihood-only distribution

                % Clamp and renormalize for numerical stability (likelihood only)
                distro = max(0.05, distro);
                distro = distro / sum(distro);
            end

            % ---------- likelihood accumulation ----------
            if real_choices(triali) > 0
                choice_selections = choice_selections + 1;

                errors(blocki) = 1 - distro(real_choices(triali));

                if strcmp(linlog,'lin')
                    likely(blocki) = likely(blocki) + errors(blocki);
                elseif strcmp(linlog,'log')
                    likely(blocki) = likely(blocki) + min(3, abs(log(distro(real_choices(triali)))));
                end
            end

            % Optional sanity check (on the likelihood distro, not the posterior)
            if max(distro) == 0.05
                error('check')
            end
        end
    end
end

sum_likely = sum(likely);
