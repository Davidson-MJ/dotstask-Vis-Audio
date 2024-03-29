% Plot_Confidencedistributions

%called from JOBS_BehaviouralAnalysis

jobs=[];

jobs.concat_Conf=1; %prepare for plots.

jobs.plotPFX_conf =0; % per ppant

jobs.plotGFX_conf =1 ; %tidy (raincloud) GFX


ExperimentOrder = zeros(length(pfols),1); % auditory or visual first


Expver=2;
 


%! including a count per ppant, of nErrors in the failure to detect error
%range (guess->sure correct).

% Deprecated:
% plotInfoSeeking=0; 
% Confidence_byChoice= zeros(length(pfols),3); % we have after choosing to
% see again, after choosing to respond, and after being forced to respond


% change the plot axes, since confidence response instructions varied between versions
fontsizeX=25;


cmap = cbrewer('qual', 'Paired',10);
colormap(cmap)
viscolour = cmap(3,:);
audcolour=cmap(9,:);


%plots individual participant level histograms of Conf, as well as Bar
%%
if jobs.concat_Conf==1 %prepare for plots.
    
    ExperimentOrder = nan(length(pfols),1);
    pnames = cell(length(pfols),1);
    GFX_allConfD = nan(length(pfols), 2); % Correct and Errors
    
    GFX_prop_trueError= nan(length(pfols),1);
    
for ippant = 1:length(pfols)
    cd(behdatadir);
    cd(pfols(ippant).name);    
    lfile = dir([pwd filesep '*final' '*']);
    
    load(lfile.name);
    
    pname = ['p_' subject.id];
    pnames{ippant} = pname;
    
    %store the experiment order for later plots.
    ExpOrder = lower(cfg.stimTypes);
    if strcmp(ExpOrder{1}, 'visual')
        ExperimentOrder(ippant) = 1;   
        xmodd = 'auditory'; % the modality conf jdgmnts were provided in
    else
        ExperimentOrder(ippant) = 2;
        xmodd = 'visual'; % the modality conf jdgmnts were provided in
    end
    
    
%gather some useful experimental data information
ConfData=[];
ConfData.modality = xmodd;
ConfData.stimdiff=UpDownStruct_partB.xCurrent;

%find the index of part B trials
npractr = cfg.ntrialsprac * cfg.nblocksprac;
% startA= npractr+1;
endA= (npractr+ cfg.nblocks_partA*cfg.ntrials);
startB= endA+npractr+1;
endB = startB+cfg.nblocks_partB*cfg.ntrials -1;

ConfData.cor1= [alltrials(startB:endB).cor];
% ConfData.cor2= [alltrials(startB:endB).confj_cor];
ConfData.confj= [alltrials(startB:endB).confj];

%also store subset (by errors vs correct).
CORid = find(ConfData.cor1);
ERRid = find(ConfData.cor1==0);

ConfData.INDEX_Correct= CORid;
ConfData.INDEX_Error= ERRid;


%NEW, also retain proportion of C and E responses based on binary split of
%confidence (guess - unsure, unsure - sure correct).

% nGuess_Err = length(intersect(ConfData.IN
%     Confidence_summary_plot; %xmodd,pname used w/in.
    
    
    %now that we have the Conf data per participant, take z score and prep
    %for GFX.
    ppantz =zscore(ConfData.confj,1);
    
    GFX_allConfD(ippant,1) = nanmean(ppantz(ConfData.INDEX_Correct));
    GFX_allConfD(ippant,2) = nanmean(ppantz(ConfData.INDEX_Error));
    
    
    %keep the count.
    errorConf = ConfData.confj(ConfData.INDEX_Error);
    %prop failure to detect: (note that 55, -55 are both a guess).
%     errorConf(errorConf==-55) =55;
    nGuess_C = length(find(errorConf>0));
    nGuess_W = length(find(errorConf<0));
    
    GFX_prop_trueError(ippant) = nGuess_C / length(errorConf);
    
    
end
end
%%
if jobs.plotPFX_conf
    %%
   for ippant=8%:length(pfols)
       cd(behdatadir);
       cd(pfols(ippant).name);
        lfile = dir([pwd filesep '*final' '*']);
    
    load(lfile.name);
    
    pname = ['p_' subject.id];
    
    Confidence_summary_plot; %xmodd,pname used w/in.
    
   end
    
end

%%
if jobs.plotGFX_conf
    %% %now plot across participants.
   
vis_first = find(ExperimentOrder==1);
aud_first = find(ExperimentOrder==2);

%%
clf;
set(gcf, 'units', 'normalized', 'position', [0 0 .8 .8], 'color', 'w')

for iorder = 1%:2
    
 if iorder==1
     barDD = GFX_allConfD(vis_first,:);
     expo = {'visual','auditory'};
     colnow = audcolour;
 else
     barDD = GFX_allConfD(aud_first,:);
     expo = {'auditory','visual'};
     colnow = viscolour;
 end
subplot(1,2,iorder);
% sort into modality * by section
partA = barDD(:,1);
partB = barDD(:,2);

% first plot all A vs B:
Xdata=[partA,partB];
[a,b]=CousineauSEM(Xdata);

dataX{1} = b(:,1);
dataX{2} = b(:,2);
bh =rm_raincloud(dataX', colnow);

%colour changes:
 % change colours
    %patches:
    bh.p{1}.FaceColor = cmap(4,:); % green
    bh.p{2}.FaceColor = cmap(6,:); % redish
    %scatter:
    bh.s{1}.MarkerFaceColor = cmap(4,:); % green
    bh.s{2}.MarkerFaceColor = cmap(6,:); % redish
    
    
    
hold on; 
%add plot specs
set(gca, 'yticklabel', {['Error'], ['Correct']})
title({['Part B: ' expo{2} ]})

%5 add text
 ytsare = get(gca, 'ytick');
    
    text(-2.8, ytsare(1), ['\it M=\rm' sprintf('%.2f',mean(Xdata(:,2)))], 'fontsize', fontsizeX)
    text(-2.8, ytsare(2), ['\it M=\rm' sprintf('%.2f',mean(Xdata(:,1)))], 'fontsize', fontsizeX)
    set(gcf, 'color', 'w');
    set(gca, 'fontsize', fontsizeX)
    set(gcf, 'color', 'w');
    set(gca, 'fontsize', fontsizeX)
    
    
if iorder==1
    sety = get(gca,'ylim');
    xlim([-3 3])
    setx = get(gca,'xlim');
    
else
%     ylim([sety(1) sety(2)]);
    xlim([setx(1) setx(2)]);
end
xlabel('z(Confidence)')

ytsare = get(gca, 'ytick');

% ttests
[~, p1] = ttest(Xdata(:,1), Xdata(:,2));

if p1<.001
    psig= '***';
elseif p1<.01
    psig= '**';
elseif p1<.05
    psig ='*';
else 
    psig= 'ns';
end
    
%rain clouds have weird axes:
yl= get(gca, 'ylim');
mY= (mean(sety));


sigheight = setx(2)*.9;


    ts=text(sigheight, mY, psig, 'fontsize', 45);
    ts.VerticalAlignment= 'middle';
    ts.HorizontalAlignment= 'center';
    hold on;
%     plot(xlim, [yl(1), yl(2)], ['k:' ]);
    plot([sigheight-.05, sigheight-.05], [ytsare(1), ytsare(2)], ['k-' ], 'linew', 2);
    
    
    
end
end
% print('-dpng', ['GFX zscored confidence by CE, split by order']);
%%
    
    
    
