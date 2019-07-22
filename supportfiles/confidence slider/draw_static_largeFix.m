Screen('TextSize', window.Number, cfg.fontsize);
Screen('TextStyle', window.Number, 1);

% add fixation
add_fixation;

Screen('TextStyle', window.Number, 0);
Screen('TextSize', window.Number, cfg.fontsize);

% draw scale
draw_scale_(window,cfg);

% draw confidence and interval landmarks
draw_landmarks(window,cfg);

% add response instructions
add_responseinstr(window,cfg);
    