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
        if isfield(alltrials(t-1), 'didrespond')
            if alltrials(t-1).didrespond==0
                response=0;
            end
        end
        
        UD = PAL_AMUD_updateUD(UD, response); %update UD structure
        
        
        alltrials(t).stimdifference = UD.xCurrent;
        
    elseif t ==1  
        alltrials(t).stimdifference = cfg.initialstimDifference; 
        
    end
else % if we have finished the practice blocks, set the stim difference:
    
    %as last staircased difference:
    
    alltrials(t).stimdifference = UD.xCurrent;
    
end
    