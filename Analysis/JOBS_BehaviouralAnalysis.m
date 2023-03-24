% JOBS_BehaviouralAnalysis

clear variables
close all

addpath(genpath('C:\Github\dotstask-Vis-Audio'));
% addpath('/Users/matthewdavidson/Documents/GitHub/dotstask-Vis-Audio/Analysis/')
%update to work on external volume:
homedir = 'C:\Users\mdav0285\OneDrive - The University of Sydney (Staff)\Documents\dotstask- Vis+Audio EXP';

behdatadir = [homedir filesep 'Exp_output/DotsandAudio_behaviour/ver2'];
figdir =[homedir filesep 'Figures'];
eegdatadir =[homedir filesep 'EEG/ver2'];
cd(behdatadir);
pfols = dir([pwd filesep '*_p*']);

%remove any hidden files (onedrive corrupts the fileist).
pfols = striphiddenFiles(pfols);      

%% JOBS LIST:

% % Plot_Accuracy_perExpOrder
 job.PlotAccuracy_perExpOrder =0;
% Plot_RTsbytype ;
 job.PlotRTs_perExpOrder =0;
% Plot_Confidence distributions
 job.PlotConfdistributions=0;
 
 job.Plottype2AUC=0;
 
 job.Plot_MS_summary =1; % Manuscript (summary) figure.
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