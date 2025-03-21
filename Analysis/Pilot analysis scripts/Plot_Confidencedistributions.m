% Plot_Confidencedistributions

%called from JOBS_BehaviouralAnalysis

jobs=[];

jobs.concat_Conf=1; %prepare for plots.

jobs.plotPFX_conf =0; % per ppant

jobs.plotGFX_conf =0 ; %tidy (raincloud) GFX


ExperimentOrder = zeros(length(pfols),1); % auditory or visual first


Expver=2;
 
%UPDATED to extract distributions / descriptive summaries of confidence
%statistics.


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
cd(behdatadir)
pfols = dir([pwd filesep '*_p*']);
pfols = striphiddenFiles(pfols);

if jobs.concat_Conf==1 %prepare for plots.
    
    ExperimentOrder = nan(length(pfols),1);
    pnames = cell(length(pfols),1);
    
    GFX_allConfD_z = nan(length(pfols), 2); % Correct and Errors (zscored
    GFX_allConfD= nan(length(pfols),2);  % not zcored.
    GFX_prop_trueError= nan(length(pfols),1);
    
    GFX_allConfDescriptives= [];% will add as a structure.
for ippant = 1:length(pfols)
    cd(behdatadir);
    cd(pfols(ippant).name);    
    lfile = dir([pwd filesep '*final' '*']);
    lfile = striphiddenFiles(lfile);
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
    
    %mean z-scored cofidence per correct and error:
    GFX_allConfD_z(ippant,1) = nanmean(ppantz(ConfData.INDEX_Correct));
    GFX_allConfD_z(ippant,2) = nanmean(ppantz(ConfData.INDEX_Error));
    GFX_allConfD(ippant,1) = nanmean(ConfData.confj(ConfData.INDEX_Correct));
    GFX_allConfD(ippant,2) = nanmean(ConfData.confj(ConfData.INDEX_Error));
    

    
    %keep the count.
    errorConf = ConfData.confj(ConfData.INDEX_Error);
    %prop failure to detect: (note that 55, -55 are the extrema (-55 <> +55) .
%     errorConf(errorConf==-55) =55;
    nGuess_C = length(find(errorConf>0));
    nGuess_W = length(find(errorConf<0));
    
    GFX_prop_trueError(ippant) = nGuess_C / length(errorConf);
    


    %new addition:
    % include result for the subjectively correct (only) subtype:
    subCindex = find(ConfData.confj>0);

    %raw conf
    M_Correct = nanmean(ConfData.confj(ConfData.INDEX_Correct));
    var_Correct = std(ConfData.confj(ConfData.INDEX_Correct));
    
    var_subjCorrect = std(ConfData.confj(subCindex));
    M_subjCorrect = nanmean(ConfData.confj(subCindex));

    M_Error= nanmean(ConfData.confj(ConfData.INDEX_Error));    
    var_Error= std(ConfData.confj(ConfData.INDEX_Error));
    
    %zscore conf (as above)
     M_Correct_Z = nanmean(ppantz(ConfData.INDEX_Correct));
    var_Correct_Z = std(ppantz(ConfData.INDEX_Correct));
    
    var_subjCorrect_Z = std(ppantz(subCindex));
    M_subjCorrect_Z = nanmean(ppantz(subCindex));

    M_Error_Z= nanmean(ppantz(ConfData.INDEX_Error));    
    var_Error_Z= std(ppantz(ConfData.INDEX_Error));
    
    % store: 
    %raw
    GFX_allConfDescriptives.MeanRaw_correct(ippant)= M_Correct;    
    GFX_allConfDescriptives.stdRaw_correct(ippant)= var_Correct;
    GFX_allConfDescriptives.MeanRaw_Subjcorrect(ippant)= M_subjCorrect;
    GFX_allConfDescriptives.stdRaw_Subjcorrect(ippant)= var_subjCorrect;
    GFX_allConfDescriptives.MeanRaw_error(ippant)= M_Error;
    GFX_allConfDescriptives.stdRaw_error(ippant)= var_Error;

    GFX_allConfDescriptives.countRawCorrect(ippant) = length(find(ConfData.INDEX_Correct));
    GFX_allConfDescriptives.countSubjCorrect(ippant) = length(subCindex);

    %z
    GFX_allConfDescriptives.MeanZ_correct(ippant)= M_Correct_Z;
    GFX_allConfDescriptives.stdZ_correct(ippant)= var_Correct_Z;
    GFX_allConfDescriptives.MeanZ_Subjcorrect(ippant)= M_subjCorrect_Z;
    GFX_allConfDescriptives.stdZ_Subjcorrect(ippant)= var_subjCorrect_Z;
    GFX_allConfDescriptives.MeanZ_error(ippant)= M_Error_Z;
    GFX_allConfDescriptives.stdZ_error(ippant)= var_Error_Z;
   
    disp(['fin cat for ppant ' num2str(ippant)]); 
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
     barDD = GFX_allConfD_z(vis_first,:);
     expo = {'visual','auditory'};
     colnow = audcolour;
 else
     barDD = GFX_allConfD_z(aud_first,:);
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
    
    
    
%% some descripvies.
% mean var on correct, and subjectivel correct trials.
pset = 1:21;
% pset= [1:18,20,21]; 
% participants 
disp(['raw conf values:'])
disp(['M count ' num2str(mean(GFX_allConfDescriptives.countRawCorrect(pset))) ' M value correct ' num2str(mean(GFX_allConfDescriptives.MeanRaw_correct(pset))) ', average SD ' num2str(mean(GFX_allConfDescriptives.stdRaw_correct(pset)))]);
disp(['M count ' num2str(mean(GFX_allConfDescriptives.countSubjCorrect(pset))) ' M value correct ' num2str(mean(GFX_allConfDescriptives.MeanRaw_Subjcorrect(pset))) ', average SD ' num2str(mean(GFX_allConfDescriptives.stdRaw_Subjcorrect(pset))) '(Subjective)'] );
%%
disp(['Zscored conf values:'])
disp(['M correct ' num2str(mean(GFX_allConfDescriptives.MeanZ_correct)) ', average SD ' num2str(mean(GFX_allConfDescriptives.stdZ_correct))]);
disp(['M correct ' num2str(mean(GFX_allConfDescriptives.MeanZ_Subjcorrect)) ', average SD ' num2str(mean(GFX_allConfDescriptives.stdZ_Subjcorrect)) '(Subjective) ']);
%%

% [h,p,i,stat]= ttest(GFX_allConfDescriptives.MeanZ_correct, GFX_allConfDescriptives.MeanZ_Subjcorrect)

[h,p,i,stat]= ttest(GFX_allConfDescriptives.MeanRaw_correct(pset), GFX_allConfDescriptives.MeanRaw_Subjcorrect(pset))
% [h,p,i,stat]= ttest(GFX_allConfDescriptives.stdRaw_correct, GFX_allConfDescriptives.stdRaw_Subjcorrect)
% [h,p,i,stat]= ttest(GFX_allConfDescriptives.stdZ_correct, GFX_allConfDescriptives.stdZ_Subjcorrect)