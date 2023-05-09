% setdirs_DotsAV
% addpath(genpath('C:\Github\dotstask-Vis-Audio'));
homedir='C:\Users\mdav0285\Documents\GitHub\dotstask-Vis-Audio';
cd(homedir);
addpath(genpath(homedir));
%
% addpath('/Users/matthewdavidson/Documents/GitHub/dotstask-Vis-Audio/Analysis/')
%update to work on external volume:
% homedir = 'C:\Users\mdav0285\Documents\dotstask- Vis+Audio EXP';
datadir = 'C:\Users\mdav0285\Documents\Data\dotstask- Vis+Audio EXP';

behdatadir = [datadir filesep 'Exp_output/DotsandAudio_behaviour/ver2'];
figdir =[datadir  filesep 'Figures'];
eegdatadir =[datadir filesep 'EEG/ver2'];
cd(eegdatadir)
pfols = dir([pwd filesep '*p_*']);
%
%remove any hidden files (onedrive corrupts the filelist).
pfols = striphiddenFiles(pfols); 