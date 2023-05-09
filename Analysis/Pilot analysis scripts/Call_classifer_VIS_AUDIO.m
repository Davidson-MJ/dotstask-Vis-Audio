% Call_classifier_VIS_AUDIO
% wrapper script to train a decoder on corrects vs errors, and totest
% classifer decoding accuracy on second half.


%%
%for all participants, specify output

GFX_decoding= zeros(length(pfols), 2, 2,281);

[nppants, trainedon, correctErr, npnts]= size(GFX_decoding);

% new: include nIterations, which repeats (and averages), the classifier
% to use more trials. (cycles through matched sizes of Errors and Correct
% trials).

nIter = 20; % 10; % n iterations, final output is the average spatial discrimination vector.

useERNorPE=2;
meanoverChans_RESP = [4,38,39,11,12,19,47,46,48,49,32,56,20,31,57]; % show channel ERP:
for ippant =1:length(pfols);
    
pcounter=1;


cd(eegdatadir)
cd(pfols(ippant).name);

%real ppant number:
lis = pfols(ippant).name;
ppantnum = str2num(cell2mat(regexp(lis, '\d*', 'Match')));
%% Load participant data. and set classifier parameters.

% load('participant TRIG extracted ERPs.mat');
load('participant EEG preprocessed.mat');
load('Epoch information.mat');

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
dec_params.showchannel= meanoverChans_RESP; % display ERP at channel, if printing
dec_params.dispprogress=1; % 1 for figure output.


% analysis parameters:
dec_params.window_frames_ms = [plotERPtimes(1) plotERPtimes(end)];  %needs to be shorter than actual epoch, or will error.
dec_params.baseline_ms = [-100 -50];
dec_params.removebaseline=0; % toggle for additional baseline subtraction.

if useERNorPE==1
dec_params.training_window_ms= [05 100]; % ERN
else    
dec_params.training_window_ms= [200 350]; % Pe
end

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
DECout = my_Classifier_VISAUD(dec_params);

%% now we have the classifer performance on all trials.

if useERNorPE==1

DEC_ERN_window = DECout;
DEC_ERN_windowparams = dec_params;
save('Classifier_trained_A_resp_ERN_window','DEC_ERN_window', 'DEC_ERN_windowparams','-append');
else
DEC_Pe_window = DECout;
DEC_Pe_windowparams = dec_params;    
save('Classifier_trained_A_resp_Pe_window', 'DEC_Pe_window','DEC_Pe_windowparams');
end



%% Now also create classifer for part B.
% 
% %create data for classifier:
% 
% dec_params.data = allD;
% 
% %save correct trial assignment (correct and errors).vec(errAindx)=1;
% vec = zeros(1,size(allD,3));
% vec(errBindx)=1;
% error_index=  vec;
% dec_params.error_index= error_index; % in binary.
% 
% vec = zeros(1,size(allD,3));
% vec(corBindx)=1;
% corr_index=  vec;
% dec_params.correct_index= corr_index; % in binary.
% 
% 
% 
% DECout = my_Classifier_VISAUD(dec_params);
% 
% DEC_Pe_B_window = DECout;
% DEC_Pe_B_windowparams = dec_params;
% save('Classifier_objectivelyCorrect', 'DEC_Pe_B_window','DEC_Pe_B_windowparams','-append');


end