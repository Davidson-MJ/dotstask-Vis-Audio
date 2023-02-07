% Trial_sequence_partA

% displays stimuli in sequence after waiting the correct amount of time
% between each flip interval.

%% we in the first or second half of experiment?
% if so, add 100 to the trigger values in this part of the experiment.
addtoTrigger = strcmp(alltrials(t).ExpType, 'B')*100; 

%% for partA, we want left / right click, so hide the cursor.
if cfg.debugging~=1
    HideCursor
end
%% -- INTERVAL 1a --  small fixation cross on screen, with response options 
    % this is displayed for cfg.stim.TW1, indicating start of a trial.
    % a blank screen is displayed with small fixation cross.
     
    %Note that whentoFlip_NEW is defined by previous trial.
    
    draw_static; % draw fix cross and response options
    
    
    %add jitter to stim ITI (range between .1 and .3, total then .3 to .5:
jitr=.1 + (.3-.1).*rand(1);
whentoFlipNEW = whentoFlip_NEW + jitr;
    
% - - Flip to show small FIX CROSS: 
    % collect trial start time (in VBL stamps). Note that first output is
    % when flip command began, third is when finished:
    
    [alltrials(t).VBLtime_starttrial, flipestimate,... % system time flip command begins
        alltrials(t).time_starttrial,... % time flip executed
        alltrials(t).flip_accuracy_starttrial] = Screen('Flip',window.Number, whentoFlip_NEW);
    
%%%%%% Trigger code for screen flip performed (start of trial).
%send trigger code to EEG for block begin:
        % Trigger
        if cfg.EEG==1        
            trigcode = 1+addtoTrigger;  % start of all trials with '01' or '101'
            sendTrig(trigcode, useport)
        end
        
%% STIMULUS PRESENTATION     

%enable the next flip, a designated time after the previous fixation cross
%has been on screen.
whentoFlip = flipestimate +cfg.stim.TW1; %
   
    %% depending on STIMULUS category, present either dots or tones:
    switch alltrials(t).stimtype
        case {'visual', 'VISUAL'}
            
            
            %draw dots on screen, leave there for cfg.durstim.
            
            DrawDotsOnScreen;    % draw dots
            draw_static;         % draw response options.
            
            % Show stimulus on screen at next possible display refresh cycle,
            % and record stimulus onset time in 'onsetstim':
            
                         % Trigger
        if cfg.EEG==1        
            trigcode = 2+addtoTrigger;  % 02 for visual, 03 for auditory (below)
            sendTrig(trigcode, useport)
        end
        
            % - - Flip

            [alltrials(t).VBLtime_stim1pres, flipestimate,...
                alltrials(t).time_stim1pres, ...
                alltrials(t).flip_accuracy_stim1pres] =  Screen('Flip', window.Number, whentoFlip);
        

        case {'audio', 'AUDIO'}
        
            % determine audio tones based on staircasing:
            FillAudiointoBuffer;
            draw_static;         % draw response options.
            
            % - - Flip (empty, no actual stim other than fix cross)
           [alltrials(t).VBLtime_stim1pres, flipestimate,...
                alltrials(t).time_stim1pres, ...
                alltrials(t).flip_accuracy_stim1pres] =  Screen('Flip', window.Number, whentoFlip);
             
             % Trigger
        if cfg.EEG==1        
            trigcode = 3+addtoTrigger;%
            sendTrig(trigcode, useport)
        end
        
            %% present AUDIO tones, require response after cfg.durstim.            
%            tic
            PsychPortAudio('Start', cfg.pahandle, 1);
%             toc
       

    end
 %% Remove stimulus to show only response screen and instructions.
 
% - - fill buffer:
    % stimulus is now on screen. Shown for cfg.stim.durstim, then collect
    % response.
    whentoFlip = flipestimate + cfg.stim.durstim;    
    %prep response screen   
    %draws instructions only (Left click or right click).    
    
    draw_static;
    
    
% - - Flip
 [alltrials(t).VBLtime_stim1offset, ~,... 
     alltrials(t).time_stim1offset, ...
     alltrials(t).flip_accuracy_stim1offset] =  Screen('Flip', window.Number, whentoFlip);
    
%% %% COLLECT timing of RESPONSE, 
  
    draw_static % redraw boxes, to avoid visual change on screen with mouse click.
    
        [~, ...
        alltrials(t).resp1_time, ...
        alltrials(t).resp1_loc, ... % left or right
        alltrials(t).didrespond] = fill_mouseboxes(window,cfg, alltrials(t).time_stim1offset, stimtype,trialpos);

    % define reaction time (resp - time previous screen flip executed).
        alltrials(t).rt = alltrials(t).resp1_time- alltrials(t).time_stim1pres;
    % define accuracy by location    
        alltrials(t).cor=  alltrials(t).resp1_loc == alltrials(t).whereTrue;        
      
        %send accuracy and location defined trigger
        % Trigger
        if cfg.EEG==1        
           %codes are 10 for left click incorrect,
           % 11 for left click correct
           % 20 for right incorrect
           % 21 for right correct#
           % adds 100 if second half of exp
           
            trigcode = alltrials(t).resp1_loc*10 + alltrials(t).cor + addtoTrigger;
            sendTrig(trigcode, useport)
        end

        
        %note that the staircase update
        
    %% revert to small fixation cross: 
    
 
    % define time, then wait appropriate interval before either saving
    % (expA), or continuing trial (expB).         
    time = alltrials(t).resp1_time;   
    
    % remove response screen, show small cross (for decoding)
    whentoFlip_NEW = time + cfg.stim.TW3;%/2;        
 
    
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
    
  