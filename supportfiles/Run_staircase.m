%Run_staircase


% Updates the Palamedes toolbox up-down structure (UD). Outputting new
% differences for stimuli (Hz or ndots) within practice trials.

%MDavidson August 2019. mjd070 at gmail dot com

if alltrials(t).isprac % only update staircase during practice.
    
    if t >= 2 %need two previous trials, only staircase during practice.
        
        %using PAL toolbox. update for previous responses.
        %in case debugging, and without previous accuracy:
        if ~isfield(alltrials(t-1), 'cor') || isempty(alltrials(t-1).cor)
            response=1;
        else
            response = alltrials(t-1).cor;
        end
        
        %overright correct responses, as incorrect, if reaction time was exceeded.
        %         if isfield(alltrials(t-1), 'didrespond')
        %             if alltrials(t-1).didrespond==0
        %                 response=0;
        %             end
        %         end
        
        
        %note that for the audio task, we may need to decrease the minimum
        %interval for very good performers (to decimals)
        if UD.xCurrent(end)<=1 && ...
                (alltrials(t).xmodtype==2 || alltrials(t).xmodtype==3)...
                && response % audio,
            % if we are at the minimum x difference, and previous response was
            % correct, need to increase difficulty
            UD.stepSizeDown = .1;
            UD.xMin=.01;
            %         %% hack to update staircase.
            %         newv =  UD.xCurrent - stepd;
            %         UD.xCurrent =newv;
            %         UD.x(end+1) =  newv;
            %         UD.staircase(end+1) =  newv;
            %         UD.response(end+1) = response;
            %         UD.reversal(end+1)= 0;
        elseif UD.xCurrent(end)<1 && alltrials(t).xmodtype==2  && response==0 % incorrect
            UD.stepSizeUp = .1;
            UD.xMin=.01;
            %             stepup = .1;
            %              newv =  UD.xCurrent - stepd;
            %         UD.xCurrent =newv;
            %         UD.x(end+1) =  newv;
            %         UD.staircase(end+1) =  newv;
            %         UD.response(end+1) = response;
        else
            [UD.stepSizeUp, UD.stepSizeDown] = deal(2);
            UD.xMin=1;
            
        end
        
        %update UD structure
        % so if
        UD = PAL_AMUD_updateUD(UD, response);
        
        if UD.xCurrent >1
            UD.xCurrent= round(UD.xCurrent);
        end
        alltrials(t).stimdifference = UD.xCurrent;
        
        
    elseif t ==1
        alltrials(t).stimdifference = cfg.initialstimDifference;
        
    end
else % if we have finished the practice blocks, set the stim difference:
    
    %as last staircased difference:
    
    alltrials(t).stimdifference = UD.xCurrent;
    
end
