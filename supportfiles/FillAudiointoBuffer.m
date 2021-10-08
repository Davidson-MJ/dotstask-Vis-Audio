% FillAudiointoBuffer



Run_staircase;

%Following Ais et al., Cognition, 2016:
%first tone randomly selected between 300-700 Hz. Different to second tone
%determined by above staircase:
%%
firstHz = randi([300, 700], 1);
lowtone               = firstHz;
lowtoneplay            = sin(2*pi*[0:1/cfg.audrate:cfg.auddur]*lowtone);

%note that the ratio difference between two frequencies determines pitch
%discrimination. therefore 150 Hz difference is not always equivalent. 

%.:. we need to convert our staircase difference (in Hz), to a ratio of the
%first frequency:
hightone = lowtone * (1 + alltrials(t).stimdifference/100);
% hightone              = firstHz + alltrials(t).stimdifference;

hightoneplay          = sin(2*pi*[0:1/cfg.audrate :cfg.auddur]*hightone);



%place higher tone where appropriate:
largerLoc = alltrials(t).whereTrue;
%append tones, using a small gap between:
gaptones = nan(1,cfg.audrate*cfg.tonegap);
gaptones = zeros(1,cfg.audrate*cfg.tonegap);

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
