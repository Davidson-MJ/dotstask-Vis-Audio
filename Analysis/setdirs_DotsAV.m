% setdirs_DotsAV
% addpath(genpath('C:\Github\dotstask-Vis-Audio'));
try homedir='C:\Users\mdav0285\Documents\GitHub\dotstask-Vis-Audio';
cd(homedir);

catch
    homedir = '/Users/164376/Documents/DATA/dotstask- Vis+Audio EXP'; % UTS mac

% homedir =['/Users/matthewdavidson/Documents/DATA/dotstask- Vis+Audio EXP'];
% homedir = 'C:\Users\mdav0285\Documents\GitHub\dotstask-Vis-Audio';
end

addpath(genpath(homedir));
%%

behdatadir = [homedir filesep 'Exp_output/DotsandAudio_behaviour/ver2'];
figdir =[homedir  filesep 'Figures'];
eegdatadir =[homedir filesep 'EEG/ver2']; % note EEG not on work station
cd(eegdatadir)
pfols = dir([pwd filesep '*p_*']);
%
%remove any hidden files (onedrive corrupts the filelist).
pfols = striphiddenFiles(pfols); 