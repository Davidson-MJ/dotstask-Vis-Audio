% Give on screen options for seeking further information.


%% define font and font size
Screen('TextSize', window.Number, 26);
Screen('TextFont', window.Number, 'Myriad Pro');

% Draw Mouse response image:(cfgs in define_mouseboxes.m)

%Draw response boxes on screen:
Screen('FrameRect', window.Number, [255,255,255], cfg.MouseRect_pos1, 2);
Screen('FrameRect', window.Number, [255,255,255], cfg.MouseRect_pos2, 2);

%Draw generic instructions, followed by modality specific:
DrawFormattedText(window.Number, '(Mouse Click) \n Left/Right ', 'center', (window.Rect(4)).*(cfg.bar.positiony + .1), [255,255,255]);
%
% 
% Select appropriate text instr.
switch cfg.stimTypes{2}
    case {'visual', 'VISUAL'}
%     %visual click instructions.
    %Left instructions.
    DrawFormattedText(window.Number, 'See again', window.Center(1)-cfg.MouseRect(3)*.75, window.Rect(4)*cfg.bar.positiony, [255,255,255]);
    DrawFormattedText(window.Number, 'Respond', window.Center(1)+cfg.MouseRect(3)*.25, window.Rect(4)*cfg.bar.positiony, [255,255,255]);
    
    Screen('TextSize', window.Number, 40);    
    DrawFormattedText(window.Number, 'Would you like to see the stimulus again?','center', window.Center(2), [255,255,255]);
    
    case { 'audio', 'AUDIO'}
    
    DrawFormattedText(window.Number, 'Hear again', window.Center(1)-cfg.MouseRect(3)*.75, window.Rect(4)*cfg.bar.positiony, [255,255,255]);
    DrawFormattedText(window.Number, 'Respond', window.Center(1)+cfg.MouseRect(3)*.25, window.Rect(4)*cfg.bar.positiony, [255,255,255]);    
    
    Screen('TextSize', window.Number, 40);    
    DrawFormattedText(window.Number, 'Would you like to hear the stimulus again?','center', window.Center(2), [255,255,255]);
end
