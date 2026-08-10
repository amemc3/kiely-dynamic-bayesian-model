%% PCB_Show_SimpleCurve
% This function generates a shadded error line plot of the choice dynamics 
% based off the best set for each task. group (slot3, fish3, slot2, fish2)
% determines the figure color.
% and allLines is true (if you want to display each subject's line) or 
% false (if you just want the average line).

function [x,Y] = PCB_Show_SimpleCurve(pars, cols, Ltype)

% group colors 

% Example teal (upset vertical bar color and example descending curve)
Eteal = [66,182,195]./255;

% Ascending majenta
Majenta = [0.95 0.45 0.95];

% fish3
fishC = [0.0902    0.5294    0.4588]; %dark teal
% slot3
slotC = [0.7686    0.1529    0.3490]; %raspberry
% slot2
slot2C = [0.8612    0.4917    0.6094]; %light raspberry
% fish2
fish2C = [0.4541    0.7176    0.6753]; %light teal

% pars = 'alpha shape', 'beta shape', 'threshold1','threshold2'
ns=length(pars(:,1));
% creates a vector of 1000 points (0.001) between 0 and 1
x=0:0.001:1;

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

Y = y;
% stdE = std(y)/sqrt(ns);

% shadedErrorBar(x,Y,stdE,'lineProps',{'color',cols,'lineWidth',2},'patchSaturation',0.4,'transparent',true)
if strcmp(Ltype,'dash')
    plot(x,Y,'Color',cols,'LineWidth',2,'LineStyle','-.')
elseif strcmp(Ltype,'bold')
    plot(x,Y,'Color',cols,'LineWidth',3)
else
    plot(x,Y,'Color',cols,'LineWidth',2)
end
ylim([0.3,1])
% title('Association Strength','FontSize',20)

xticks([0 1])
% xticklabels([0.5 0.75 1])
yticks([0.3 1])
% xticklabels({'',''})
yticklabels({'1/N','1'})

xlabel('Confidence Index')
ylabel(['\lambda'])