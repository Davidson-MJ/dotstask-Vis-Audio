% JOBS_ERP_decoder

clear all
close all

addpath(genpath('C:\Github\dotstask-Vis-Audio'));
% addpath('/Users/matthewdavidson/Documents/GitHub/dotstask-Vis-Audio/Analysis/')
%update to work on external volume:
homedir = 'C:\Users\mdav0285\Documents\dotstask- Vis+Audio EXP';
behdatadir = [homedir filesep 'Exp_output/DotsandAudio_behaviour/ver2'];
figdir =[homedir filesep 'Figures'];
eegdatadir =[homedir filesep 'EEG/ver2'];
cd(eegdatadir)
pfols = dir([pwd filesep 'p_*']);
%% JOBS list
% first training a classifer on a predetermined window (similar to Boldt et al)
job.trainclassifierpartA_Pe_CvsE            =0; % first version, with a fixed time window.

%perform calc, then plot the above:
job.plot_Pe_vs_Untrainedtrials            = 0;       %  PFX_ Plots the results of discrim component Cor vs Err in A, on all response locked ERP.
job.plot_Pe_vs_Untrainedtrials_GFX        = 0;   
job.plot_Pe_vs_Confidence_split            =0;
job.plot_Pe_vs_SLIDINGwindow_corr_in_B      =0;
   
 
%% DIAGONAL (test train same times), also used in time-gen below.
%  called below, but we can toggle whether to train on A, B, stim locked or
% resp locked (below).
job.trainclassifier_CvsE_diagonal=1; % diagonal training and testing (same axis). 
% note the size of the window and steps are specficied in
% Call_classifier... .m

% perform calc, then plot the above
job.calcplot_diagonal_vs_Untrainedtrials   = 0;       %  PFX_ Plots the results of discrim component Cor vs Err in A, on all response locked ERP.
job.plot_GFX_diagonal                       =  0 ; % shows diagonal decoding for all time points.
job.plot_GFX_diagonal_MSver1             =0; % shows just within same condition, with overall accuracy as the main feature (mean Errors and Correct performance).

job.calcPlot_diagonal_predictsConfidence         =0; % incl. calc, concat, PFX, GFX
job.calcPlot_diagonal_slidingCorr               =0; % incl. calc, concat, PFX, GFX

%% timegen. Note this uses the results from *_alltimepoints above. 
% all 4 combinations must have been completed (A stim,resp, B stim resp).

job.calcplot_diagonal_timegen           =0; % calcs and saves per ppant first.
job.plot_GFX_timegen                    =0;
%plot results from classifier trained on part B of exp, on predicting
%confidence.
job.calcPlot_timegen_slidingCorr =0;



%%
 % >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 % BEGIN analysis of jobs above
 % >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 

 %% single trial decoding, based on logistic regression (Pe window only)
if job.trainclassifierpartA_Pe_CvsE==1
    % currently just resp errors in A, but could generalise to others as in
    % diagonal script below.
    Call_classifer_VIS_AUDIO;
end
%
if job.plot_Pe_vs_Untrainedtrials==1
    %  PFX_ Plots the results of discrim component Cor vs Err in A, on all response locked ERP.    
  Plot_decA_vs_untrained;
end

%
if job.plot_Pe_vs_Untrainedtrials_GFX==1   
    Plot_decA_vs_untrained_GFX; %concats then plots (PFX calcd above), also includes overall accuracy
end

%

if job.plot_Pe_vs_Confidence_split==1
 Plot_decA_vs_Confidence_split;
end

if job.plot_Pe_vs_SLIDINGwindow_corr_in_B==1
 % script changed to compare RT and conf in B, to decoder performance.
    
 Plot_decA_vs_B_Beh_slidingwindow; 

end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Diagonal section:
if job.trainclassifier_CvsE_diagonal==1
    %% some specifics, determines inpu
    cfg=[];
    cfg.pfols=pfols;
    cfg.eegdatadir= eegdatadir;
    cfg.behdatadir= behdatadir;
    


    prts= {'A', 'A', 'B', 'B'};
    tps= {'stim', 'resp', 'stim', 'resp'};

    for id=1:4%
        cfg.expPart =prts{id};
        cfg.EEGtype = tps{id};

        Call_classifier_VIS_AUDIO_diagonal(cfg);
    end


end



if job.calcplot_diagonal_vs_Untrainedtrials  
    %% performs analysis at participant level, saves, then plots.
    cfg=[];
    cfg.pfols=pfols;
    cfg.eegdatadir= eegdatadir;
    cfg.behdatadir= behdatadir;
    cfg.figdir= figdir;
    cfg.crunchPPant = 0; %
    cfg.justplot= 0;


    % should we test only on untrained, or all trials?
    cfg.testAll= 1; % or 0

    prts= {'A', 'A', 'B', 'B'};

    tps= {'stim', 'resp', 'stim', 'resp'};

    for id=1:4 
    cfg.expPart =prts{id};
    cfg.EEGtype = tps{id};
    calc_Plot_diagonal_vs_untrained(cfg); % as above, but we have trained and tested along the same data points.
    end
end
%% GFX of the diagonal train-test.
if job.plot_GFX_diagonal
%%
      cfg=[];
    cfg.pfols=pfols;
    cfg.eegdatadir= eegdatadir;
    cfg.behdatadir= behdatadir;
    cfg.figdir= figdir;
    cfg.concat = 1;
    cfg.justplot= 1;

    prts= {'A', 'A', 'B', 'B'};

    tps= {'stim', 'resp', 'stim', 'resp'};

    for id=2%1:4
    cfg.expPart =prts{id};
    cfg.EEGtype = tps{id};
    Plot_GFX_DEC_diagonal(cfg); % as above, but we have trained and tested along the same data points.
    end
    
    
end
%% GFX of the diagonal train-test.
if job.plot_GFX_diagonal_MSver1
%%
      cfg=[];
    cfg.pfols=pfols;
    cfg.eegdatadir= eegdatadir;
    cfg.behdatadir= behdatadir;
    cfg.figdir= figdir;
    cfg.concat = 1;
    cfg.justplot= 1;

    prts= {'A', 'A', 'B', 'B'};

    tps= {'stim', 'resp', 'stim', 'resp'};

    for id=2%1:4
    cfg.expPart =prts{id};
    cfg.EEGtype = tps{id};
    Plot_GFX_DEC_diagonal_MSVer1(cfg); % as above, but we have trained and tested along the same data points.
    end
    
    
end
%%
%% 
if job.calcPlot_diagonal_predictsConfidence==1
% this sees whether a classifier that predicts errors captures differences
% in confidnce
%%

 cfg=[];
    cfg.pfols=pfols;
    cfg.eegdatadir= eegdatadir;
    cfg.behdatadir= behdatadir;
    cfg.figdir= figdir;

    cfg.crunchPPant = 1; % also concats GFX
    cfg.plotPFX= 1;
    cfg.plotGFX= 1;


    % trained (use which decoder as our trained set->)
    cfg.expPart='A';
    cfg.EEGtype= 'resp';
%%
calc_Plot_diagonal_splitsConfidence(cfg)


end


%% 
if job.calcPlot_diagonal_slidingCorr==1
% this sees whether a classifier that predicts errors captures differences
% in confidnce
%%

 cfg=[];
    cfg.pfols=pfols;
    cfg.eegdatadir= eegdatadir;
    cfg.behdatadir= behdatadir;
    cfg.figdir= figdir;

    cfg.crunchPPant = 1; % also concats GFX
    cfg.plotPFX= 1;
    cfg.plotGFX= 1;


    % trained (use which decoder as our trained set->)
    cfg.expPart='A';
    cfg.EEGtype= 'resp';
%%
calcPlot_diagonal_slidingCorr(cfg)


end




%% % %%%%%% TIME GEN -> 
if job.calc_plot_diagonal_timegen==1 % participant level effects.
 %%
    cfg=[];
    cfg.pfols=pfols;
    cfg.eegdatadir= eegdatadir;
    cfg.behdatadir= behdatadir;
    cfg.figdir= figdir;
    cfg.crunchPPant = 1;
    cfg.justplot= 0;

    % can cycle through different combinations as we plase:
    cfg.singleorAvIterations = 2; % 1 for single iterations (slow), 2 for average of iteration discrim vectors.

    % trained (use which decoder as our trained set->)
    cfg.expPart_train ='A';
    cfg.EEGtype_train = 'resp';

    %test (test the above on the below).
    cfg.expPart_test ='B';
    cfg.EEGtype_test= 'resp';
    % ^ will cycle through all time points.

Plot_decA_diagonal_timegen(cfg);
end

if job.plot_GFX_timegen
%%
      cfg=[];
    cfg.pfols=pfols;
    cfg.eegdatadir= eegdatadir;
    cfg.behdatadir= behdatadir;
    cfg.figdir= figdir;

    cfg.concat = 1;
    cfg.justplot= 1;


    % trained (use which decoder as our trained set->)
    cfg.expPart_train ='A';
    cfg.EEGtype_train = 'resp';

    %test (test the above on the below).
    cfg.expPart_test ='B';
    cfg.EEGtype_test= 'resp';
    Plot_GFX_DEC_timegen(cfg); % as above, but we have trained and tested along the same data points.
    
    
end

if job.calcPlot_timegen_slidingCorr==1


 cfg=[];
    cfg.pfols=pfols;
    cfg.eegdatadir= eegdatadir;
    cfg.behdatadir= behdatadir;
    cfg.figdir= figdir;

    cfg.crunchPPant = 1; % also concats GFX
    cfg.plotPFX= 1;
    cfg.plotGFX= 1;

 cfg.expPart_train ='A';
    cfg.EEGtype_train = 'resp';

    %test (test the above on the below).
    cfg.expPart_test ='B';
    cfg.EEGtype_test= 'resp';
%%
calcPlot_timegen_slidingCorr(cfg)


end
% 
% 
% 
% 
% %%
% %%%%%%%%%%%%%%%%%%%%%
% if job.plot_A_vs_Untrainedtrials_pooled==1
%     % As above, but uses cross validation to estimate classifier accuracy
%     % (rather than single shot per iteration).
%   Plot_decA_vs_untrained_pooledClassifier;
% end
% 
% 
% if job.plot_A_vs_Untrainedtrials_GFX_AUCsplit==1   
%     Plot_decA_vs_untrained_GFX_AUCsplit;
% end
% 
% % if job.plot_A_vs_RTtercile ==1 % using ROC to compare RT affect on classifier accuracy.    
% % Plot_decA_vs_RTsinA_ROC; % unfinished.
% % end
% 
% if job.plot_A_vs_RTsinA==1
%  Plot_decA_vs_RTsinA_correlation;
% end
% %%
% 
% 
% %%
% if job.plot_B_vs_Confidence ==1
%   
%     Plot_decB_vs_Confidence;
% end
% 
% 
% % %% SVM methods:
% % %%% >>>>>>>>>>>>>
% if job.trainclassifierpartA_CvsE_useSVM==1
%     Call_classifer_partA_useSVM;
% end
% if job.traincrossmodalAvsB_useSVM== 1
%     Call_classifer_crossmod_useSVM;
% end
% 
% %% plotting
% if job.plot_A_classifier_SVMresults==1
%     plotResults_SVM_classifierA;
% end
%     
