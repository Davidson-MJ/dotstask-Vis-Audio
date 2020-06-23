% Plot_AccuracybyExpType

%called from JOBS_BehaviouralAnalysis.
%plot bar data (visual vs auditory RTs).

cd(behdatadir)

%preallocate some variables
ExperimentOrder = zeros(length(pfols),1); % auditory or visual first
Accuracy_byAorB = zeros(length(pfols),2); % first and second half


fontsizeX=25;

%separate into Aud and Visual.
cmap = cbrewer('qual', 'Paired',10);
colormap(cmap)
viscolour = cmap(3,:);
audcolour=cmap(9,:);
%plots individual participant level histograms of RT, as well as Bar
%%
for ippant = 1:length(pfols)
    cd(behdatadir);
    cd(pfols(ippant).name);
    
    lfile = dir([pwd filesep '*final' '*']);
    
    load(lfile.name);
    
    clf;
    set(gcf, 'units', 'normalized', 'position', [0 0 .25 .5], 'color', 'w')
    %we need to restrct the trials to only NON practice trials.
    usetrials=alltrials;
    isprac = find([alltrials.isprac]);
    usetrials(isprac)=[];
    
    %store the experiment order for later plots.
    ExpOrder = lower(cfg.stimTypes);
    
    %% plot average accuracy per
    %participant:
    startA = 1;
    endA = cfg.ntrials* cfg.nblocks_partA;
    startB=endA+1;
    endB = length(usetrials);
    
    alltrialsA= [usetrials(startA:endA).cor];
    alltrialsB= [usetrials(startB:endB).cor];
    %%
    Aacc= sum(alltrialsA)./length(alltrialsA);
    Bacc= sum(alltrialsB)./length(alltrialsB);
    
    errorsA = length(alltrialsA) - sum(alltrialsA);
    errorsB = length(alltrialsB) - sum(alltrialsB);
    %%
    bh1=bar([Aacc ,nan]); hold on;
    bh2=bar([nan ,Bacc]);
    if strcmp(ExpOrder{1}, 'visual')
        bh1.FaceColor = viscolour;
        bh2.FaceColor = audcolour;
        ExperimentOrder(ippant) =1;
    else
        bh1.FaceColor = audcolour;
        bh2.FaceColor = viscolour;
        ExperimentOrder(ippant) =2;
    end
    hold on;
    text(0.9, Aacc+.05, ['Nerr = ' num2str(errorsA)])
    text(1.9, Bacc+.05, ['Nerr = ' num2str(errorsB)])
    set(gca, 'xticklabel', {['part A (' ExpOrder{1} ')'], ['part B, (' ExpOrder{2} ')']})
    ylabel('Accuracy');
    title(['Partcipant ' num2str(ippant) ' total accuracy'])
    ylim([0 1])
    %%
    set(gcf, 'color', 'w');
    set(gca, 'fontsize', 16)
    cd(figdir)
    cd('Accuracy plots')
    %%
    print('-dpng', ['Participant ' num2str(ippant) ', accuracy summary'])
    %% store for  across participant averaging:
    Accuracy_byAorB(ippant, :) = [Aacc,Bacc];
    %just look by exp type, sort next into modality.
    
end
%%

% PLOTTING.
%separate into Aud and Visual.


figure(1); clf;
set(gcf, 'units', 'normalized', 'position', [0 0 .3 .5], 'color', 'w')

% sort into modality * by section
partA = Accuracy_byAorB(:,1);
partB = Accuracy_byAorB(:,2);

% first plot all A vs B:
Xdata=[partA,partB];
[a,b]=CousineauSEM(Xdata);

dataX{1} = b(:,1);
dataX{2} = b(:,2);
bh =rm_raincloud(dataX', [cmap(2,:)]);

hold on;
%add plot specs
set(gca, 'yticklabel', {['all part B '], ['all part A']})
title(['Grand average total accuracy'])
xlim([.4 1])
hold on; plot([.5 .5], ylim, 'k:', 'linew', 3)
%
ytsare = get(gca, 'ytick');

text(.45, ytsare(1), ['\it M=\rm' sprintf('%.2f',mean(partB))], 'fontsize', fontsizeX)
text(.45, ytsare(2), ['\it M=\rm' sprintf('%.2f',mean(partA))], 'fontsize', fontsizeX)
set(gcf, 'color', 'w');
set(gca, 'fontsize', fontsizeX)

xlabel('Accuracy')
print('-dpng', ['Grand average accuracy A vs B'])
%% now separate by order

vis_first = find(ExperimentOrder==1);
aud_first = find(ExperimentOrder==2);

partA_vis = partA(vis_first,:);
partA_aud = partA(aud_first,:);

partB_vis = partB(aud_first,:);
partB_aud = partB(vis_first,:);
%%
clf;
set(gcf, 'units', 'normalized', 'position', [0 0 .6 .5], 'color', 'w')

for iorder = 1:2
    if iorder==1
        Xdata=[partA_vis,partB_aud];
        expo = {'visual','auditory'};
    else
        Xdata=[partA_aud,partB_vis];
        expo = {'auditory','visual'};
    end
    
    subplot(1,2, iorder)
    
    [a,b]=CousineauSEM(Xdata);
    
    dataX{1} = b(:,1);
    dataX{2} = b(:,2);
    bh =rm_raincloud(dataX', [cmap(2,:)]);
    
    %add plot specs
    set(gca, 'yticklabel', {['Part B ' expo{2}], ['Part A ' expo{1}]})
    title(['Accuracy when ' expo{1} '-' expo{2}])
    xlim([.4 1])
    hold on; plot([.5 .5], ylim, 'k:', 'linew', 3)
    %
    
    ytsare = get(gca, 'ytick');
    
    text(.45, ytsare(1), ['\it M=\rm' sprintf('%.2f',mean(Xdata(:,2)))], 'fontsize', fontsizeX)
    text(.45, ytsare(2), ['\it M=\rm' sprintf('%.2f',mean(Xdata(:,1)))], 'fontsize', fontsizeX)
    set(gcf, 'color', 'w');
    set(gca, 'fontsize', fontsizeX)
    set(gcf, 'color', 'w');
    set(gca, 'fontsize', fontsizeX)
    
    xlabel('Accuracy')
end

print('-dpng', ['Grand average accuracy split by order type'])

%%



