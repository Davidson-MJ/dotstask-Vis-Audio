function [] = add_responseinstr(Sc,cfg)
% Usage:
% [] = add_responseinstr(Sc,cfg)
% 
% Required fields:
% cfg.instr.instr refers to the response mode instructions 
% at the bottom of the page.
% cfg.bar.positiony
% 
% Default values are assigned only to cfg.instr.instr
% 
% Niccolo Pescetelli
%
% - - updated MD July 2019 to accomodate new variable names.
% - - New font cfgs (size and colour).

%% check required fields
% if ~isfield(cfg.instr,'instr')
    cfg.instr.instr = {'Left click with the mouse \n \n Press spacebar to confirm response'};
% end


%% add response istructions
Screen('TextSize', Sc.Number, cfg.fontsize);
Screen('TextFont', Sc.Number, 'Myriad Pro');
DrawFormattedText(Sc.Number, cfg.instr.instr{1}, 'center', (Sc.Rect(4)).*(cfg.bar.positiony+.1), [1,1,1]);
% DrawFormattedText(Sc.Number, cfg.instr.instr{2}, 'center', (Sc.Rect(4)).*(cfg.bar.positiony+.2), [1,1,1]);

return
