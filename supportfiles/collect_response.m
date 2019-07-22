function [resp t code]  = collect_response(cfg,delay)
% resp returns 1 if keyIsDown, 0 if it is not, 2 if experimenter pressed ESCAPE
% cfg.port : 'keyboard', or precised (parallel, etc)
 
if ~isfield(cfg,'port'),            cfg.port = 'keyboard';end
if ~isfield(cfg,'experimenter'),    cfg.experimenter = 'space';end
if ~isfield(cfg,'escape'),          cfg.escape = 'ESCAPE';end
if ~isfield(cfg,'pause'),           cfg.pause = 'P';end
if ~isfield(cfg,'until_release'),   cfg.until_release = true;end
 
%% get response
resp                        = 0; % response key
t                           = 0; % time of response
code                        = '';
while (sum(resp) == 0 || isempty(code)) && t <= delay
    t           = GetSecs;
    %experimenter
    [exp_resp exp_t exp_code]       = KbCheck;          % get cfg.timing and resp1 from keyboard
    % translate
    exp_code = KbName(exp_code);
    % only take first response if multiple responses
    if ~iscell(exp_code), exp_code = {exp_code}; end
    exp_code = exp_code{1};
    if ~isempty(exp_code)
        switch exp_code
            case cfg.experimenter
                resp = exp_resp;
                code = exp_code;
                t = exp_t;
                break;
            case cfg.pause
                pause(1);
                w = 1;
                while w == 1
                    if KbCheck > 0,break;end
                end
            case cfg.escape, sca; resp = 2; break;
        end
    end
    
    if strcmp(cfg.port,'meg')              % if MEG experiment       
        [bin dec codes] =read_meg_buttons();
        if length(codes) == 1
            resp        = 1;
            code        = codes{1};
            break;
        else
            code = [];
        end

    else
        [resp z code]       = KbCheck;          % get cfg.timing and resp1 from keyboard
        % translate
        code = KbName(code);
        % only take first response if multiple responses
        if ~iscell(code), code = {code}; end
        code = code{1};
    end
end

%-- until release
if cfg.until_release
    resp_release = resp;
    while sum(resp_release) ~= 0 
        if strcmpi(cfg.port,'meg')              % if MEG experiment
            for ii = 500:-1:1
                [binary decimal name] =read_meg_buttons();
                keep_press(ii) = decimal;
            end
            if nanmean(keep_press>0) < .10
               resp_release = 0;
            end
        else
            [resp_release x name] = KbCheck;          % get cfg.timing and resp1 from keyboard
            if sum(resp_release) == 1
                if strcmp('',KbName(name))
                    resp_release = 0;
                end
            end
        end
    end
end

if sum(resp) == 0
    resp = [];
    t = [];
    code = [];
end

end