% Give on screen options for seeking further information.


%% define font and font size
Screen('TextSize', window.Number, 26);
Screen('TextFont', window.Number, 'Myriad Pro');

% Draw Mouse response image:(cfgs in define_mouseboxes.m)

%Draw response boxes on screen (centred);
Screen('FrameRect', window.Number, [255,255,255], cfg.MouseRect_pos3, 2);
%fill box with text
DrawFormattedText(window.Number, 'Respond', 'center', window.Rect(4)*cfg.bar.positiony, [255,255,255]);
%includ instructions beneath
DrawFormattedText(window.Number, '(Mouse Click)', 'center', (window.Rect(4)).*(cfg.bar.positiony + .1), [255,255,255]);

%title:
Screen('TextSize', window.Number, 40);
DrawFormattedText(window.Number, 'Get ready to respond','center', window.Center(2), [255,255,255]);