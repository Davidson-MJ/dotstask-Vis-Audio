% Call_classifier_VIS_AUDIO
% wrapper script to train a decoder on corrects vs errors, and totest
% classifer decoding accuracy on second half.


%%
%for all participants, specify output

GFX_decoding= zeros(length(pfols), 2, 2,281);

[nppants, trainedon, correctErr, npnts]= size(GFX_decoding);

for ippant =1:length(pfols)
    
pcounter=1;


cd(basedir)
cd(pfols(ippant).name);

%real ppant number:
lis = pfols(ippant).name;
ppantnum = str2num(cell2mat(regexp(lis, '\d*', 'Match')));
%% Load participant data. and set classifier parameters.

load('participant TRIG extracted ERPs.mat');
load('Epoch information.mat');

%for this participant, specify the classifier parameters we want:
dec_params.type = 'lr'; 
dec_params.ppant = ippant;


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
dec_params.showchannel= 32; % display ERP at channel

% analysis parameters:
dec_params.window_frames_ms = [plotXtimes(1) plotXtimes(end)];  %needs to be shorter than actual epoch, or will error.
dec_params.baseline_ms = [-250 -50];
% dec_params.training_window_ms= [05 100]; % ERN
dec_params.training_window_ms= [200 350]; % Pe

%create data for classifier:
allD = resplockedEEG;
dec_params.data = allD;

%save correct trial assignment (correct and errors).
vec = zeros(1,size(allD,3));
vec(errAindx)=1;
error_index=  vec;
dec_params.error_index= error_index; % in binary.
vec(corAindx)=1;
corr_index=  vec;
dec_params.correct_index= corr_index; % in binary.

% 
% % %>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
% % %call classifier based on above:
DECout = my_Classifier_VISAUD(dec_params);

%% now we have the classifer performance on all trials.

DEC_Pe_window = DECout;
DEC_Pe_windowparams = dec_params;
save('Classifier_objectivelyCorrect', 'DEC_Pe_window','DEC_Pe_windowparams');


%% Now also create classifer for part B.

%create data for classifier:

dec_params.data = allD;

%save correct trial assignment (correct and errors).vec(errAindx)=1;
vec = zeros(1,size(allD,3));
vec(errBindx)=1;
error_index=  vec;
dec_params.error_index= error_index; % in binary.
vec(corBindx)=1;
corr_index=  vec;
dec_params.correct_index= corr_index; % in binary.



DECout = my_Classifier_VISAUD(dec_params);

DEC_Pe_B_window = DECout;
DEC_Pe_B_windowparams = dec_params;
save('Classifier_objectivelyCorrect', 'DEC_Pe_B_window','DEC_Pe_B_windowparams','-append');


end