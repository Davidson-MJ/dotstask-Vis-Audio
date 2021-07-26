% JOBS_MatchEEG2BEH
%match BEH and EEG output

% critical step of matching the EEG data, after trial rejection, with
% eligible behavioural data, to ensure conditions are compared
% appropriately.

%runs per ppant, from the EEGdir.


clear variables
close all

%set up directories, find participant folders.
%update to work on external volume:
behdatadir = '/Volumes/MattsBackup (2TB)/dotstask- Vis+Audio EXP/Exp_output/DotsandAudio_behaviour/ver2';
eegdatadir ='/Volumes/MattsBackup (2TB)/dotstask- Vis+Audio EXP/EEG/ver2';
figdir ='/Volumes/MattsBackup (2TB)/dotstask- Vis+Audio EXP/Figures';
%%
cd(eegdatadir);
pfols = dir([pwd filesep 'p_*']);
cd(behdatadir)
allppbeh =dir([pwd filesep '*_p*']);
%%

for ippant = 1:length(pfols)
    cd(eegdatadir)
    cd(pfols(ippant).name);
    
    clearvars 'rejected*' 'allTrigger*'
    load('Epoch information.mat');
    
    %% per participant, we can calculate the remaining trials based on the following information:
    %The trial index, in EEG, of all remaining stimlocked epochs:
    %allTriggerEvents_stim contains all the recorded events in the epoched
    %dataset, using stim onset at time 0. This can contain resp locked
    %triggers (e.g. 10,11,20,21).
    allstimTrials_EEG = unique(allTriggerEvents_stim.epoch);
    allrespTrials_EEG = unique(allTriggerEvents_resp.epoch);
    
    %note that we need to adjust to match!
    
    % we also have the number (in EEG), of epochs rejected by eye:
    rejS= rejected_trials_stim;
    rejR= rejected_trials_resp;
    
    % we will return to this directory
    retdir= pwd;
    %%
    % load behavioural output, recorded in matlab.
    cd(behdatadir);
    thispp = allppbeh(ippant).name;
    disp(['PAIRING EEG from ' pfols(ippant).name ' with BEH:' thispp])
    cd(thispp)
    
    %load final saved beh
    lfile = dir([pwd filesep '*_final.mat']);
    load(lfile.name, 'alltrials');
    
    % basic info:
    alltrialsrecorded = 1:size(alltrials,2);
    alltrialsprac = find([alltrials.isprac]);
    %%
    
    % now restrict only to the remaining trial types, for both Stim and Resp locked.
    %the remaining EEG should match the total count, minus those rejected.
    cd(retdir)
    %%
    used = {'STIM', 'RESP'};
    for idset =1:2
        loadt = used{idset};
        dload = dir([ pwd filesep '*' loadt ' interpd.set']);
        %load EEG
        ALLEEG= pop_loadset('filename', [dload(1).name]);
        EEGtmp = eeg_checkset( ALLEEG );
        
        %% extract different epochs based on trigger def'ns.
        
        %restrict to EEG channels
        EEG_tmpsub = EEGtmp.data(1:64,:,:);
        switch idset
            case 1
                remainingSTIM = EEG_tmpsub;
            case 2
                remainingRESP = EEG_tmpsub;
        end
    end
    plotXtimes = EEGtmp.times;
    
    %%
    % first sanity check, does EEG match post rejection count?
    if size(remainingSTIM,3) ~=(max(allstimTrials_EEG) - length(rejS))
        error('warning - incorrect to being with (STIM)')
    elseif size(remainingRESP,3) ~=(max(allrespTrials_EEG) - length(rejR))
        error('warning - incorrect to being with (RESP)')
    end
    
    % OK, now using EEG as ground truth, match the trial indexes for stim and
    % resp, and associated behaviour in new table.
    
    %% all trials remaining (in EEG): this removes the index for trials
    % that we rejected by eye in preprocessing.
    remainingSTIM_index = allstimTrials_EEG;
    remainingSTIM_index(rejS)=[];
    
    remainingRESP_index = allrespTrials_EEG;
    remainingRESP_index(rejR)=[];
    
    %for both stim and resp, remove the trials that are present in only
    % one dataset
    
    
    % note that for some participants, EEG errors in recording also occurred,
    % as follows;
    if ippant ==2 % recording started at trial 3 (868 total trials).
        %extra complication,there is an extra resp locked Epoch, as the EEG
        % started recording late (mid trial!).
        % so hard-code to adjust all values to equate the trial indexes between stim, resp
        % and BEH
        remainingSTIM_index = remainingSTIM_index+2;
        remainingRESP_index = remainingRESP_index+1;
    end
    
    
    % use the larger dataset as reference.
    
    if length(rejS)>=length(rejR) % Stim EEG has more trials:
        keeptS = ismember(remainingSTIM_index,remainingRESP_index);
        %keeptS now indexes all the shared trials, that are in stim, but also in RESP
        %( A that is in B.(logical id))
        
        %so shrink STIM EEG
        matchedS_indx = remainingSTIM_index(keeptS);
        EEGstim_matched = remainingSTIM(:,:,keeptS);
        
        %also remove the trials from R, that are not in S (rejected from S)
        %easiest to just keep the matched indx.
        keeptR = ismember(remainingRESP_index, matchedS_indx);
        
        %logical vector containing those that are in R, but should not be.
        matchedR_indx = remainingRESP_index(keeptR);
        EEGresp_matched = remainingRESP(:,:,keeptR);
        
        
        
    elseif length(rejR)>length(rejS) % more resp than stim.
        keeptR = ismember(remainingRESP_index,remainingSTIM_index);
        
        matchedR_indx = remainingRESP_index(keeptR);
        EEGresp_matched = remainingRESP(:,:,keeptR);
        
        keeptS = ismember(remainingSTIM_index, matchedR_indx);
        
        %logical vector containing those that are in R, but should not be.
        matchedS_indx = remainingSTIM_index(keeptS);
        EEGstim_matched = remainingSTIM(:,:,keeptS);
        
    end
    
    %% retain the final trial ID, to match with beh.
    alltrials_INDX = unique([matchedS_indx, matchedR_indx]);
    %%
    
    % now all trials should match (sanity check);
    if length(alltrials_INDX) ~=(size(EEGstim_matched,3))
        error('indexing problem');
    elseif length(alltrials_INDX) ~=(size(EEGresp_matched,3))
        error('indexing problem') %
    end
    
    
    
    %%
    %% now for each type of response, let's establish index for later analysis.
    
    
    BEH_matched = alltrials(alltrials_INDX);
    %         %also remove practice trials from consideration.
    notprac = find([BEH_matched.isprac]==0);
    corAindx = intersect(find([BEH_matched.cor]), find(ismember([BEH_matched.ExpType], 'A')));
    corAindx = intersect(corAindx, notprac);
    %
    corBindx = intersect(find([BEH_matched.cor]), find(ismember([BEH_matched.ExpType], 'B')));
    corBindx = intersect(corBindx, notprac);
    
    errAindx = intersect(find([BEH_matched.cor]==0), find(ismember([BEH_matched.ExpType], 'A')));
    errAindx = intersect(errAindx, notprac);
    
    errBindx = intersect(find([BEH_matched.cor]==0), find(ismember([BEH_matched.ExpType], 'B')));
    errBindx = intersect(errBindx, notprac);
    
    visStimindx = find(ismember(lower([BEH_matched.stimtype]), 'visual'));
    visStimindx = intersect(visStimindx, notprac);
    
    audStimindx = find(ismember(lower([BEH_matched.stimtype]), 'audio'));
    audStimindx = intersect(audStimindx, notprac);
    
    
    %% now save all this, ready for analysis.
    % save all.
    save('Epoch information', 'ExpOrder', 'BEH_matched', ...
        'corAindx', 'corBindx', 'errAindx', 'errBindx', 'visStimindx',...
        'audStimindx', '-append');
    
    
    save('participant TRIG extracted ERPs', ...
        'EEGstim_matched',...
        'EEGresp_matched',...
        'plotXtimes','BEH_matched', 'ExpOrder');%, '-append');
    
end % ppant loop