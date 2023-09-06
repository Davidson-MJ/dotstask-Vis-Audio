% setdirs_DotsAV
% addpath(genpath('C:\Github\dotstask-Vis-Audio'));
try homedir='C:\Users\mdav0285\Documents\GitHub\dotstask-Vis-Audio';
cd(homedir);
catch
    
    homedir =['/Users/matthewdavidson/Documents/DATA/dotstask- Vis+Audio EXP'];

end

addpath(genpath(homedir));
%
% addpath('/Users/matthewdavidson/Documents/GitHub/dotstask-Vis-Audio/Analysis/')
%update to work on external volume:
% homedir = 'C:\Users\mdav0285\Documents\dotstask- Vis+Audio EXP';
behdatadir = [homedir filesep 'Exp_output/DotsandAudio_behaviour/ver2'];
figdir =[homedir  filesep 'Figures'];
eegdatadir =[homedir filesep 'EEG/ver2'];
cd(eegdatadir)
pfols = dir([pwd filesep '*p_*']);
%
%remove any hidden files (onedrive corrupts the filelist).
pfols = striphiddenFiles(pfols); 