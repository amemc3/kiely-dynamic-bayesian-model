% PCB_Get_Final
function HC_F = PCB_Get_Final(HC,F)
ns = size(HC,1);
HC_F = HC;

for iS = 1:ns
    PID = HC.PID{iS};
    % Fish3_Task
    if HC.Fish3_Task(iS) == 1
        i = find(strcmp(F.F3F.PID, PID));
        if F.F3F.No_Response(i) == 1 | F.F3F.Color_Following(i) == 1 ...
            | F.F3F.Corrupt_Data(i) == 1
            HC_F.Fish3_Task(iS) = 0;
        end
    end
    % Fish2_Task
    if HC.Fish2_Task(iS) == 1
        i = find(strcmp(F.F2F.PID, PID));
        if F.F2F.No_Response(i) == 1 | F.F2F.Color_Following(i) == 1 ...
            | F.F2F.Corrupt_Data(i) == 1
            HC_F.Fish2_Task(iS) = 0;
        end
    end
    % NegFish3_Task
    if HC.NegFish3_Task(iS) == 1
        i = find(strcmp(F.FNF.PID, PID));
        if F.FNF.No_Response(i) == 1 | F.FNF.Color_Following(i) == 1 ...
            | F.FNF.Corrupt_Data(i) == 1
            HC_F.NegFish3_Task(iS) = 0;
        end
    end
    % Slot3_Task
    if HC.Slot3_Task(iS) == 1
        i = find(strcmp(F.S3F.PID, PID));
        if F.S3F.No_Response(i) == 1 | F.S3F.WSLS(i) == 1
            HC_F.Slot3_Task(iS) = 0;
        end
    end
    % Slot2_Task
    if HC.Slot2_Task(iS) == 1
        i = find(strcmp(F.S2F.PID, PID));
        if F.S2F.No_Response(i) == 1 | F.S2F.WSLS(i) == 1
            HC_F.Slot2_Task(iS) = 0;
        end
    end
    % NegSlot3_Task
    if HC.NegSlot3_Task(iS) == 1
        i = find(strcmp(F.SNF.PID, PID));
        if F.SNF.No_Response(i) == 1 | F.SNF.WSLS(i) == 1 ...
                | strcmp(PID,'667e6da95ae0a25f225ae6e6')
            HC_F.NegSlot3_Task(iS) = 0;
        end
    end
end