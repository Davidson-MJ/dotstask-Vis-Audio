% JOBS_BehaviouralAnalysis

clear variables
close all
addpath('/Users/mdavidson/Documents/MATLAB/dotstask-Vis-Audio/Analysis')

behdatadir = '/Users/mdavidson/Desktop/dotstask- Vis+Audio EXP/Exp_output/DotsandAudio_behaviour/ver2';
figdir ='/Users/mdavidson/Desktop/dotstask- Vis+Audio EXP/Figures';
%%
cd(behdatadir);
pfols = dir([pwd filesep '*_p*']);

%%
%need to remove practice trials from final datasets.
% which participants had visual stim first? Needs to be updated.
    vis_first = [2,3,6,7,8,9,10,11,12];
    aud_first = [1,4,5];
% Plot_Accuracy_perExpOrder
 job.PlotAccuracy_perExpOrder =0;
% Plot_RTsbytype ;
 job.PlotRTs_perExpOrder =1;
% Plot_Confidence distributions
 job.PlotConfdistributions=0;
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