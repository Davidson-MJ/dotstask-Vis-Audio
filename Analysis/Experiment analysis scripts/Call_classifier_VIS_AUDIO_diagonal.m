function Call_classifier_VIS_AUDIO_diagonal(cfg)
% Call_classifier_VIS_AUDIO_diagonal
% wrapper script to train a decoder on corrects vs errors, now testing each
% time point (in 50 ms steps).


%note that the current version performs baseline subtraction, and
%normalization, consider smoothing also.

%%
%for all participants, specify output

GFX_decoding= zeros(length(cfg.pfols), 2, 2,281);

[nppants, trainedon, correctErr, npnts]= size(GFX_decoding);

% new: include nIterations, which repeats (and averages), the classifier
% to use more trials. (cycles through matched sizes of Errors and Correct
% trials).

nIter = 20; % 10; % n iterations, final output is the average spatial discrimination vector.


%set up params.

if strcmp(cfg.EEGtype, 'resp')

    meanoverChans_RESP = [4,38,39,11,12,19,47,46,48,49,32,56,20,31,57]; % show channel ERP:
    showchans=meanoverChans_RESP;


else
    if strcmp(cfg.expPart, 'A'); % visual stim locked
        showchans=  [20:31, 57:64];

    else
        %aud stim locked
        showchans = [4:15,39:52]; % aud locked
    end

end
%rename for ease
pfols= cfg.pfols;
for ippant =1:length(pfols)
    
pcounter=1;


cd(cfg.eegdatadir)
cd(pfols(ippant).name);

%real ppant number:
lis = pfols(ippant).name;
ppantnum = str2num(cell2mat(regexp(lis, '\d*', 'Match')));
%% Load participant data. and set classifier parameters.

% load('participant TRIG extracted ERPs.mat');
load('participant EEG preprocessed.mat');
load('Epoch information.mat');
dec_params=[];
%for this participant, specify the classifier parameters we want:
dec_params.type = 'lr'; 
dec_params.ppant = lis;


% dec_params.dtype = 0;    % if using EEGlab data structure
% dec_params.wholeepoch_timevec = EEGcor.times;

dec_params.dtype = 1;    % if using .mat matrix.
dec_params.wholeepoch_timevec = plotERPtimes;

dec_params.chans = 1:64; % channel subset.
dec_params.normtype = 'n1'; % normalization type
dec_params.LOO = 1; % perform Leave one out sanity check.
dec_params.matchCE= 1; % match size of correct and errors.
dec_params.filtlo= 0; % filter lo/ hi
dec_params.filthi= 0;
dec_params.showchannel= showchans; % display ERP at channel, if printing
dec_params.dispprogress=0; % 1 for figure output.


% analysis parameters:
dec_params.window_frames_ms = [plotXtimes(1) plotXtimes(end)];  %needs to be shorter than actual epoch, or will error.
dec_params.baseline_ms = [-250 -50];% this baseline is subtracted (again).
dec_params.removebaseline=0;

%create data for classifier:
if strcmp(cfg.EEGtype, 'resp')

    allD = resplockedEEG;    
else
    allD = stimlockedEEG;
end

if strcmp(cfg.expPart, 'A')

    errIndx =errAindx;
    corrIndx= corAindx;
else
errIndx = errBindx;
corrIndx= corBindx;
end

dec_params.data = allD;

%save correct trial assignment (correct and errors).
vec = zeros(1,size(allD,3));
vec(errIndx)=1;
error_index=  vec;
dec_params.error_index= error_index; % in binary.

vec = zeros(1,size(allD,3));
vec(corrIndx)=1;
corr_index=  vec;
dec_params.correct_index= corr_index; % in binary.

dec_params.nIter = nIter; %% how many times to train?
% 
% % %>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
% % %call classifier based on above:
% note that we will smooth to speed up the process:
%% 
dec_params.movingWin=[0.050,.025]; % in seconds. %ensures overlap.
% dec_params.movingWin=[0.050,.005]; % in seconds.
dec_params.Fs=256;

% note that the analysis will perform decoding in a sliding window:

%%

% dec_params.data = data_ds; % now using the downsampled data.
DECout = my_Classifier_VISAUD_diagonal(dec_params);

%% now we have the classifer performance on all trials.
disp(['Now saving ppant ' num2str(ippant)]);

DECout_diagonal_window = DECout;
DECin_diagonal_windowparams = dec_params;

% save accordingly:
savename = ['Classifier_trained_' cfg.expPart '_' cfg.EEGtype '_diagonal'];
save(savename,'DECout_diagonal_window', 'DECin_diagonal_windowparams');



end