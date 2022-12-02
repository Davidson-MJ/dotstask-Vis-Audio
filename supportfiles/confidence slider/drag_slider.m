function [cj resp_t interval hasconfirmed] = drag_slider(window,cfg,stimtype)
% Usage:
% [cj resp_t interval hasconfirmed] = drag_slider(Sc,cfg [,cj1])
% Inputs:
% Sc: Sc structure
% cfg: cfg structure
% cj1: first confidence judgement. If present cj1 is shown in shaded color
%
% function by niccolo.pescetelli@psy.ox.ac.uk

%Updated by MDavidson July 2019.


%% Show mouse pointer
SetMouse (window.Center(1), window.Center(2)+20);
ShowCursor('Arrow');


%% initialize variables
  resp = 0; buttons=[]; haschanged=false; hasconfirmed=false;int=0;

%% display cursor

    ft = display_response_(window,cfg,[haschanged,resp+int], stimtype);


%% collect response
while ~any(buttons) % wait for click
    [x,y,buttons] = GetMouse;
end
while ~hasconfirmed
    while any(buttons) || ~haschanged   % wait for release and change of cj and confirmation
        [resp_x, resp_y, buttons] = GetMouse();


%         if resp_x>=cfg.bar.barrect(1) && resp_x<window.Center(1) % if mouse's on the left rect
        if resp_x<window.Center(1) % if mouse's on the left rect

            resp = find(resp_x < (cfg.bar.xshift+cfg.bar.cursorwidth.*.5),1) - cfg.bar.maxScale-1;
            haschanged = true;
            int = -1;
            if resp==0, resp=int;end
        elseif resp_x>=window.Center(1) %&& resp_x<=cfg.bar.barrect(3) % if mouse's on the right rect
            resp = find(resp_x < (cfg.bar.xshift+cfg.bar.cursorwidth.*.5),1) - cfg.bar.maxScale;
            haschanged = true;
            int = 1;
            if isempty(resp), resp=cfg.bar.maxScale;end
        end
        
        %--- display response
        
            ft = display_response_(window,cfg,[haschanged,resp], stimtype);
        
    end
    
    % check for confirmation
    if ~hasconfirmed
        switch 'keyboard'
            case 'mouse'
                [x,y,buttons] = GetMouse;
                if buttons(3)==1, hasconfirmed = true;end
                resp_t = GetSecs;
            case 'keyboard'
                [x,y,buttons] = GetMouse;
                [isdown resp_t keycode] = KbCheck;                 % get timing and key
                % translate key code into key name
                name = KbName(keycode);
                % only take first response if multiple responses
                if ~iscell(name), name = {name}; end
                name = name{1};
                if strcmp('space',name),hasconfirmed = true;end
                if strcmp('ESCAPE',name),sca;end
                
                %until release
                if cfg.until_release
                    [resp_release x name] = KbCheck;          % get cfg.timing and resp1 from keyboard
                    if sum(resp_release) == 1
                        if strcmp('',KbName(name))
                            resp_release = 0;
                        end
                    end
                end
        end
    end
    
end


%% compute confidence judgment
cj = resp ;

% change interval to [1 2] range
interval = 2-(int<0);

%% hide back cursor
if cfg.debugging~=1
    HideCursor;
end

return