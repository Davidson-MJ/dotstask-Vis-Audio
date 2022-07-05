% JOBS_BehaviouralAnalysis

clear variables
close all


% addpath('/Users/matthewdavidson/Documents/GitHub/dotstask-Vis-Audio/Analysis/')
%update to work on external volume:
behdatadir = '/Volumes/MattsBackup (2TB)/dotstask- Vis+Audio EXP/Exp_output/DotsandAudio_behaviour/ver2';
figdir ='/Volumes/MattsBackup (2TB)/dotstask- Vis+Audio EXP/Figures';
eegdatadir ='/Volumes/MattsBackup (2TB)/dotstask- Vis+Audio EXP/EEG/ver2';
cd(behdatadir);
pfols = dir([pwd filesep '*_p*']);

%% JOBS LIST:

% % Plot_Accuracy_perExpOrder
 job.PlotAccuracy_perExpOrder =1;
% Plot_RTsbytype ;
 job.PlotRTs_perExpOrder =1;
% Plot_Confidence distributions
 job.PlotConfdistributions=1;
 
 job.Plottype2AUC=1;
 
 job.Plot_MS_summary =0; % Manuscript (summary) figure.
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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

%%
if job.Plottype2AUC
    
    plot_type2_AUCpersubj;
    
end

%% 
if job.Plot_MS_summary

plot_MSfig_Beh;

end