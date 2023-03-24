% Plot_AccuracybyExpType


%plot bar data (visual vs auditory RTs).
clear all
homedir= '/Users/mdavidson/Desktop/dotstask- Vis+Audio EXP';
cd('/Users/mdavidson/Desktop/dotstask- Vis+Audio EXP/Exp_output/DotsandAudio_behaviour/ver2');


basedir=pwd;
addpath('/Users/mdavidson/Desktop/dotstask- Vis+Audio EXP/Analysis');
pfols= dir([pwd filesep '*' '_p*']);


ExperimentOrder = zeros(length(pfols),1); % auditory or visual first
Accuracy_byAorB = zeros(length(pfols),2); % first and second half


fontsizeX=25;

%plots individual participant level histograms of RT, as well as Bar
%%
for ippant = 1:length(pfols)
    cd(basedir);
    cd(pfols(ippant).name);
    
    lfile = dir([pwd filesep '*final' '*']);
    
    load(lfile.name);
    
%     usetrials=alltrials_final;

      usetrials=alltrials;
    
    
    %store the experiment order for later plots.
    if cfg.xmodBlockTypes(1)==3      %  audio 'VISUAL' 
        
    ExperimentOrder(ippant,1) =2;
    else                             % order is visual 'AUDIO'
    ExperimentOrder(ippant,1) =1;
    end
    
    
    
    %plot staircase, running accuracy, and averaege accuracy per
    %participant:
    
    Accuracy_summary_plot;
    
    
    %just look by exp type, sort next into modality.
    
    end
    %%

% PLOTTING.
%separate into Aud and Visual.
cmap = cbrewer('qual', 'Paired',10);
colormap(cmap)

figure(1); clf;
set(gcf, 'units', 'normalized', 'position', [0 0 .3 .5])
% sort into modality * by section
partA = Accuracy_byAorB(:,1);
partB = Accuracy_byAorB(:,2);

vis_first = find(ExperimentOrder==1);
aud_first = find(ExperimentOrder==2);

partA_vis = partA(vis_first,:);
partA_aud = partA(aud_first,:);

partB_vis = partB(aud_first,:);
partB_aud = partB(vis_first,:);
%


mBar = [mean(partA_vis,1), mean(partA_aud); ...
    mean(partB_vis,1), mean(partB_aud,1)];
%
%stack for comparison.
bh=bar(mBar); hold on
bh(1).FaceColor = cmap(3,:);
bh(2).FaceColor = cmap(9,:);


%can also compute stE for group of ppants.
stE_Avis= std(partA_vis)/sqrt(size(partA_vis,1));
stE_Aaud= std(partA_aud)/sqrt(size(partA_aud,1));

stE_Bvis= std(partB_vis)/sqrt(size(partB_vis,1));
stE_Baud= std(partB_aud)/sqrt(size(partB_aud,1));
    
%arrange for fitting to plot
plotErr = [stE_Avis, stE_Aaud;stE_Bvis, stE_Baud];
errorbar_groupedfit(mBar,plotErr);	



ylabel('Accuracy')
%
legend('visual', 'auditory', 'Autoupdate', 'off')
%
set(gca, 'XTickLabel', {['part A'];['part B, with confidence']}, 'XtickMode', 'manual')
%
ylim([.4 1])

set(gca, 'fontsize', fontsizeX)
text(.8, .5, ['\itn \rm= ' num2str(length(vis_first))], 'fontsize', fontsizeX)
text(2.1, .5, ['\itn \rm= ' num2str(length(vis_first))], 'fontsize', fontsizeX)

text(1.1, .5, ['\itn \rm= ' num2str(length(aud_first))], 'fontsize', fontsizeX)
text(1.8, .5, ['\itn \rm= ' num2str(length(aud_first))], 'fontsize', fontsizeX)

% stE= CousineauSEM(ReactionTimesALL');
% stE=[stE(1:2);stE(3:4)];
% eH= errorbar_groupedfit(mBar,stE);
% set(gca, 'fontsize', 25);
% ylim([0 3])

set(gcf, 'color', 'w')

%%
print('-dpng', 'Group effects accuracy summary');
%%


