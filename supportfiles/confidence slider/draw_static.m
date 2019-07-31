Screen('TextSize', window.Number, cfg.fontsize*2);

drawBig=0; % passed into add_fixation to determine fix cross params.
% add fixation
add_fixation;

Screen('TextSize',window.Number, cfg.fontsize*2);

% draw scale
draw_scale_(window,cfg);

% draw confidence and interval landmarks
draw_landmarks(window,cfg);

% add response instructions
add_responseinstr(window,cfg);
    