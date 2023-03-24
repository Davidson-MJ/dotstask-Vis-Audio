% script for calculating individual ERPs (trigger and response locked).

% called from Plot_dataforERPs_EEGtrigbased


lindetrend = 0;
rmbase = 1;
%
totaltrialN= 780;
%
for ippant=1:length(pfol)
    cd(basedir)
    cd('EEG')
    
    cd(pfol(ippant).name);
    
    %real ppant number:
    %     lis = pfol(ippant).name;
    %     ppantnum = str2num(cell2mat(regexp(lis, '\d*', 'Match')));
    %%
    dload = dir([ pwd filesep '*pruned with ICA.set']);
    
    %load EEG
    ALLEEG= pop_loadset('filename', [dload(1).name]);
    
    EEG = eeg_checkset( ALLEEG );
    
    %also load epoch information, for linking to behavioural data.
    load('Epoch information.mat', 'allTriggerEvents');
    
    
    %% extract different epochs based on trigger def'ns.  
    
    for itrig = 1:2
        switch itrig
            case 1
                % collect all data for stim-locked.                
                trigsnow = [2,3,102,103]; % trialstarts
                EEGtmp = pop_epoch( EEG, { num2str(trigsnow(1)) ...
                    num2str(trigsnow(2))  num2str(trigsnow(3))   ...
                    num2str(trigsnow(4)) }, [-.2 .9]);                
            case 2
                %all responses.
                trigsnow = [10,20, 11,21,110,120,111,121]; % all responses.
                EEGtmp = pop_epoch( EEG, { num2str(trigsnow(1)) ...
                    num2str(trigsnow(2))  num2str(trigsnow(3))   ...
                    num2str(trigsnow(4))...
                    num2str(trigsnow(5))...
                    num2str(trigsnow(6))...
                    num2str(trigsnow(7))...
                    num2str(trigsnow(8))}, [-.2 .9]); 
        end
                       
        EEGtmp = eeg_checkset( EEGtmp );
        %restrict to EEG channels
        EEG_tmpsub = EEGtmp.data(1:64,:,:);
        
        %        
        plotXtimes_2= EEGtmp.times;
     
     %%%%%% Here some extra preprocessing as required
        if lindetrend==1
            %% linearly detrend each channel, all trials.
            EEGdetr = zeros(size(EEG_tmpsub));
            
            for ichan=1:64
                %detrend each matrix
                alld = squeeze(double(EEG_tmpsub(ichan,:,:)));
                
                %detrend works across columns (2nd dim)
                EEGdetr(ichan,:,:) = detrend(alld);
            end
            EEG_tmpsub=EEGdetr;
        end
        
        if rmbase==1
            %% remove baseleine, 100ms
            EEGrmb = zeros(size(EEG_tmpsub));
            zerostart = dsearchn(plotXtimes_2', [-100 0]');
            %%
            for ichan = 1:64
                for itrial=1:size(EEG_tmpsub,3)
                    
                    tmpt= squeeze(EEG_tmpsub(ichan,:,itrial));
                    baseb= mean(tmpt(zerostart(1):zerostart(2)));
                    
                    EEGrmb(ichan,:, itrial) =tmpt - baseb;
                end
            end
            
            EEG_tmpsub = EEGrmb;
        end                
        %% %% Now for behavioural analysis, we need to know which EEG data we have.        
        %Note that for analyzing the data, we also need to know which epoch (chronologically) is being saved.
        
        ntrials = size(EEG_tmpsub,3);
        
        myepoch_index= zeros(ntrials,1);
        for itrial = 1:ntrials
            
            %this is the event as recorded in the EEG.
            try myevent_index= cell2mat(EEGtmp.epoch(itrial).eventurevent(1));
            catch
                myevent_index= (EEGtmp.epoch(itrial).eventurevent(1));
            end
            
            %find which epoch the behavioural data will be saved in.
            id=min(find(allTriggerEvents.urevent==myevent_index));
            
            %store
            myepoch_index(itrial) = allTriggerEvents.epoch_in_exp_adjusted(id);
        end
        
        if max(myepoch_index)>780
            error('check code');
        end
        
        %remove any nans.
        myepoch_index(isnan(myepoch_index))=[];
      
        %to make things easier later on, rearrange in chronological order,
        %and for the missing trials, leave as NAN.
        
        nanframe = nan(size(EEG_tmpsub, 1),size(EEG_tmpsub, 2), totaltrialN); % note 780 is max trialn.
        
        %now for the retained trials, complete the matrix:
        %this is slow, but safe:
        for ikept = 1:length(myepoch_index)
            
            realtrial = myepoch_index(ikept);
            nanframe(:,:,realtrial) = EEG_tmpsub(:,:,ikept);
        end
    
        %now we have each EEG placed in chronological order, with NaNs when
        %the ERP was removed.
        
        
        %now save
        switch itrig
            case 1
                stimlockedEEG = nanframe;
            case 2
                resplockedEEG = nanframe;
        end
    end
    
    save('participant TRIG extracted ERPs', ...
        'stimlockedEEG',...
        'resplockedEEG',...
        'plotXtimes_2','-append');

    %% now that we have this data, we can 
    
    
end

