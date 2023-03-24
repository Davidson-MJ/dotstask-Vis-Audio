%cycle through first practice trials, then all experimental trials
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
% in case debugging or restart, allow 2s for first trial, as well as
% initialize relevant PTB dependencies:



% if cfg.debugging==1
%     Initialize PsychSound (since not done in block order).
    cfg.pahandle = PsychPortAudio('Open', [], [], 0, [], 2);
% end

%--- Get the          KbQueue up and running, to monitor for escape keys.
% FlushEvents('keyDown')
% kbdevice = KbCheck;
KbQueueCreate();
KbQueueStart();
% in case we have restarted/rebooted after a crash,
% give the first trial a start time.
time = GetSecs;
whentoFlip_NEW = time+2;

%partBstart = trial index at start of practice for part B (InfoSeek with
%confidence).
ListenChar(2);
for  t  = starttrial:length(alltrials) %starttrial:length(alltrials)
    
    
    %flush    previously held keys:
    KbReleaseWait();
    KbQueueFlush([],3); % reset key-event buffer;
    
    
    
     %% experimenter output (Show details of previous trial)
    if t > 1
        try
            commandwindowOUTPUT
        catch
        end
    end
    
    %% if first trial in practice
     if alltrials(t).trialid== .01 || alltrials(t).xmodtype ~=alltrials(t-1).xmodtype
        
        % if auditory stimui are needed, open psychport audio once (now).
        if strcmp(alltrials(t).stimtype, 'audio') ||  strcmp(alltrials(t).stimtype, 'AUDIO')
            InitializePsychSound
            cfg.pahandle = PsychPortAudio('Open', [], [], 0, [], 2);
        end
        
        
        %% Play correct instructions per experiment type.
        instructions_byXMODtype(window, cfg, alltrials(t).xmodtype)
        time = GetSecs;
        whentoFlip_NEW = time+1;
        
    end
    
    %% Restart staircase if Exp Part B. Define stop trial when staircase
    %should end, as end of staircase length.
    updateStaircase_trialstart;
    
   
    %% save and break if between blocks:
    if alltrials(t).break>0
        tempSave_and_BreakInstructions;        
    end
    
    
    
    %% Run through locked stimulus sequence for first half of presentation
    %note that this sequence will be either visual/auditory, with only first
    % order discrimination.
    trialpos = 'A';
    stimtype = alltrials(t).stimtype;
    
    
    Trial_sequence_partA; %includes practice trials
    
    %check to see if there was an error correction made for this first half
    % discrimination task.
    %get time of last click event.
    lastev =KbEventGet();
    % is this a new click? 
    prevclick_resp = alltrials(t).resp1_time;
%     if lastev.Time >prevclick_resp 
        
%     end
    %% For first half of blocks, no option to see again.
    % otherwise, present option to see again (when relevant).
    if  strcmp(alltrials(t).ExpType, 'B')
        
        % update trial   pos to throw correct instructions/stim timing.
        trialpos= 'B';
        
        
        if cfg.AllowInfoSeeking==1                     
        % In this version, participants have the option to see/hear again,
        % or respond immediately with their confidence:
            
            Trial_Loop_Seeagain_opt;
        else
            %  or respond immediately with their confidence:
            Trial_Loop_Conf_only;
        end
    else
        
        
        %%%%%%%%%%%%%%%% Determine whether audio feedback should be given
        %%%%%%%%%%%%%%%% (within-trial).
        if cfg.giveAudioFeedback==1 % feedback throughout experiment (every trial).
            if (alltrials(t).cor == 0 || isnan(alltrials(t).cor))
                %play matlab error beep
                beep
            end
            
        elseif alltrials(t).blockcount<1 && cfg.giveAudioFeedback==1
            %provide feedback if practice trials
            % error feedback, but only on practice trials
            if (alltrials(t).cor == 0 || isnan(alltrials(t).cor))
                
                %play matlab error beep(?)
                beep
                
            end
        end
    end
    
    
    %% closescreen buffers
    Screen('Close');
    
    %Check if escape key has been pressed
    %Flush previously stored keys (avoids buffer overflow), and begin
    %collecting keys incase of user input to quit.
    
    [~,pressedTiVec] = KbQueueCheck();
    if pressedTiVec(cfg.response.escape)
        % user quit, run escape protocol (saves, displays instructions).
        escape_protocol
        break
    end
end
