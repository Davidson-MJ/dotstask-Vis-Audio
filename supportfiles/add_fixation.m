
%add fixation '+' the center of screen
if drawBig==1
    
    Screen('TextSize', window.Number, cfg.fontsize*4);
    DrawFormattedText(window.Number, '+','center','center', [127 255 0]); % pulse bright green
else
    Screen('TextSize', window.Number, cfg.fontsize*2);
    DrawFormattedText(window.Number, '+','center','center', [255 255 255]); % small white down time.
end


%here can include better fixation