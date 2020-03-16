%Preprocess pilot data from visual and auditory confidence experiments.
clear variables
close all

basedir= '/Users/mdavidson/Desktop/dotstask- Vis+Audio EXP/EEG';
cd(basedir);
pfols = dir([pwd filesep 'p_*']);

%preprocessing pipeline
job.loadraw_chandata_reref = 1 ;                % load data.
job.filter_epoch_saveinfo  = 1 ;
job.epochrejbyinspectino_saverejidx = 1;
job.runICA_rejcomps =1;


%% >>>>>>>>>>>>>>>>>>>>>>>>>
% BEGIN participant loop
% >>>>>>>>>>>>>>>>>>>>>>>>>

for ippant=1:4
    
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
%     pfols = dir([pwd filesep 'p_*']);
    %% load raw data only if this step hasn't been completed (very slow)
    % >>>>>>>>>>>>>>>>>>>>>>>>>
    % load,
    % name channels,
    % re reference to mastoids.
    
    if job.loadraw_chandata_reref==1
        
        filenameis = dir([pwd filesep '*' sstr '*.bdf']);
        EEG = pop_biosig([pwd filesep filenameis.name]);
        EEG.setname=['p' sstr];
        EEG = eeg_checkset( EEG );
        
        %downsample
        EEG = pop_resample( EEG, 256);
        EEG = eeg_checkset( EEG );
        
        %check for channels:
        EEG=pop_chanedit(EEG, 'lookup',...
            '/Users/mdavidson/Documents/MATLAB/Matlab toolboxes/eeglab13_5_4b/plugins/dipfit2.3/standard_BESA/standard-10-5-cap385.elp',...
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
    end
    %% If filtering /epoching hasn't yet been performed:
    % >>>>>>>>>>>>>>>>>>>>>>>>>
    % filter
    % epoch
    % save epoch information for later link to behavioural data.
    
    if job.filter_epoch_saveinfo ==1
        %%
        %load prev set.
        EEG= pop_loadset(['p_' sstr ' resampled reref.set']);
        
        EEG = pop_eegfiltnew(EEG, 45, 0, 8448, 0, [], 1); % remove the high-pass filter!
        EEG.setname=['p_' sstr ' resampled reref filt'];
        EEG = eeg_checkset( EEG );
        
        %% Epoch, note that some triggers are mutually exclusive (02/03,
        %102/103, 202/203) and will not be in the same experiment.
        EEG = pop_epoch( EEG, { '2'  '3'  '10'  '11'  '20'  '21'  '51'  '52'  '53'  '102'  '103' '110'  '111'  '120'  '121' '202' '203' '204' }, [-0.2           1], 'newname', 'p_01 resampled reref epochs', 'epochinfo', 'yes');
        EEG = eeg_checkset( EEG );
        EEG = pop_rmbase( EEG, [-150    0]);
        EEG = eeg_checkset( EEG );
        
        %
        EEG.setname=['p_' sstr ' resampled reref filt epochs'];
        EEG=eeg_checkset(EEG);
        EEG=pop_saveset(EEG, 'filename', EEG.setname);
        
        % Capture Trigger events.
        allTriggerEvents = struct2table(EEG.event);
        
        %%critically, we need to assign an actual trial index to all these epochs, for later matching with behavioural data.
        %so go through and find all the indices for either 2,3, or 102,103, as
        %these indicate first stimulus onset in trial.
        %all epochs partA
        sub1= find(allTriggerEvents.type==3); %auditory
        sub2= find(allTriggerEvents.type==2); %visual
        Aonset_index = [sub1;sub2]; %covers all epochs regardless of exp type.
        %all epochs partB
        sub1= find(allTriggerEvents.type==103); %auditory
        sub2= find(allTriggerEvents.type==102); %visual
        
        Bonset_index = [sub1,sub2]; %covers all epochs regardless of exp type.
        
        %% Now create a table entry, for the real epochs, as they will be defined in
        %the behavioural output.
        % NB nEpochs= length(onset_index)
        for irow = 1:length(Aonset_index)-1
            %each epoch should be added to table.
            
            startE=Aonset_index(irow);
            endE = Aonset_index(irow+1)-1;
            
            %append real epoch information to this table.
            allTriggerEvents(startE:endE, 5)= table(irow);
            
            %          %the final epoch is added as
            if irow==(length(Aonset_index)-1)
                
                startE=Aonset_index(irow+1);
                endE = Bonset_index(1)-1;
                %i.e. first epoch in second half of experiment, signifies end
                %of first half.
                allTriggerEvents(startE:endE, 5)= table(irow+1);
            end
        end
        
        %% now do the same for second half (part B)
        for irow = 1:length(Bonset_index)-1
            %each epoch should be added to table.
            realrow = irow+length(Aonset_index);
            
            startE=Bonset_index(irow);
            endE = Bonset_index(irow+1)-1;
            
            %append real epoch information to this table.
            allTriggerEvents(startE:endE, 5)= table(realrow);
            
            %the final epoch is added as
            if irow==(length(Bonset_index)-1)
                
                startE=Bonset_index(irow+1);
                endE = size(allTriggerEvents,1);
                
                allTriggerEvents(startE:endE, 5)= table(realrow+1);
            end
        end
        %rename this column
        allTriggerEvents.Properties.VariableNames{5} = 'epoch_in_exp';
        
        %now adjust for the '1'/101 case, for robustness. These are actual
        %trial beginning marks, caught in the baseline of our ERPs. So adjust
        %to the following index, to correct for the actual trial we represent.
        all1s = find(allTriggerEvents.type ==1);
        all101s = find(allTriggerEvents.type ==101);
        alltoadjust = [all1s; all101s];
        %%
        allTriggerEvents(alltoadjust,5) = allTriggerEvents(alltoadjust+1,5);
        %save this important per participant info.
        save('Epoch information', 'allTriggerEvents')
        
    end
    
    
    %%  perform Epoch based artefact rejection
    % >>>>>>>>>>>>>>>>>>>>>>>>>
    % load eeglab gui for visual inspection and epoch rejection
    %
    
    %plot for inspection.
    if job.epochrejbyinspectino_saverejidx==1
%% requires user input (eeglab)

eeglab
%load prev set, reject and save as: 
%['p_0' num2str(ippant) ' resampled reref filt epochs gd.set']
%using mouse input ONLY.


%% We can load the EEG history as a text file. Scan it for the pop_rejepoch
     dbstop if error
        try
            
            EEGh= EEG.history;
            findme ='pop_rejepoch( EEG, [';
            rejl = strfind(EEGh, findme);
            %numbers start at the end of this index.
            % find the next closed bracket.
            startat = rejl+length(findme);
            EEGh2 = EEGh(startat:end);
            rejEp_end = strfind(EEGh2, ']');
            %now we can extract the string of rejected epoch indices.
            rejind = EEGh(1,startat-1:rejEp_end+startat);
            %extract only numbers:
%             rejected_trials= str2double(regexp(rejind, '\d*', 'match'));
%             rejected_trials= str2double(regexp(rejind, '\s', 'split'));%, 'match', 'forceCellOutput'));
            rejected_trials = str2num(rejind);
            
            %save rejected epoch indices.
            save('Epoch information', 'rejected_trials', '-append');
            % save retained files.
            EEG.setname=['p_' sstr ' resampled reref filt epochs gd'];
            EEG=eeg_checkset(EEG);
            EEG=pop_saveset(EEG, 'filename', [EEG.setname]);
        catch
            error('epoch rejection not YET saved, load  ...resampled reref filt epochs.set in eeglab. Perform epoch rejection, then save ')
        end
        
    end
    
    %%  perform ICA based component rejection (blinks).
    % >>>>>>>>>>>>>>>>>>>>>>>>>
    % load eeglab gui for visual inspection
    
    if job.runICA_rejcomps ==1
        EEG= pop_loadset(['p_' sstr  ' resampled reref filt epochs gd.set']);
        
        %% reject epochs, run ICA, reject components in GUI.
        
        EEG = pop_runica(EEG, 'extended',1,'interupt','on');
        EEG = eeg_checkset( EEG );
        %save as we go.
        EEG.setname = ['p_0' num2str(ppantnum) ' resampled reref filt epochs wICA'];
        EEG = eeg_checkset( EEG );
        EEG=pop_saveset(EEG, 'filename', [EEG.setname]);
        
        %% plot comps for rejection.
        eeglab
        %%
      
        %%
        EEG.setname =['p_0' num2str(ppantnum) ' resampled reref filt epochs pruned with ICA'];
        EEG = eeg_checkset( EEG );
        
        EEG=pop_saveset(EEG, 'filename', EEG.setname);
       
        
        % end
        
        
    end
end
