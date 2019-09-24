% Trial_sequence_partBsca

% displays stimuli for the second time, and collects a confidence judgement

% MDavidson August 2019

%% -- INTERVAL 1a --  small fixation cross on screen 
    % this is displayed for cfg.stim.TW1, indicating start of a trial.
    % a blank screen is displayed with small fixation cross, which
    % increases in size (next step) before stim presentation.
     
    
    %Note that whentoFlip_NEW is defined by previous trial.
    
    draw_static; % draw fix cross and response options
    
% - - Flip to show small FIX CROSS: 
    % collect trial start time (in VBL stamps). Note that first output is
    % when flip command began, third is when finished:
    
    [alltrials(t).VBLtime_starttrial2, flipestimate,... % system time flip command begins
        alltrials(t).time_starttrial2,... % time flip executed
        alltrials(t).flip_accuracy_starttrial2] = Screen('Flip',window.Number,whentoFlip_NEW);
    
%% -- INTERVAL 1b -- Larger fixation cross on screen.
    % preparation fixation flash: displayed for short duration.
% - - Fill buffer
%  % note that this flip needs to be appropriate time after first fix
%     % cross   
%     
%     whentoFlip = flipestimate + cfg.stim.TW1;  %% if small cross has been on for long enough  
%         
%     draw_static_largeFix;     
%     
%     %flip screen to show larget fixation cross, and record flip intervals.   
% % - - Flip  
%     %flip to show large cross (once time elapsed).    
%     [alltrials(t).VBLtime_largeFix2, flipestimate,...
%        alltrials(t).time_largeFix2,...
%        alltrials(t).flip_accuracy_largeFix2] = Screen('Flip', window.Number, ...
%         whentoFlip);       
%%   
%% STIMULUS PRESENTATION     
% - - Fill buffer    
    %prep small cross for next interval
%     whentoFlip = flipestimate + cfg.stim.TW2; %if large fix cross has been up long enough
    
    whentoFlip = flipestimate +cfg.stim.TW1; %increased length to avoid large fix cross
    
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
            
            
            draw_static_largeFix;% draw response options.
            
            % Show stimulus on screen at next possible display refresh cycle,
            % and record stimulus onset time in 'onsetstim':
            
            % - - Flip
            [alltrials(t).VBLtime_stim2pres, flipestimate,...
                alltrials(t).time_stim2pres, ...
                alltrials(t).flip_accuracy_stim2pres] =  Screen('Flip', window.Number, whentoFlip);
        
        
        case {'audio', 'AUDIO'}
        
            %% Repeat the tones defined in part A:
            
            PsychPortAudio('FillBuffer', cfg.pahandle, chanDATA);
            
            %present AUDIO tones, require response after cfg.durstim.            
          alltrials(t).time_stim2pres=  PsychPortAudio('Start', cfg.pahandle, 1, whentoFlip);

            flipestimate=alltrials(t).time_stim2pres;
            
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
 [alltrials(t).VBLtime_stim2offset, flipestimate,... 
     alltrials(t).time_stim2offset, ...
     alltrials(t).flip_accuracy_stim2offset] =  Screen('Flip', window.Number, whentoFlip);
    
%% %% COLLECT timing of RESPONSE, also show on screen
 
 % need to show the cursor:
 
        % collect response:
   [alltrials(t).confj, alltrials(t).confj_time, ...
       alltrials(t).confj_loc,...
       alltrials(t).confj_didrespond] = ...
                        drag_slider(window,cfg, stimtype);
    
                    
                    
    %% store accuracy and reaction time:
    
    % define reaction time (resp - time previous screen flip executed).
        alltrials(t).confj_rt = alltrials(t).confj_time- alltrials(t).time_stim1offset;
    %define accuracy by location    
        alltrials(t).confj_cor=  alltrials(t).confj_loc == alltrials(t).whereTrue;        
        
        %%
        % define next flip time                    
                    whentoFlip_NEW = alltrials(t).confj_time + cfg.stim.TW1; 
        
