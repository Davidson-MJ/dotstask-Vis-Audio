% Call_classifier_VIS_AUDIO_diagonal
% wrapper script to train a decoder on corrects vs errors, now testing each
% time point (in 50 ms steps).


%note that the current version performs baseline subtraction, and
%normalization, consider smoothing also.

%%
%for all participants, specify output

GFX_decoding= zeros(length(pfols), 2, 2,281);

[nppants, trainedon, correctErr, npnts]= size(GFX_decoding);

% new: include nIterations, which repeats (and averages), the classifier
% to use more trials. (cycles through matched sizes of Errors and Correct
% trials).

nIter = 10; % 10; % n iterations, final output is the average spatial discrimination vector.



for ippant =1%:length(pfols);
    
pcounter=1;


cd(eegdatadir)
cd(pfols(ippant).name);

%real ppant number:
lis = pfols(ippant).name;
ppantnum = str2num(cell2mat(regexp(lis, '\d*', 'Match')));
%% Load participant data. and set classifier parameters.

% load('participant TRIG extracted ERPs.mat');
load('participant Long TRIG extracted ERPs.mat');
load('Epoch information.mat');

%for this participant, specify the classifier parameters we want:
dec_params.type = 'lr'; 
dec_params.ppant = lis;


% dec_params.dtype = 0;    % if using EEGlab data structure
% dec_params.wholeepoch_timevec = EEGcor.times;

dec_params.dtype = 1;    % if using .mat matrix.
dec_params.wholeepoch_timevec = plotXtimes;

dec_params.chans = 1:64; % channel subset.
dec_params.normtype = 'n1'; % normalization type
dec_params.LOO = 1; % perform Leave one out sanity check.
dec_params.matchCE= 1; % match size of correct and errors.
dec_params.filtlo= 0; % filter lo/ hi
dec_params.filthi= 0;
dec_params.showchannel= 32; % display ERP at channel, if printing
dec_params.dispprogress=0; % 1 for figure output.


% analysis parameters:
dec_params.window_frames_ms = [plotXtimes(1) plotXtimes(end)];  %needs to be shorter than actual epoch, or will error.
dec_params.baseline_ms = [-250 -50];% this baseline is subtracted (again).
dec_params.removebaseline=0;

%create data for classifier:
allD = resplockedEEG;
dec_params.data = allD;

%save correct trial assignment (correct and errors).
vec = zeros(1,size(allD,3));
vec(errAindx)=1;
error_index=  vec;
dec_params.error_index= error_index; % in binary.

vec = zeros(1,size(allD,3));
vec(corAindx)=1;
corr_index=  vec;
dec_params.correct_index= corr_index; % in binary.

dec_params.nIter = nIter; %% how many times to train?
% 
% % %>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
% % %call classifier based on above:
% 
dec_params.timebins = -500:50:950;


DECout = my_Classifier_VISAUD_diagonal(dec_params);

%% now we have the classifer performance on all trials.
disp(['Now saving ppant ' num2str(ippant)]);

DEC_diagonal_window = DECout;
DEC_diagonal_windowparams = dec_params;
save('Classifier_objectivelyCorrect','DEC_diagonal_window', 'DEC_diagonal_windowparams','-append');





end