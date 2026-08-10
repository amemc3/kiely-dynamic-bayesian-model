
function P = PCB_Get_percents(best_set, all_data, percent)

switch percent
    case 'Pcorrect'
        P = zeros(length(best_set),1);
        for iS = 30:length(best_set)
            data = all_data{iS};
            pcb = zeros(10,1);
            for iB = 1:10
                d = data{iB};
                pct = zeros(15,1);
                for iT = 1:15
                    % choice column (slot 1 = column 3, slot 2 = column 4, slot 3 = 5)
                    % 1 = best option, 2  = mid option, 3 = worst option
                    % Cc = choice column: for each trial
                    Cc = d(iT,1) + 2;
                    disp(iB, iT)
                    if d(iT,Cc) == 1
                        pct(iT) = 1;
                    else
                    end
                end
                pcb(iB) = mean(pct);
            end
            P(iS) = mean(pcb);
            disp(iS)
        end
    case 'Pswitch'
        P = zeros(length(best_set),1);
        for iS = 1:length(best_set)
            data = all_data{iS};
            psb = zeros(10,1);
            for iB = 1:10
                d = data{iB};
                pst = zeros(15,1);
                for iT = 2:15
                    if d(iT,1) == d(iT-1,1)
                        pst(iT) = 1;
                    else
                    end
                end
                psb(iB) = mean(pst);
            end
            P(iS) = mean(psb);
        end
end
