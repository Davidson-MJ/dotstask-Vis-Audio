% Trial_Loop_Conf_only

% 
% For this is second half trial sequence, participants simply
% provide their confidence judgement.

% MDavidson, Jan 2020. mjd070@gmail.com

%keep fix cross on screen:
% - - Flip
Screen('TextSize', window.Number, cfg.fontsize*2);

drawBig=0; % passed into add_fixation to determine fix cross params.
% add fixation
add_fixation;

%also need to add response options, otherwise there will be a visual change
%on screen.
draw_simpleResponseinstructions(window, cfg, stimtype);


% flip and wait before displaying conf j options.
[~, ~,... % system time flip command begins
    flipexec,... % time flip executed
    ~] = Screen('Flip',window.Number, whentoFlipNEW);





%% fill fields of outgoing alltrials structure, to avoid errors in analysis
% later, when comparing to the column indices of the InfoSeeking version.

[alltrials(t).VBLtime_Opt_onset, ...
    alltrials(t).time_Opt_onset,...
    alltrials(t).flip_accuracy_Opt_onset,...
    alltrials(t).respInfoSeek_time, ...
    alltrials(t).respInfoSeek_loc, ... 
    alltrials(t).didrespond_IS, ...
    alltrials(t).ISeek, ...
    alltrials(t).respInfoSeek_loc,...
    alltrials(t).ISeek_rt, ...
    alltrials(t).VBLtime_starttrial2,...
    alltrials(t).time_starttrial2,...
    alltrials(t).flip_accuracy_starttrial2,...
    alltrials(t).VBLtime_stim2pres,...
    alltrials(t).time_stim2pres, ...
    alltrials(t).flip_accuracy_stim2pres,...
    alltrials(t).time_stim2pres, ...
    alltrials(t).time_stim2offset,...
    alltrials(t).VBLtime_stim2offset,...
    alltrials(t).flip_accuracy_stim2offset]= deal(nan);

%% %% COLLECT Conf J RESPONSE, 
  
%     draw_static % redraw boxes, to avoid visual change on screen with mouse click.

%%now allow time period for decoding.
whentoFlip = flipexec+ cfg.stim.TW3; % came from the end of trial loop A

%preload new response options (sliders etc)
draw_static

%flip to show response options.
% - - Flip
[alltrials(t).VBLtime_confj_onset, flipestimate,...
    alltrials(t).time_confj_onset, ...
    alltrials(t).flip_accuracy_confj_onset] =  Screen('Flip', window.Number, whentoFlip);

if cfg.EEG==1
%     trigcode = 88; %onset of conf J response options.
    sendTrig(88, useport)
end


% collect response:
[alltrials(t).confj, alltrials(t).confj_time, ...
    alltrials(t).confj_loc,...
    alltrials(t).confj_didrespond] = ...
    drag_slider(window,cfg, stimtype);

%define whether correct or not, and send trigger.
%define accuracy by location
alltrials(t).confj_cor=  alltrials(t).confj_loc == alltrials(t).whereTrue;
if cfg.EEG==1
    if alltrials(t).confj_cor==1 % correct with confj.
            sendTrig(91, useport);
    else % incorrect
        sendTrig(90, useport);
    end
end
%% store accuracy and reaction time:
% define reaction time (resp - time previous screen flip executed).
alltrials(t).confj_rt = alltrials(t).confj_time- alltrials(t).time_confj_onset;
alltrials(t).confj_cor=  alltrials(t).confj_loc == alltrials(t).whereTrue;

%%
% define next flip time
whentoFlip_NEW = alltrials(t).confj_time + cfg.stim.TW1;
%

%if practice trial, provide error-feedback:
if cfg.giveAudioFeedback==1 && alltrials(t).blockcount<1
    if alltrials(t).confj_cor == 0
        %play matlab error beep
        beep
        %%
    end
    
end

