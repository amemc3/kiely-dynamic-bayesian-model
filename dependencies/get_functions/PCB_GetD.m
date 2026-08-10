%% PCB_GetD
% This function generates D - a data table of all the survey outcomes
% from the prolific questionaire

% Adapted from TT_GetD - Does not include BDD

function D = PCB_GetD(filename)

% Specify the path to your CSV file
if isempty(filename)
    filename = 'C:\Users\amcla\Documents\Neuroscience\Fiore\SPICE\2024-08-08_MainQuest.csv';
end

% Read the CSV file into a table
data = readtable(filename);

%% clean data
% % ensure PID standard format
goodFormat = ones(length(data.prolific_pid),1);
for i = 1:length(data.prolific_pid)
    % Remove leading spaces from each ID in the cell array
    data.prolific_pid{i} = strtrim(data.prolific_pid{i});
    % Remove extra symbols
    if size(data.prolific_pid{i},2)>24
        data.prolific_pid{i} = data.prolific_pid{i}(1:24);
    end
    % change faulty PID
    if strcmp(data.prolific_pid{i}, 'ACVEFRSUAPSEQ')
        data.prolific_pid{i} = '576017836442fa0006cfb7cd';
    end
    % indicate if PID is still out of format
    if size(data.prolific_pid{i},2)<24
        goodFormat(i) = 0;
    end
end

%% exclude survey NaNs
rowsWithNaNs = isnan(data.cannabis_check) | isnan(data.gambling) | isnan(data.oci1) | isnan(data.alc_check)...
    | isnan(data.cesd_1) | isnan(data.bis11_10r_nonplan_cogcmplx) | isnan(data.nic_check)...
    | isnan(data.ede_q_6_1) | isnan(data.video_game_use) | isnan(data.sc_tot_score) | isnan(data.social_media_use);
% exclude attention check fails
rowsWithFailedAC = data.attention_check_1 ~= 1 | data.attn_check_2 ~= 1 | data.attention_check3 ~= 3;
% exclude incorrect PIDs
D = data(~rowsWithNaNs & ~rowsWithFailedAC & goodFormat,:);

%% score each survey
% Cannabis
D.CUDIT_score = D.cudit_score;
D.CUDIT_score(isnan(D.CUDIT_score)) = 0;

% Gambling
D.GSAS_score = D.gsas_calc;
D.GSAS_score(isnan(D.GSAS_score)) = 0;

% OCD
ociVars = D.Properties.VariableNames(contains(D.Properties.VariableNames, 'oci'));
ociVars = ociVars(2:19);
ociData = D{:, ociVars};

D.OCI_score = sum(ociData, 2);
D.OCI_score(isnan(D.OCI_score)) = 0;

% Depression
D.CESD_score = D.cesd_score;
D.CESD_score(isnan(D.CESD_score)) = 0;

% Anxiety
D.GAD_score = D.sc_tot_score;
D.GAD_score(isnan(D.GAD_score)) = 0;

% Impulsivity
bisVars = D.Properties.VariableNames(contains(D.Properties.VariableNames, 'bis'));
reverseVars = [bisVars(3), bisVars(9:12), bisVars(14:15), bisVars(17), bisVars(22), bisVars(31)];
bisVars = [bisVars(4:8), bisVars(13), bisVars(16),bisVars(18:21), bisVars(23:30), bisVars(32)];
bisData = D{:, bisVars};
reverseData = D{:, reverseVars};
lookup = [4 3 2 1];
flippedData = lookup(reverseData);
bisData = [bisData, flippedData];

D.BIS_score = sum(bisData, 2);
D.BIS_score(isnan(D.BIS_score)) = 0;

% Alcohol
alcVars = D.Properties.VariableNames(contains(D.Properties.VariableNames, 'audit'));
alcVars = alcVars(2:11);
alcData = D{:, alcVars};

D.AUDIT_score = sum(alcData, 2);
D.AUDIT_score(isnan(D.AUDIT_score)) = 0;

% Nicotine
D.FTCD_score = D.ftcd_score;
D.FTCD_score(isnan(D.FTCD_score)) = 0;

% Eating Disorder
edVars = D.Properties.VariableNames(contains(D.Properties.VariableNames, 'ede'));
edVars = edVars(2:29);
edData = D{:, edVars};

D.edRestraint = mean(edData(:,1:5),2);
D.edEating = mean([edData(:,7), edData(:,9), edData(:,19), edData(:,20), edData(:,21)],2);
D.edShape = mean([edData(:,6), edData(:,8), edData(:,10), edData(:,11), edData(:,23), edData(:,26:28)],2);
D.edWeight = mean([edData(:,8), edData(:,12), edData(:,22), edData(:,24:25)],2);

D.EDEQ_score = mean([D.edRestraint, D.edEating, D.edShape, D.edWeight],2);
D.EDEQ_score(isnan(D.EDEQ_score)) = 0;

% Video Games
vgVars = D.Properties.VariableNames(contains(D.Properties.VariableNames, 'vg'));
vgVars = vgVars(2:7);
vgData = D{:, vgVars};

D.VGAQ_score = sum(vgData, 2);
D.VGAQ_score(isnan(D.VGAQ_score)) = 0;
D.VGAQ_score = D.VGAQ_score/6;

% Social Media
smVars = D.Properties.VariableNames(contains(D.Properties.VariableNames, 'sm'));
smVars = smVars(8:13);
smData = D{:, smVars};

D.SMAQ_score = sum(smData, 2);
D.SMAQ_score(isnan(D.SMAQ_score)) = 0;
D.SMAQ_score = D.SMAQ_score/6;

% Binge Eating
D.BE_episodes = D.ede_q_6_14;

%% BDD - Not included in PCB study 
% BDD = [D.bdd_1, D.bdd_2, D.bdd_3, D.bdd_4, D.bdd_5, D.bdd_6, D.bdd_7];
% D.BDD_score = nansum(BDD,2);
% for iS = 1:length(BDD)
%     if isnan(D.bdd(iS))
%         D.BDD_score(iS,1) = nan;
%     end
% end

%% Healthy control IDs
D.isControl = D.GAD_score <5 & D.CESD_score <10 & D.OCI_score <21 ...
    & D.AUDIT_score <8 & D.FTCD_score <1 & D.CUDIT_score <1 ...
    & D.BE_episodes <4 & D.GSAS_score <9 & D.VGAQ_score <=2 & D.SMAQ_score <=2;

D.isDiagnostic = D.GAD_score >9 | D.CESD_score >9 | D.OCI_score >20 ...
    | D.AUDIT_score >13 | D.FTCD_score >=3 | D.CUDIT_score >11 ...
    | D.BE_episodes >3 | D.GSAS_score >20 | D.VGAQ_score >2 | D.SMAQ_score >2;
end
