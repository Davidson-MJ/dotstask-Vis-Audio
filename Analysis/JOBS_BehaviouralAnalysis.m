% JOBS_BehaviouralAnalysis

clear variables
close all


% addpath('/Users/matthewdavidson/Documents/GitHub/dotstask-Vis-Audio/Analysis/')
%update to work on external volume:
behdatadir = '/Volumes/MattsBackup (2TB)/dotstask- Vis+Audio EXP/Exp_output/DotsandAudio_behaviour/ver2';
figdir ='/Volumes/MattsBackup (2TB)/dotstask- Vis+Audio EXP/Figures';

%%
cd(behdatadir);
pfols = dir([pwd filesep '*_p*']);

%%
% Quick ref:
% Which participants had visual stim first? Needs to be updated.
%     vis_first = [2,3,6:18,20];
%     aud_first = [1,4,5];


% % Plot_Accuracy_perExpOrder
 job.PlotAccuracy_perExpOrder =0;
% Plot_RTsbytype ;
 job.PlotRTs_perExpOrder =0;
% Plot_Confidence distributions
 job.PlotConfdistributions=1;
%% >........................................>.............................
if job.PlotAccuracy_perExpOrder ==1
    Plot_Accuracy_perExpOrder;
end
%%
if job.PlotRTs_perExpOrder ==1
    
   Plot_RTs_perExpOrder;
end
%%
if job.PlotConfdistributions==1
    
    Plot_Confidencedistributions;
    
end