%% PCB_Show_ParameterComp
% compares parameters of the same subjects on different tasks
function PCB_Show_ParameterComp(best_set1, best_set2, task1, task2,par, colors)

% color
if strcmp(colors,'teal')
    col = [0.0902    0.5294    0.4588]; %dark teal
else
    col = [0.7686    0.1529    0.3490]; %raspberry
end

if strcmp(par,'alpha')
    nP = 6;
    yL = 0;
    yH = 25;
    yd = 1;
    XT = [1,2];
elseif strcmp(par,'beta')
    nP = 7;
    yL = 0;
    yH = 25;
    yd = 1;
    XT = [1,2];
elseif strcmp(par,'ru')
    nP = 8;
    yL = 0;
    yH = 1;
    yd = .1;
    XT = [1,2];
elseif strcmp(par,'rc')
    nP = 9;
    yL = 0;
    yH = 1;
    yd = .1;
    XT = [1,2];
elseif strcmp(par, 'h')
    nP = 3;
    yL = 0;
    yH = 1;
    yd = .1;
    XT = [1,2];
end

ns = length(best_set1);

patchSaturation = 0.4;
patchC = col + (1-col) * (1-patchSaturation);


Y = [best_set1(:,nP),best_set2(:,nP)];
x = [ones(ns,1), ones(ns,1)*2];
patchColor = [patchC;patchC];
parlabs = {task1,task2};

bp = boxplot(Y,"Colors",'k');
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
s = swarmchart(x,Y,'MarkerEdgeColor',[1 1 1]);

s(1).LineWidth = 1;
s(1).SizeData = 30;
s(1).XJitterWidth = 0.1;
s(1).MarkerFaceColor = col;

s(2).LineWidth = 1;
s(2).SizeData = 30;
s(2).XJitterWidth = 0.1;
s(2).MarkerFaceColor = col;



% plot subject lines
for iS = 1:length(Y)
    plot(Y(iS,:),'Color',col,'LineWidth',0.25)
end

xticks(XT)
xticklabels(parlabs)
ylim([yL-yd,yH+yd])
yticks([yL yH])
title(par,'FontSize',16);
