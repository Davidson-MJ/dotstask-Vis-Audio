function [] = draw_scale_(Sc,cfg)
% Usage:
% [] = draw_scale(Sc,cfg)
%
% cfg must have .bar fields in order to work. 
% cfg.bar must have gaprect and barrect fields
% Default values are assigned otherwise.
%
% Niccolo Pescetelli


%- - UPDATED by MDavidson July 2019.


%% check for fields existence
if ~isfield(cfg,'bar')
   
    define_scale


end

if ~isfield(cfg.bar,'gaprect')
    cfg.bar.gaprect            = CenterRectOnPoint([0,0,cfg.bar.cursorwidth * cfg.bar.gap_size,cfg.bar.cursorheight],...
        Sc.Center(1), ...
        Sc.Rect(4)*cfg.bar.positiony);
end
if ~isfield(cfg.bar,'barrect')
    cfg.bar.barrect             = CenterRectOnPoint([0 0 (cfg.bar.nScale*cfg.bar.cursorwidth) (cfg.bar.cursorheight)], ...
        Sc.Center(1),Sc.Rect(3)*cfg.bar.positiony);
end

%% draw barrect and gap
% rect = [cfg.bar.barrect' cfg.bar.gaprect'];
%   Screen('FillRect', Sc.Number, [[1 1 1]' [1 1 1]'],rect);
Screen('FillRect', Sc.Number, [.3 .3 .3], cfg.bar.barrect); % draw bar for response:
Screen('FillRect', Sc.Number, [128 128 128], cfg.bar.gaprect); % draw gap on top of response bar
Screen('TextFont', Sc.Number, 'Myriad Pro');

end