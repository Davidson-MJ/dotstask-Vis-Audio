%check if working on Matt's laptop, or Psych test building

%Mac or PC?
str=computer;
                                              

%set up directories accordingly (in path outpath)
supportdir = [pwd filesep 'supportfiles'];
stims_path = [supportdir filesep 'stims' filesep 'Exp1'];
conf_path = [supportdir filesep 'confidence slider'];
switch str
    case 'MACI64'
        if ~isfolder('/Users/mdavidson/Desktop/MDexp_dots+audio/dotstask- Vis+Audio')        
            mkdir('/Users/mdavidson/Desktop/MDexp_dots+audio/dotstask- Vis+Audio');
            cd('/Users/mdavidson/Desktop/MDexp_dots+audio/dotstask- Vis+Audio');
        else
            cd('/Users/mdavidson/Desktop/MDexp_dots+audio/dotstask- Vis+Audio');
        end
    case 'PCWIN64'
         if ~isfolder('/Users/mdavidson/Desktop/MDexp_dots+audio/dotstask- Vis+Audio')        
            mkdir('/Users/mdavidson/Desktop/MDexp_dots+audio/dotstask- Vis+Audio');
            cd('/Users/mdavidson/Desktop/MDexp_dots+audio/dotstask- Vis+Audio');
        else
            cd('/Users/mdavidson/Desktop/MDexp_dots+audio/dotstask- Vis+Audio');
         end
         
         %if in Anna Watts, and testing, set up serial-port to send/receive
         %triggers:
         useport = pairStimtoEEG;
         % now 'write(trigger, useport)' will send triggers.
         %define triggers based on trial position.
         cfg.EEG=1;% to send triggers
         cfg.offscreen=1; %for PTB screen settings.
end
        basedir=pwd;        
        savedir = [basedir filesep 'Exp_output'];
        
        cfg.basedirectory = basedir;
   
addpath(basedir); 
addpath(savedir); 
addpath(supportdir);
addpath(stims_path);
addpath(conf_path);

%

cd(basedir)
