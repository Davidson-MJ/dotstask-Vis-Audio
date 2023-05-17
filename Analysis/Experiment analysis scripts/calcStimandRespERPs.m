
% script for calculating individual ERPs (trigger and response locked).

% called from JOBS_ERPsortandaverage


dbstop if error

%% Note the change to stimLong below! (longer epochs for stim locked triggers).
%% updated 23-06-20, to also calculate response locked ERPs, with prestim baseline.

%extra preprocessing before plotting:
lindetrend = 1; %% now detrending with longer epochs.
rmbase = 1;

% job list:
job1.calcindividual = 1;
job1.concat_GFX = 1;
%
%data types to analyze.
idatatypes = {'STIM', 'RESP', 'RESP-stimbase'};


% note, now adjusting the auditory epochs to baseline before second tone
% onset (700-800 ms) in plotXtimes.
% we will also restrict the size. Shrink down to stim/response -.5 + 1 second.

maxEEGlength = 1000; % ms
%first job is to match the EEG and behavioural data. This is the most
%important step!
%%
cd(eegdatadir)
pfols=dir([pwd filesep 'p_*']);
%%
if job1.calcindividual == 1
    
    for ippant=1:length(pfols)
        
        clearvars EEG* -except EEGlength
        %load eeg folder
        cd(eegdatadir)
        cd(pfols(ippant).name);
        pdir = pwd;
        
        %load raw EEG, matched for trial index with behaviour.
        disp([' loading ppant ' num2str(ippant) ]);

        load('participant trigger matched EEG.mat');
        load('Epoch information.mat'); 
        clc;
        %%%%%% Here some extra preprocessing as required
        %stimulus locked, response locked, and response locked- with a pre-stimulus
        %baseline.
        %%
        for itype = 1:2
            disp(['Preprocessing eeg data ' num2str(itype)]);
            %which data type to load?
            switch itype
                case 1
                    EEG_tmpsub1 = EEGstimLong_matched;
%                     EEG_tmpsub1 = EEGstim_matched;
                case 2
%                     EEG_tmpsub1 = EEGresp_matched;
                    EEG_tmpsub1 = EEGrespLong_matched;
                    
                case 3
                    EEG_tmpsub1 = EEGrespLong_matched;
                    EEG_tmpsub2 = EEGstimLong_matched;
            end
            
            if itype==1 % stim locked epochs. shift onset for baseline subtraction.

                % for vis stim, simply subselect:
                epochbounds = dsearchn(plotXtimes', [min(plotXtimes) maxEEGlength]');
                EEG_tmp= [];
                EEG_tmp(:,:,visStimindx) = EEG_tmpsub1(:,  epochbounds(1):epochbounds(2),visStimindx);
               
                plotERPtimes = plotXtimes(epochbounds(1):epochbounds(2));
                % for auditory, so that time zero is 700 ms?  (2nd tone trial onset).

                epochStart = dsearchn(plotXtimes', [(800 -(abs(min(plotXtimes))))]'); % same pre onset window.
                epochEnd = epochStart + epochbounds(2) -1; % same length
                EEG_tmp(:,:,audStimindx) = EEG_tmpsub1(:,  epochStart:epochEnd,audStimindx);
                
                EEG_tmpsub1= EEG_tmp;
    


            elseif itype==2 % response locked. shrink.
                epochbounds = dsearchn(plotXtimes', [min(plotXtimes) maxEEGlength]');
                EEG_tmpsub1= EEG_tmpsub1(:, epochbounds(1):epochbounds(2), :);

                plotERPtimes = plotXtimes(epochbounds(1):epochbounds(2));
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
                else % stim locked

                zerostart = dsearchn(plotXtimes', [-100 0]');
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
                
                EEG_tmpsub1 = EEGrmb;
            end
            
         
            %save again
            switch itype
                case 1
                    stimlockedEEG = EEG_tmpsub1;
                case 2
                    resplockedEEG = EEG_tmpsub1;
                case 3
                    resplockedEEG_stimbaserem = EEG_tmpsub1;
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
        
        disp(['SAVING: >>> ' pfols(ippant).name])

% save('participant EEG preprocessed', 'stimlockedEEG', 'resplockedEEG', 'plotERPtimes','-append');
save('participant EEG preprocessed', 'stimlockedEEG', 'resplockedEEG', 'plotERPtimes');

            save('PFX ERPs', ...           
            'corr_Vis_rl','err_Vis_rl',...
            'corr_Aud_rl','err_Aud_rl',...                        
            'corr_Vis_sl', 'err_Vis_sl',...
            'corr_Aud_sl', 'err_Aud_sl', 'plotERPtimes');
        
        disp(['Done!']);
        
        
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
        clearvars stimlocked* resplocked*
        load('PFX ERPs'); % contains ERPs % created above
        load('participant EEG preprocessed.mat'); % contains all trials (created above)
        load('Epoch information');
        disp(['concat participant.. ' num2str(ippant)]);
        
        %
        %     %sort by modality.
        if strcmp(ExpOrder{1}, 'visual') % visual in first half of exp:
           
            vis_first= [vis_first, ippant];
            
        else
          
            aud_first= [aud_first, ippant];
            
        end
        
        EEG_visstim = squeeze(mean(stimlockedEEG(:,:,visStimindx),3, 'omitnan'));
        EEG_audstim = squeeze(mean(stimlockedEEG(:,:,audStimindx),3, 'omitnan'));
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