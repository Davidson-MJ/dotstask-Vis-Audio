% JOBS_ERPsortandaverage

% NB: The script JOBS_MatchEEG2BEH must be run before this one.


clear all
close all

setdirs_DotsAV;
%% jobs list:
% Participant stimulus trigger and response locked ERPs.
job.calc_individualERPs = 0; %1 Trig and response locked, also concatenates across participants for GFX.


job.plot_StimandResplocked_butterfly=0;
job.plot_StimandResplocked_participantaverage =0;
job.plot_StimandResplocked_grandaverage_GFX =0;
job.plot_StimandResplocked_grandaverage_GFX_MS =0;
job.plot_StimandResplocked_grandaverage_GFX_MSv2 =1; % used in MS

job.plot_StimandResplocked_grandaverage_GFX_MS_butterfly=0; % summarise response locked this way.

% Calculated ERPs, after stratifying by subjective confidence.
job.calc_individualERPsxConfidence =0; %Response locked, also concatenates across participants for GFX.
job.plot_PFXxConf =0;
job.plot_GFXxConf=  0;


% Calculated ERPs, after stratifying by RT (both part A and B).
job.calc_individualERPsxRT=0; %Response locked, also concatenates across participants for GFX.
job.plot_PFXxRT =0;
job.plot_GFXxRT=  0;


%% Stimulus and response locked ERPs >
if job.calc_individualERPs == 1 % Trig and response locked, 
    % also concatenates across participants for GFX.        
    calcStimandRespERPs;
end

if job.plot_StimandResplocked_butterfly==1
    plot_stimandrespERPs_butterfly;
end


if job.plot_StimandResplocked_participantaverage ==1
    plot_stimandrespERPs;
end

if job.plot_StimandResplocked_grandaverage_GFX ==1
    Plot_GFX_ERPs;    
end


if job.plot_StimandResplocked_grandaverage_GFX_MS ==1
    Plot_GFX_ERPs_MSver;    
end

if job.plot_StimandResplocked_grandaverage_GFX_MSv2 ==1
    Plot_GFX_ERPs_MSver2;    
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

%% stimulus and response locked by rt

% Calculated ERPs, after stratifying by RT (both part A and B).
if job.calc_individualERPsxRT==1; %Response locked, also concatenates across participants for GFX.
    calc_ERPsxRTs;
end

if job.plot_PFXxRT ==1
    Plot_PFX_ERPsxReactiontime;
end

if job.plot_GFXxRT==  1;
Plot_GFX_ERPsxReactiontime;
end
