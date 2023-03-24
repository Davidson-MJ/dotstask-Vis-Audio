%         Trial_Loop_Seeagain_opt;
% this is the second half trial sequence, in which participants either
% receive an option to see/hear the stimulus again, or have to simply
% provide their confidence judgement.

% MDavidson, Aug 2019. mjd070@gmail.com


%% First we will draw the appropriate responses screen.
if strcmp(alltrials(t).SeeAgainOpt, 'n')
    % no option on screen.
    % provide confidence straight away:
    RespondnowTextoption;
    
elseif strcmp(alltrials(t).SeeAgainOpt, 'y')    
    % draw see/ hear again options on screen.
    SeeAgainTextOption;
end

%% progress with instructions
Screen('TextSize', window.Number, cfg.fontsize);

% flip to show the option on screen.
[alltrials(t).VBLtime_Opt_onset, ~, ...
    alltrials(t).time_Opt_onset,...
    alltrials(t).flip_accuracy_Opt_onset] = Screen('Flip',window.Number, whentoFlip_NEW);

% Trigger
if cfg.EEG==1
%     trigcode = 5;  % 1 = trialstart, 2,3 = Vis,Aud stim, 5= InfoSeeking
%     opt onset.
    sendTrig(5, useport)
end

% collect and show participant choice on screen,
[~, ...
    alltrials(t).respInfoSeek_time, ...
    alltrials(t).respInfoSeek_loc, ... % left or right
    alltrials(t).didrespond_IS] = fill_mouseboxes(window,cfg, alltrials(t).time_Opt_onset, stimtype,trialpos);


%define choice by location
if strcmp(alltrials(t).SeeAgainOpt, 'y')
    if alltrials(t).respInfoSeek_loc==1
        alltrials(t).ISeek=   1;
        trigcode=51;
    else
        alltrials(t).ISeek=   0;
        trigcode=52;
    end
elseif strcmp(alltrials(t).SeeAgainOpt, 'n') % no option
    alltrials(t).ISeek=   0;
    alltrials(t).respInfoSeek_loc =2; %distinguish for analysis.
    trigcode = 53;
end

% send Trigger to identify prev choice.
if cfg.EEG==1
    %trigcode defined above. Based on selection made.
    sendTrig(trigcode, useport)
end

%store choice and reaction time:
% define reaction time (resp - time previous screen flip executed).
alltrials(t).ISeek_rt = alltrials(t).respInfoSeek_time- alltrials(t).time_Opt_onset;


%% continue with trial presentation (second round), regardless of if info-seeking
% was selected, make sure same time has elapsed between flips:
%so draw small fix cross

whentoFlip = whentoFlip_NEW+cfg.stim.TW1;

%% -- INTERVAL 1a --  small fixation cross on screen
% this is displayed for cfg.stim.TW1, indicating start of a trial.
Screen('TextSize', window.Number, cfg.fontsize*2);
drawBig=0; % passed into add_fixation to determine fix cross parameters.
% add fixation
add_fixation;

% - - Flip to show small FIX CROSS:
% collect trial start time (in VBL stamps). Note that first output is
% when flip command began, third is when finished:

%flip now (fix cross on screen only):
[alltrials(t).VBLtime_starttrial2, flipestimate,... % system time flip command begins
    alltrials(t).time_starttrial2,... % time flip executed
    alltrials(t).flip_accuracy_starttrial2] = Screen('Flip',window.Number, whentoFlip);



%% next flip will be after fixcross time has elapsed:
%flip when stim is ready
stimpresFlip = flipestimate + cfg.stim.TW1  ; %

if alltrials(t).ISeek ==1
    %rerun the stimulus:
    % very similar to A, just changing variable names that are output
    % and saving accordingly.
    
    %% depending on STIMULUS category, present either dots or tones:
    switch alltrials(t).stimtype
        case {'visual', 'VISUAL'}
            %% Repeat the drawing of Dots from Part A:
            %draw frame
            % defined in 'define_boxes.m'
            Screen('FrameRect', window.Number,[255 255 255], rect1, pix_framewidth);
            Screen('FrameRect', window.Number,[255 255 255], rect2, pix_framewidth);
            
            %Left
            Screen('DrawDots', window.Number, ...
                cfg.xymatrix(:,squeeze(alltrials(t).wheredots(1,:))), ...
                dotsize, 255, center1, 2);
            %Right
            Screen('DrawDots', window.Number, ...
                cfg.xymatrix(:,squeeze(alltrials(t).wheredots(2,:))), ...
                dotsize, 255, center2, 2);
            
            
            %                 draw_static_largeFix;% draw response options.
            
            % Show stimulus on screen at next possible display refresh cycle,
            % and record stimulus onset time in 'onsetstim':
            
            % -   - Flip
            [alltrials(t).VBLtime_stim2pres, flipestimate,...
                alltrials(t).time_stim2pres, ...
                alltrials(t).flip_accuracy_stim2pres] =  Screen('Flip', window.Number, stimpresFlip);
            
            if cfg.EEG==1
%                 trigcode = 202; % vis onset (part B).
                sendTrig(202, useport)
            end
            
            
        case {'audio', 'AUDIO'}
            
            %% Repeat the tones defined in part A:
            
            PsychPortAudio('FillBuffer', cfg.pahandle, chanDATA);
            %flip to show fix cross, also collect timings.
            Screen('TextSize', window.Number, cfg.fontsize*2);
            drawBig=0; % passed into add_fixation to determine fix cross params.
            % add fixation
            add_fixation;
            
            % - - Flip (empty, no actual stim other than fix cross)
            [alltrials(t).VBLtime_stim2pres, flipestimate,...
                alltrials(t).time_stim2pres, ...
                alltrials(t).flip_accuracy_stim2pres] =  Screen('Flip', window.Number, stimpresFlip);
             
            %             tic
            %present AUDIO tones, require response after cfg.durstim.
            PsychPortAudio('Start', cfg.pahandle, 1); 
            
            %             toc
            %             elapsed = toc-tic
            if cfg.EEG==1
%                 trigcode = 203; % vis onset (part B).
                sendTrig(203, useport)
            end
            
            
    end
    
    
else %no second stim presentation, leave the cross on screen, but record timings:
    Screen('TextSize', window.Number, cfg.fontsize*2);
    drawBig=0; % passed into add_fixation to determine fix cross params.
    % add fixation
    add_fixation;
    
    % - - Flip (empty, no actual stim other than fix cross)
    [alltrials(t).VBLtime_stim2pres, flipestimate,...
        alltrials(t).time_stim2pres, ...
        alltrials(t).flip_accuracy_stim2pres] =  Screen('Flip', window.Number, stimpresFlip);
    
    %trigger
    if cfg.EEG==1
%         trigcode = 204; % blank, just a place holder for comparative analysis to vis and audio conditions.
        sendTrig(204, useport)
    end
    
end

%in both cases, we will now wait until the stim duration has passed, before continuing.
%end of 2nd stim presentation.
endstimFlip =   alltrials(t).time_stim2pres + cfg.stim.durstim;

%keep fix cross on screen:
% - - Flip
Screen('TextSize', window.Number, cfg.fontsize*2);
drawBig=0; % passed into add_fixation to determine fix cross params.
% add fixation
add_fixation;

[alltrials(t).VBLtime_stim2offset, flipestimate,...
    alltrials(t).time_stim2offset, ...
    alltrials(t).flip_accuracy_stim2offset] =  Screen('Flip', window.Number, endstimFlip);

%% %% COLLECT timing of RESPONSE, 
  
    draw_static % redraw boxes, to avoid visual change on screen with mouse click.
%     
%         [~, ...
%         alltrials(t).resp2_time, ...
%         alltrials(t).resp2_loc, ... % left or right
%         alltrials(t).didrespond_2] = fill_mouseboxes(window,cfg, alltrials(t).time_stim2offset, stimtype,trialpos);

    % define reaction time (resp - time previous screen flip executed).
%         alltrials(t).rt2 = alltrials(t).resp2_time- alltrials(t).time_stim2offset;
    % define accuracy by location    
%         alltrials(t).cor2=  alltrials(t).resp2_loc == alltrials(t).whereTrue;        
      
        %send accuracy and location defined trigger
%         % Trigger
%         if cfg.EEG==1        
%            %codes are 110 for left click incorrect,
%            % 111 for left click correct
%            % 120 for right incorrect
%            % 121 for right correct#
%            
%             trigcode = 100 + alltrials(t).resp2_loc*10 + alltrials(t).cor2;
%             sendTrig(trigcode, useport)
%         end
%%


%%now allow time period for decoding.
whentoFlip = flipestimate + cfg.stim.TW3;

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

