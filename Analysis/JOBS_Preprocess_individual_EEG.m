%Preprocess pilot data from visual and auditory confidence experiments.
clear variables
close all

%set up directories, find participant folders.
basedir= '/Users/mdavidson/Desktop/dotstask- Vis+Audio EXP/EEG/ver2';
behdatadir = '/Users/mdavidson/Desktop/dotstask- Vis+Audio EXP/Exp_output/DotsandAudio_behaviour/ver2';

cd(basedir);
pfols = dir([pwd filesep 'p_*']);


%preprocessing pipeline
job.loadraw_chandata_reref = 0;
job.filter_epoch_saveinfo  = 0 ;
job.epochrejbyinspectino_saverejidx = 0;

% run ICA after epoch rejection:

job.runICA  =1;
job.rejICA_comps  =0;


job.matchPPanttrials =0; 

%% >>>>>>>>>>>>>>>>>>>>>>>>>
% BEGIN participant loop
% >>>>>>>>>>>>>>>>>>>>>>>>>

for ippant=7%:length(pfols)
    
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
        %%
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
        
        EEGstim = pop_epoch( EEGIN, { '2'  '3'  '102', '103'}, [-0.5 , 1], 'newname', 'p_01 resampled reref epochs', 'epochinfo', 'yes');
        EEG = eeg_checkset( EEGstim );
        EEG = pop_rmbase( EEG, [-100    0]);
        EEG.setname=['p_' sstr ' resampled reref filt epochs stim'];
        EEG=eeg_checkset(EEG);
        EEG=pop_saveset(EEG, 'filename', EEG.setname);
        %%
        allTriggerEvents_stim = struct2table(EEG.event);
        %%
        EEGresp = pop_epoch( EEGIN, { '10', '11','20','21','110','111','120', '121'}, [-0.5 , 1],  'newname', 'p_01 resampled reref epochs', 'epochinfo', 'yes');
        EEG = eeg_checkset( EEGresp );
        EEG = pop_rmbase( EEG, [-100    0]);
        EEG.setname=['p_' sstr ' resampled reref filt epochs resp'];
        EEG=eeg_checkset(EEG);
        EEG=pop_saveset(EEG, 'filename', EEG.setname);
        %%
        allTriggerEvents_resp = struct2table(EEG.event);
        
        %%
        save('Epoch information', 'allTriggerEvents_stim', 'allTriggerEvents_resp')
        
        %clean up
        clearvars -except sstr job basedir
    end
    
    
    %%  perform Epoch based artefact rejection
    % >>>>>>>>>>>>>>>>>>>>>>>>>
    % load eeglab gui for visual inspection and epoch rejection
    %
    
    %plot for inspection.
    if job.epochrejbyinspectino_saverejidx==1
        
        %% requires user input (eeglab), slow, but perform ICA on both resp and stim locked data.
        
        
        %%
        for itype =1%:2
            
            %load prev stim and resp based sets, reject and save as:
            if itype==1
                EEG = pop_loadset('filename',['p_' sstr ' resampled reref filt epochs stim.set'],'filepath',pwd);
            else
                EEG = pop_loadset('filename',['p_' sstr ' resampled reref filt epochs resp.set'],'filepath',pwd);
            end
            %% We can load the EEG history as a text file. Scan it for the pop_rejepoch
            dbstop if error
            try
                %%
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
                %
                %save rejected epoch indices.
                if itype==1
                    rejected_trials_stim = rejected_trials;
                    save('Epoch information', 'rejected_trials_stim', '-append');
                else
                    rejected_trials_resp = rejected_trials;
                    save('Epoch information', 'rejected_trials_resp', '-append');
                end
                
                clearvars -except sstr job itype
                
            catch
                error('epoch rejection not YET saved, load  ...resampled reref filt epochs TYPE .set in eeglab. Perform epoch rejection, then continue ')
                %%
                eeglab
            end
            
        end
    end
    
    %%  perform ICA based component rejection (blinks).
    % >>>>>>>>>>>>>>>>>>>>>>>>>
    % load eeglab gui for visual inspection
    
    if job.runICA ==1
    %%
        for idset = 1:2
            switch idset
                case 1
                    EEG= pop_loadset(['p_' sstr  ' resampled reref filt epochs stim gd.set']);
                    typeis = 'stim';
                case 2
                    EEG= pop_loadset(['p_' sstr  ' resampled reref filt epochs resp gd.set']);
                    typeis = 'resp';
            end
            
            
            %% reject epochs, run ICA, reject components in GUI.
            
            EEG = pop_runica(EEG, 'extended',0,'interupt','on');
            EEG = eeg_checkset( EEG );
            %save as we go.
            %%
            EEG.setname = ['p_' sstr ' resampled reref filt epochs ' typeis ' wICA2'];
            EEG = eeg_checkset( EEG );
            EEG=pop_saveset(EEG, 'filename', [EEG.setname]);
            
        end
    end
    
    
    if job.rejICA_comps  ==1
        %% plot comps for rejection, use SASICA
        
        used = {'stim', 'resp'};
        %%
        for idset =1%:2
            eeglab
%                        EEG= pop_loadset('filename', ...
%                 ['p_' sstr ' resampled reref filt epochs ' used{idset} ' wICA.set'],...
%                 'filepath', [basedir  filesep pfols(ippant).name]);
%             EEG=eeg_checkset(EEG);
%             pop_selectcomps(EEG, [1:35]);
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
                 if idset==1
                    rejected_comps_stim = rejected_components;
                    save('Epoch information', 'rejected_comps_stim', '-append');
                else
                    rejected_comps_resp = rejected_components;
                    save('Epoch information', 'rejected_comps_resp', '-append');
                 end
                 %save pruned version.
                EEG.setname=['p_' sstr ' resampled reref filt epochs ' upper(used{idset})  ' pruned with ICA'];
                 EEG = eeg_checkset( EEG );    
                 EEG=pop_saveset(EEG, 'filename', EEG.setname);
    %%
            end
              
                %%
%                 eeglab
            end
            
    end
  
    %% after all Preprocessing, we need to match the EEG to BEH.
    if job.matchPPanttrials ==1; 
        matchEEG2BEH;
    end
end


% idset=1;


