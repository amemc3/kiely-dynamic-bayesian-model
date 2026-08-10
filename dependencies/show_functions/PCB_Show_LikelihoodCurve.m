%% PCB_Show_LikelihoodCurve
% This function generates a shadded error line plot of the choice dynamics 
% based off the best set for each task. group (slot3, fish3, slot2, fish2)
% determines the figure color.
% and allLines is true (if you want to display each subject's line) or 
% false (if you just want the average line).

function [Y,stdE] = PCB_Show_LikelihoodCurve(best_set, group, allLines)

% group colors 

% fish3
fishC = [0.0902    0.5294    0.4588]; %dark teal
% slot3
slotC = [0.7686    0.1529    0.3490]; %raspberry
% slot2
slot2C = [0.8612    0.4917    0.6094]; %light raspberry
% fish2
fish2C = [0.4541    0.7176    0.6753]; %light teal
% orange
orange = [0.9294    0.6941    0.1255]; %orange
% decreasing/increasing
decCol = [0.1 0.1 0.6]; %indigo
incCol = [0.6 0.1 0.1]; %dark red

% pars = 'alpha shape', 'beta shape', 'threshold1','threshold2'
% This is from the log best set on the BI model.
pars=best_set(:,6:9);
ns=length(pars(:,1));
% creates a vector of 1000 points (0.001) between 0 and 1
x=0:0.001:1;

if strcmp(group, 'fish3')
    cols = fishC;
elseif strcmp(group, 'slot3')
    cols = slotC;
elseif strcmp(group, 'fish2')
    cols = fish2C;
elseif strcmp(group, 'slot2')
    cols = slot2C;
elseif strcmp(group, 'Negfish')
    cols = fishC;
elseif strcmp(group, 'Negslot')
    cols = slotC;
elseif strcmp(group, 'orange')
    cols = orange;
elseif strcmp(group, 'dec')
    cols = decCol;
elseif strcmp(group, 'inc')
    cols = incCol;    
else
    cols = [0 0 0];
end

j=1;
while j<=ns
    alpha=pars(j,1);
    beta=pars(j,2);
    th1=abs(pars(j,4)-pars(j,3)); % 'range'
    th2=pars(j,3); % y intercept
    % if the liklihood at x = 1 is > liklihood at x = 0
    if pars(j,4)<pars(j,3)
        eta=0;
    else
        eta=1;
    end

    % This is the incomplete beta function (betainc). it "fills in the
    % gaps" to datapoints in the beta function that describe the
    % relationship between the parameters in our model???    
    if eta==0
        y(j,:)=th2-(betainc(x,alpha,beta)*(th1));   %decreasing
    elseif eta==1
        y(j,:)=th2+(betainc(x,alpha,beta)*(th1));       %growing
    end
%     if min(y(j,:))>1/3 && max(y(j,:))<=1
    j=j+1;
%     end
end

%% plot individual lines
hold on
if allLines
    for j=1:ns
        plot(x,y(j,:), 'Color', cols);
        yhc(j,:)=y(j,:);
    end
else
end

Y = mean(y);
stdE = std(y)/sqrt(ns);
stdD = std(y);

shadedErrorBar(x,Y,stdE,'lineProps',{'color',cols,'lineWidth',3},'patchSaturation',0.4,'transparent',true)
title(group,'FontSize',20)

% xticks([0 0.5 1])
% xticklabels([0.5 0.75 1])
% yticks([0.5 0.75 1])

xlabel('Confidence Index')
ylabel('\lambda')

%% format axes
if strcmp(group, 'fish2') || strcmp(group, 'slot2')
    ylim([0.5 1])
    yticks([0.5 1])
    xlim([0 1])
    xticks([0 1])
else
    ylim([0.33 1])
    yticks([0.33 1])
    xlim([0 1])
    xticks([1])
end


