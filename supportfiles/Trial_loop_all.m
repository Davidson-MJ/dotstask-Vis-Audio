%cycle through first practice trials, then all experimental trials

%listen for pause or quit keys:

ListenChar(2); %suppresses output to matlab windows.

for  t  =  starttrial : length(alltrials)
    
  
    %% if first trial in practice
    if alltrials(t).trialid== .01 
    
        % if auditory stimui are needed, open psychport audio once (now).
        if strcmp(alltrials(t).stimtype, 'audio') ||  strcmp(alltrials(t).stimtype, 'AUDIO')
            InitializePsychSound
            cfg.pahandle = PsychPortAudio('Open', [], [], 0, [], 2);
        end
        
        
        %% Play correct instructions per experiment type.
        instructions_byXMODtype(window, cfg, alltrials(t).xmodtype)
        
        time = GetSecs;
        whentoFlip_NEW = time+2;
        
    end
    
    %% Restart staircase if Exp Part B. Define stop trial when staircase
    %should end.
    updateStaircase_trialstart;
    
    %% experimenter output (Show details of previous trial)
    if t > 1
        commandwindowOUTPUT
    end
    %% save and break if between blocks:
    if alltrials(t).break
        tempSave_and_BreakInstructions;
    end
    
    %     %% feedback
    %     if alltrials(t).feedback % give feedback only between blocks;
    %         feedback_interblock;
    %     end
    
    
    
    %% Run through locked stimulus sequence for first half of presentation
    %note that this sequence will be either visual/auditory, with only first
    % order discrimination.
    
    Trial_sequence_partA;
    
    
    %% For first half of blocks, no option to see again.
    % otherwise, present option to see again (when relevant).
    if  strcmp(alltrials(t).ExpType, 'B')
        
        %come back to this code.
        error('code unfinished')
        Trial_Loop_Seeagain_opt;
        
        
        [alltrials(t).cj1, ...
            alltrials(t).resp1_t, ...
            alltrials(t).int1, ...
            alltrials(t).responded1] = drag_slider(window,cfg);
        %          %% second decision
        %             [alltrials(t).cj2, alltrials(t).resp2_t, alltrials(t).int2, alltrials(t).responded2] = ...
        %                 drag_slider(window,cfg,alltrials(t).cj1);
        %
        %             % define accuracy
        %             alltrials(t).cor2 = alltrials(t).int2 == alltrials(t).whereTrue;
        %             % define reaction times
        %             if alltrials(t).adviceTrial == 1
        %                 alltrials(t).rt2 = alltrials(t).resp2_t - alltrials(t).offsetAdvice;
        %             elseif alltrials(t).adviceTrial == 0
        %                 alltrials(t).rt2 = alltrials(t).resp2_t - alltrials(t).offsetstim2;
        %             end
        %             time = alltrials(t).resp2_t;
        
        
        
    end
    
    
    %Save data from this trial.
    
    %% %%%%%%%%%% PRESENTATION END < store data.
    
    %     %% compute timing variables
    %     %actual stimulus presentation:
    %     alltrials(t).act_stimdur       = alltrials(t).offsetstim - alltrials(t).onsetstim;
    % %
    % %     if t>1
    % %         alltrials(t-1).RSI2        = alltrials(t).onsetstim - alltrials(t-1).resp2_t;
    % %     end
    % %
    %
    %     if strcmp(alltrials(t).SeeAgainOpt, 'y') % if stim presented again.
    %
    %         alltrials(t).RSI1          = NaN;
    %         alltrials(t).act_stimdur2  = alltrials(t).offsetstim2 - alltrials(t).onsetstim2;  %stim2 duration
    %         %time between info choice and confidence
    %
    %     end
    
    %% closescreen buffers
    Screen('Close');
    
    % error feedback, but only on practice trials
    if alltrials(t).blockcount<1
        if (alltrials(t).cor == 0 || isnan(alltrials(t).cor))
            %             pahandle = PsychPortAudio('Open', [], [], 0, [], 2);
            %             PsychPortAudio('FillBuffer', pahandle, ...
            %                 repmat(cfg.stim.beep.*cfg.stim.beepvolume,2,1));
            %             PsychPortAudio('Start', pahandle, 1, 0, 1);
            %             PsychPortAudio('Close',pahandle);
            
            %play matlab error beep
            beep
            %%
        end
    end
    
    %check to see if   quit keys have been pressed
%     keyspressed = GetChar;
    
   
    
end
