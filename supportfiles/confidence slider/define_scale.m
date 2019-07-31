
%% -- MD July 2019, adapting old code for new pilotting.

%need to change to dva if possible (i.e. pre-define values, based on screen res, and distance).

    cfg.bar.maxScale            = 55;
    cfg.bar.minScale            = -55;
    cfg.bar.nScale              = length([cfg.bar.minScale:cfg.bar.maxScale]);
    cfg.bar.cursorwidth         = window.Rect(3)/200;
    cfg.bar.cursorheight        = 20;
    
    cfg.bar.positiony           = .7;
    
    %define rect for confidence slider
    cfg.bar.barrect             = CenterRectOnPoint([0 0 (cfg.bar.nScale*cfg.bar.cursorwidth) (cfg.bar.cursorheight)], ...
                                window.Center(1),window.Rect(4)*cfg.bar.positiony);
    cfg.bar.barlength           = cfg.bar.barrect(3)- cfg.bar.barrect(1);
    cfg.bar.gap_size            = 11;
    
    
    %define rect for gap in middle (separate L/R)
    cfg.bar.gaprect            = CenterRectOnPoint([0,0,cfg.bar.cursorwidth * cfg.bar.gap_size,cfg.bar.cursorheight],...
                                window.Center(1), window.Rect(4)*cfg.bar.positiony);
    cfg.bar.gaplength           = 10;

    % define increments along bar, that cursor can rest on    
    cfg.bar.xshift              = [linspace(cfg.bar.barrect(1)+cfg.bar.cursorwidth.*.5,...
                            cfg.bar.gaprect(1)-cfg.bar.cursorwidth.*.5,cfg.bar.maxScale) ...
                            linspace(cfg.bar.gaprect(3)+cfg.bar.cursorwidth.*.5, ...
                            cfg.bar.barrect(3)-cfg.bar.cursorwidth.*.5,cfg.bar.maxScale)];
    
    cfg.bar.gaplength               =(cfg.bar.gaprect(3)-cfg.bar.gaprect(1)).*.5; % define difference between bars for gap.

    
    %% -- previous parameters (old variable names:)
    % cfg.bar.maxScale            = 55;
% cfg.bar.minScale            = -55;
% cfg.bar.nScale              = 111;
% cfg.bar.cursorwidth         = window.Rect(3)/200; %was Sc.size(1)/200;
% cfg.bar.cursorheight        = 20;
% cfg.bar.positiony           = .7;
% cfg.bar.barrect             = CenterRectOnPoint([0 0 (cfg.bar.nScale*cfg.bar.cursorwidth) (cfg.bar.cursorheight)],window.Center(1)-cfg.bar.cursorwidth,window.Rect(4)*cfg.bar.positiony);
% cfg.bar.barlength           = cfg.bar.barrect(3)- cfg.bar.barrect(1);
% cfg.bar.gap_size            = 11;
% cfg.bar.gap_rect            = CenterRectOnPoint([0,0,cfg.bar.cursorwidth * cfg.bar.gap_size,cfg.bar.cursorheight],...
%     window.Center(1) -((cfg.bar.nScale*cfg.bar.cursorwidth/2)+cfg.bar.cursorwidth) + (cfg.bar.maxScale * cfg.bar.cursorwidth  + cfg.bar.cursorwidth/2), window.Rect(4)*cfg.bar.positiony);
% cfg.bar.gaplength           = 10;

%% -- temporary short names
% maxScale                    = cfg.bar.maxScale;
% minScale                    = cfg.bar.minScale;
% nScale                      = cfg.bar.nScale;
% cursorwidth                 = cfg.bar.cursorwidth;
% cursorheight                = cfg.bar.cursorheight;
% barrect                     = cfg.bar.barrect;
% barlength                   = cfg.bar.barlength;
% gap_size                    = cfg.bar.gap_size;
% gap                         = cfg.bar.gap_rect;