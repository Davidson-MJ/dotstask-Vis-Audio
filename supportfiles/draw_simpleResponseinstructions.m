function draw_simpleResponseinstructions(window,cfg, stimtype)
%Usage:

% Simple text displayed on screen, below presentation of Dots (if
% appropriate).

% Shows response options (using left click or right click).
% In visual tasks, left (right) click = left (right) box.
% In auditory tasks, left (right) click = first (second) tone.

% M Davidson July 2019
%%
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
switch stimtype
    case {'visual', 'VISUAL'}
%     %visual click instructions.
    %Left instructions.
    DrawFormattedText(window.Number, 'Left Box', window.Center(1)-cfg.MouseRect(3)*.75, window.Rect(4)*cfg.bar.positiony, [255,255,255]);
    DrawFormattedText(window.Number, 'Right Box', window.Center(1)+cfg.MouseRect(3)*.25, window.Rect(4)*cfg.bar.positiony, [255,255,255]);
    
    case {'audio', 'AUDIO'}
    DrawFormattedText(window.Number, '1st Tone', window.Center(1)-cfg.MouseRect(3)*.75, window.Rect(4)*cfg.bar.positiony, [255,255,255]);
    DrawFormattedText(window.Number, '2nd Tone', window.Center(1)+cfg.MouseRect(3)*.25, window.Rect(4)*cfg.bar.positiony, [255,255,255]);    
end
end




