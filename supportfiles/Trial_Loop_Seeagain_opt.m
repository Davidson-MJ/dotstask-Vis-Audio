%         Trial_Loop_Seeagain_opt;
% this is the second half trial sequence, in which participants either
% receive an option to see/hear the stimulus again, or have to simply
% provide their confidence judgement.

% MDavidson, Aug 2019. mjd070@gmail.com


%% First we will draw the appropriate responses screen.



if strcmp(alltrials(t).SeeAgainOpt, 'n')
    
    
    % no option on screen.
    % provide confidence straight away:
    
    
    % Screen('TextStyle', window.Number, 0);
    Screen('TextSize', window.Number, cfg.fontsize);
    
    %% second half experiment, present confdidence slider response screen.
    % % draw scale    
    draw_scale_(window,cfg);
    % % draw confidence and interval landmarks
    draw_landmarks(window,cfg,stimtype);    
    % % add response instructions
    add_responseinstr(window,cfg);
    
    % flip screen if sufficient time has passed:
    %     - - Flip
    [alltrials(t).VBLtime_Opt_onset, flipestimate,...
        alltrials(t).time_Opt_onset, ...
        alltrials(t).flip_accuracy_Opt_onset] = Screen('Flip',window.Number, whentoFlip_NEW);
    
    
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
        
    
                    
    
    %for this trial type, no response for the following:
    filltable_if_respond_now;
                    
elseif strcmp(alltrials(t).SeeAgainOpt, 'y')
    %% This trial sequence contains the option to see/hear stimulus again:
    
    % draw see/ hear again options on screen.
    SeeAgainTextOption;
    
    % flip to show this option on screen.
    [alltrials(t).VBLtime_Opt_onset, flipestimate, ...
        alltrials(t).time_Opt_onset,...
        alltrials(t).flip_accuracy_Opt_onset] = Screen('Flip',window.Number, whentoFlip_NEW);
    
    % collect and show participant choice on screen,
    [~, ...
        alltrials(t).respInfoSeek_time, ...
        alltrials(t).respInfoSeek_loc, ... % left or right
        alltrials(t).didrespond_IS] = fill_mouseboxes(window,cfg, alltrials(t).time_Opt_onset, stimtype,trialpos);
    
    
        %store choice and reaction time:
        % define reaction time (resp - time previous screen flip executed).
        alltrials(t).ISeek_rt = alltrials(t).respInfoSeek_time- alltrials(t).time_Opt_onset;
        
        %define choice by location
        if alltrials(t).respInfoSeek_loc==1
            alltrials(t).ISeek=   1;
        else
            alltrials(t).ISeek=   0;
        end
    
    
    
    %% continue with stimulus presentation (second round), if info-seeking
    % was selected.
    
    if alltrials(t).ISeek ==1
        
        %rerun the stimulus:
        whentoFlip_New = alltrials(t).respInfoSeek_time + cfg.stim.TW1;
        
        %% display stimulus again:
        % very similar to A, just changing variable names that are output
        % and saving accordingly.
        
         Trial_sequence_partB;
        
        
    else %show response options:
        
        Screen('TextSize', window.Number, cfg.fontsize);
    %flip screen if sufficient time has passed:
    % % second half experiment, present confdidence slider response screen.
    % % draw scale
    draw_scale_(window,cfg);
    % % draw confidence and interval landmarks
    draw_landmarks(window,cfg, stimtype);
    %
    % % add response instructions
    add_responseinstr(window,cfg);
    
    %     - - Flip
    [alltrials(t).VBLtime_Opt_onset, flipestimate,...
        alltrials(t).time_Opt_onset, ...
        alltrials(t).flip_accuracy_Opt_onset] = Screen('Flip',window.Number, whentoFlip_NEW);
    
    
        % collect response:
   [alltrials(t).confj, alltrials(t).confj_time, ...
       alltrials(t).confj_loc,...
       alltrials(t).confj_didrespond] = ...
                        drag_slider(window,cfg,stimtype);
    
                    
                    
    %% store accuracy and reaction time:
    
    % define reaction time (resp - time previous screen flip executed).
        alltrials(t).confj_rt = alltrials(t).confj_time- alltrials(t).time_stim1offset;
    %define accuracy by location    
        alltrials(t).confj_cor=  alltrials(t).confj_loc == alltrials(t).whereTrue;        
        
        %%
        % define next flip time                    
                    whentoFlip_NEW = alltrials(t).confj_time + cfg.stim.TW1; 
        
    end
   
end
    %if practice trial, provide error-feedback:
    if cfg.giveAudioFeedback==1 && alltrials(t).blockcount<1
        if alltrials(t).confj_cor == 0
            %play matlab error beep
            beep
            %%
        end
    
    end

