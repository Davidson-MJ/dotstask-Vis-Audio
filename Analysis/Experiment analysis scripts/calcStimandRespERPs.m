
% script for calculating individual ERPs (trigger and response locked).

% called from JOBS_ERPsortandaverage


%extra preprocessing before plotting:
lindetrend = 0;
rmbase = 1;

%
job1.calcindividual = 1;
job1.concat_GFX = 0;
%
%data types to analyze.
idatatypes = {'STIM', 'RESP'};

%first job is to match the EEG and behavioural data. This is the most
%important step!
if job1.calcindividual == 1

for ippant=2%11:12;%length(pfols)
    
    %load eeg folder
    cd(basedir)     
    cd(pfols(ippant).name);
    pdir = pwd;
    %load epoch information, for linking to behavioural data.
    load('Epoch information.mat');
     
    %what was the experimental order for this participant?
        if any(allTriggerEvents_stim.type==2)
            %if 2, then we had visual - audio.
             ExpOrder = {'visual', 'auditory'};
        else
             ExpOrder = {'auditory', 'visual'};
        end
        
        
         %% also import behavioural data
         %real ppant number:
        lis = pfols(ippant).name;
        ppantnum = str2num(cell2mat(regexp(lis, '\d*', 'Match')));
        if ppantnum <10
            sstr = ['0' num2str(ppantnum)]; 
        else
            sstr = num2str(ppantnum); 
        end
        cd(behdatadir);
        %behfolder:
        behfol = dir([pwd filesep '*_p' sstr ]);
        cd(behfol.name);
        disp(['MATCHING eeg folder ' pfols(ippant).name ' to behav folder ' behfol.name]);
        %load behavioural data.
        finalfol = dir([pwd filesep '*_final.mat']);
        % we will save this with the ERPs for easy analysis.
        load(finalfol.name, 'alltrials'); 
        alltrials_raw = alltrials;
        %find index of practice trials to remove from further analysus
        %(below)
        allpractrials = find([alltrials_raw.isprac]);
        
        
        %return to EEG folder
        cd(pdir)
        
    for itype = 1:2
        
        %which data type to load?
        loadt = idatatypes{itype};    
        dload = dir([ pwd filesep '*' loadt ' interpd.set']);
    %%
    %load EEG
    ALLEEG= pop_loadset('filename', [dload(1).name]);
    
    EEGtmp = eeg_checkset( ALLEEG );
    
    
    %% extract different epochs based on trigger def'ns.  
   
        %restrict to EEG channels
        EEG_tmpsub = EEGtmp.data(1:64,:,:);
        
        %        
        plotXtimes= EEGtmp.times;
     
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
            zerostart = dsearchn(plotXtimes', [-250 -50]');
            %%
            for ichan = 1:64
                for itrial=1:size(EEG_tmpsub,3)
                    
                    tmpt= squeeze(EEG_tmpsub(ichan,:,itrial));
                    baseb= mean(tmpt(zerostart(1):zerostart(2)));
                    
                    EEGrmb(ichan,:, itrial) =tmpt - repmat(baseb, 1, size(tmpt,2));
                end
            end
            
            EEG_tmpsub = EEGrmb;
        end                
       
        %now we have our final EEG data. Now to store the behavioural data
        %correctly.
        %% which trials remain?        
        if itype==1
            %real trials in EEG (based on behavioural index)
            alltrials_tmp = unique(allTriggerEvents_stim.epoch); 
            %remove the trials from this index, which were already
            %identified.
            findme = intersect(alltrials_tmp, rejected_trials_stim);
            alltrials_tmp(findme) =[]; 
        else
            alltrials_tmp = unique(allTriggerEvents_resp.epoch);
            findme = intersect(alltrials_tmp, rejected_trials_resp);
            alltrials_tmp(findme) =[]; 
        end
        
        %make sure the data sets match.        
        %these are those that remain
        remainingtrials = alltrials_tmp;
        
        %now note all that need to be removed.                
        allremovetrials = unique([rejected_trials_stim, rejected_trials_resp]);
       
        %for both the STIM and RESP locked, make sure we have kept the same
        %trials.
        %find members of the remaining trials, which still need to be
        %removed.
        findme = intersect(remainingtrials, allremovetrials);
        
        %now remove thise final trials from our processed data.
        lindex = ismember(remainingtrials, findme);
        
        EEG_tmpsub_final = EEG_tmpsub(:,:,lindex==0);
        
        %%
        %now save
        switch itype
            case 1
                stimlockedEEG = EEG_tmpsub_final;
            case 2
                resplockedEEG = EEG_tmpsub_final;
        end
    end
    if size(stimlockedEEG,3)~= size(resplockedEEG,3)
        error('check code, indexing problem');
    end
    %%
    %now finally restrict the behavioural data to match.
    alltrials_tmp = alltrials_raw;
    % note that for participant 2, we need to adjust for missing data. 
    % trials were absent from EEG:
    if ippant==2 
        alltrials_raw(870)=[];         
        alltrials_raw(1)=[]; 
        
        alltrials_tmp= alltrials_raw; 
    elseif ippant== 4 ||ippant== 6
        % this participant also had a stimulus locked trial missing (last
        % one)
        alltrials_raw(870)=[]; 
        alltrials_tmp=alltrials_raw; 
    end
    
    alltrials_tmp(allremovetrials)=[];
    alltrials_matched = alltrials_tmp;
    
    % 
    if length(alltrials_matched) ~= size(stimlockedEEG,3)
          error('check code, indexing problem'); 
    end
    
%% now for each type of response, let's establish index for later analysis.
%also remove practice trials from consideration.
notprac = find([alltrials_matched.isprac]==0);
corAindx = intersect(find([alltrials_matched.cor]), find(contains({alltrials_matched.ExpType}, 'A')));
corAindx = intersect(corAindx, notprac);

corBindx = intersect(find([alltrials_matched.cor]), find(contains({alltrials_matched.ExpType}, 'B')));
corBindx = intersect(corBindx, notprac);

errAindx = intersect(find([alltrials_matched.cor]==0), find(contains({alltrials_matched.ExpType}, 'A')));
errAindx = intersect(errAindx, notprac);

errBindx = intersect(find([alltrials_matched.cor]==0), find(contains({alltrials_matched.ExpType}, 'B')));
errBindx = intersect(errBindx, notprac);

visStimindx = find(contains(lower({alltrials_matched.stimtype}), 'visual'));
visStimindx = intersect(visStimindx, notprac);

audStimindx = find(contains(lower({alltrials_matched.stimtype}), 'audio'));
audStimindx = intersect(audStimindx, notprac);
    %% save all.
%     save('Epoch information', 'ExpOrder', 'alltrials_matched', ...
%         'corAindx', 'corBindx', 'errAindx', 'errBindx', 'visStimindx',...
%         'audStimindx', '-append');
    
    save('participant TRIG extracted ERPs', ...
        'stimlockedEEG',...
        'resplockedEEG',...
        'plotXtimes','alltrials_matched', 'ExpOrder');%, '-append');

end
end


if job1.concat_GFX == 1
%after completing across participants, store GFX.
%%     %%
[GFX_visstimERP, GFX_audstimERP, GFX_visrespCOR, GFX_audrespCOR,...
    GFX_visrespERR, GFX_audrespERR] =  deal(nan(length(pfols), 64, size(stimlockedEEG,2)));
%%
cd(basedir)
for ippant=1:length(pfols)
    cd(basedir)    
    cd(pfols(ippant).name);
    load('participant TRIG extracted ERPs');
    load('Epoch information');
%     
%     
%     %sort by modality.
    if strcmp(ExpOrder{1}, 'visual')
%         
        corr_Vis  = squeeze(mean(resplockedEEG(:,:,corAindx),3));
        err_Vis  = squeeze(mean(resplockedEEG(:,:,errAindx),3)); 
        corr_Aud = squeeze(mean(resplockedEEG(:,:,corBindx),3));
        err_Aud  = squeeze(mean(resplockedEEG(:,:,errBindx),3));
    %         
   
    
    else
        corr_Vis  = squeeze(mean(resplockedEEG(:,:,corBindx),3));
        err_Vis  = squeeze(mean(resplockedEEG(:,:,errBindx),3));
        corr_Aud = squeeze(mean(resplockedEEG(:,:,corAindx),3));
        err_Aud  = squeeze(mean(resplockedEEG(:,:,errAindx),3));
        
   
    end
    
    EEG_visstim = squeeze(nanmean(stimlockedEEG(:,:,visStimindx),3));
    EEG_audstim = squeeze(nanmean(stimlockedEEG(:,:,audStimindx),3));
%     
%     %store
    GFX_visstimERP(ippant,:,:)= EEG_visstim;
    GFX_audstimERP(ippant,:,:)= EEG_audstim;
    
    GFX_visrespCOR(ippant,:,:) = corr_Vis;
    GFX_visrespERR(ippant,:,:) = err_Vis;
    
    GFX_audrespCOR(ippant,:,:) = corr_Aud;
    GFX_audrespERR(ippant,:,:) = err_Aud;
    
end
%% 
% %% % save Group FX
cd(basedir)
cd('GFX')
% %%
    save('GFX_averageERPs TRIG based', 'GFX_audrespCOR', 'GFX_audrespERR', ...
        'GFX_audstimERP', 'GFX_visrespCOR', 'GFX_visrespERR', 'GFX_visstimERP', 'plotXtimes');
end