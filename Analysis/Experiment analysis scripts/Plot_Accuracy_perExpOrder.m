% Plot_AccuracybyExpType

%called from JOBS_BehaviouralAnalysis.
%plots raincloud distributions of accuracy.
% Plots:
%    PFX    
%    Grand total (all conditions combined).
%    Split by order (V-A, A-V). 

% cd(behdatadir)

jobs=[];

jobs.concat_Acc=1; %prepare for plots.

jobs.plotPFX_Acc =1; % per ppant

jobs.plotGFX_Acc =1 ; %tidy (raincloud) GFX

%preallocate some variables
ExperimentOrder = zeros(length(pfols),1); % auditory or visual first
[Accuracy_byAorB,nErrors_byAorB] = deal(zeros(length(pfols),2)); % first and second half

 pnames = cell(length(pfols),1);

fontsizeX=25;

%separate into Aud and Visual.
cmap = cbrewer('qual', 'Paired',10);
colormap(cmap)
viscolour = cmap(3,:);
audcolour=cmap(9,:);
%plots individual participant level histograms of RT, as well as Bar
%%
cd(behdatadir)

% cd(eegdatadir)
pfols = dir([pwd filesep '*_p*']);
pfols = striphiddenFiles(pfols);
%%
if jobs.concat_Acc
 for ippant = 1:length(pfols)
     
    cd(behdatadir);
    cd(pfols(ippant).name);    
    lfile = dir([pwd filesep '*final' '*']);
    load(lfile.name, 'alltrials', 'subject', 'cfg');
    
%     cd(eegdatadir);
%         cd(pfols(ippant).name);    
%     load('Epoch information', 'BEH_matched');
%     alltrials = BEH_matched; % note that 'alltrials' is also in the behdatadir.

    %use file name for debugging plots
    pname = ['p_' subject.id];
    pnames{ippant} = pname;
    
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
    
     %% store for  across participant averaging:
    Accuracy_byAorB(ippant, :) = [Aacc,Bacc];
    nErrors_byAorB(ippant,:) = [errorsA, errorsB];
    
    %sort next into modality.
    if strcmp(ExpOrder{1}, 'visual')
        ExperimentOrder(ippant) =1;
    else
        ExperimentOrder(ippant) =2;
    end
    
 end

end

%%

if jobs.plotPFX_Acc
for ippant = 1:length(pfols)
    cd(behdatadir);
   
    %use file name for debugging plots
    pname =pnames{ippant};
    
    clf;
    set(gcf, 'units', 'normalized', 'position', [0 0 .25 .5], 'color', 'w')
    %we need to restrct the trials to only NON practice trials.
    
    %% ppant specifics:
    
   Aacc= Accuracy_byAorB(ippant,1);
   Bacc= Accuracy_byAorB(ippant,2);
   errorsA = nErrors_byAorB(ippant,1);
   errorsB = nErrors_byAorB(ippant,2);
   
   
    %% plot
    bh1=bar([Aacc ,nan]); hold on;
    bh2=bar([nan ,Bacc]);
    
    if ExperimentOrder(ippant)==1 % visual -audio
        bh1.FaceColor = viscolour;
        bh2.FaceColor = audcolour;
     printOrder= {'visual', 'auditory'};
    else % auditory= visual
        bh1.FaceColor = audcolour;
        bh2.FaceColor = viscolour;
     printOrder= {'auditory', 'visual'};
    end
    
    hold on;
    text(0.9, Aacc+.05, ['Nerr = ' num2str(errorsA)])
    text(1.9, Bacc+.05, ['Nerr = ' num2str(errorsB)])
    set(gca, 'xticklabel', {['part A (' printOrder{1} ')'], ['part B, (' printOrder{2} ')']})
    ylabel('Accuracy');
    title(['Partcipant ' pname ' total accuracy'], 'Interpreter', 'none')
    ylim([0 1])
    %%
    set(gcf, 'color', 'w');
    set(gca, 'fontsize', 16)
    cd(figdir)
    cd('Accuracy plots')
    %%
    print('-dpng', ['Participant ' num2str(ippant) ', accuracy summary'])
    
end
%%
end

%% PLOTTING. GFX
%separate into Aud and Visual.


%% now separate by order
if jobs.plotGFX_Acc 
% sort into modality * by section
partA = Accuracy_byAorB(:,1);
partB = Accuracy_byAorB(:,2);

vis_first = find(ExperimentOrder==1);
aud_first = find(ExperimentOrder==2); % have removed.

partA_vis = partA(vis_first,:);
partA_aud = partA(aud_first,:);

partB_vis = partB(aud_first,:);
partB_aud = partB(vis_first,:);
%%
clf;
set(gcf, 'units', 'normalized', 'position', [0 0 .8 .5], 'color', 'w')

for iorder = 1%:2
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
    set(gca, 'yticklabel', {[expo{2}], [ expo{1}]})
    title([ expo{1} '-' expo{2} ', n' num2str(length(b)) ])
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
%%
% print('-dpng', ['Grand average accuracy split by order type'])

%%
end


