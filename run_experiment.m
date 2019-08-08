%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Crossmodal information-seeking task: Dots and auditory discrimination
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% In this version of the experiment participants peform either a visual or 
% auditory discrimintion task in the first half of the experiment.
% 
% All participants then perform the alternate modality (vis or aud) in the 
% second half.
% In this second half, 75% of trials will have the option to see/hear the 
% stimulus again. 25% are forced respons e (no option to see again).

% VisTask = dots (choose left/right)
% AudTask = pitch discrimination (first/second tone higher pitch)
 
%%%%%%%%%%%%%%%%%%%%%%%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% June 2019 - MD      
% - first pilot
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% expA=  First half of exp : (n=300)
% Trial structure:
% [ + ],[ stim1 ],[resp],[ + ]  % on sreen  
% [200],[  150  ],[ spd],[400]  % msec (spd=speeded).
% trial total ~ 1.5s 

% expB= second half of exp : (n=420) [0.7 w/IS; 0.3 wResp now]
% Trial structure:
% [ + ],[ sti  m2a],[resp],[ + ] , [ISc], [ + ],[stim2b],[ + ],[resp] ; % onscreen, ISc=info seeking choice
% [200],[   z15 0  ],[ sp.],[400] , [sp.], [200],[  200 ],[400],[ sp ] ; % msec.
% trial total ~ 3.5s, 
  
%% 
clear all; close all; clc;
%% Experiment pre-requisites.
%what type of experiment are w  e running?

% Note stimulus order is randomized, based on participant number.
% participant number is determined based on the directories already
% created, in create_subject_directory.

% df_order=0;                                 % set to 1 for first PP, sets exp order.
cfg.df_order='aV';

cfg.offscreen=0;                            % 0 = use builtin, 1=use external monitor.
cfg.giveAudiofeedback=0;                    % change to 1 to provide beeps when correct/incorrect.
cfg.useInfoSeeking_or_Advice=1;             % change to 1 to include 'see again' as the option, 2 for advice from an agent.

%% set up load/save directories:
setup_directories;                          % first determines if mac(laptop) or experimental PC (A Watts bldg). 
% record participant info here:
create_subject_directory;                   % if Debugging, empty participant ID field in gui (click 'OK' runs in debug mode).
  
%% set up experiment configuration

configure_parameters;                       % sets all experimental params (ntrials, quit keys, etc) 

build_trials;                               % pre-allocates all practice and experimental trials.

%% RUN EXPERIMENT
Prep_PTBScreenandSound                      %throws PTB screen, defines dotslocation etc.

%begin trial loop:
Trial_loop_all;

%% Save and shutdown
End_experiment_protocol
