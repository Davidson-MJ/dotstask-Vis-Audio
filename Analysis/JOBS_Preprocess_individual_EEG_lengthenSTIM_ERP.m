%Preprocess pilot data from visual and auditory confidence experiments.

%This script extends the duration of the stim locked epochs, to analyze
%later event related potentials.

% note that preprocessing has to already be completed, as we use the epochs
% rejected previously to save time.

% ICA rejection needs to be performed a-new however.
%  have switched to running the faster 'picard' algorithm, and grouping the
%  entire subject dataset (stim and response locked) together.
clear variables
close all

basedir= '/Volumes/MattsBackup (2TB)/dotstask- Vis+Audio EXP/EEG/ver2';
cd(basedir);
pfols = dir([pwd filesep 'p_*']);
%%
%preprocessing pipeline
% 1) load previously reref, resampled
% 2) filter, epoch
% 3) reject previously identified trials.
% 4) perform ICA.

% 5) Manually - reject ICA comps.
% 6) Manually - interp bad electrodes (save as *interpd.mat)

% tic
%automatic
job.loadraw_filter_epoch=0; % complete for ippant = 1

%manual:
job.rejEpochs_byEye=0;

%automatic
job.runICA=1;

%manual
job.rejICA_comps=0;

%% >>>>>>>>>>>>>>>>>>>>>>>>>
% BEGIN participant loop
% >>>>>>>>>>>>>>>>>>>>>>>>>
tic
if job.loadraw_filter_epoch==1
for ippant=16%:length(pfols)
    
    cd(basedir)
    cd(pfols(ippant).name);
    
    %real ppant number:
    lis = pfols(ippant).name;
    ppantnum = str2num(cell2mat(regexp(lis, '\d*', 'Match')));
    
    
    %convert to string
    sstr = num2str(ppantnum);
    if ppantnum<10
        sstr = ['0' sstr];
    end
    
    firstset = ['p_' sstr ' resampled reref.set'];
    
    
    load('Epoch information', 'ExpOrder');
    %%  load previous resampled, rerefd data set, filter and epoch with new sized window.
    
    if ~exist(firstset, 'file'); % continue, else create the missing file.
        %%
        disp([' No resampled reref for ' sstr])
        disp([' ... creating file'])
        
        filenameis = dir([pwd filesep '*' sstr '*.bdf']);
        EEG = pop_biosig([pwd filesep filenameis.name]);
        EEG.setname=['p' sstr];
        EEG = eeg_checkset( EEG );
        
        %downsample
        EEG = pop_resample( EEG, 256);
        EEG = eeg_checkset( EEG );
        
        %check for channels:
        EEG=pop_chanedit(EEG, 'lookup',...
            '/Users/matthewdavidson/Documents/MATLAB/Matlab toolboxes/eeglab13_5_4b/plugins/dipfit2.3/standard_BESA/standard-10-5-cap385.elp',...
            'changefield',{65 'labels' 'EOG_H1'},...
            'changefield',{66 'labels' 'EOG_H2'},...
            'changefield',{67 'labels' 'EOG_V1'},...
            'changefield',{68 'labels' 'EOG_V2'},...
            'changefield',{69 'labels' 'M1'},...
            'changefield',{69 'type' 'mastoids'},...
            'changefield',{70 'labels' 'M2'},...
            'changefield',{70 'type' 'mastoids'},...
            'changefield',{68 'type' 'EOGV'},...
            'changefield',{67 'type' 'EOGV'},...
            'changefield',{66 'type' 'EOGH'},...
            'changefield',{65 'type' 'EOGH'});
        
        EEG = eeg_checkset( EEG );
        %%
        %subselect channels:
        EEG = pop_select( EEG,'channel',{'Fp1' 'AF7' 'AF3' 'F1' 'F3' 'F5' 'F7' ...
            'FT7' 'FC5' 'FC3' 'FC1' 'C1' 'C3' 'C5' 'T7' 'TP7' 'CP5' 'CP3' 'CP1' ...
            'P1' 'P3' 'P5' 'P7' 'P9' 'PO7' 'PO3' 'O1' 'Iz' 'Oz' 'POz' 'Pz' 'CPz' ...
            'Fpz' 'Fp2' 'AF8' 'AF4' 'AFz' 'Fz' 'F2' 'F4' 'F6' 'F8' 'FT8' 'FC6'...
            'FC4' 'FC2' 'FCz' 'Cz' 'C2' 'C4' 'C6' 'T8' 'TP8' 'CP6' 'CP4' 'CP2'...
            'P2' 'P4' 'P6' 'P8' 'P10' 'PO8' 'PO4' 'O2' 'EOG_H1' 'EOG_H2' 'EOG_V1'...
            'EOG_V2' 'M1' 'M2'});
        
        EEG = eeg_checkset( EEG );
        
        %reref to mastoids:
        EEG = pop_reref( EEG, [69 70] ,'exclude',65:68 );
        EEG.setname=['p_' sstr ' resampled reref'];
        EEG = eeg_checkset( EEG );
        EEG=pop_saveset(EEG, 'filename', [EEG.setname]);
        
    end % load the resampled reref file and continue.
    %%
    disp(['...filtering ' sstr]);
    EEG= pop_loadset(['p_' sstr ' resampled reref.set']);
    %%
%     EEG = pop_eegfiltnew(EEG, 0, 30, 8448, 0, [], 1); % no hp filt
            EEG = pop_eegfiltnew(EEG, 30, .1, 8448, 0, [], 0); %
    %%
    EEG.setname=['p_' sstr ' resampled reref filt'];
    EEGIN = eeg_checkset( EEG );
    
    %% Epoch, note that some triggers are mutually exclusive (02/03,
    %102/103, 202/203) and will not be in the same experiment.
    %         EEG = pop_epoch( EEG, { '2'  '3'  '10'  '11'  '20'  '21'  '51'  '52'  '53'  '102'  '103' '110'  '111'  '120'  '121' '202' '203' '204' }, [-0.2           1], 'newname', 'p_01 resampled reref epochs', 'epochinfo', 'yes');
    %epoch around stim onset, and then we will extract epochs based on responses separately.
    
%     EEGstim = pop_epoch( EEGIN, { '2'  '3'  '102', '103'}, [-0.5 , 3], 'newname', 'p_01 resampled reref epochs', 'epochinfo', 'yes');
    EEGstim_Vis = pop_epoch( EEGIN, { '2' '102'}, [-0.3 , 3.2], 'newname', 'p_01 resampled reref epochs', 'epochinfo', 'yes');
    
    EEGstim_Aud = pop_epoch( EEGIN, { '3' '103'}, [-0.5 , 3], 'newname', 'p_01 resampled reref epochs', 'epochinfo', 'yes');

    EEGstim_Resp= pop_epoch(EEGIN,  {'10', '11','20','21','110','111','120', '121'}, [-0.5, 3], 'newname', 'p_01 resampled reref epochs', 'epochinfo', 'yes');
%%
    %preserve event order:
    tab1 = struct2table(EEGstim_Vis.event);
    
    tab2 = struct2table(EEGstim_Aud.event);
    
    tab3 = struct2table(EEGstim_Resp.event);
    
    plotXtimes = EEGstim_Resp.times;
    
    
    % bit of clean up here, remove the non relevant event markers to ease
    % matching to behaviour later.
    
    keeprows = find(ismember(tab1.type, [2,102]));
    visTriggerEvents= tab1(keeprows,:);
    %remove duplicates (long epochs can contain 2 stimuli).
     idx_dup = find(diff(visTriggerEvents.epoch)~=1) + 1 ; % plus 1 to remove the second occurrence of each idx
    %remove from table.
    visTriggerEvents(idx_dup,:)= [];
    
    %repeat for auditory and response.
    
    keeprows = find(ismember(tab2.type, [3,103]));
    audTriggerEvents= tab2(keeprows,:);
    %remove duplicates (long epochs can contain 2 stimuli).
     idx_dup = find(diff(audTriggerEvents.epoch)~=1) + 1 ; % plus 1 to remove the second occurrence of each idx
    %remove from table.
    audTriggerEvents(idx_dup,:)= [];
    
    
    keeprows = find(ismember(tab3.type, [10,11,20,21,110,111,120,121]));
    respTriggerEvents= tab3(keeprows,:);
    %remove duplicates (long epochs can contain 2 stimuli).
     idx_dup = find(diff(respTriggerEvents.epoch)~=1) + 1 ; % plus 1 to remove the second occurrence of each idx
    %remove from table.
    respTriggerEvents(idx_dup,:)= [];
    
    %%
    if contains(ExpOrder{1}, 'visual',  'IgnoreCase', true)
    %% merge into one dataset
     ALLEEG=[];
     ALLEEG = eeg_store(ALLEEG, EEGstim_Vis,1);
     ALLEEG= eeg_store(ALLEEG, EEGstim_Aud, 2);
     ALLEEG= eeg_store(ALLEEG, EEGstim_Resp, 3);
    
     %adjust epoch counts for the second sequence of stim.
     npartA = max(visTriggerEvents.epoch);
     audTriggerEvents.epoch = audTriggerEvents.epoch + npartA;
     
     allTriggerEvents_combinedLong= [visTriggerEvents;audTriggerEvents;respTriggerEvents]; % note that this preserves the urevent order.

    else
        % change order:
     ALLEEG=[];
     ALLEEG = eeg_store(ALLEEG, EEGstim_Aud,1);
     ALLEEG= eeg_store(ALLEEG, EEGstim_Vis, 2);
     ALLEEG= eeg_store(ALLEEG, EEGstim_Resp, 3);
      %adjust epoch counts for the second sequence of stim.
     npartA = max(audTriggerEvents.epoch);
     visTriggerEvents.epoch = visTriggerEvents.epoch + npartA;
          allTriggerEvents_combinedLong= [audTriggerEvents; visTriggerEvents, respTriggerEvents]; % note that this preserves the urevent order.

    end
    %%
            EEG = pop_mergeset(ALLEEG, 1:3, 1); % all 3, keep all.
    
  % we want to append the .sets after epoching with different times.
%   EEG = pop_rmbase( EEG, [-100    0]);
    EEG.setname=['p_' sstr ' resampled reref filt epochs combined LONG'];
    EEG=eeg_checkset(EEG);
    EEG=pop_saveset(EEG, 'filename', EEG.setname);
   
    if size(allTriggerEvents_combinedLong,1) ~= EEG.trials
        error('Count off!')
    end
    %%
    save('Epoch information', 'allTriggerEvents_combinedLong' , 'plotXtimes','visTriggerEvents', 'audTriggerEvents', 'respTriggerEvents', '-append')
    %%
    %clean up
    clearvars -except sstr job basedir pfols
%     %% load index of previously rejected Epochs (stim), reject and save.
%     
%     EEG = pop_loadset('filename',['p_' sstr ' resampled reref filt epochs combined LONG.set'],'filepath',pwd);
%     load('Epoch information.mat', 'rejected_trials_stim');
%     
%     EEGr=pop_rejepoch(EEG, rejected_trials_stim,0);
%     
%     %save
%     EEG=pop_saveset(EEGr, 'filename', ['p_' sstr  ' resampled reref filt epochs stim LONG gd.set']);
%     
%     %% reject epochs, run ICA, reject components in GUI.
%     
% %     EEG = pop_runica(EEG, 'extended',0,'interupt','on'); %extd=0, pps 13:20
%     EEG = pop_runica(EEG, 'icatype', 'picard', 'maxiter',500);
% 
%     EEG = eeg_checkset( EEG );
%     %save as we go.

%     %%
%     EEG.setname = ['p_' sstr ' resampled reref filt epochs STIM LONG wICA2'];
%     EEG = eeg_checkset( EEG );
%     EEG=pop_saveset(EEG, 'filename', [EEG.setname]);
%     
end % ppant loop.
beep; pause(.1); beep

end
toc

 %plot for inspection.
    if job.rejEpochs_byEye==1
       
        ippant=21;
        
        
         %real ppant number:
    lis = pfols(ippant).name
    ppantnum = str2num(cell2mat(regexp(lis, '\d*', 'Match')));
    
    
    
    %convert to string
    sstr = num2str(ppantnum);
    if ppantnum<10
        sstr = ['0' sstr];
    end
    %%
          
%             EEG = pop_loadset('filename',['p_' sstr ' resampled reref filt epochs combined LONG.set'],'filepath',pwd);

            
            %% We can load the EEG history as a text file. Scan it for the pop_rejepoch
            dbstop if error
            try
                %%
                EEGh= EEG.history;
                findme ='pop_rejepoch( EEG, [';                
                rejl = strfind(EEGh, findme);
                endsearchat = ']';
                if isempty(rejl);
                    findme ='pop_rejepoch( EEG, '; % single epoch rejected.
                    rejl = strfind(EEGh, findme);
                    endsearchat = ',0';
                end
                    
                %numbers start at the end of this index.
                % find the next closed bracket.
                startat = rejl+length(findme);
                EEGh2 = EEGh(startat:end);
                rejEp_end = strfind(EEGh2, endsearchat);
                %now we can extract the string of rejected epoch indices.
                rejind = EEGh(1,startat-1:rejEp_end+startat);
                %extract only numbers:
                %             rejected_trials= str2double(regexp(rejind, '\d*', 'match'));
                %             rejected_trials= str2double(regexp(rejind, '\s', 'split'));%, 'match', 'forceCellOutput'));
                rejected_trials = str2num(rejind)
                %%
                %save rejected epoch indices.
                    rejected_trials_combined = rejected_trials;
                    save('Epoch information', 'rejected_trials_combined', '-append');
               
                %
                clearvars -except sstr job itype pfols
                
            catch
                error('epoch rejection not YET saved, load  ...resampled reref filt epochs TYPE .set in eeglab. Perform epoch rejection, then continue ')
                %%
                eeglab
            end
            
        
    end
%%

if job.runICA==1
    %%
    for ippant=17:21%length(pfols)
        
        cd(basedir)
        cd(pfols(ippant).name);
        
        %real ppant number:
        lis = pfols(ippant).name;
        ppantnum = str2num(cell2mat(regexp(lis, '\d*', 'Match')));
        
        
        %convert to string
        sstr = num2str(ppantnum);
        if ppantnum<10
            sstr = ['0' sstr];
        end
        
        %%
        tic
        EEG = pop_loadset('filename',['p_' sstr ' resampled reref filt epochs combined LONG gd.set'],'filepath',pwd);
        %%
        % %     EEG = pop_runica(EEG, 'extended',0,'interupt','on'); %extd=0, pps 13:20
        EEG = pop_runica(EEG, 'icatype', 'picard', 'maxiter',500);
        %
        EEG = eeg_checkset( EEG );
        %     %save as we go.
        %     %%
        EEG.setname = ['p_' sstr ' resampled reref filt epochs combined LONG gd wICA2'];
        EEG = eeg_checkset( EEG );
        EEG=pop_saveset(EEG, 'filename', [EEG.setname]);
        %
        toc
    end

end


%%

if job.rejICA_comps  ==1
    %% plot comps for rejection, use SASICA
    
    ippant=21;
        
        
         %real ppant number:
    lis = pfols(ippant).name
    ppantnum = str2num(cell2mat(regexp(lis, '\d*', 'Match')));
    
    
    
    %convert to string
    sstr = num2str(ppantnum);
    if ppantnum<10
        sstr = ['0' sstr];
    end
    % %             %show EEG for rejection.
    %%
    rejected_components=[];
    while isempty(rejected_components)
        
        beep
        error(['component rejection not YET saved, load  ' sstr ' wICA2.set in eeglab. Perform ICA rejection, then continue '])
        %%
        EEGh= EEG.history;
        findme ='pop_subcomp( EEG, [';
        rejl = strfind(EEGh, findme);
        %numbers start at the end of this index.
        % find the next closed bracket.
        startat = rejl+length(findme);
        EEGh2 = EEGh(startat:end);
        rejEp_end = strfind(EEGh2, ']');
        %now we can extract the string of rejected epoch indices.
        rejind = EEGh(1,startat-1:rejEp_end+startat);
        %extract only numbers:
        rejected_components= str2num(rejind)
        %%
        %save
       
            rejected_comps_stimLONG = rejected_components;
            save('Epoch information', 'rejected_comps_stimLONG', '-append');
       
        
      
        %%
    end
    
    %%
%     eeglab
end



toc
% idset=1;


