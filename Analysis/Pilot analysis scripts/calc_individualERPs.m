% script for calculating individual ERPs (trigger and response locked).

% called from Plot_dataforERPs_EEGtrigbased


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
    for trigsearch= 1:6
        switch trigsearch
            case 1
                trigsnow = [10,20]; %incorrect first half
            case 2
                trigsnow = [110,120]; %incorrect second half
            case 3
                trigsnow = [11,21];  %correct first
            case 4
                trigsnow = [111,121]; %correct second
            case 5
                trigsnow = [2,102]; % will grab visual in first or second half.
            case 6
                trigsnow = [3,103]; % will grab audio in first or second half.
        end
        
        
        
        EEGtmp = pop_epoch( EEG, {  num2str(trigsnow(1))   num2str(trigsnow(2))  }, [-.2 .9]);
        
        
        EEGtmp = eeg_checkset( EEGtmp );
        
        
        
        
        EEG_tmpsub = EEGtmp.data(1:64,:,:);
        
        %
        
        plotXtimes= EEGtmp.times;
        
        %note that we need to adjust (in pilot data), for the 180 ms delay between
        %sound onset and trigger release, for auditory tones.
        % % which leaves us with a 20ms baseline.
        % if trigsearch<6
        % newb_20ms = dsearchn(plotXtimes', [plotXtimes(1)+180, plotXtimes(end)]');
        % else
        %     newb_20ms = dsearchn(plotXtimes', [plotXtimes(1), plotXtimes(end)-180]');
        % end
        %
        % %now adjust data to plot appropriately, accounting for delay:
        %     newvec= newb_20ms(1):newb_20ms(2);
        %
        % %condensed data:
        %     datac = EEG_tmpsub(:, newvec, :);
        %
        % %also select appropriate x axis dimensions.
        %    newb_20ms = dsearchn(plotXtimes', [plotXtimes(1)+180, plotXtimes(end)]');
        %     newvec= newb_20ms(1):newb_20ms(2);
        %     plotXtimes = plotXtimes(newvec);
        %
        
        %% also detrend?
        EEGdetr = zeros(size(EEG_tmpsub));
        
        for ichan=1:64
            %detrend each matrix
            alld = squeeze(double(EEG_tmpsub(ichan,:,:)));
            
            %detrend works across columns (2nd dim)
            EEGdetr(ichan,:,:) = detrend(alld);
        end
        
% EEGdetr=EEG_tmpsub;
        %% remove baseleine?
        
        %
            EEGrmb = zeros(size(EEGdetr));
            zerostart = dsearchn(plotXtimes', [-100 0]');
            %%
            for ichan = 1:64
                for itrial=1:size(EEGdetr,3)
        
                    tmpt= squeeze(EEGdetr(ichan,:,itrial));
                    baseb= mean(tmpt(zerostart(1):zerostart(2)));
        
                    EEGrmb(ichan,:, itrial) =tmpt - baseb;
                end
            end
            
        EEGdetr=EEGrmb;
        %% save this data below.
        %%
        
        %%%%
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
        switch trigsearch
            case 1
                EEG_err_A = EEGdetr;
                EEG_err_A_index = myepoch_index;
            case 2
                EEG_err_B = EEGdetr;
                EEG_err_B_index = myepoch_index;
            case 3
                EEG_cor_A = EEGdetr;
                EEG_cor_A_index = myepoch_index;
            case 4
                EEG_cor_B = EEGdetr;
                EEG_cor_B_index = myepoch_index;
            case 5
                EEG_visstim = EEGdetr;
                EEG_visstim_index = myepoch_index;
                
            case 6
                EEG_audstim= EEGdetr;
                EEG_audstim_index = myepoch_index;
                
                %check to see which type we have
                if any([EEGtmp.event(1:end).type]==103)
                    ExpOrder = {'visual', 'auditory'};
                else
                    ExpOrder = {'auditory', 'visual'};
                end
                
        end
    end
    
    
    
    
    
    
    save('participant TRIG extracted ERPs', ...
        'EEG_err_B',...
        'EEG_err_A',...
        'EEG_cor_A',...
        'EEG_cor_B',...
        'EEG_visstim',...
        'EEG_audstim',...
        'EEG_err_B_index',...
        'EEG_err_A_index',...
        'EEG_cor_A_index',...
        'EEG_cor_B_index',...
        'EEG_visstim_index',...
        'EEG_audstim_index','plotXtimes', 'ExpOrder');
    
    
    
end

%now concatenate and save across participants.
    %%
[GFX_visstimERP, GFX_audstimERP, GFX_visrespCOR, GFX_audrespCOR,...
    GFX_visrespERR, GFX_audrespERR] =  deal(nan(length(pfol), 64, 281));
%%
for ippant=1:length(pfol) % 1,3,4
    cd(basedir)
    cd('EEG')
    cd(pfol(ippant).name);
    load('participant TRIG extracted ERPs');
    
    
    %sort by modality.
    if strcmp(ExpOrder{1}, 'visual')
        
        corr_Vis  = EEG_cor_A;
        err_Vis  = EEG_err_A;
        
        corr_Aud = EEG_cor_B;
        err_Aud  = EEG_err_B;
        
    else
        
        corr_Vis  = EEG_cor_B;
        err_Vis  = EEG_err_B;
        corr_Aud = EEG_cor_A;
        err_Aud  = EEG_err_A;
    end
    
    %store
    GFX_visstimERP(ippant,:,:)= squeeze(nanmean(EEG_visstim,3));
    GFX_audstimERP(ippant,:,:)= squeeze(nanmean(EEG_audstim,3));
    
    GFX_visrespCOR(ippant,:,:) = squeeze(nanmean(corr_Vis,3));
    GFX_visrespERR(ippant,:,:) = squeeze(nanmean(err_Vis,3));
    
    GFX_audrespCOR(ippant,:,:) = squeeze(nanmean(corr_Aud,3));
    GFX_audrespERR(ippant,:,:) = squeeze(nanmean(err_Aud,3));
    
end

%% % save Group FX
cd(basedir)
  cd('EEG')
cd('GFX')
%%
    save('GFX_averageERPs TRIG based', 'GFX_audrespCOR', 'GFX_audrespERR', ...
        'GFX_audstimERP', 'GFX_visrespCOR', 'GFX_visrespERR', 'GFX_visstimERP', 'plotXtimes');
