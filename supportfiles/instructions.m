function [] = instructions(window,cfg, setlist)
% Usage:
% instructions(set, groups)
% Inputs:
% set: instruction part. Typically block number
% groups: vector indicating the boundaries of slides groupings


r = cfg.instr.groups(setlist);

cfg.advisor.type = 1;
while r< cfg.instr.groups(setlist+1)
    
    if cfg.advisor.type == 1 %
        insimdata = imread(['instructions/instr' num2str(r) '.jpg']);
        
%     else
%         
        texins = Screen('MakeTexture', window.Number, insimdata);
        Screen('DrawTexture', window.Number, texins,[],window.Rect);
        Screen('Flip',window.Number);
        WaitSecs(.25);
        [responded tilde code] = collect_response(cfg,inf);
        switch code
            case 'LeftArrow'
                r = r-1;
            case 'RightArrow'
                r = r+1;
        end
        % 
        if r<cfg.instr.groups(setlist)
            r=cfg.instr.groups(setlist);
        end
    end
    %%
    
end