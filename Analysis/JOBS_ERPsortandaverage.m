% JOBS_ERPsortandaverage
clear variables
close all
addpath('/Users/mdavidson/Documents/MATLAB/dotstask-Vis-Audio/Analysis')

behdatadir = '/Users/mdavidson/Desktop/dotstask- Vis+Audio EXP/Exp_output/DotsandAudio_behaviour/ver2';

basedir= '/Users/mdavidson/Desktop/dotstask- Vis+Audio EXP/EEG/ver2';
cd(basedir);
pfols = dir([pwd filesep 'p_*']);

% which participants had visual stim first? Needs to be updated.
    vis_first = [2,3,6,7,8,9,10,11,12];
    aud_first = [1,4,5];

% Participant stimulus trigger and response locked ERPs.
job.calc_individualERPs = 0; %1 Trig and response locked, also concatenates across participants for GFX.

job.plot_StimandResplocked_participantaverage =0;
job.plot_StimandResplocked_grandaverage_GFX =0;


% Calculated ERPs, after stratifying by subjective confidence.
job.calc_individualERPsxConfidence =0; %Response locked, also concatenates across participants for GFX.
job.plot_PFXxConf =0;
job.plot_GFXxConf =1;

%% Stimulus and response locked ERPs >
if job.calc_individualERPs == 1 % Trig and response locked, also concatenates across participants for GFX.        
    calcStimandRespERPs;%(basedir, behdatadir) % also concats across subjects.
end

if job.plot_StimandResplocked_participantaverage ==1
    plot_stimandrespERPs;
end

if job.plot_StimandResplocked_grandaverage_GFX ==1
    Plot_GFX_ERPs;    
end

%% Response locked ERPs, by confidence >
if job.calc_individualERPsxConfidence ==1 %Response locked, also concatenates across participants for GFX.
    calcERPsxConfidence;
end
if job.plot_PFXxConf ==1
    Plot_PFX_ERPsxConfidence;
end
if job.plot_GFXxConf ==1
    Plot_GFX_ERPsxConfidence
end
