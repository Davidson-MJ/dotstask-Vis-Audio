Screen('TextSize', window.Number, cfg.fontsize*2);

drawBig=0; % passed into add_fixation to determine fix cross params.
% add fixation
add_fixation;

Screen('TextSize',window.Number, cfg.fontsize*2);

%Draw Correct response type 
%expA = simple respponse, speeded.
%expB = confidence slider.


%otherwise defined in earlier sections of trials.
if strcmp(trialpos, 'A')

%draws instructions only (Left click or right click).
   
draw_simpleResponseinstructions(window, cfg, stimtype);
    


elseif strcmp(trialpos, 'B')
    
% second half experiment, present confdidence slider response screen.    



% draw scale
draw_scale_(window,cfg);

% draw confidence and interval landmarks
draw_landmarks(window,cfg, stimtype);

% add response instructions
add_responseinstr(window,cfg);
end