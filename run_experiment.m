%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Crossmodal information-seeking task: Dots and auditory discrimination
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% In this version of the experiment participants see two boxes containing dots and have
% to decide which box contains more dots. Participants express their first order
% judgements and confidence in the task and are then presented with an
% option of seeing the stimulus again (or receiving advice) on some trials.

% In other trials, they must commit to their initial choice.

% In other blocks, an auditory discrimination task is presented in place of visual dots
% discrimination.

% After receiving this additional information (viewing / hearing), subjects
% give another first order response and rate their confidence again.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% June 2019 - MD
% - first pilot
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
clear all; close all; clc;

%% Experiment pre-requisites.
%what type of experiment are we running?

isMac=1;
cfg.useAuditorymasks=0;                     % change to 1 for masking auditory tone in white noise. (different aud task).
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
