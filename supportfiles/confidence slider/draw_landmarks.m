function [cfg] = draw_landmarks(Sc,cfg, stimtype)
% Usage: 
% [] = draw_landmarks(Sc,cfg)
% 
% Required fields are cfg.instr.cjtext, cfg.instr.interval and 
% cfg.bar.barlength.
% The first one refers to 2 confidence landmarks (eg. sure maybe)
% The second one refers to interval landmarks (eg. LEFT and RIGHT)
% The third one refers to the length of the confidence scale
% Defaults values are assigned only for cfg.instr fields.

% Niccolo Pescetelli

%% ---- Updated MD July 2019 to accomodate new var names.

%% define font and font size
Screen('TextSize',Sc.Number, cfg.fontsize);
Screen('TextFont', Sc.Number, 'Myriad Pro');


switch stimtype
    case {'visual', 'VISUAL'}
        instrsAR= {'LEFT', 'RIGHT'};        
    case {'audio', 'AUDIO'}        
        instrsAR= {'FIRST', 'SECOND'};
        
end
            
cfg.instr.interval = instrsAR;

%% check for required fields
if ~isfield(cfg,'instr')
    cfg.instr.cjtext = {'Certainly' 'Maybe'};
    cfg.instr.interval = instrsAR;
end

if ~isfield(cfg.instr,'instr')
    cfg.instr.interval = instrsAR;
end
if ~isfield(cfg.instr, 'xshift') % places along barrect to adapt cursor
    cfg.instr.xshift = [linspace(cfg.bar.gaprect(1)-cfg.bar.cursorwidth.*.5,...
            cfg.bar.barrect(1)+cfg.bar.cursorwidth.*.5,length(cfg.instr.cjtext)) ...
        linspace(cfg.bar.gaprect(3)+cfg.bar.cursorwidth.*.5, ...
            cfg.bar.barrect(3)-cfg.bar.cursorwidth.*.5,length(cfg.instr.cjtext))];
end

%% define instructions for confidence judgement
for i=1:length(cfg.instr.cjtext)
    bounds(i,:) = Screen('TextBounds',Sc.Number,cfg.instr.cjtext{i});
end
LintBounds              = Screen('TextBounds',Sc.Number,cfg.instr.interval{1});
RintBounds              = Screen('TextBounds',Sc.Number,cfg.instr.interval{2});

%% draw confidence landmarks
for i=1:length(cfg.instr.xshift)
    Screen('DrawText', Sc.Number, ...
        cfg.instr.cjtext{mod(i-1,length(cfg.instr.cjtext))+1}, ...
        cfg.instr.xshift(i) - bounds(mod(i-1,length(cfg.instr.cjtext))+1,3)/2, ...
        Sc.Rect(4).*cfg.bar.positiony-40, 0);
end

%% draw interval landmarks
Screen('DrawText', Sc.Number, cfg.instr.interval{1}, ...
    Sc.Center(1)- (cfg.bar.barlength*.25 + cfg.bar.gaplength*.5) - LintBounds(3)*.5, ...
    (Sc.Rect(4).*cfg.bar.positiony +40), 0);

Screen('DrawText', Sc.Number, cfg.instr.interval{2}, ...
    Sc.Center(1)+ (cfg.bar.barlength*.25 + cfg.bar.gaplength*.5) - RintBounds(3)*.5, ...
    (Sc.Rect(4).*cfg.bar.positiony +40), 0);

return