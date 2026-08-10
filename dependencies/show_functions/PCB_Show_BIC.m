%% PCB_Show_BIC
% This function shows the BIC scores of all 5 models for a given group 
% on a given task.
% original: use version 1
% updated 10/2025: BIC scores for ALL tasks include softmax - use version 2
function PCB_Show_BIC(date,task,group,version)

% colors
DBIblue = [0.3490 0.7412 1.0000]; % light blue
BIblue = [0 0.4471 0.7412]; % navy
Hpurple = [0.4941 0.1843 0.5569]; % purple
RLKFgreen = [0.6471 0.8118 0.4392]; % light green
RLgreen = [0.2471 0.3882 0.0627]; % dark green

% put colors in reverse order
Cols = [RLgreen;RLKFgreen;Hpurple;BIblue;DBIblue];

% get BIC scores
[bic, aic] = PCB_Get_BIC(date, task, group,'standard',version);

% if version ==1 || version ==2
%     data = bic;
% else
%     data = aic;
% end

data = aic;

% make boxplot
bp = boxplot(data,"Colors","k");
h = findobj(gca,'Tag','Box');
for j=1:length(h)
    patch(get(h(j),'XData'),get(h(j),'YData'),Cols(j,:),'FaceAlpha',.75);
    % change outliar marker
    % h(j).Marker = '.';     % small dot
    % h(j).MarkerSize = 6;   % smaller size (adjust as needed)
    % h(j).MarkerEdgeColor = 'k';  % black
end
set(bp,'LineWidth',2)
set(gca,'children',flipud(get(gca,'children')))
% change outliar marker
set(bp,'Marker','.')
set(bp,'MarkerSize',6)
set(bp,'MarkerEdgeColor','k')

ylim([0,400])
yticks([0 200 400])
xticklabels({'BI_D4', 'BI_1', 'H_1', 'RL_KF1', 'RL_1'})
% if version ==1 || version ==2
%     ylabel('BIC score')
% else
%     ylabel('AIC score')
% end
ylabel('AIC score')
