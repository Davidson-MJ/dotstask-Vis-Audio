% Trial_sequence_partA

% displays stimuli in sequence after waiting the correct amount of time
% between each flip interval.



%% -- INTERVAL 1a --  small fixation cross on screen 
    % this is displayed for cfg.stim.TW1, indicating start of a trial.
    % a blank screen is displayed with small fixation cross, which
    % increases in size (next step) before stim presentation.
     
    
    %Note that whentoFlip_NEW is defined by previous trial.
    
    draw_static_largeFix; % draw fix cross and response options
    
% - - Flip to show small FIX CROSS: 
    % collect trial start time (in VBL stamps). Note that first output is
    % when flip command began, third is when finished:
    
    [alltrials(t).VBLtime_starttrial, flipestimate,... % system time flip command begins
        alltrials(t).time_starttrial,... % time flip executed
        alltrials(t).flip_accuracy_starttrial] = Screen('Flip',window.Number,whentoFlip_NEW);
    
%% -- INTERVAL 1b -- Larger fixation cross on screen.
    % preparation fixation flash: displayed for short duration.
% - - Fill buffer
 % note that this flip needs to be appropriate time after first fix
    % cross   
    
    whentoFlip = flipestimate + cfg.stim.TW1;  %% if small cross has been on for long enough  
        
    draw_static_largeFix;     
    
    %flip screen to show larget fixation cross, and record flip intervals.   
% - - Flip  
    %flip to show large cross (once time elapsed).    
    [alltrials(t).VBLtime_largeFix, flipestimate,...
       alltrials(t).time_largeFix,...
       alltrials(t).flip_accuracy_largeFix] = Screen('Flip', window.Number, ...
        whentoFlip);       
%%   
%% STIMULUS PRESENTATION     
% - - Fill buffer    
    %prep small cross for next interval
    whentoFlip = flipestimate + cfg.stim.TW2; %if large fix cross has been up long enough
    
    
    
    %% depending on STIMULUS category, present either dots or tones:
    switch alltrials(t).stimtype
        case {'visual', 'VISUAL'}
            
            
            %draw dots on screen, leave there for cfg.durstim.
            
            DrawDotsOnScreen;    % draw dots
            draw_static_largeFix;% draw response options.
            
            % Show stimulus on screen at next possible display refresh cycle,
            % and record stimulus onset time in 'onsetstim':
            
            % - - Flip
            [alltrials(t).VBLtime_stim1pres, flipestimate,...
                alltrials(t).time_stim1pres, ...
                alltrials(t).flip_accuracy_stim1pres] =  Screen('Flip', window.Number, whentoFlip);
        
        
        case {'audio', 'AUDIO'}
        
            % determine audio tones based on staircasing:
            FillAudiointoBuffer;
            
            
            %present AUDIO tones, require response after cfg.durstim.            
          alltrials(t).time_stim1pres=  PsychPortAudio('Start', cfg.pahandle, 1, whentoFlip);

            flipestimate=alltrials(t).time_stim1pres;
            
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
 [alltrials(t).VBLtime_stim1offset, flipestimate,... 
     alltrials(t).time_stim1offset, ...
     alltrials(t).flip_accuracy_stim1offset] =  Screen('Flip', window.Number, whentoFlip);
    
%% %% COLLECT timing of RESPONSE, also show on screen
  
        [~, ...
        alltrials(t).resp1_time, ...
        alltrials(t).resp1_loc, ... % left or right
        alltrials(t).didrespond] = fill_mouseboxes(window,cfg, alltrials(t).time_stim1offset);
   
    
    %if timed-out:
    if isempty(alltrials(t).didrespond)
        alltrials(t).resp1_time    = NaN;
        alltrials(t).resp1_loc     = NaN;
       
        alltrials(t).cor           = NaN;
        alltrials(t).rt            = NaN;
    
    else %store accuracy and reaction time:
    
    % define reaction time (resp - time previous screen flip executed).
        alltrials(t).rt = alltrials(t).resp1_time- alltrials(t).time_stim1offset;
    %define accuracy by location    
        alltrials(t).cor=  alltrials(t).resp1_loc == alltrials(t).whereTrue;        
    end
    
           
    %% revert to small fix cross: 
    
 
    % define time, then wait appropriate interval before either saving
    % (expA), or continuing trial (expB).         
    time = alltrials(t).resp1_time;   
    
    % remove given response from screen after cfg.stim.TW1/2 (So no trials miss visual feedback).
    whentoFlip = time + cfg.stim.TW1/2;        
    
    draw_static;
        
% - - Flip
     [alltrials(t).VBLtime_fixreturn, flipestimate,... 
     alltrials(t).time_fixreturn, ...
     alltrials(t).flip_accuracy_fixreturn] = Screen('Flip',window.Number, whentoFlip);
    
    
    %% define next flip time (how long fix cross will now remain on screen.
    
    whentoFlip_NEW = flipestimate + cfg.stim.TW3;
    
    %note that this flip time carries to limit start time of next trial (i.e. start of this script), or
    % begin trial sequence B.
    
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %                    STORE DATA from this sequence:
    
     %% compute timing variables
     %actual stimulus presentation:
%         alltrials(t).act_stimdur       = alltrials(t).offsetstim - alltrials(t).onsetstim;
    
    
    
    
  