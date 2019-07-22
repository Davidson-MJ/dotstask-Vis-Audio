cfg.bar.maxwindowale            = 50;
cfg.bar.minwindowale            = -50;
cfg.bar.nwindowale              = length([cfg.bar.minwindowale:cfg.bar.maxwindowale]);
cfg.bar.cursorwidth         = window.Rect(3)/150;
cfg.bar.cursorheight        = 20;
cfg.bar.positiony           = .8;
cfg.bar.barrect             = CenterRectOnPoint([0 0 (cfg.bar.nwindowale*cfg.bar.cursorwidth) (cfg.bar.cursorheight)], ...
    window.Center(1),window.Rect(4)*cfg.bar.positiony);
cfg.bar.barlength           = cfg.bar.barrect(3)- cfg.bar.barrect(1);
cfg.bar.gap_size            = 5;
cfg.bar.gaprect            = CenterRectOnPoint([0,0,cfg.bar.cursorwidth * cfg.bar.gap_size,cfg.bar.cursorheight],...
    window.Center(1), window.Rect(4)*cfg.bar.positiony);
% define cursor possible positions along x-axis
cfg.bar.xshift = [linspace(cfg.bar.barrect(1)+cfg.bar.cursorwidth.*.5,...
    cfg.bar.gaprect(1)-cfg.bar.cursorwidth.*.5,cfg.bar.maxwindowale) ...
    linspace(cfg.bar.gaprect(3)+cfg.bar.cursorwidth.*.5, ...
    cfg.bar.barrect(3)-cfg.bar.cursorwidth.*.5,cfg.bar.maxwindowale)];
cfg.bar.gaplength=(cfg.bar.gaprect(3)-cfg.bar.gaprect(1)).*.5;


% % temporary short names
% maxwindowale                    = cfg.bar.maxwindowale;
% minwindowale                    = cfg.bar.minwindowale;
% nwindowale                      = cfg.bar.nwindowale;
% cursorwidth                 = cfg.bar.cursorwidth;
% cursorheight                = cfg.bar.cursorheight;
% barrect                     = cfg.bar.barrect;
% barlength                   = cfg.bar.barlength;
% gap_size                    = cfg.bar.gap_size;
% gap                         = cfg.bar.gap_rect;