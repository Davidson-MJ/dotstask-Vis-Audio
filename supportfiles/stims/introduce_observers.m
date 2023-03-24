cfg.expositionTime = [];
cfg.expositionTime=[];
advisors = randperm(4);
pressKey = 'Press any key';
bounds = Screen('TextBounds',Sc.window,pressKey);
for obs = advisors
    % draw advisor image
    imagedata = imread([stims_path '/observer',int2str(cfg.advisor.pics(obs)),'.jpg']);
    Screen('DrawText', Sc.window, 'Press any key', Sc.center(1)-bounds(3)/2,Sc.center(2)+Sc.size(2)/3, 0);
    texture = Screen('MakeTexture', Sc.window, imagedata);
    Screen('DrawTexture', Sc.window, texture, [], CenterRectOnPoint([0 0 258 325],(Sc.center(1)),(Sc.center(2))));
    
    % fill audio buffer with advisor voice
    speech = PsychPortAudio('Open', [], [], 0, cfg.introSpeechFreq{cfg.advisor.voices(obs)}, cfg.introSpeechChannels{cfg.advisor.voices(obs)});
    PsychPortAudio('FillBuffer',speech , cfg.introSpeechData{cfg.advisor.voices(obs)});
    
    % get time
    ti=GetSecs;
    
    % flip on screen
    onset_pic(obs) = Screen('Flip',Sc.window,ti);
    
    % start audio
    onset_speech(obs)  = PsychPortAudio('Start', speech, 1);
    
    % stop audio
    [startTime offset_speech(obs) xruns ~] = PsychPortAudio('Stop', speech,1);
    
    % close audio device
    PsychPortAudio('Close', speech);
    
    % wait for response
    [resp offset_pic(obs) kcode] = collect_response(cfg,inf);
    Screen('Flip',Sc.window);
    cfg.expositionTime(obs) = offset_pic(obs) - ti;
end

cfg.obsIntro_times = [onset_pic; offset_pic; onset_speech; offset_speech];
clear startTime xruns resp kcode ti speech imagedata texture bounds pressKey