%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Crossmodal information-seeking task: Dots and auditory discrimination
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% In this version of the experiment participants peform either a visual or 
% audisctory discrimintion task in the first half of the experiment.
% 
% All participants then perform the alternate modality (vis or aud) in the 
% second half.
% In this second half, 70   % of trials will have the option to see/hear the 
% stimulus again. 30% are forced response (no option to see again).

% VisTask = dots (choose left/right)
% AudTask = pitch discrimination (first/second tone higher pitch)
 
%%%%%%%%%%%%%%%%%%%%%%%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% June 2019 - MD
% updated Feb 2020, removing the information seeking portion for exp 1.
% - Matt Davidson
% - mjd070 at gmail.com
%%%%%%%%%%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% expA=  First half of exp :
% Trial structure:
% [ + ],[ stim1 ],[resp],[ + ]  % on sreen  
% [TW1],[  stimdur  ],[ spd],[TW3]  % msec (spd=speeded; timeout after 800ms).
% TW and stimdur set in configure parameters.
 
% expB= second half of exp : [0.7 w/IS; 0.3 wResp now]
% Trial structure:
% [ + ],[ stim2],  [resp], [ + ] , [ISc], [ + ], [stim2b],   [ + ], [resp] ; % onscreen, ISc=info seeking choice
% [TW1],[  stimdur],[ spd.],[TW3] , [sp.], [TW1],[  stimdur ],[TW3, [ sp ] ; % msec.
%  
  
%%     
clear all;% close all; clc;
%% Experiment pre-requisites.
%what type of experiment a re we running?

% Note stimulus order is randomized, based on participant number.
% participant number is determined based on the directories already
% created, in create_subject_directory. 
 cfg.offscreen=1;
%if debugging, set here, ...and>>
cfg.debugging=1;
%>>>> and define cfg.df_order:
% cfg.df_order = 'aV';


cfg.AllowInfoSeeking=0;                     % if set to 1, then second half
                                            % of experiment has an
                                            % additional response stage, asking
                                            % whether participants want to
                                            % see/hear the stim again, or
                                            % respond straight away.
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
End_experiment_protocol;
