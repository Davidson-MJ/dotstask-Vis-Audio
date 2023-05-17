% JOBS_BehaviouralAnalysis

clear variables
close all

setdirs_DotsAV;
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