function [cj, resp_t, interval, hasconfirmed] = fill_mouseboxes(window,cfg, prevfliptime)
% Usage:
% [cj resp_t interval hasconfirmed] = fill_mouseboxes(window,cfg [,cj1])
% Inputs:
% window: window(PTB) structure
% cfg: cfg structure

%outputs:
% cj = confidence judgmeent. Included for backwards compatibility. [1]
% resp_t = response time (in secs).
% interval = response selection.
% hasconfirmed = space bar pressed to submit response.

%by MDavidson July 2019.


%% initialize variables
  resp = 0;
  buttons=[]; 
  haschanged=false; 
  hasconfirmed=true; % all clicks taken as a response in time.
  int=0;
  cj=1;
  
% %% display cursor
% if isempty(cj1)
%     ft = display_response_(window,cfg,[haschanged,resp+int]);
% else
%     ft = display_response_(window,cfg,[haschanged,resp+int],cj1);
% end


% make sure box is there to be filled)
draw_simpleResponseinstructions(window, cfg); 

%% collect response
while ~any(buttons) % wait for click
    [~,~,buttons] = GetMouse; % not interested in location.
end

% what time for response?
resp_t = GetSecs;

%if too slow fill both boxes with RED .
if resp_t > prevfliptime + cfg.respduration
    
    % fill both boxes with red as error.
    Screen('FillRect', window.Number, [255,0,0], cfg.MouseRect_pos1);
    Screen('FillRect', window.Number, [255,0,0], cfg.MouseRect_pos2);    
    interval=find(buttons);
    
else
    % display response:    
    % fill box on screen according to button pressed:
    if find(buttons)==1
        % fill left mouse button.
        Screen('FillRect', window.Number, [102,255,0], cfg.MouseRect_pos1);
        Screen('FillRect', window.Number, [0,0,0], cfg.MouseRect_pos2);
        interval=1;
        
    elseif find(buttons)==2
        %fill right mouse button.
        Screen('FillRect', window.Number, [102,255,0], cfg.MouseRect_pos2);
        Screen('FillRect', window.Number, [0,0,0], cfg.MouseRect_pos1);
        
        interval=2;
    end
end
%flip to show response.

Screen('Flip', window.Number);
% wait until release of spacebar? until release
%                 if cfg.until_release
%                     [resp_release x name] = KbCheck;          % get cfg.timing and resp1 from keyboard
%                     if sum(resp_release) == 1
%                         if strcmp('',KbName(name))
%                             resp_release = 0;
%                         end
%                     end
%                 end

%         
% while ~hasconfirmed % before spacebar
%     
%     while any(buttons) || ~haschanged   % wait for release and change of cj and confirmation
%         [resp_x, resp_y, buttons] = GetMouse();
%         
%   
% 
%         if resp_x>=cfg.bar.barrect(1) && resp_x<window.Center(1) % if mouse's on the left rect
%               resp = find(resp_x < (cfg.bar.xshift+cfg.bar.cursorwidth.*.5),1) - cfg.bar.maxScale-1;
%             haschanged = true;
%             int = -1;
%             if resp==0, resp=int;end
%         elseif resp_x>=window.Center(1) && resp_x<=cfg.bar.barrect(3) % if mouse's on the right rect
%             resp = find(resp_x < (cfg.bar.xshift+cfg.bar.cursorwidth.*.5),1) - cfg.bar.maxScale;
%             haschanged = true;
%             int = 1;
%             if isempty(resp), resp=cfg.bar.maxScale;end
%         end
%         
%         % bound response to maximum value
% %         if resp<-(cfg.bar.maxScale-round(cfg.bar.gap_size/2)),
% %             resp=-(cfg.bar.maxScale-round(cfg.bar.gap_size/2));
% %         elseif resp>(cfg.bar.maxScale-round(cfg.bar.gap_size/2)),
% %             resp=(cfg.bar.maxScale-round(cfg.bar.gap_size/2));
% %         end 
% %         
%         %--- display response
%         if isempty(cj1)
%             ft = display_response_(window,cfg,[haschanged,resp]);
%         else
%             ft = display_response_(window,cfg,[haschanged,resp],cj1);
%         end
%     end
%     
%     % check for confirmation
%     if ~hasconfirmed
%         switch 'keyboard'
%             case 'mouse'
%                 [x,y,buttons] = GetMouse;
%                 if buttons(3)==1, hasconfirmed = true;end
%                 resp_t = GetSecs;

%             case 'keyboard'
%                 [x,y,buttons] = GetMouse;
%                 [isdown resp_t keycode] = KbCheck;                 % get timing and key
%                 % translate key code into key name
%                 name = KbName(keycode);
%                 % only take first response if multiple responses
%                 if ~iscell(name), name = {name}; end
%                 name = name{1};
%                 if strcmp('space',name),hasconfirmed = true;end
%                 if strcmp('ESCAPE',name),sca;end
%                 
%                 %until release
%                 if cfg.until_release
%                     [resp_release x name] = KbCheck;          % get cfg.timing and resp1 from keyboard
%                     if sum(resp_release) == 1
%                         if strcmp('',KbName(name))
%                             resp_release = 0;
%                         end
%                     end
%                 end
%         end
%     end
%     
% end


%% compute confidence judgment
% cj = resp ;

% change interval to [1 2] range
% interval = 2-(int<0);

%% hide back cursor
% HideCursor;

return