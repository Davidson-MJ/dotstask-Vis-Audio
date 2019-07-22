function [ft] = display_response(window,cfg,temp,varargin)
% Usage:
% [ft] = display_response(Sc,cfg,temp [,cj1])
%
% Inputs:
% Sc: Screen structure
% cfg: cfg strucure
% temp: vector containing haschanged boolean and current confidence 
%       judgement
% cj1: first confidece judgement if one is available
% 

if nargin < 4, 
    show_cj1    = false; 
else
    show_cj1    = true;
    cj1         = varargin{1};
    int1        = sign(cj1);
end
gs = round(cfg.bar.gap_size/2);
[haschanged,cj] = deal(temp(1),temp(2));
fdTxt = cfg.instr.finaldecision{1};

%% display response
% draw static elements
draw_static

% display previous confidence
if show_cj1
    switch int1
        case -1 % 1
            positions = linspace(cfg.bar.gaprect(1)-cfg.bar.cursorwidth.*.5,...
                cfg.bar.barrect(1)+cfg.bar.cursorwidth.*.5,cfg.bar.maxScale);
        case 1
            positions = linspace(cfg.bar.gaprect(3)+cfg.bar.cursorwidth.*.5, ...
                cfg.bar.barrect(3)-cfg.bar.cursorwidth.*.5,cfg.bar.maxScale);
    end
    cj1rect = CenterRectOnPoint([0,0,cfg.bar.cursorwidth,cfg.bar.cursorheight],...
    positions(abs(cj1)), ...
    window.Rect(4).*cfg.bar.positiony);
    Screen('FillRect', window.Number, [.4 .4 .4]',cj1rect );

    Screen('TextSize', window.Number, 23); % change font size
    DrawFormattedText(window.Number,fdTxt,'center',window.Center(2) -100);
    Screen('TextSize', window.Number, 13); % change back font size
end

% define response cursor position
switch sign(cj)
    case -1
        positions = linspace(cfg.bar.gaprect(1)-cfg.bar.cursorwidth.*.5,...
            cfg.bar.barrect(1)+cfg.bar.cursorwidth.*.5,cfg.bar.maxScale);
    case 1
        positions = linspace(cfg.bar.gaprect(3)+cfg.bar.cursorwidth.*.5, ...
            cfg.bar.barrect(3)-cfg.bar.cursorwidth.*.5,cfg.bar.maxScale);
end

% draw cursor only after first click
if haschanged,
    cursorrect = CenterRectOnPoint([0,0,cfg.bar.cursorwidth,cfg.bar.cursorheight],...
        positions(abs(cj)), ...
        window.Rect(4) .* cfg.bar.positiony);
    Screen('FillRect', window.Number, [.8 .8 .8]',cursorrect');
end

Screen('TextFont', window.Number, 'Myriad Pro');

% Flip on screen
ft = Screen('Flip', window.Number);

return