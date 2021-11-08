% JOBS_ERP_decoder

clear all
close all

behdatadir = '/Volumes/MattsBackup (2TB)/dotstask- Vis+Audio EXP/Exp_output/DotsandAudio_behaviour/ver2';
figdir ='/Volumes/MattsBackup (2TB)/dotstask- Vis+Audio EXP/Figures';
eegdatadir ='/Volumes/MattsBackup (2TB)/dotstask- Vis+Audio EXP/EEG/ver2';
cd(eegdatadir);
pfols = dir([pwd filesep 'p_*']);

    %%
job.trainclassifierpartA_CvsE            =0;

job.plot_A_vs_Untrainedtrials            = 0;       %  PFX_ Plots the results of discrim component Cor vs Err in A, on all response locked ERP.
job.plot_A_vs_Untrainedtrials_pooled            = 0;       %  PFX_ Plots the results of discrim component Cor vs Err in A, on all response locked ERP.
job.plot_A_vs_Untrainedtrials_GFX        = 0;    %  GFX_ of above
job.plot_A_vs_untrainedtrials_GFX_AUCsplit =0;

% job.plot_A_vs_RTtercile =0; % see if classifier accuracy in A, is affected by RT (implying capture of confidence).

job.plot_A_vs_RTsinA                    =0; % won't work unless difference in C and E RTs!

job.plot_A_vs_SLIDINGwindow_corr_in_B   =0;  % using the A vector, multiple part B ERP, and see check performance correlation with confidence (or RT) over time..
job.plot_A_vs_Confidence_split          =0;  % using the A vector, multiple part B ERP, and see if we see quantile definition in confidence.

%plot results from classifier trained on part B of exp, on predicting
%confidence.

job.plot_B_vs_Confidence                =0; % uses the amplitude of discriminator performance (in quantiles), to collect confidence



%alternate method, using SVM
%>>
job.trainclassifierpartA_CvsE_useSVM     = 0;
job.traincrossmodalAvsB_useSVM          = 0;
job.plot_A_classifier_SVMresults        =0;
%%

 cmap = flip(cbrewer('div', 'Spectral', 4));

 elocs = readlocs('BioSemi64.loc');
 % >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 %% single trial decoding, based on logistic regression:
if job.trainclassifierpartA_CvsE==1
    Call_classifer_VIS_AUDIO;
end

if job.plot_A_vs_Untrainedtrials==1
    %  PFX_ Plots the results of discrim component Cor vs Err in A, on all response locked ERP.    
  Plot_decA_vs_untrained;
end
%%%%%%%%%%%%%%%%%%%%%
if job.plot_A_vs_Untrainedtrials_pooled==1
    % As above, but uses cross validation to estimate classifier accuracy
    % (rather than single shot per iteration).
  Plot_decA_vs_untrained_pooledClassifier;
end

%% 
if job.plot_A_vs_Untrainedtrials_GFX==1   
    Plot_decA_vs_untrained_GFX; %concats then plots (PFX calcd above)
end

if job.plot_A_vs_Untrainedtrials_GFX_AUCsplit==1   
    Plot_decA_vs_untrained_GFX_AUCsplit;
end

% if job.plot_A_vs_RTtercile ==1 % using ROC to compare RT affect on classifier accuracy.    
% Plot_decA_vs_RTsinA_ROC; % unfinished.
% end

if job.plot_A_vs_RTsinA==1
 Plot_decA_vs_RTsinA_correlation;
end
%%
if job.plot_A_vs_SLIDINGwindow_corr_in_B==1
 % script changed to compare RT and conf in B, to decoder performance.
    
 Plot_decA_vs_B_Beh_slidingwindow; 

end

if job.plot_A_vs_Confidence_split==1
 Plot_decA_vs_Confidence_split;
end
%%
if job.plot_B_vs_Confidence ==1
  
    Plot_decB_vs_Confidence;
end


%% SVM methods:
%%% >>>>>>>>>>>>>
if job.trainclassifierpartA_CvsE_useSVM==1
    Call_classifer_partA_useSVM;
end
if job.traincrossmodalAvsB_useSVM== 1
    Call_classifer_crossmod_useSVM;
end

%% plotting
if job.plot_A_classifier_SVMresults==1
    plotResults_SVM_classifierA;
end
    
