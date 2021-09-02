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
    
    
    %% load Beh data to help with corrections
    % We will return to this directory
    retdir= pwd;
    %%
    % load behavioural output, recorded in matlab.
    cd(behdatadir);
    thispp = allppbeh(ippant).name;
    disp(['PAIRING EEG from ' pfols(ippant).name ' with BEH:' thispp])
    cd(thispp)
    
    %load final saved beh
    lfile = dir([pwd filesep '*_final.mat']);
    load(lfile.name, 'alltrials', 'cfg');
    %store the experiment order for later plots.
    ExpOrder = lower(cfg.stimTypes);    
    cd(retdir)
    
    

    %% prepare data
    tStim =num2str(max(allTriggerEvents_stim.epoch));
    tResp =num2str(max(allTriggerEvents_resp.epoch));
    disp(['Prepping ' pfols(ippant).name ]);
    disp(['Pre-Rej, stim EEG count = ' num2str(tStim)]);
    disp(['Pre-Rej, resp EEG count = ' num2str(tResp)]);
    %%
    % make copies, retain the events for the processed data 
    %( before and after rejection based on eeglab index).
    
    % Restrict table to only stim and resp codes:
    % stim trigs: 2,3, 102,103 
    % resp trigs: 10,11,20,21, 110,111, 120, 121 
    

    allstimTrials_rows = find(ismember(allTriggerEvents_stim.type, [2,3,102,103]));
    allTriggerEvents_stim = allTriggerEvents_stim(allstimTrials_rows,:);
    
    allrespTrials_rows = find(ismember(allTriggerEvents_resp.type, [10,11,20,21,110,111,120,121]));
    allTriggerEvents_resp = allTriggerEvents_resp(allrespTrials_rows,:);
     
    %% Note that for some participants, EEG errors in recording also occurred.
    % before removing the rejected epochs, we need to first adjust the
    % saved epoch information. Otherwise, the remaining EEG indices,
    % recorded in eeglab, will not correspond with our behavioural data.
    
    
    %%
    if ~strcmp(tStim,tResp) % find whether the trials were misaligned.
    
    % The following scatter plot can be plotted for any participant. For
    % those with errors, the zoom is placed to highlight the change needed
    % within the scatter data.
    
    % we also have the index (in EEG), of epochs rejected by eye.   
    % we can now remove those rejected, to retain information of our 
    % processed dataset.
        
        % function plotdebugscatter(a,b)
        clf; figure(1);
        subplot(211)
        sX = allTriggerEvents_stim.urevent;
        sY = allTriggerEvents_stim.epoch;
        rX = allTriggerEvents_resp.urevent;
        rY = allTriggerEvents_resp.epoch;
        scatter(sX,sY, '>'); hold on; scatter(rX,rY,'<');
        xlabel('EEG event'), ylabel('recorded epoch'); legend('stim', 'resp');
        shg
         
        
    end
      %%  
    if ippant ==2 
        % recording started at trial 3 (868 stim trials, 869 resp locked).
        % And an extra complication, there was an extra resp locked Epoch, as the EEG
        % started recording late (mid trial!).
        
        % Hard-code to adjust all values to fix the trial indexes.
        
        %These errors are visible at the beginning of epoch counts: 
        ylim([0 5]);
        
        %EEG indices need to be increased to match BEH data.
        allTriggerEvents_stim.epoch = allTriggerEvents_stim.epoch+2;
        allTriggerEvents_resp.epoch = allTriggerEvents_resp.epoch+1;
        
        %replot scatter as sanity check:
        sX = allTriggerEvents_stim.urevent;
        sY = allTriggerEvents_stim.epoch;
        rX = allTriggerEvents_resp.urevent;
        rY = allTriggerEvents_resp.epoch;
        figure(1); clf; scatter(sX,sY, '>'); hold on; scatter(rX,rY,'<');
        xlabel('EEG event'), ylabel('recorded epoch'); legend('stim', 'resp');
        
        
        %now we can remove the rejected epochs safely.
        tmp=allTriggerEvents_resp;
        tmp(rejected_trials_resp,:)=[];
        allTriggerEvents_resp_gd=tmp;
        
        tmp=allTriggerEvents_stim;
        tmp(rejected_trials_stim,:)=[];
        allTriggerEvents_stim_gd=tmp;
        
    elseif ippant ==4
        % stim trials = 869, resp trials = 870.
        % use the following to plot, and identify which epoch is skipped:

        %These errors are visible at the  epoch counts: 
        ylim([663 670]); shg
        
        % For this ppant, there is a missing stim trigger ("102"). On epoch
        % 667, stimulus onset events begin to follow after  responses! 
        % therefore stim epoch 667 is actually 668, Adjust all thereafter
        % accordingly.
        
        %find the relevant index.
        tmp=allTriggerEvents_stim.epoch;
        changeme = find(tmp==667);
        
        %extract epoch indices of interest, adjust value.
        tmp2 = tmp(changeme(1):end);
        allTriggerEvents_stim.epoch(changeme(1):end) = tmp2+1; 
        
    %now we can remove the rejected epochs safely.
        tmp=allTriggerEvents_resp;
        tmp(rejected_trials_resp,:)=[];
        allTriggerEvents_resp_gd=tmp;
        
        tmp=allTriggerEvents_stim;
        tmp(rejected_trials_stim,:)=[];
        allTriggerEvents_stim_gd=tmp;
    elseif ippant ==6; 
        %stim trials = 869. resp trials = 870.
        % for this ppant, missing a trigger "2" on epoch 46. 46 is actually
        % 47. Adjust accordingly...
        %These errors are visible at the  epoch counts: 
        ylim([42 49]); shg
        %find the relevant index.
        tmp=allTriggerEvents_stim.epoch;
        changeme = find(tmp==46);
        
        %extract epoch indices of interest, adjust value.
        tmp2 = tmp(changeme(1):end);
        allTriggerEvents_stim.epoch(changeme(1):end) = tmp2+1; 
       
        %now we can remove the rejected epochs safely.
        tmp=allTriggerEvents_resp;
        tmp(rejected_trials_resp,:)=[];
        allTriggerEvents_resp_gd=tmp;
        
        tmp=allTriggerEvents_stim;
        tmp(rejected_trials_stim,:)=[];
        allTriggerEvents_stim_gd=tmp;
        
    elseif ippant==13
        % stim trials = 869, resp trials = 870.
        
        % For this ppant, there is a missing trigger ("2"), for stimulus onset, on
        % epoch 184 (should be event 551). Epoch 184 in stimulus EEG dataset is missing. 
        % Thus is 184 is 185, increment all the remaining epoch indices to
        % correct.
         
        %These errors are visible at the  epoch counts: 
        ylim([179 190]); shg
        
        
        %find the relevant index.
        %find the relevant index.
        tmp=allTriggerEvents_stim.epoch;
        changeme = find(tmp==184);
        
        %extract epoch indices of interest, adjust value.
        tmp2 = tmp(changeme(1):end);
        allTriggerEvents_stim.epoch(changeme(1):end) = tmp2+1; 
         
        %now we can remove the rejected epochs safely.
        tmp=allTriggerEvents_resp;
        tmp(rejected_trials_resp,:)=[];
        allTriggerEvents_resp_gd=tmp;
        
        tmp=allTriggerEvents_stim;
        tmp(rejected_trials_stim,:)=[];
        allTriggerEvents_stim_gd=tmp;
    elseif ippant == 16;
        
        %This one is tricky, since we will be removing data, we need to
        %first remove the rejected trials from preprocessing.
        % Then any remaining differences
        % with BEH can be addressed.
        
        allTriggStim_tmp = allTriggerEvents_stim;
        allTriggStim_tmp(rejected_trials_stim,:) =[];
        
        allTriggResp_tmp = allTriggerEvents_resp;
        allTriggResp_tmp(rejected_trials_resp,:) =[];
        
        %% plot the scatter to inspect:
        subplot(212)
        sX = allTriggStim_tmp.urevent;
        sY = allTriggStim_tmp.epoch;
        rX = allTriggResp_tmp.urevent;
        rY = allTriggResp_tmp.epoch;
        figure(1); clf; scatter(sX,sY, '>'); hold on; scatter(rX,rY,'<');
        xlabel('EEG event'), ylabel('recorded epoch'); legend('stim', 'resp');
        
        % A missing trigger on trial 241.
        %find the relevant index.
        tmp=allTriggStim_tmp.epoch;
        changeme = find(tmp==241);
        
        %extract epoch indices of interest, adjust value.
        tmp2 = tmp(changeme(1):end);
        allTriggStim_tmp.epoch(changeme(1):end) = tmp2+1; 
        
        % Still too many responses, compared to behavioural order of responses.
        % There are spurious extra clicks in EEG, prior to start of second
        % half (part B). 
        %(found when looking at all response triggers in EEG (pre-rej), 
        % and order of resps in BEH. See variable compareOrder, calcd below).
        
        %	delete extra entries from EEG stim and resp indx.
        % (NB: following part A, first 3 resp trigs are bogus.    
        % remove those for comparison)
        
        % epochs 480:482 (in StimEEG) 
        % epochs 481:483 (in RespEEG) 
        
        %The corresponding trigger events  are 
        % 1441 (103), 1442 (120)
        % 1446 (103), 1447 (121)
        % 1450 (103). 1351 (111)
        % These have no corresponding
        % behavioural data.
        % Epochs should resume at epoch #481, trigger code 111.
        
        %delete entries:
        allTriggStim_tmp(480:482,:)=[];
        allTriggResp_tmp(481:483,:)=[];
        
        %now adjust
        tt = find(allTriggStim_tmp.epoch==484);
        allTriggStim_tmp.epoch(tt:end) = allTriggStim_tmp.epoch(tt:end)-3; 
        
        tt = find(allTriggResp_tmp.epoch==484);
        allTriggResp_tmp.epoch(tt:end,:) = allTriggResp_tmp.epoch(tt:end)-3; 
        
        % now we can save our index.
        allTriggerEvents_resp_gd = allTriggResp_tmp;
        allTriggerEvents_stim_gd = allTriggStim_tmp;
        
        disp(['Remember to remove from processed EEG, participant 16:'])
        disp(['Stim EEG: epochs 480:482.'])
        disp(['Resp EEG: epochs 481:483.'])
        pause(1)
    elseif ippant == 17;        
        % stim trials = 869, resp trials = 870.
        
        % For this ppant, there is a missing trigger, for stimulus onset, on
        % epoch 332 (should be event 995). Epoch 332 in stimulus EEG dataset is missing. 
        % Thus is 332 is 333, increment all the remaining epoch indices to
        % correct.
         
        %These errors are visible at the  epoch counts: 
        ylim([330 340]); shg
        
        
        %find the relevant index.
        %find the relevant index.
        tmp=allTriggerEvents_stim.epoch;
        changeme = find(tmp==332);
        
        %extract epoch indices of interest, adjust value.
        tmp2 = tmp(changeme(1):end);
        allTriggerEvents_stim.epoch(changeme(1):end) = tmp2+1; 
        
        %now we can remove the rejected epochs safely.
        tmp=allTriggerEvents_resp;
        tmp(rejected_trials_resp,:)=[];
        allTriggerEvents_resp_gd=tmp;
        
        tmp=allTriggerEvents_stim;
        tmp(rejected_trials_stim,:)=[];
        allTriggerEvents_stim_gd=tmp;
    else
        % for all other participants, we don't need to carefully adjust
        % the trial info (all 870 recorded for both stim and resp).
        % therefore the ...gd information, is just triggers with rejected
        % epochs removed:
        %set up a copy.
        
        allTriggerEvents_resp_gd =allTriggerEvents_resp ;
        allTriggerEvents_stim_gd =allTriggerEvents_stim ;
        
        allTriggerEvents_resp_gd(rejected_trials_resp,:) =[];
        allTriggerEvents_stim_gd(rejected_trials_stim,:) =[];
    end
    
    
    %% having now adjusted the epoch numbers, we can continue to match with BEH data.
    %THe critical variables:
    allstimTrials_inEEG_BEHindx=allTriggerEvents_stim_gd.epoch;    
    allrespTrials_inEEG_BEHindx=allTriggerEvents_resp_gd.epoch;
    
    
    %% stock take: compare the order of events (correct and error), in both behaviour
    % and EEG response triggers, to make sure they are align before
    % continuing.
    %to match the trigger codes, first half trials 
    % 1,2 for left/right response= 1,0 for correct incorrect, resulting in
    % (10,11,20,21).
    
    %match behavioural data to trigger codes:
    allBehresps = ([alltrials.resp1_loc] .*10) + ([alltrials.cor]);
    %         %increment all second half by 100, to match EEG triggers.
    secondHalf = ismember([alltrials.ExpType],'B');
    allBehresps(secondHalf) = allBehresps(secondHalf)+100;
    
    %now compare order of recorded and retained trigger codes in EEG, with
    %the BEH data.
    allBeh_trigs= allBehresps(allrespTrials_inEEG_BEHindx);
    allEEG_trigs= allTriggerEvents_resp_gd.type;
    
    %should be no difference between the 2!
             triggdiff = allBeh_trigs - allEEG_trigs';
    clf; 
    xvec= 1:length(allBeh_trigs);
    subplot(211);
    plot(xvec, allBeh_trigs, 'b'); hold on;
    plot(xvec, allEEG_trigs, 'r'); legend('beh', 'eeg');
    title({['Participant id ' num2str(ippant) ];[' EEG triggers and BEH triggers, overlapped']});
    subplot(212);
    plot(xvec, triggdiff);
    title('difference between triggers: should be zero');
    shg
    
    %% load the processed EEG data
    used = {'STIM', 'RESP'};
    %load each EEG type, preprocessed.
    for idset =1:2
        loadt = used{idset};
        dload = dir([ pwd filesep '*' loadt ' interpd.set']);
        %load EEG
        ALLEEG= pop_loadset('filename', [dload(1).name]);
        EEGtmp = eeg_checkset( ALLEEG );
                        
        %restrict to EEG channels
        
        switch idset
            case 1
                remainingSTIM_EEGdata = EEGtmp.data(1:64,:,:);

            case 2
                remainingRESP_EEGdata = EEGtmp.data(1:64,:,:);
        end
    end
    
    plotXtimes = EEGtmp.times; % declare to save later.
    
    %% (see above for this cells expl.) 
    if ippant ==16
        remainingSTIM_EEGdata(:,:,480:482)=[];
        remainingRESP_EEGdata(:,:,481:483)=[];
    end
    
    %% Sanity check, does EEG trial count (just loaded), match the trial
    % count we have information for after rejection/alignment above
    NstimEEGtrials=size(remainingSTIM_EEGdata,3) ;
    NrespEEGtrials=size(remainingRESP_EEGdata,3) ;
    
    if NstimEEGtrials ~=size(allstimTrials_inEEG_BEHindx,1)       
        error('warning - incorrect count to begin with (STIM)')
    elseif NrespEEGtrials ~=size(allrespTrials_inEEG_BEHindx,1)
        error('warning - incorrect count to begin with (RESP)')
    end
    
    
    
    % Now, make sure that both STIM and RESP have the same trials in both.
    % This is necessary to make sure we  can match stimulus and response
    % data on the same trial.
    
    % Shrink the larger dataset to match the smaller:
    
    disp([num2str(NstimEEGtrials) ' trials in STIMeeg, ' num2str(NrespEEGtrials) ' in RESPeeg'])
    
    if NstimEEGtrials>= NrespEEGtrials;
    
        disp('Shrinking Stim to match Resp');
    
        
        %keeptS  indexes all the shared trials, that are in stim, but also in RESP
        %( A that is in B.(logical id))
        
        keeptS = ismember(allstimTrials_inEEG_BEHindx,allrespTrials_inEEG_BEHindx);
        
        
        %Since more STIM than RESP, remove those in STIM without a partner.
        matchedS_indx = allstimTrials_inEEG_BEHindx(keeptS);
        EEGstim_matched = remainingSTIM_EEGdata(:,:,keeptS);
        disp(['////////////////////////////'])
        disp(['Removing ' num2str(NstimEEGtrials - length(find(keeptS))) ' Stim trials']);
        pause(1);
        
        %also remove the trials from R, that were not in S (rejected from S)
        %easiest to just compare to the matched indx.
        keeptR = ismember(allrespTrials_inEEG_BEHindx, matchedS_indx);
        
        disp(['Removing ' num2str(NrespEEGtrials - length(find(keeptR))) ' Resp trials']);
        pause(1);
        
        %logical vector containing those that are in S&R
        matchedR_indx = allrespTrials_inEEG_BEHindx(keeptR);
        EEGresp_matched = remainingRESP_EEGdata(:,:,keeptR);
        
        
        
    elseif NrespEEGtrials> NstimEEGtrials % more resp than stim.
        disp('Shrinking Resp to match Stim');
        
        keeptR = ismember(allrespTrials_inEEG_BEHindx,allstimTrials_inEEG_BEHindx);
        
        matchedR_indx = allrespTrials_inEEG_BEHindx(keeptR);
        EEGresp_matched = remainingRESP_EEGdata(:,:,keeptR);
        
        disp(['////////////////////////////'])
        
        disp(['Removing ' num2str(NrespEEGtrials - length(find(keeptR))) ' Resp trials']);
        pause(1)
        
        keeptS = ismember(allstimTrials_inEEG_BEHindx, matchedR_indx);
        
        %logical vector containing those that are in R, but should not be.
        matchedS_indx = allstimTrials_inEEG_BEHindx(keeptS);
        EEGstim_matched = remainingSTIM_EEGdata(:,:,keeptS);
        disp(['Removing ' num2str(NstimEEGtrials - length(find(keeptS))) ' Stim trials']);
        pause(1);
    end
    
    %% retain the final, combined trial ID, to match with beh.
    disp(['Matched size is S(' num2str(length(matchedS_indx)) ')'])
    disp(['Matched size is R(' num2str(length(matchedR_indx)) ')'])
    
    alltrials_INDX = unique([matchedS_indx, matchedR_indx]);
    
    %%
    
    % now all trials should match (sanity check);
    if length(alltrials_INDX) ~=(size(EEGstim_matched,3))
        error('indexing problem');
    elseif length(alltrials_INDX) ~=(size(EEGresp_matched,3))
        error('indexing problem') %
    end
    
    
    
    %%
    %% Now with our unified trial index, of what remains in EEG
    % we will extract the relevant behaviour.
    
    
    BEH_matched = alltrials(alltrials_INDX);
    
    % remove practice trials from further consideration.
    
    notprac = find([BEH_matched.isprac]==0);
    %% collect indexes for comparisons of interest and save per ppant.
    
    %% Correct in part A
    corAindx = intersect(find([BEH_matched.cor]), find(ismember({BEH_matched.ExpType}, 'A')));
    corAindx = intersect(corAindx, notprac);
    
    %% Correct in part B
    corBindx = intersect(find([BEH_matched.cor]), find(ismember({BEH_matched.ExpType}, 'B')));
    corBindx = intersect(corBindx, notprac);
    %% Error in part A
    errAindx = intersect(find([BEH_matched.cor]==0), find(ismember({BEH_matched.ExpType}, 'A')));
    errAindx = intersect(errAindx, notprac);
    
    %% Error in part B
    errBindx = intersect(find([BEH_matched.cor]==0), find(ismember({BEH_matched.ExpType}, 'B')));
    errBindx = intersect(errBindx, notprac);
    
    %% Vis stim
    visStimindx = find(ismember(lower({BEH_matched.stimtype}), 'visual'));
    visStimindx = intersect(visStimindx, notprac);
    
    %% Audio stim
    audStimindx = find(ismember(lower({BEH_matched.stimtype}), 'audio'));
    audStimindx = intersect(audStimindx, notprac);
    
    
    %% now save all this, ready for analysis.
    % save all.
    save('Epoch information', 'ExpOrder','BEH_matched', ...
        'corAindx', 'corBindx', 'errAindx', 'errBindx', 'visStimindx',...
        'audStimindx', '-append');
    
    
    save('participant TRIG extracted ERPs', ...
        'EEGstim_matched',...
        'EEGresp_matched',...
        'plotXtimes','BEH_matched', 'ExpOrder');%, '-append');
    
end % ppant loop

%%