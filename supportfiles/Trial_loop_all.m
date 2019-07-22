%cycle through first practice trials, then all experimental trials


for t = starttrial : length(alltrials)
    %% experimenter output (Show details of previous trial)
    if t > 1
        disp(['t: ' num2str(t-1)])
        disp(['accuracy1: ' num2str(alltrials(t-1).cor)])
        disp(['confidence1: ' num2str(alltrials(t-1).cj1)])
        if isfield(alltrials,'cor2')
            disp(['accuracy2: ' num2str(alltrials(t-1).cor2)])
            disp(['confidence2: ' num2str(alltrials(t-1).cj2)])
        end
        disp(['obs acc: ' num2str(alltrials(t-1).obsacc)]);
        disp('------------------------------------------');
    end
    %% save and break
    if alltrials(t).break
        %-- Save data every 20th trials
        save([results_path subject.dir '/behaviour/' subject.fileName '_' num2str(round(t/20))],'alltrials', 'cfg', 'subject', 't')
        %-- break
        Screen('TextSize',window.Number,18);
        DrawFormattedText(window.Number, 'Break. Press button to continue','center', 'center', [0 0 0]);
        Screen('Flip', window.Number);
        collect_response(cfg.response, inf);
    end
    %% feedback
    if alltrials(t).feedback % give feedback only between blocks;
        feedback_interblock;
    end
    %% instructions
    if alltrials(t).instr
%         instructions(window, cfg, alltrials(t).block)
    end
    
    %% start trial
    % Clear screen to background color
    
    draw_static
    
    alltrials(t).time_starttrial = Screen('Flip',window.Number);
    
    
    if t == 1 || subject.restart == 1 || alltrials(t).break == 1, time = GetSecs; end
    
    % preparation fixation flash
    draw_static_largeFix
     
    [alltrials(t).largeFix,...
    FlipTimestamp, ...
    alltrials(t).tmissed_largeFix] = Screen('Flip', window.Number, ...
        time + cfg.stim.RSI3 - cfg.frame/2);
    
    %back to normal fixation
    draw_static
     Screen('Flip', window.Number, ...
        time +  cfg.stim.RSI3 + cfg.stim.RSI4 - cfg.frame);

   
    
    %Run staircase for medium difficulty
    if t > 2
        if alltrials(t).difficulty == 2
            alltrials(t).dotdifference = ...
                staircase([currentDotCor(2) currentDotCor(1)], ...
                [currentDotDiff(2) currentDotDiff(1)]); 
            currentDotDiff(2) = currentDotDiff(1);
            currentDotDiff(1) = alltrials(t).dotdifference;
            %Set dotdifference for
        elseif alltrials(t).difficulty == 1
            alltrials(t).dotdifference = currentDotDiff(1)*3;
        elseif alltrials(t).difficulty == 3
            alltrials(t).dotdifference = round(currentDotDiff(1)/3);
        end
    end

    
    larger = 200 + alltrials(t).dotdifference;
    smaller = 200 - alltrials(t).dotdifference;
    
    % vectors are created that contain logical values to tell where
    % dots have to be set in the squares (randomized)
    
    alltrials(t).wheredots(alltrials(t).wherelarger,randsample(400,larger)) = 1;
    alltrials(t).wheredots(3-alltrials(t).wherelarger,randsample(400,smaller)) = 1;
    alltrials(t).wheredots = logical(alltrials(t).wheredots);
    
    %% stimulus presentation
    Screen('DrawLines',window.Number,innerrect1out,3,255);
    Screen('DrawLines',window.Number,innerrect2out,3,255);
    Screen('DrawDots', window.Number, ...
        cfg.xymatrix(:,squeeze(alltrials(t).wheredots(1,:))), ...
        2, 255, center1, 2);
    Screen('DrawDots', window.Number, ...
        cfg.xymatrix(:,squeeze(alltrials(t).wheredots(2,:))), ...
        2, 255, center2, 2);
    
    draw_static
    
    % Show stimulus on screen at next possible display refresh cycle,
    % and record stimulus onset time in 'onsetstim':
    [VBLTimestamp ...
        alltrials(t).onsetstim ...
        FlipTimestamp ...
        alltrials(t).tmissed_onset1] = ...
        Screen('Flip', window.Number, ...
        time + cfg.stim.RSI2 - cfg.frame/2);
    
    % stimulus is shown for 160 ms and the screen turns blank again
    % no response collection before 160 ms
    draw_static
    [VBLts ...
        alltrials(t).offsetstim ...
        Fts ...
        alltrials(t).tmissed_offset1] = ...
        Screen('Flip',window.Number, ...
        alltrials(t).onsetstim + cfg.stim.durstim - cfg.frame/2);
    
    %% pre-advisor decision
    [alltrials(t).cj1, ...
        alltrials(t).resp1_t, ...
        alltrials(t).int1, ...
        alltrials(t).responded1] = drag_slider(window,cfg);
    
    % define accuracy
    alltrials(t).cor = alltrials(t).int1 == alltrials(t).wherelarger;
    
    %if medium difficulty save accuracy for next trial
    if alltrials(t).difficulty == 2
        currentDotCor(2) = currentDotCor(1);
        currentDotCor(1) = alltrials(t).cor;
    end
       
    
    % define reaction times
    alltrials(t).rt = alltrials(t).resp1_t - alltrials(t).offsetstim;
    
    time = alltrials(t).resp1_t;
    
    if isempty(alltrials(t).responded1) %subject did not respond in time
        alltrials(t).cj1           = NaN;
        alltrials(t).resp1_t       = NaN;
        alltrials(t).int1          = NaN;
        alltrials(t).responded1    = NaN;
        alltrials(t).cor           = NaN;
        alltrials(t).rt            = NaN;
    end
    
    
    %% Information type choice
    %For first training blocks don't present information type options
    if  alltrials(t).block < 3
        alltrials(t).adviceTrial    = NaN;
        alltrials(t).subjChoice     = NaN;
        alltrials(t).infoTypeOnset  = NaN;
        alltrials(t).infoRT         = NaN;
        alltrials(t).obsacc         = NaN;
        alltrials(t).agree          = NaN;
        alltrials(t).resp2_t        = NaN;
        alltrials(t).cor2           = NaN;
        alltrials(t).rt2            = NaN;
        alltrials(t).cj2            = NaN;
        alltrials(t).responded2     = NaN;
        alltrials(t).offsetinfoType = NaN;
        
        % Display information type options and get choice
        
    elseif alltrials(t).block >= 3
            draw_static
            [alltrials(t).adviceTrial, ...
            alltrials(t).subjChoice, ...    
            alltrials(t).infoTypeOnset, ...
            alltrials(t).infoRT] = getInfoType(cfg, window, time, alltrials, t); 
            time = alltrials(t).infoRT;
            
            %Draw the fixation cross and boxes in next possible frame
            draw_static
            [VBLts ...
            alltrials(t).offsetinfoType ...
            Fts] = Screen('Flip', window.Number);
            
            time = alltrials(t).offsetinfoType;
            
        %% If view trial 
       if alltrials(t).adviceTrial == 0
            alltrials(t).obsacc = NaN;
             alltrials(t).agree = NaN;
             alltrials(t).onsetAdvice = NaN;
             alltrials(t).offsetAdvice = NaN;
            
            % preparation fixation flash
            draw_static_largeFix
                 Screen('Flip', window.Number, ...
                 time +  cfg.stim.RSI3 - cfg.frame/2);
    
            draw_static
            Screen('Flip', window.Number, ...
                time +  cfg.stim.RSI3 + cfg.stim.RSI4 - cfg.frame/2);
            
            %% stimulus presentation second time
            Screen('DrawLines',window.Number,innerrect1out,3,255);
            Screen('DrawLines',window.Number,innerrect2out,3,255);
            Screen('DrawDots', window.Number, ...
                cfg.xymatrix(:,squeeze(alltrials(t).wheredots(1,:))), ...
                2, 255, center1, 2);
            Screen('DrawDots', window.Number, ...
                cfg.xymatrix(:,squeeze(alltrials(t).wheredots(2,:))), ...
                2, 255, center2, 2);

            draw_static
            % Wait 0.8 sec, display stimulus on screen again,
            % and record stimulus onset time in 'onsetstim': 
            [VBLTimestamp ...
                alltrials(t).onsetstim2 ...
                FlipTimestamp2 ...
                alltrials(t).tmissed_onset2] = ...
                Screen('Flip', window.Number, ...
                time + cfg.stim.RSI2 - cfg.frame/2);
            
            % stimulus is shown for 300 ms and the screen turns blank again

            draw_static;
            [VBLts ...
                alltrials(t).offsetstim2 ...
                Fts2 ...
                alltrials(t).tmissed_offset2] = Screen('Flip',window.Number, ...
                alltrials(t).onsetstim2 + cfg.stim.durstim2 - cfg.frame/2);
          
        %% if Advice trial
        
    elseif alltrials(t).adviceTrial == 1
        
        alltrials(t).onsetstim2 = NaN;
        alltrials(t).offsetstim2 = NaN;
        % get observer accuracy
        alltrials(t).obsacc  = alltrials(t).advCor;

        % define advisor agreement
        if alltrials(t).obsacc == alltrials(t).cor,
            alltrials(t).agree = 1;
        else alltrials(t).agree = 0;
        end
        

        %% display advice
                           
          %Write the advice in center
          draw_static
          display_advice
         
          
          %Draw empty boxes  
          Screen('DrawLines',window.Number,innerrect1out,3,255);
          Screen('DrawLines',window.Number,innerrect2out,3,255);
        
           % Wait 0.3 secs and then show the advice
           [VBLTimestamp ...
                alltrials(t).onsetAdvice ...
                FlipTimestamp2 ...
                alltrials(t).tmissed_onset2] = ...
                Screen('Flip', window.Number, ...
                time + cfg.stim.RSI1 - cfg.frame/2);
            
            % Advice is shown for 1.5 sec and the screen turns blank again
            draw_static;
            [VBLts ... 
                alltrials(t).offsetAdvice ...
                Fts2 ...
                alltrials(t).tmissed_offset2] = Screen('Flip',window.Number, ...
                alltrials(t).onsetAdvice + cfg.stim.durAdv - cfg.frame/2);
           
                       
        end
        %% second decision
            [alltrials(t).cj2, alltrials(t).resp2_t, alltrials(t).int2, alltrials(t).responded2] = ...
                drag_slider(window,cfg,alltrials(t).cj1);
            
            % define accuracy
            alltrials(t).cor2 = alltrials(t).int2 == alltrials(t).wherelarger;
            % define reaction times
            if alltrials(t).adviceTrial == 1
                alltrials(t).rt2 = alltrials(t).resp2_t - alltrials(t).offsetAdvice;
            elseif alltrials(t).adviceTrial == 0
                alltrials(t).rt2 = alltrials(t).resp2_t - alltrials(t).offsetstim2;
            end
            time = alltrials(t).resp2_t;


    end
                  
    %% compute timing variables
    alltrials(t).act_stimdur       = alltrials(t).offsetstim - alltrials(t).onsetstim;
    if t>1
        alltrials(t-1).RSI2        = alltrials(t).onsetstim - alltrials(t-1).resp2_t;
    end
    if alltrials(t).adviceTrial == 1
        alltrials(t).act_advicedur = alltrials(t).offsetAdvice - alltrials(t).onsetAdvice; %advice duration
        alltrials(t).RSI1          = alltrials(t).onsetAdvice - alltrials(t).offsetinfoType; %time between info choice and advice
        alltrials(t).act_stimdur2 = NaN;
    elseif alltrials(t).adviceTrial == 0
        alltrials(t).act_advicedur = NaN;
        alltrials(t).RSI1          = NaN;
        alltrials(t).act_stimdur2  = alltrials(t).offsetstim2 - alltrials(t).onsetstim2;  %stim2 duration
        %time between info choice and confidence
    else
        alltrials(t).act_advicedur = NaN;
        alltrials(t).act_stimdur2 = NaN;
        alltrials(t).RSI1         = NaN; 
        alltrials(t).RSI3         = NaN;
    end
    
    %% closescreen buffers
    Screen('Close');
    
    %% error feedback, but only on practice trials
    if alltrials(t).block <=2
        if (alltrials(t).cor == 0 || isnan(alltrials(t).cor))
            pahandle = PsychPortAudio('Open', [], [], 0, [], 2);
            PsychPortAudio('FillBuffer', pahandle, ...
                repmat(cfg.stim.beep.*cfg.stim.beepvolume,2,1));
            PsychPortAudio('Start', pahandle, 1, 0, 1);
            PsychPortAudio('Close',pahandle);
        end
    end

end
alltrials(end).RSI2 = NaN;