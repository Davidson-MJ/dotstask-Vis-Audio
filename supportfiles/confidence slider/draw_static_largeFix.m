%make a larger FIX CROSS
Screen('TextSize', window.Number, cfg.fontsize*4);
% Screen('TextStyle', window.Number, [127,255,0]); % bright green pulse.

drawBig=1;
% add fixation
add_fixation;

% Screen('TextStyle', window.Number, 0);
Screen('TextSize', window.Number, cfg.fontsize*2);

if strcmp(alltrials(t).ExpType, 'A')

%draws instructions only (Left click or right click).
   
draw_simpleResponseinstructions(window, cfg);
    


elseif strcmp(alltrials(t).ExpType, 'B')
    
% second half experiment, present confdidence slider response screen.
% draw scale
draw_scale_(window,cfg);

% draw confidence and interval landmarks
draw_landmarks(window,cfg);

% add response instructions
add_responseinstr(window,cfg);
end