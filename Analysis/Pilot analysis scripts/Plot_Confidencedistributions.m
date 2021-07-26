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
set(gcf, 'units', 'normalized', 'position', [0 0 .8 1], 'color', 'w')

for iorder = 1:2
    
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

    
hold on; 
%add plot specs
set(gca, 'yticklabel', {['Error'], ['Correct']})
title({['Part B (' expo{2} '), n' num2str(length(b))]})
% xlim([-1.5 1.5])

hold on; plot([0 0], ylim, 'k:', 'linew', 3)
%
set(gcf, 'color', 'w');
set(gca, 'fontsize', fontsizeX)
if iorder==1
    sety = get(gca,'ylim');
    setx = get(gca,'xlim');
else
%     ylim([sety(1) sety(2)]);
    xlim([setx(1) setx(2)]);
end
xlabel('z(Confidence)')

end
print('-dpng', ['GFX zscored confidence by CE, split by order']);
%%
    
    
    

%     
%     if plotInfoSeeking==1
% % PLOTTING.
% clf
% %separate into Aud and Visual.
% cmap = cbrewer('qual', 'Paired',12);
% colormap(cmap)
% 
% 
% % sort into modality * by section
% 
% vis_first = find(ExperimentOrder==1);
% aud_first = find(ExperimentOrder==2);
% 
% partB_aud = Confidence_byChoice(vis_first,:);
% partB_vis = Confidence_byChoice(aud_first,:);
% 
% for id=1:2
%     switch id
%         case 1
%             datais = partB_aud;
%             tis = 'auditory';
%             cis=2;
%         case 2
%             datais = partB_vis;
%             tis = 'visual';
%             cis=10;
%     end
% subplot(2,1,id)
% dataX=[];
% dataX{1} = datais(:,1);
% dataX{2} = datais(:,2);
% dataX{3} = datais(:,3);
% 
% 
% h=rm_raincloud(dataX', cmap([cis],:), 1, 'ks');
% xlabel('Confidence judgement')
% ylabel('Response')
% set(gca, 'yticklabels', {['Forced response'] , ['Review by choice'], ['Respond by choice']}, 'fontsize', 16)
% %  xlim([0 100]) 
% title(['Confidence in ' tis ' trials ']);
% hold on;
% set(gcf, 'color', 'w')
% shg
% end
% %%
% print('-dpng', 'Group effects, confidence summary raincloud');
% 
% %%
% figure(2); clf 
% mBar = [mean(partB_vis,1); mean(partB_aud,1)];
% %
% %stack for comparison.
% bh=bar(mBar); hold on
% bh(1).FaceColor = cmap(3,:);
% bh(2).FaceColor = cmap(9,:);
% 
% %can also compute stE for group of ppants.
% stE_Bvis= std(partB_vis)/sqrt(size(partB_vis,1));
% stE_Baud= std(partB_aud)/sqrt(size(partB_aud,1));
% 
% %arrange for fitting to plot
% plotErr = [stE_Bvis; stE_Baud];
% errorbar_groupedfit(mBar,plotErr);	
% ylim([ 50 100])
% 
% ylabel('Confidence')
% %
% legend('Respond by choice', 'Review by choice', 'Forced response', 'Autoupdate', 'off')
% %
% set(gca, 'XTickLabel', {'visual', 'auditory'})
% %
% % ylim([.4 1])
% % axis tight
% 
% set(gca, 'fontsize', 20)
% % text(.8, .5, ['\itn \rm= ' num2str(length(vis_first))], 'fontsize', 15)
% % text(2.1, .5, ['\itn \rm= ' num2str(length(vis_first))], 'fontsize', 15)
% % 
% % text(1.1, .5, ['\itn \rm= ' num2str(length(aud_first))], 'fontsize', 15)
% % text(1.8, .5, ['\itn \rm= ' num2str(length(aud_first))], 'fontsize', 15)
% 
% % stE= CousineauSEM(ReactionTimesALL');
% % stE=[stE(1:2);stE(3:4)];
% % eH= errorbar_groupedfit(mBar,stE);
% % set(gca, 'fontsize', 25);
% % ylim([0 3])
% 
% set(gcf, 'color', 'w')
% 
% %%
% print('-dpng', 'Group effects, confidence summary bar');
% %%
%     end

