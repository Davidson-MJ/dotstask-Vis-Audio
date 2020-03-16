% Job list for ERP data from pilot visual and auditory experiment.

%plot data for ERPs:

clear variables
close all
basedir= '/Users/mdavidson/Desktop/dotstask- Vis+Audio EXP';
addpath([basedir filesep 'Analysis'])
cd(basedir);
cd('EEG');
pfol=dir([pwd filesep 'p_*']);
%%


% as some participants had breaks / crashses, run this step once.
job.correctTriggereventindex_forexpBreaks=0;


% Participant stimulus trigger and response locked ERPs.
job.calc_individualERPs = 0; % Trig and response locked, also concatenates.
job.calc_individualERPs_wholetrial = 0; % Trig and response locked, also concatenates.

%plotting:
job.plot_individualERPs=0;
job.plot_GFXERPs =0;

% Now begins the analysis for combining with behavioural data.

job.calc_PFX_ERPs_xConfidence =0 ; %only works for part B obviously. Participant level, then concatenates

job.plot_PFX_ERPs_xConfidence=0;
job.plot_GFX_ERPs_xConfidence =1 ; %only works for part B obviously. Participant level

%%
% >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
% >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
% >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
% >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
% >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
if job.correctTriggereventindex_forexpBreaks==1
    % We have already corrected the behavioural data to = 780 trials, in
    % AA_Adjust_behavioural_output_data;
    AA_Adjust_Trigger_output_data;
end

if job.calc_individualERPs ==1
    calc_individualERPs;
end

if job.calc_individualERPs_wholetrial == 1 %wholetrial, keeps the order intact.
calc_individualERPs_wholetrial
end
%%
if job.plot_individualERPs ==1   %% PLOT each type:
    % %this script prints Stimulus locked and response locked ERPs per
    %pariticopant, in this same folder.
    Plot_PFX_ERPs; % stimulus locked and response locked.
end

%%
if job.plot_GFXERPs == 1
    %plot stimulus and response locked ERPs.
    Plot_GFX_ERPs;
end

if job.calc_PFX_ERPs_xConfidence ==1  %only works for part B obviously. Participant level, then concatenates
    calc_individualERPsxConf
end

if job.plot_PFX_ERPs_xConfidence==1
    Plot_PFX_ERPsxConfidence;
end
if job.plot_GFX_ERPs_xConfidence==1
    Plot_GFX_ERPsxConfidence;
end
