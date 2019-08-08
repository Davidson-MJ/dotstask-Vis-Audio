function instructions_byXMODtype(window,cfg, setlist)

% cycles through pre-saved instructions based on experiment type
% type saved in 


%set list degined as xmodal types (1,2,3,4).
% 1 = visual no information seeking option (or confidence).
% 2 = Auditory with Information seeking option

% 3 = auditory no information seeking option (or confidence).
% 4 = Visual with Information seeking option

switch setlist
    
    case 1
        
        instructions_folder = ['instructions' filesep 'visualtask no infoseeking instructions'];
    case 2
        instructions_folder = ['instructions' filesep 'Auditorytask with infoseeking instructions'];
    case 3
        instructions_folder = ['instructions' filesep 'auditorytask no infoseeking instructions'];        
    case 4
        instructions_folder = ['instructions' filesep 'Visualtask with infoseeking instructions'];
        
end


%% now cycle through the appropriate set list.

allinstr= dir([ instructions_folder filesep '*.jpeg']);
%%
r=1; 
while r<= length(allinstr)
    
    %read image:
    insimdata = imread([instructions_folder filesep  allinstr(r).name ]);
    
    %show in PTB
    texins = Screen('MakeTexture', window.Number, insimdata);
    Screen('DrawTexture', window.Number, texins,[],window.Rect);
    Screen('Flip',window.Number);
    WaitSecs(.25);
    %wait for response (allows backtracking)
    
      [responded tilde code] = collect_response(cfg,inf);
    
    switch code
        case 'LeftArrow'
            r = r-1;
        case 'RightArrow'
            r = r+1;
        case 'space'
            %if space bar, play two tones (easy; 500 vs 600 Hz)
            firsttone               = sin(2*pi*[0:1/cfg.audrate:cfg.auddur]*700);
            secondtone              = sin(2*pi*[0:1/cfg.audrate :cfg.auddur]*400);
            
            %append tones, using a small gap between:
            gaptones = nan(1,cfg.audrate*cfg.tonegap);
            thistrialtone = [firsttone, gaptones, secondtone];
            % fill both channels:
            chanDATA = [thistrialtone;thistrialtone];
            
            %% stimulus presentation
            PsychPortAudio('FillBuffer', cfg.pahandle, chanDATA);
            %play immediately 
            PsychPortAudio('Start', cfg.pahandle, 1);

    end
            
    end
    %
    if r<1
        r=1; % don't allow a zero.
    end
end
    %%
    