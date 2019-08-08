% FillAudiointoBuffer


if t > 2 % need two previous trials
    %using PAL toolbox. update for previous responses.
    response = alltrials(t-1).cor;
    UD = PAL_AMUD_updateUD(UD, response); %update UD structure
    
    %we have the new difference in log units.
    % convert to ndots:
    %
    alltrials(t).stimdifference = UD.xCurrent;
    
else
    alltrials(t).stimdifference = cfg.intialstimDifference;
end

%Following Ais et al., Cognition, 2016:
%first tone randomly selected between 300-700 Hz. Different to second tone
%determined by above staircase:
%%
firstHz = randi([300, 700], 1);
lowtone               = firstHz;
lowtoneplay            = sin(2*pi*[0:1/cfg.audrate:cfg.auddur]*lowtone);

hightone              = firstHz + alltrials(t).stimdifference;
hightoneplay          = sin(2*pi*[0:1/cfg.audrate :cfg.auddur]*hightone);



%place higher tone where appropriate:
largerLoc = alltrials(t).whereTrue;
%append tones, using a small gap between:
gaptones = nan(1,cfg.audrate*cfg.tonegap);

if largerLoc==1 %First tone larger
    
    %record Hz presented for posterity sake.
    alltrials(t).firstHz= hightone;
    alltrials(t).secondHz = lowtone;
    thistrialtone = [hightoneplay, gaptones, lowtoneplay];
else
    alltrials(t).firstHz= lowtone;
    alltrials(t).secondHz = hightone;
    thistrialtone = [lowtoneplay, gaptones, hightoneplay];
end

%% stimulus presentation
% fill both channels:
chanDATA = [thistrialtone;thistrialtone];
PsychPortAudio('FillBuffer', cfg.pahandle, chanDATA);
