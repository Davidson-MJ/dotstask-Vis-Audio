%check if working on Matt's laptop, or Psych test building

%Mac or PC?
str=computer;

%set up directories accordingly (in path outpath)
supportdir = [pwd filesep 'supportfiles'];
stims_path = [supportdir filesep 'stims' filesep 'Exp1'];
conf_path = [supportdir filesep 'confidence slider'];
switch str
    case 'MACI64'
        if ~isfolder('/Users/mdavidson/Desktop/dotstask- Vis+Audio')        
            mkdir('/Users/mdavidson/Desktop/dotstask- Vis+Audio');
            cd('/Users/mdavidson/Desktop/dotstask- Vis+Audio');
        else
            cd('/Users/mdavidson/Desktop/dotstask- Vis+Audio');
        end
        basedir=pwd;        
        savedir = [basedir filesep 'Exp_output'];
        
        
        
        %     case PC % in EEG room.
end
addpath(basedir); 
addpath(savedir); 
addpath(supportdir);
addpath(stims_path);
addpath(conf_path);
%
cd(basedir)
