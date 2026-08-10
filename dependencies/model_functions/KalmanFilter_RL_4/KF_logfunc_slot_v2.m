function total_log = KF_logfunc_slot_v2(v, s, tau, data)

%% Preallocate data structures
nBlocks = 10;
nTrials = 15;

% Initialize total log
total_log = 0;

% Total reward
total_reward = 110;
%% for loop
for iB = 1:nBlocks
    % Initialize probability vector
    prob_vector = zeros(nTrials,3);
    prob_vector(1,:) = (ones(1,3))/3;
    % Initialize expected reward vector
    expected_reward = zeros(nTrials,3);
    expected_reward(1,:) = (ones(1,3)/3)*110;
    % Initialize log vector
    log_value = zeros(nTrials, 1);
    log_value(1, 1) = abs(log(1/3));
    % Initialize variance vector
    var_vector = zeros(nTrials,3);
    var_vector(1,:) = .5;
    % Initialize k vector
    k = zeros(nTrials,3);
    k(1,:) = .5;
    % Initialize tallies
    % Reward tallies
    T1 = zeros(1,3);
    T2 = zeros(1,3);
    T3 = zeros(1,3);
    % Arm tally
    A = zeros(1,3);
    % Initialize expected values
    E1 = zeros(1,3);
    E2 = zeros(1,3);
    E3 = zeros(1,3);
    % Stastistics
    sigma = zeros(1,3);

    for iT = 1:nTrials
        % Extract user choice current
        user_choice_current = data{iB,1}(iT,1);
        % Extract reward current
        reward_current = data{iB,1}(iT,2);

        % Calculate sigma for kf
        % Create tallies
        % Reward tallies
        if user_choice_current ~= 0
            if reward_current == 100
                T1(user_choice_current) = T1(user_choice_current) + 1;
            elseif reward_current == 10
                T2(user_choice_current) = T2(user_choice_current) + 1;
            elseif reward_current == 0
                T3(user_choice_current) = T3(user_choice_current) + 1;
            end
        end
        % Arm tallies
        if user_choice_current == 1
            A(1) = A(1) + 1;
        elseif user_choice_current == 2
            A(2) = A(2) +1 ;
        elseif user_choice_current == 3
            A(3) = A(3) + 1;
        elseif user_choice_current == 0
            continue;
        end

        % Calculate E
        for i = 1:3
            if A(i) > 0
                E1(i) = T1(i)/A(i);
                E2(i) = T2(i)/A(i);
                E3(i) = T3(i)/A(i);
            end
        end
        
        % Calculate Sigma [E(x^2) - (E(x))^2]
        for i = 1:3
            if A(i) > 0
                % Weighted variance
                sigma(i) = ((1^2)*E1(i)+(2^2)*E2(i)+(3^2)*E3(i)) - ((1)*E1(i)+(2)*E2(i)+(3)*E3(i))^2;
            else
                sigma(i) = .5;
            end
            % Sigma bounds
            sigma(i) = max(0.2, min(sigma(i), 0.8));
        end

        % Extract past data
        if iT ~= 1
            % Extract user choice past
            user_choice = data{iB,1}(iT-1,1);
            % Extract reward past
            reward = data{iB,1}(iT-1,2);
        end

        % Add a "forgetting" drift if no option is selected
        if iT ~= 1 && user_choice == 0
            % Average prior probabilities with initials
            prob_vector(iT,:) = (prob_vector(iT-1,:) + 1/3)/2;
            % Notify
            % disp(subject_list(iS).name);
            % disp('failed to press button');
        elseif iT ~= 1 && user_choice ~= 0

            % setdiff
            other_choices = setdiff(1:3,user_choice);

            % Kalman gain
            k(iT,:) = var_vector(iT-1, :)./(var_vector(iT-1, :) + sigma);

            % update reward
            expected_reward(iT, user_choice) = expected_reward(iT-1, user_choice) + s*k(iT,user_choice).*(reward - expected_reward(iT-1, user_choice));
            expected_reward(iT, other_choices) = expected_reward(iT-1, other_choices) + s*k(iT,other_choices).*((total_reward - reward)/2 - expected_reward(iT-1, other_choices));

            % update variance
            var_vector(iT, :) = (1-k(iT,:)).*(var_vector(iT-1,:)) + v; %%% REVISIT Index two steps back

            % softmax
            prob_vector(iT,:)=(exp(expected_reward(iT,:)/tau))/sum(exp(expected_reward(iT,:)/tau));
            % prob_vector(iT,:) = expected_reward(iT,:)/sum(expected_reward(iT,:));

            % Add a minimum to the probability distribution to prevent
            % optimization methods from getting stuck
            prob_vector(iT,:) = max(0, min(prob_vector(iT,:), 1));
            if any(prob_vector(iT, :) < 0.05)
                prob_vector(iT,:) = max(0.05, prob_vector(iT,:));
            end
            prob_vector(iT,:) = prob_vector(iT,:) / sum(prob_vector(iT,:));

            % Calculate error continued
            if user_choice_current ~= 0
                log_value(iT, 1) = abs(log(prob_vector(iT, user_choice_current)));
            elseif user_choice_current == 0
                log_value(iT, 1) = 0;
            end
        end

        % Store probabilities
        prob_array{iB, 1}(iT,:) = prob_vector(iT,:);
        % Store choices
        choice_array{iB,1}(iT,1) = user_choice_current;
        % Store rewards
        reward_array{iB,1}(iT,1) = reward_current;
        % Store log(prob)
        log_prob{iB,1}(iT,1) = log_value(iT,1);
        % Total log
        total_log = total_log + log_value(iT,1);
    end
end
