% JOBS_ERPsortandaverage

% NB: The script JOBS_MatchEEG2BEH must be run before this one.


clear all
close all

behdatadir = '/Volumes/MattsBackup (2TB)/dotstask- Vis+Audio EXP/Exp_output/DotsandAudio_behaviour/ver2';
figdir ='/Volumes/MattsBackup (2TB)/dotstask- Vis+Audio EXP/Figures';
eegdatadir ='/Volumes/MattsBackup (2TB)/dotstask- Vis+Audio EXP/EEG/ver2';
cd(eegdatadir);
pfols = dir([pwd filesep 'p_*']);

% Participant stimulus trigger and response locked ERPs.
job.calc_individualERPs = 0; %1 Trig and response locked, also concatenates across participants for GFX.

job.plot_StimandResplocked_participantaverage =0;
job.plot_StimandResplocked_grandaverage_GFX =0;


% Calculated ERPs, after stratifying by subjective confidence.
job.calc_individualERPsxConfidence =1; %Response locked, also concatenates across participants for GFX.
job.plot_PFXxConf =0;
job.plot_GFXxConf=  1;

%% Stimulus and response locked ERPs >
if job.calc_individualERPs == 1 % Trig and response locked, also concatenates across participants for GFX.        
    calcStimandRespERPs;
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
