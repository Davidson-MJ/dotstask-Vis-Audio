%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Crossmodal information-seeking task: Dots and auditory discrimination
% In this version of the experiment participants see two boxes containing dots and have
% to decide which box contains more dots. Participants express their first order
% judgements and confidence in the task and are then presented with an
% option of seeing the stimulus again on some trials.
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
% Timings:
% Fixation (800 ms - RSI2): 400ms (small fixation, RSI3) ->  big fixation (100 ms RSI4) - > small fix (300 ms) 
%Dot duration: 150ms
%First decision (free time)
%If view trial: fixation (same as previous) -> stimulus  300 ms - > second decision
%Advice trial:  300 ms fixation (RSI1)-> advice is displayed (1500 ms) -> second decision
%%
clear all; close all; clc;

%% Experiment pre-requisites.
% set up load/save directories:
setup_directories; % first determines if mac(laptop) or experimental PC (A Watts bldg). 
% record participant info
create_subject_directory; % if Debugging participant = " " (runs in debug mode).
%%
configure_parameters; %sets all experimental params (ntrials, quit keys, etc) 

% % % % % quick adjust key parameters:
% cfg.nblocksprac     = 3;
% cfg.
% % % % %
% build_trials; %based on above, pre-allocates all practice and experimental trials.
%%
