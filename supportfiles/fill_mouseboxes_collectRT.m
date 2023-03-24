% fill_mouseboxes_collectRT
function [alltrials, hasflipped] = fill_mouseboxes_collectRT(window,cfg, prevfliptime, stimtype, trialpos, alltrials)
% Usage:
% new script to collect RTs after stim onset, but also to flip to remove
% dots from screen if enough time has passed.

%outputs:
% 
% 
%by MDavidson Mar 2020.

%% initialize variables
  
  buttons=[];   
  hasflipped=false;
 % make sure box is there to be filled)
if strcmp(trialpos, 'A')
draw_simpleResponseinstructions(window, cfg, stimtype); 
else % don't draw boxes, just collect response.
end
   
%% collect response
% flip if the time has elapsed for stimulus presentation.
time_now = GetSecs;
while ~any(buttons) % wait for click
    
    
    [~,~,buttons] = GetMouse; % not interested in location.        
    %check if the time has elapsed, if so, then remove dots from screen.    
    if time_now > prevfliptime+cfg.stim.durstim
        %flip immediately.
        
    [alltrials(t).VBLtime_stim1offset, ~,... 
     alltrials(t).time_stim1offset, ...
     alltrials(t).flip_accuracy_stim1offset] =  Screen('Flip', window.Number);
 
    hasflipped=true;
        
    end
    
end

% what time for response?
alltrials(t).resp1_time= GetSecs;
alltrials(t).rt = alltrials(t).resp1_time- alltrials(t).time_stim1pres;

%if too slow, mark trial as incomplete
if resp_t > prevfliptime + cfg.stim.respduration 
    
    alltrials(t).didrespond = false;
    interval=find(buttons);
    if interval>2 %avoid click '3' on scroll mouse types.
        alltrials(t).resp1_loc=2;
    end
else
     
    % display response:
    % fill box on screen according to button pressed:
    
    alltrials(t).didrespond = true;
    
    %save response location.
    if find(buttons)==1
        alltrials(t).resp1_loc=1;        
    elseif find(buttons)>=2
        alltrials(t).resp1_loc=2;
    end
end
%flip to show response.

Screen('Flip', window.Number);

return