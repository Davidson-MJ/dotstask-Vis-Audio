% JOBS_MatchEEG2BEH_longStim
%match BEH and EEG output

% critical step of matching the EEG data, after trial rejection, with
% eligible behavioural data, to ensure conditions are compared
% appropriately.

%runs per ppant, from the EEGdir.

% now updated for the new EEGstimLong (without baseline subtraction).


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

respTriggs= [10,11,20,21,110,111,120,121];
stimTriggs = [2,3,102,103];
visTriggs = [2, 102];
audTriggs = [3, 103];
corrTriggs = [11,21,111,121];
errTriggs = [10,20,100,120];
partATriggs = [2,3];
partBTriggs= [102,103];%
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
    
    

    % prepare data
   % for ease of update, just relabel 
   disp('Relabelling stimulus data for Long epochs');
    
   nVis = size(visTriggerEvents,1);
   nAud = size(audTriggerEvents,1);
   
   nResp = max(respTriggerEvents.epoch);
   
    nStim =nVis+nAud;
    
    disp(['Prepping ' pfols(ippant).name ]);
    disp(['Stim EEG count = ' num2str(nStim)]);
    disp(['Resp EEG count = ' num2str(nResp)]);
    %%
   
    %% Note that for some participants, EEG errors in recording also occurred.
    % before removing the rejected epochs, we need to first adjust the
    % saved epoch information. Otherwise, the remaining EEG indices,
    % recorded in eeglab, will not correspond with our behavioural data.
    
    
    stimTable = allTriggerEvents_combinedLong(1:nStim,:);
    respTable = respTriggerEvents;
    %%
    if nStim~= nResp || nResp~=870 % find whether the trials were misaligned/ missing.
    
        
        % we can align based on the behavioural data.
        % create an array for behavioural responses to match the trigger
        % codes. Use an autocorrelation to see which lag is optimal (+ or
        % -)
        
        result = {};
        respVec=[];
        stimVec=[];
        locarray = [alltrials.resp1_loc];
        corarray = [alltrials.cor];
        
        for i = 1:length(alltrials)
            
            result{i} = strcat(num2str(locarray(i)), num2str(corarray(i)));
            respVec(i) = str2num(result{i});
            
            % increment if second half:
            
            a = alltrials(i).xmodtype + 1; % 1 or 2.
            b= strcmp(alltrials(i).ExpType, 'B')*100; 
            
            stimVec(i) = a+b;
            respVec(i)= respVec(i) +b;
        end
        %%
    % The following  plot can be plotted for any participant. For
    % those with errors, the zoom is placed to highlight the change needed
    % within the scatter data.
    
    figure(1);clf; 
    subplot(221); title('stim order'); hold on;
    plot(stimVec, 'b', 'linew', 2); 
    plot(stimTable.type, 'r-o')
    legend(['Behaviour (n=' num2str(length(stimVec)) ')'],['EEG (n=' num2str(nStim) ')']);
    yyaxis right;
%         plot(stimTable.type' - stimVec, 'k'); ylabel('difference')

%     plot(respTriggerEvents.type' - respVec, 'k'); ylabel('difference')
    subplot(223);
    plot(respVec, 'b', 'linew', 2);
    hold on;
    plot(respTriggerEvents.type, 'r-o')
    yyaxis right
%     plot(respTriggerEvents.type' - respVec, 'k'); ylabel('difference')
    
    legend(['Behaviour (n=' num2str(length(respVec)) ')'],['EEG (n=' num2str(nResp) ')']);

        grid on
        
    adj_respTable = respTable;
    adj_stimTable= stimTable;
      %%  
    if strcmp('p_02', pfols(ippant).name)
        % EEG recording is off by 1.
       subplot(221); 
       xlim([ 475 485])
        %EEG stimulus indices need to be increased to match BEH data.        
        adj_stimTable.epoch = stimTable.epoch+2;
%
        subplot(223);
        xlim([ 475 485])
               
        adj_respTable.epoch = respTable.epoch+1;

%         
%         
    elseif strcmp('p_06', pfols(ippant).name)
         subplot(221); 
       xlim([ 475 485])
       % looks like stimulus recording missed the first epoch.
%         % EEG stim trials = 869, resp trials = 870.
%         % use the following to plot, and identify which epoch is skipped:
    adj_stimTable.epoch = stimTable.epoch +1;

    elseif strcmp('p_13', pfols(ippant).name)
         subplot(221); 
       xlim([ 475 485])
       % looks like stimulus recording missed the first epoch.
%         % EEG stim trials = 869, resp trials = 870.
%         % use the following to plot, and identify which epoch is skipped:
    adj_stimTable.epoch = stimTable.epoch +1;
    
    elseif strcmp('p_16', pfols(ippant).name)
        %
        %         %This one is tricky, since we will be removing data, we need to
        %         %first remove the rejected trials from preprocessing.
        %         % Then any remaining differences
        %         % with BEH can be addressed.
        %
        % It appears the first 2 stim triggers in part B, and first 3
        % response triggers in part B, should be removed.
        % No idea how that happens.
        % in Stimulus EEG:
        % note that at stim 480, the event is incorrect:
        
        adj_stimTable.type(480) = adj_stimTable.type(479);
        adj_stimTable.type(481:482) = nan;
        adj_stimTable.epoch(481:482) = nan;
        % now decrease the remaining epoch codes to match.
        Bindx= find(adj_stimTable.type>100);
        adj_stimTable.epoch(Bindx) = adj_stimTable.epoch(Bindx)-2;
        
        % for Response data, there are 3 extra clicks at onset of Part B
        % (absent from Behavioural record).
        adj_respTable.type(481:483) = nan;
        adj_respTable.epoch(481:483) = nan;
        
        Bindx= find(adj_respTable.type>100);
        adj_respTable.epoch(Bindx) = adj_respTable.epoch(Bindx)-3;
        % remove
        stim_Table = adj_stimTable;
        resp_Table = adj_respTable; % retain Nans for easy indexing later.
        
        adj_respTable(481:483,:) = [];
        
        adj_stimTable(481:482,:) = [];
        
    elseif strcmp('p_17', pfols(ippant).name)
        %            subplot(221);
        xlim([ 475 485])
        % looks like stimulus recording missed the first epoch.
        %         % EEG stim trials = 869, resp trials = 870.
%         % use the following to plot, and identify which epoch is skipped:
    adj_stimTable.epoch = stimTable.epoch +1;
    
    elseif strcmp('p_26', pfols(ippant).name)
        xlim([ 475 485])
        % looks like stimulus recording missed the first epoch.
        %         % EEG stim trials = 869, resp trials = 870.
%         % use the following to plot, and identify which epoch is skipped:
    adj_stimTable.epoch = stimTable.epoch +1;
        
   end
    
    
    %% replot to confirm:
    figure(1); 
    subplot(222); title('stim order'); hold on;
    plot(stimVec, 'b', 'linew', 2); 
    plot(adj_stimTable.epoch, adj_stimTable.type, 'r-o')
    legend(['Behaviour (n=' num2str(length(stimVec)) ')'],['EEG (n=' num2str(length(adj_stimTable.epoch)) ')']);
    subplot(224);
    plot(respVec, 'b', 'linew',2);
    hold on;
    plot(adj_respTable.epoch, adj_respTable.type, 'r-o')
    
    legend(['Behaviour (n=' num2str(length(respVec)) ')'],['EEG (n=' num2str(length(adj_respTable.epoch)) ')']);

    grid on
        yyaxis right
%     plot(adj_respTable.type' - respVec, 'k'); ylabel('difference')
    %%
    
    
    adjustedTriggerEvents = [adj_stimTable; adj_respTable];
    else
        %no adjustments (all data in both BEH and EEG).
        disp('Stim and Resp matched pre epoch rej, continuing...');
        adjustedTriggerEvents = allTriggerEvents_combinedLong;
        
    end
        
    
    
    %%  having now adjusted the epoch numbers, we can continue by removing those epochs IDd by eye.
    %first, what was the epoch ID (in behavioural order), of the to be
    %rejected epochs?
    
    trueBehaviouralIDX = adjustedTriggerEvents.epoch;
    rejBehIDX = trueBehaviouralIDX(rejected_trials_combined);
    
    
    % now we can restrict out EEGevent table to match the EEGdata on file;
    
    retainedTriggerEvents = adjustedTriggerEvents;
    %remove data for rejected epochs:
    retainedTriggerEvents(rejected_trials_combined,:)=[];
    %^ This should now match the size of the EEG.
    
     %% load the processed EEG data (with epochs already rejected).
    dload = dir([ pwd filesep pfols(ippant).name '* combined LONG *'  'interpd.set']);
    %load EEG
    ALLEEG= pop_loadset('filename', [dload(1).name]);
    EEGtmp = eeg_checkset( ALLEEG );
    EEGdata = EEGtmp.data(1:64,:,:);
    
    % note that if p_16 (special case). we need to update our EEG structure
    % to match,
    if strcmp('p_16', pfols(ippant).name)
        
        %we removed 2 epocjs from the stim section, 3 from resp.
        %convert.
        tmpEpochs = [stim_Table.epoch ;resp_Table.epoch];
        remnan = find(isnan(tmpEpochs));
        EEGdata(:,:,remnan)=[];
    end
    plotXtimes = EEGtmp.times; % declare to save later.
    
    %next, we want to retain only trials that have both Stim and Resp EEG,
    %for subsequent analysis.
    % 
    nStim = find(ismember(retainedTriggerEvents.type, respTriggs), 1, 'first')-1;
    nResp= size(retainedTriggerEvents,1)-nStim;
    
    retainedStim = retainedTriggerEvents(1:nStim,:);
    retainedResp = retainedTriggerEvents(nStim+1:end,:);
    %%
   
        disp('Identifying extra stim trials');
        
        
        %keeptS  indexes all the shared trials, that are in resp, but NOT
        %in stim
        
        %( A that is in B.(logical id))
        
        keeptS = ismember(retainedStim.epoch,retainedResp.epoch);
        
        % find the location of non-repeated members:
        singleton_inTable = find(keeptS==0);
        singleton_inBehIdx = retainedStim.epoch(singleton_inTable);
        
        %where is this epoch to remove?
        remFromEEG_s= find(ismember(retainedTriggerEvents.epoch,singleton_inBehIdx));

        %add to list of those we will reject from BEH:
        rejBehIDX= vertcat(rejBehIDX , singleton_inBehIdx);

        disp('Identifying extra Resp trials');        
        %keeptR  indexes all the shared trials, that are in Resp, but NOT
        %in stim
        
        %( A that is in B.(logical id))
        
        keeptS = ismember(retainedResp.epoch,retainedStim.epoch);
        
        % find the location of non-repeated members:
        singleton_inTable = find(keeptS==0);
        singleton_inBehIdx = retainedResp.epoch(singleton_inTable);
        
        %where is this epoch to remove?
        remFromEEG_r= find(ismember(retainedTriggerEvents.epoch,singleton_inBehIdx));
        
        
        %add to list of those we will reject from BEH:
        rejBehIDX= vertcat(rejBehIDX , singleton_inBehIdx);
        remFromEEG= [remFromEEG_s', remFromEEG_r'];
        
    
    
    %% continue by adjusting the EEG and table, and append the epoch to those to remove from Beh:
    if size(EEGdata,3) ~= size(retainedTriggerEvents,1)
        error('check code')
    end
    
    EEGdata(:,:,remFromEEG)=[];
    retainedTriggerEvents(remFromEEG,:)=[];
  
    
    % check that we have matched sizes (stim == eeg).
    if mod(size(retainedTriggerEvents,1),2)~=0
        error('check code')
    end
    
    %^ which epochs remain (in EEG)? 
    retainedEpochs = unique(retainedTriggerEvents.epoch);
    
    behavTable = struct2table(alltrials);
    behavData= behavTable(retainedEpochs,:);
    
    nStim = find(ismember(retainedTriggerEvents.type, respTriggs), 1, 'first')-1;
    nResp= size(retainedTriggerEvents,1)-nStim;
    
    EEGstimLong_matched = EEGdata(:,:,1:nStim);
    EEGrespLong_matched = EEGdata(:,:,nStim+1:end);
    
    % remove practice trials from further consideration.
    
    notprac = find([behavData.isprac]==0);
    
    %% collect indexes for comparisons of interest and save per ppant.
    BEH_matched = behavData;
    %% Correct in part A
    corAindx = intersect(find([BEH_matched.cor]), find(contains(BEH_matched.ExpType, 'A')));
    corAindx = intersect(corAindx, notprac);
    
    %% Correct in part B
    corBindx = intersect(find([BEH_matched.cor]),  find(contains(BEH_matched.ExpType, 'B')));
    corBindx = intersect(corBindx, notprac);
    %% Error in part A
    errAindx = intersect(find([BEH_matched.cor]==0), find(contains(BEH_matched.ExpType, 'A')));
    errAindx = intersect(errAindx, notprac);
    
    %% Error in part B
    errBindx = intersect(find([BEH_matched.cor]==0),  find(contains(BEH_matched.ExpType, 'B')));
    errBindx = intersect(errBindx, notprac);
    
    %% Vis stim
    visStimindx = find(contains(BEH_matched.stimtype, 'visual', 'IgnoreCase', true));
    visStimindx = intersect(visStimindx, notprac);
    
    %% Audio stim
    audStimindx = find(contains(BEH_matched.stimtype, 'audio', 'IgnoreCase', true));
    audStimindx = intersect(audStimindx, notprac);
    
    
    %% now save all this, ready for analysis.
    % save all.
    disp('Saving matched EEG and Beh');
    disp([pfols(ippant).name ' has ' num2str(size(EEGstimLong_matched,3)) ' trials']);
    
    save('Epoch information', 'ExpOrder','BEH_matched', ...
        'corAindx', 'corBindx', 'errAindx', 'errBindx', 'visStimindx',...
        'audStimindx', '-append');
    
   %%
    save('participant trigger matched EEG', ...
        'EEGstimLong_matched',...
        'EEGrespLong_matched',...
        'plotXtimes','BEH_matched', 'ExpOrder');%, '-append');
    
end % ppant loop

%%