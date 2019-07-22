function [] = draw_scale_(Sc,cfg)
% Usage:
% [] = draw_scale(Sc,cfg)
%
% cfg must have .bar fields in order to work. 
% cfg.bar must have gaprect and barrect fields
% Default values are assigned otherwise.
%
% Niccolo Pescetelli


%UPDATED by MD July 2019.
%% check for fields existence
if ~isfield(cfg,'bar')
   
    define_scale
    %defaults:
%     cfg.bar.maxScale            = 55; 
%     cfg.bar.minScale            = -55;
%     cfg.bar.nScale              = length([cfg.bar.minScale:cfg.bar.maxScale]);
%     cfg.bar.cursorwidth         = Sc.Rect(3)/200;
%     cfg.bar.cursorheight        = 20;
%     
%     cfg.bar.positiony           = .7;
%     
%     cfg.bar.barrect             = CenterRectOnPoint([0 0 (cfg.bar.nScale*cfg.bar.cursorwidth) (cfg.bar.cursorheight)], ...
%         Sc.Center(1),Sc.Rect(4)*cfg.bar.positiony);
%     cfg.bar.barlength           = cfg.bar.barrect(3)- cfg.bar.barrect(1);
%     cfg.bar.gap_size            = 11;
%     cfg.bar.gaprect            = CenterRectOnPoint([0,0,cfg.bar.cursorwidth * cfg.bar.gap_size,cfg.bar.cursorheight],...
%         Sc.Center(1), Sc.size(2)*cfg.bar.positiony);
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
rect = [cfg.bar.barrect' cfg.bar.gaprect'];
Screen('FillRect', Sc.Number, [[.3 .3 .3]' [.5 .5 .5]'],rect);
Screen('TextFont', Sc.Number, 'Myriad Pro');

end