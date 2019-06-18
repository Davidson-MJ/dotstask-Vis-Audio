%check if working on Matt's laptop, or Psych test building

%Mac or PC?
str=computer;

%set up directories accordingly (in path outpath)
switch str
    case 'MACI64'
        basedir = '/Users/matthewdavidson/Desktop/dotstask- Vis+Audio';
        savedir = [basedir filesep 'Exp_output'];
        supportdir = [basedir filesep 'supportfiles'];
        
        %     case PC
end
addpath(basedir); addpath(savedir); addpath(supportdir);
%
cd(basedir)
