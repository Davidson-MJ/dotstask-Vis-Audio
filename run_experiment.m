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
% expA=  First half of exp :
% Trial structure:
% [ + ],[ stim1 ],[resp],[ + ]  % on sreen  
% [400],[  300  ],[ spd],[800]  % msec (spd=speeded; timeout after 800ms).
% trial total ~ 1.7s 
 
% expB= seaccond half of exp : [0.7 w/IS; 0.3 wResp now]
% Trial structure:
% [ + ],[ sti  m2a],[resp],[ + ] , [ISc], [ + ],[stim2b],[ + ],[resp] ; % onscreen, ISc=info seeking choice
% [200],[   z15 0  ],[ sp.],[400] , [sp.], [200],[  200 ],[400],[ sp ] ; % msec.
% trial total ~ 3.5s,  
  
%%     
clear all; close all; clc;
%% Experiment pre-requisites.
%what type of experiment are we running?

% Note stimulus order is randomized, based on participant number.
% participant number is determined based on the directories already
% created, in create_subject_directory. 
 
%if debugging, set here:
cfg.df_order='aV';                           % which t   ype o f experiment?
                                             %visual-audio, or audio-visual order. Note that this is overridden in
                                            %create_subject_directory for real experiment.

cfg.offscreen=1;                            % 0 = use builtin, 1=use external monitor.

%% set up load/save directories:
setup_directories;                          % first determines if mac(laptop) or experimental PC (A Watts bldg). 
% record participant info here:
create_subject_directory;                    % if Debugging, empty participant ID field in gui (click 'OK' runs in debug mode).
  
%% set up experiment configuration

configure_parameters;                       % sets all experimental params (ntrials, quit keys, etc) 
build_trials;                               % pre-allocates all practice and experimental trials.

%% RUN EXPERIMENT
Prep_PTBScreenandSound                      %throws PTB screen, defines dotslocation etc.
        
%begin trial loop:s
Trial_loop_all;

%% Save, thank, and shutdown
End_experiment_protocol
