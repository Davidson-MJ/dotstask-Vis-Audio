
% script for calculating individual ERPs (trigger and response locked).

% called from JOBS_ERPsortandaverage


dbstop if error

%% Note the change to stimLong below! (longer epochs for stim locked triggers).
%% updated 23-06-20, to also calculate response locked ERPs, with prestim baseline.

%extra preprocessing before plotting:
lindetrend = 0; %% now detrending with longer epochs.
rmbase = 1;

% job list:
job1.calcindividual = 1;
job1.concat_GFX = 1;
%
%data types to analyze.
idatatypes = {'STIM', 'RESP', 'RESP-stimbase'};

%first job is to match the EEG and behavioural data. This is the most
%important step!
if job1.calcindividual == 1
    
    for ippant=1:length(pfols)
        
        %load eeg folder
        cd(eegdatadir)
        cd(pfols(ippant).name);
        pdir = pwd;
        
        %load raw EEG, matched for trial index with behaviour.
        load('participant TRIG extracted ERPs.mat');
        load('Epoch information.mat'); 
        clc;
        disp([' loading ppant ' num2str(ippant) ]);
        %%%%%% Here some extra preprocessing as required
        %stimulus locked, response locked, and response locked- with a pre-stimulus
        %baseline.
        for itype = 1:3
            
            %which data type to load?
            switch itype
                case 1
                    EEG_tmpsub1 = EEGstimLong_matched;
%                     EEG_tmpsub1 = EEGstim_matched;
                case 2
                    EEG_tmpsub1 = EEGresp_matched;
                    
                case 3
                    EEG_tmpsub1 = EEGresp_matched;
                    EEG_tmpsub2 = EEGstim_matched;
            end
            
            
            
            if lindetrend==1
                %% linearly detrend each channel, all trials.
                EEGdetr = zeros(size(EEG_tmpsub1));
                
                for ichan=1:64
                    %detrend each matrix
                    alld = squeeze(double(EEG_tmpsub1(ichan,:,:)));
                    
                    %detrend works across columns (2nd dim)
                    EEGdetr(ichan,:,:) = detrend(alld);
                end
                EEG_tmpsub1=EEGdetr;
            end
            
            
            if rmbase==1
                %% remove baseleine, 
                EEGrmb = zeros(size(EEG_tmpsub1));
%                 zerostart = dsearchn(plotXtimes', [-250 -50]');
                if itype==2 % response locked
                zerostart = dsearchn(plotXtimes', [-150 -50]'); % response locked is unaffected?
                else % stim lockedm there is a 250 ms delay (approx).

                zerostart = dsearchn(plotXtimes', [150 250]');
                end
                %% which data to use for baseline subtraction?
                if itype <3
                    baselinewith = EEG_tmpsub1;
                else
                    % use stim locked baseline for resp locked data.
                    baselinewith = EEG_tmpsub2;
                end
                
                for ichan = 1:64
                    for itrial=1:size(EEG_tmpsub1,3)
                        rawtrial =squeeze(EEG_tmpsub1(ichan,:,itrial));
                        baselinetrial = squeeze(baselinewith(ichan,:,itrial));
                        
                        baseb= mean(baselinetrial(zerostart(1):zerostart(2)));
                        %remove basleine
                        EEGrmb(ichan,:, itrial) =rawtrial- repmat(baseb, 1, size(rawtrial,2));
                    end
                end
                
                EEG_tmpsub = EEGrmb;
            end
            
            
            %save again
            switch itype
                case 1
                    stimlockedEEG = EEG_tmpsub;
                case 2
                    resplockedEEG = EEG_tmpsub;
                case 3
                    resplockedEEG_stimbaserem = EEG_tmpsub;
            end
            
        end
        
        
        %% perform some further splits, makes plotting easier later:
        if strcmp(ExpOrder{1}, 'visual') % visual in first half of exp:
            %
            corr_Vis_rl  = squeeze(mean(resplockedEEG(:,:,corAindx),3));
            err_Vis_rl  = squeeze(mean(resplockedEEG(:,:,errAindx),3));
            corr_Aud_rl = squeeze(mean(resplockedEEG(:,:,corBindx),3));
            err_Aud_rl  = squeeze(mean(resplockedEEG(:,:,errBindx),3));
            
            corr_Vis_sl  = squeeze(mean(stimlockedEEG(:,:,corAindx),3));
            err_Vis_sl  = squeeze(mean(stimlockedEEG(:,:,errAindx),3));
            corr_Aud_sl = squeeze(mean(stimlockedEEG(:,:,corBindx),3));
            err_Aud_sl  = squeeze(mean(stimlockedEEG(:,:,errBindx),3));
            
        else
            corr_Vis_rl  = squeeze(mean(resplockedEEG(:,:,corBindx),3));
            err_Vis_rl  = squeeze(mean(resplockedEEG(:,:,errBindx),3));
            corr_Aud_rl = squeeze(mean(resplockedEEG(:,:,corAindx),3));
            err_Aud_rl  = squeeze(mean(resplockedEEG(:,:,errAindx),3));
                        
            corr_Vis_sl  = squeeze(mean(stimlockedEEG(:,:,corBindx),3));
            err_Vis_sl  = squeeze(mean(stimlockedEEG(:,:,errBindx),3));
            corr_Aud_sl = squeeze(mean(stimlockedEEG(:,:,corAindx),3));
            err_Aud_sl  = squeeze(mean(stimlockedEEG(:,:,errAindx),3));           
            
        end
        save('participant TRIG extracted ERPs', ...
            'stimlockedEEG',...
            'resplockedEEG',...
            'resplockedEEG_stimbaserem',...
            'corr_Vis_rl','err_Vis_rl',...
            'corr_Aud_rl','err_Aud_rl',...                        
            'corr_Vis_sl', 'err_Vis_sl',...
            'corr_Aud_sl', 'err_Aud_sl', '-append');
        
        disp(['SAVING: >>> pp' pfols(ippant).name])
        
        
        
    end
end

%%
if job1.concat_GFX == 1
    %after completing across participants, store GFX.
    %%     %%
    [GFX_visrespCOR, GFX_audrespCOR,...
        GFX_visrespERR, GFX_audrespERR] =  deal(nan(length(pfols), 64, size(resplockedEEG,2)));
    
    [GFX_visstimERP, GFX_audstimERP,GFX_visstimCOR, GFX_audstimCOR,...
        GFX_visstimERR, GFX_audstimERR ] = deal(nan(length(pfols), 64, size(stimlockedEEG,2)));
    
    %%
    [vis_first, aud_first] = deal([]);
    cd(eegdatadir)
    %%
    for ippant=1:length(pfols)
        cd(eegdatadir)
        cd(pfols(ippant).name);
        load('participant TRIG extracted ERPs');
        load('Epoch information');
        %
        %
        %     %sort by modality.
        if strcmp(ExpOrder{1}, 'visual') % visual in first half of exp:
           
            vis_first= [vis_first, ippant];
            
        else
          
            aud_first= [aud_first, ippant];
            
        end
        
        EEG_visstim = squeeze(nanmean(stimlockedEEG(:,:,visStimindx),3));
        EEG_audstim = squeeze(nanmean(stimlockedEEG(:,:,audStimindx),3));
        %
        %     %store
        GFX_visstimERP(ippant,:,:)= EEG_visstim;
        GFX_audstimERP(ippant,:,:)= EEG_audstim;
        
        GFX_visrespCOR(ippant,:,:) = corr_Vis_rl;
        GFX_visrespERR(ippant,:,:) = err_Vis_rl;
        
        GFX_audrespCOR(ippant,:,:) = corr_Aud_rl;
        GFX_audrespERR(ippant,:,:) = err_Aud_rl;
        
        GFX_visstimCOR(ippant,:,:) = corr_Vis_sl;
        GFX_visstimERR(ippant,:,:) = err_Vis_sl;
        
        GFX_audstimCOR(ippant,:,:) = corr_Aud_sl;
        GFX_audstimERR(ippant,:,:) = err_Aud_sl;
        
        disp(['fin concat for pp ' num2str( ippant)])
    end
    %%
    % %% % save Group FX
    cd(eegdatadir)
    cd('GFX')
    % %%
    
    disp(['saving GFX - stim and resp locked ERPs']);
    save('GFX_averageERPs TRIG based', 'GFX_audrespCOR', 'GFX_audrespERR', ...
        'GFX_visrespCOR', 'GFX_visrespERR', ...
        'GFX_visstimCOR', 'GFX_visstimERR', ...
        'GFX_audstimCOR', 'GFX_audstimERR', ...
        'GFX_visstimERP', 'GFX_audstimERP',... 
        'plotXtimes',...
        'vis_first', 'aud_first');
end