% JOBS_ERPsortandaverage

% NB: The script JOBS_MatchEEG2BEH must be run before this one.


clear all
close all

addpath(genpath('C:\Github\dotstask-Vis-Audio'));
% addpath('/Users/matthewdavidson/Documents/GitHub/dotstask-Vis-Audio/Analysis/')
%update to work on external volume:
homedir = 'C:\Users\mdav0285\OneDrive - The University of Sydney (Staff)\Documents\dotstask- Vis+Audio EXP';

behdatadir = [homedir filesep 'Exp_output/DotsandAudio_behaviour/ver2'];
figdir =[homedir filesep 'Figures'];
eegdatadir =[homedir filesep 'EEG/ver2'];
cd(eegdatadir)
pfols = dir([pwd filesep '*p_*']);

%remove any hidden files (onedrive corrupts the fileist).
pfols = striphiddenFiles(pfols); 

%% jobs list:
% Participant stimulus trigger and response locked ERPs.
job.calc_individualERPs = 1; %1 Trig and response locked, also concatenates across participants for GFX.

job.plot_StimandResplocked_participantaverage =0;
job.plot_StimandResplocked_grandaverage_GFX =0;
job.plot_StimandResplocked_grandaverage_GFX_MS =1;


% Calculated ERPs, after stratifying by subjective confidence.
job.calc_individualERPsxConfidence =0; %Response locked, also concatenates across participants for GFX.
job.plot_PFXxConf =0;
job.plot_GFXxConf=  0;

%% Stimulus and response locked ERPs >
if job.calc_individualERPs == 1 % Trig and response locked, 
    % also concatenates across participants for GFX.        
    calcStimandRespERPs;
end

if job.plot_StimandResplocked_participantaverage ==1
    plot_stimandrespERPs;
end

if job.plot_StimandResplocked_grandaverage_GFX ==1
    Plot_GFX_ERPs;    
end


if job.plot_StimandResplocked_grandaverage_GFX_MS ==1
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
