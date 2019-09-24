function [cj, resp_t, interval, hasconfirmed] = fill_mouseboxes(window,cfg, prevfliptime, stimtype, trialpos)
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
  hasconfirmed=false; % Click within respond time changes this val.
  int=0;
  cj=1;
  
 
  
% %% display cursor
% if isempty(cj1)
%     ft = display_response_(window,cfg,[haschanged,resp+int]);
% else
%     ft = display_response_(window,cfg,[haschanged,resp+int],cj1);
% end


% make sure box is there to be filled)
draw_simpleResponseinstructions(window, cfg, stimtype); 

%% collect response
while ~any(buttons) % wait for click
    [~,~,buttons] = GetMouse; % not interested in location.
end

% what time for response?
resp_t = GetSecs;

%if too slow, mark trial as incomplete
if resp_t > prevfliptime + cfg.stim.respduration 
    
    % fill both boxes with red as error.
%     Screen('FillRect', window.Number, [255,0,0], cfg.MouseRect_pos1);
%     Screen('FillRect', window.Number, [255,0,0], cfg.MouseRect_pos2);    
    
interval=find(buttons);
    
else
     hasconfirmed=true; 
    % display response:
    % fill box on screen according to button pressed:
    if find(buttons)==1
        
%instead of providing coloured feedback, simply emphasize frame border
%(green is too positive).
% Screen('FrameRect', window.Number, [255,255,255], cfg.MouseRect_pos1, 14);
% Screen('FrameRect', window.Number, [127,127,127], cfg.MouseRect_pos2, 1);
        interval=1;
        
    elseif find(buttons)==2
        %fill right mouse button.
%         Screen('FrameRect', window.Number, [255,255,255], cfg.MouseRect_pos2, 6);
%         Screen('FrameRect', window.Number, [127,127,127], cfg.MouseRect_pos1, 1);
        interval=2;
    end
end
%flip to show response.

Screen('Flip', window.Number);

return