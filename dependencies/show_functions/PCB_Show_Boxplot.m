%% PCB_Show_Ttest
% shows boxplot and scatter for data
% data must be a single vector of all data
% groups must be an aligned vecotr of group labels for data
% colors is a 2x3 matrix of colors for the groups
function PCB_Show_Boxplot(data, groups, colors)

yL = 0;
yH = 1;
yd = 0.1;
XT = [1,2];


patchSaturation = 0.4;
patchC1 = colors(1,:) + (1-colors(1,:)) * (1-patchSaturation);
patchC2 = colors(2,:) + (1-colors(2,:)) * (1-patchSaturation);

Y = data;
patchColor = [patchC2;patchC1];

[~, ~, group_idx] = unique(groups);


bp = boxplot(Y,groups,"Colors",'k');
h = findobj(gca,'Tag','Box');
for j=1:length(h)
    patch(get(h(j),'XData'),get(h(j),'YData'),patchColor(j,:),'FaceAlpha',1);
end
set(bp,'LineWidth',1)
% change outliar marker
set(bp,'Marker','.')
set(bp,'MarkerSize',1)
% set(bp,'MarkerEdgeColor',[1 1 1])

% this sends the patches to the back of the graph
set(gca,'children',flipud(get(gca,'children')))

hold on

for i = 1:2
    idx = group_idx == i;
    swarmchart(group_idx(idx), Y(idx), 10,'MarkerEdgeAlpha',0,...
        'MarkerFaceColor', colors(i,:),'MarkerFaceAlpha',0.3,'XJitterWidth',0.25);
end


xticks(XT)
ylim([yL-yd,yH+yd])
yticks([yL yH])





