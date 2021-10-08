% Plot_Confidencedistributions





ExperimentOrder = zeros(length(pfols),1); % auditory or visual first


Expver=2;
 

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

GFX_allConfD = nan(length(pfols), 2); % Correct and Errors
%plots individual participant level histograms of Conf, as well as Bar
%%
for ippant = 1:length(pfols)
    cd(behdatadir);
    cd(pfols(ippant).name);    
    lfile = dir([pwd filesep '*final' '*']);
    
    load(lfile.name);
    
    pname = ['p_' subject.id];
    
    %store the experiment order for later plots.
    ExpOrder = lower(cfg.stimTypes);
    if strcmp(ExpOrder{1}, 'visual')
        ExperimentOrder(ippant) = 1;   
        xmodd = 'auditory'; % the modality conf jdgmnts were provided in
    else
        ExperimentOrder(ippant) = 2;
        xmodd = 'visual'; % the modality conf jdgmnts were provided in
    end
    
    
    %plot staircase, running accuracy, and averaege accuracy per
    %participant:
        
    Confidence_summary_plot; %xmodd,pname used w/in.
    
    
    %now that we have the Conf data per participant, take z score and prep
    %for GFX.
    ppantz =zscore(ConfData.confj,1);
    
    GFX_allConfD(ippant,1) = nanmean(ppantz(ConfData.INDEX_Correct));
    GFX_allConfD(ippant,2) = nanmean(ppantz(ConfData.INDEX_Error));
    
    end
    %% %now plot across participants.
    clf;
    set(gcf, 'units', 'normalized', 'position', [0 0 .4 .5], 'color', 'w')
    % sort into modality * by section
    partA = GFX_allConfD(:,1);
    partB = GFX_allConfD(:,2);
    
    % first plot all A vs B:
    Xdata=[partA,partB];
    [a,b]=CousineauSEM(Xdata);
    
    dataX{1} = b(:,1);
    dataX{2} = b(:,2);
    bh =rm_raincloud(dataX', [cmap(8,:)]);
    
    hold on;
    %add plot specs
    set(gca, 'yticklabel', {['Error'], ['Correct']})
    title(['Responses x Confidence, n' num2str(length(b))])
    % xlim([.4 1])
    xlabel('z(Confidence)')
    set(gca, 'fontsize', fontsizeX)
    print('-dpng', ['GFX zscored confidence by CE, n' num2str(length(b))]);
    %% as before, separate by modality order.
    
    
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
% print('-dpng', ['GFX zscored confidence by CE, split by order']);
%%
    
    
    
