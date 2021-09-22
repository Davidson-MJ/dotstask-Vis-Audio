%Preprocess pilot data from visual and auditory confidence experiments.

%This script extends the duration of the stim locked epochs, to analyze
%later event related potentials.

% note that preprocessing has to already be completed, as we use the epochs
% rejected previously to save time.

% ICA rejection needs to be performed a-new however.

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

tic
%% >>>>>>>>>>>>>>>>>>>>>>>>>
% BEGIN participant loop
% >>>>>>>>>>>>>>>>>>>>>>>>>

for ippant=1:length(pfols);
    
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
    disp(['...filtering ' sstr]);
    EEG= pop_loadset(['p_' sstr ' resampled reref.set']);
    %%
    EEG = pop_eegfiltnew(EEG, 0, 30, 8448, 0, [], 1); % no hp filt
    %         EEG = pop_eegfiltnew(EEG, 30, .1, 8448, 0, [], 1); %
    %%
    EEG.setname=['p_' sstr ' resampled reref filt'];
    EEGIN = eeg_checkset( EEG );
    
    %% Epoch, note that some triggers are mutually exclusive (02/03,
    %102/103, 202/203) and will not be in the same experiment.
    %         EEG = pop_epoch( EEG, { '2'  '3'  '10'  '11'  '20'  '21'  '51'  '52'  '53'  '102'  '103' '110'  '111'  '120'  '121' '202' '203' '204' }, [-0.2           1], 'newname', 'p_01 resampled reref epochs', 'epochinfo', 'yes');
    %epoch around stim onset, and then we will extract epochs based on responses separately.
    
    EEGstim = pop_epoch( EEGIN, { '2'  '3'  '102', '103'}, [-0.5 , 3], 'newname', 'p_01 resampled reref epochs', 'epochinfo', 'yes');
    EEG = eeg_checkset( EEGstim );
    EEG = pop_rmbase( EEG, [-100    0]);
    EEG.setname=['p_' sstr ' resampled reref filt epochs stim LONG'];
    EEG=eeg_checkset(EEG);
    EEG=pop_saveset(EEG, 'filename', EEG.setname);
    %%
    allTriggerEvents_stimLong = struct2table(EEG.event);
    
    %%
    save('Epoch information', 'allTriggerEvents_stimLong' ,'-append')
    
    %clean up
    clearvars -except sstr job basedir pfols
    %% load index of previously rejected Epochs (stim), reject and save.
    
    EEG = pop_loadset('filename',['p_' sstr ' resampled reref filt epochs stim LONG.set'],'filepath',pwd);
    load('Epoch information.mat', 'rejected_trials_stim');
    
    EEGr=pop_rejepoch(EEG, rejected_trials_stim,0);
    
    %save
    EEG=pop_saveset(EEGr, 'filename', ['p_' sstr  ' resampled reref filt epochs stim LONG gd.set']);
    
    
    
    
    
    %% reject epochs, run ICA, reject components in GUI.
    
    EEG = pop_runica(EEG, 'extended',0,'interupt','on'); %extd=0, pps 13:20
    EEG = eeg_checkset( EEG );
    %save as we go.
    %%
    EEG.setname = ['p_' sstr ' resampled reref filt epochs STIM LONG wICA2'];
    EEG = eeg_checkset( EEG );
    EEG=pop_saveset(EEG, 'filename', [EEG.setname]);
    
end % ppant loop.
toc
%%
if job.rejICA_comps  ==1
    %% plot comps for rejection, use SASICA
    
    used = {'stim LONG', 'resp'};
    idset =1;%:2
%     eeglab
    %
    % %             %show EEG for rejection.
    %%
    rejected_components=[];
    while isempty(rejected_components)
        
        beep
        error(['component rejection not YET saved, load  ... ' used{idset} ' wICA .set in eeglab. Perform ICA rejection, then continue '])
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
        rejected_components= str2num(rejind);
        %
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


