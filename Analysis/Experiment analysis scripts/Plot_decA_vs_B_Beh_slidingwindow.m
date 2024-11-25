% plot classifer trained on part B (C vs E), to predict confidence or RT
% with a sliding window analysis

%called from JOBS_ERPdecoder.m

cmap = flip(cbrewer('seq', 'RdPu', 5));

%% Note that this script can save a sliding window of classifier performance, correlated
% with RT or confidence in part B.

%amended 23/06/20 -MD

baselinetype=1; % for response-locked with response baseline
% baselinetype=2;% for response-locked with prestimulus baseline

job1.calcandconcat_PFX =0;
job1.plotPFX=0;
job1.plotGFX=0;
job1.plotGFX_MS=0; % single plot of one condition
job1.plotGFX_MS2=1; % 2x2 plot of interest 


elocs = readlocs('BioSemi64.loc');

normON = 1; % 0,1 ; normalize EEG data.
plotRTorConf =2;  %1, 2 for GFX


%%
savenamecell= {'GFX_DecA_Pe_slidingwindow_predictsB_Behav',...
                'GFX_DecA_Pe_slidingwindow_predictsB_Behav_wprestim'};
savename= savenamecell{baselinetype};
%
    
    ylabsare= {'confidence', 'rt', 'confidence'};
    titlesare= {'corrects', 'errors', 'all'};
    ylimsAre= [-.15 .15; -.2 .2; -.15 .15];

%%
if job1.calcandconcat_PFX ==1
    %
    TESTondatatypes = {'resplocked', 'stimlocked', 'resplocked-stimbase'};
    % run once per basleinetype.
    for testontype = 1:3%; of the above  -> each now saved with new name
        
        %         [GFX_DECA_Conf_corr_slid ,GFX_DECA_RT_corr_slid ]=deal(nan(length(pfols), 28));
        
        [GFX_DECA_Conf_corr_slid ,GFX_DECA_RT_corr_slid ,GFX_DECA_Conf_Subjcorr_slid]=deal([]);
        GFX_DecA_ScalpProj=nan(length(pfols), 64);
        GFX_ExpOrders=[];
        
        for ippant = 1:length(pfols)
            cd(eegdatadir)
            cd(pfols(ippant).name);
            %% load the Classifer and behavioural data:
            if baselinetype==1 % which classifier ?
                load('Classifier_trained_A_resp_Pe_window.mat');
            elseif baselinetype==2
                load('Classifier_trained_A_resp_Pe_window_wprestim.mat');
            end
            load('participant EEG preprocessed');
            load('Epoch information.mat');
            %%
            %
            %how many iterations were used in classifier training?
            
            nIter = size(DEC_Pe_window.scalpproj,1);
            %% both or corr only?
            for idatatype=1:3
                switch idatatype
                    case 1
                        partBindx = sort(corBindx);
                    case 2
                        partBindx = sort(errBindx); %
                    case 3
                        partBindx= sort([corBindx; errBindx]);
                end
                
                switch testontype
                    case 1
                        partBdata = resplockedEEG(:,:,partBindx);
                    case 2
                        partBdata = stimlockedEEG(:,:,partBindx);
                    case 3
                        partBdata = resplockedEEG_stimbaserem(:,:,partBindx);
                end
                
                dataprint = TESTondatatypes{testontype};
                
                [nchans, nsamps, ntrials] =size(partBdata);
                
                
                if normON==1
                    data_norm = zeros(size(partBdata));
                    for ichan = 1:nchans
                        for itrial=1:ntrials
                            temp = partBdata(ichan,:,itrial);
                            % rescale
                            temp=temp-(0.5*(min(temp)+max(temp)));
                            if(min(temp)~=max(temp))
                                temp=temp/max(temp);
                            end
                            
                            data_norm(ichan,:,itrial) = temp;
                        end
                    end
                    partBdata= data_norm;
                end
                
                
                
                for iSLIDE = 1:3 % compare classifier output based on RT and confidence.
                    
                    % collect relevant behavioural data per ppant.
                    switch iSLIDE
                        case 1
                            %note that confjmnts are from sure error - to sure correct.
                            
                            %                         allBEH= zscore(abs([BEH_matched.confj{partBindx}])); % remove absolute
                            
                            % this will use either only objectively correct
                            % trials, objectively incorrect trials, or all
                            % trials.
                            allBEH= zscore(([BEH_matched.confj{partBindx}]));
                            slidepartBdata= partBdata;
                        case 2
                            %these RTs are incorrect (need to be adjusted, as
                            %in prev script).
                            allBEH= zscore([BEH_matched.rt(partBindx)]);
                            %analysis:
                            
                            %remove RTs > 5s.
                            keepvec1 = allBEH<5;
                            
                            
                            %remove implausible values, any RTs recorded before second tone begins.
                            keepvec2 = allBEH >.6;
                            
                            %which trials to save overall?
                            keepvec = intersect(find(keepvec1),find(keepvec2));
                            %extract RTs and to start RT after second tone ONSET.
                            allBEH = allBEH(keepvec) - .6;
                            
                            
                            % zscore for aross ppant comparison
                            allBEH= zscore(allBEH);
                            %ensure EEG is reduced to match:
                            slidepartBdata = partBdata(:,:,keepvec);
                            
                        case 3
                            
                            % this will use either only objectively correct
                            % trials, objectively incorrect trials, or all
                            % trials.
                            % AND
                            % restrict focus to only subjectively correct confidence judgements
                            % (avoids error detection complications).
                            
                            
                            allBEH= [BEH_matched.confj{partBindx}];
                            keepvec =  find(allBEH>0); % only subjectively correct responses:
                            allBEH = zscore(allBEH(keepvec));
                            slidepartBdata = partBdata(:,:,keepvec);
                            
                    end
                    [nchans, nsamps, ntrials] = size(slidepartBdata);
                    %before continuing, we want to apply the spatial discrim to each trial.
                    %% we are using the decoder from part A (correct vs Errors)
                    %note, use the average discrim vector!
                    v = mean(DEC_Pe_window.discrimvector,1)';
                    
                    
                    %                 v = DEC_Pe_window.discrimvector(1,:)'
                    %we want to take the probability, when this decoder is applied to a
                    %sliding window across part B epochs.
                    testdata = reshape(slidepartBdata, nchans, nsamps* ntrials)';%
                    %% multiply data by classifier:
                    %if using vector
                    ytest_tmp = testdata* v(1:end-1) + v(end);
                    %take the prob
                    ytest_bp= bernoull(1,ytest_tmp);
                    % reshape for single trial decoding
                    ytest_trials = reshape(ytest_bp,nsamps,ntrials);
                    
                    
                    
                    %% now take correlation with confidence, in a sliding window:
                    
                    % set up the sliding window. 100ms window, 10 ms steps.
                    movingwin = [.05, .01]; % was 50 ms 5 ms
                    Fs = 256;
                    Nwin=round(Fs*movingwin(1)); % number of samples in window
                    Nstep=round(movingwin(2)*Fs); % number of samples to step through
                    
                    winstart=1:Nstep:nsamps-Nwin+1;
                    nw=length(winstart);
                    %%
                    outgoing =zeros(1,nw);
                    
                    
                    for n=1:nw
                        indx=winstart(n):winstart(n)+Nwin-1;
                        
                        %get mean decoder prob in this window, all trials.
                        
                        datawin = mean(ytest_trials(indx,:),1);
                        
                        %correlate with confidence (all trials)
                        [R,p] = corrcoef(datawin, allBEH);
                        %                     [R,p] = corr([datawin',allBEH'],'type', 'Spearman');
                        %
                        %store sliding probability :
                        outgoing(n)= R(1,2);
                        
                    end
                    % centre values:
                    winmid=winstart+round(Nwin/2);
                    
                    slideTimes = plotERPtimes(winmid);
                    
                    %% alternate:
                    outgoing2 =zeros(1,nsamps);
                    for isamp= 1:nsamps
                        
                        [R,p]= corrcoef(ytest_trials(isamp,:), allBEH);
                        outgoing2(isamp)= R(1,2);
                        
                    end
                    
                    
                    
                    %%
                    %                  %% DEBUG plots
                    %                  figure(2);
                    %                  subplot(121);
                    %                  plot(plotXtimes(winmid), outgoing); title('corr. using scalp');
                    %%
                    %                  subplot(122);
                    %                  plot(plotXtimes(winmid), outgoing); title('corr. using sp');
                    %% %% store output participants:
                    if iSLIDE==1
                        GFX_DECA_Conf_corr_slid(ippant,:, idatatype) = outgoing;
                    elseif iSLIDE==2
                        GFX_DECA_RT_corr_slid(ippant,:,idatatype) = outgoing;
                    elseif iSLIDE==3
                        GFX_DECA_Conf_Subjcorr_slid(ippant,:,idatatype) = outgoing;
                    end
                    
                end % iSLIDE
            end % corrects errors, all
            
            %% sanity check.
            %     clf
            %     tsare={'corrects', 'errors', 'all'}
            %     for i=1:3
            %     subplot(2,3,i);
            % plot(plotXtimes(winmid), GFX_DECA_Conf_corr_slid(ippant,:,i))
            % hold on; plot(xlim, [0 0]);
            % ylim([-.4 .4]);
            % ylabel('p(Error) and conf')
            % title(tsare{i})
            %     subplot(2,3,i+3);
            % plot(plotXtimes(winmid),GFX_DECA_RT_corr_slid(ippant,:,i))
            % hold on; plot(xlim, [0 0]);
            % ylim([-.4 .4]);
            % ylabel('p(Error) and rt');
            %     end
            %%
            
            
            
            GFX_DecA_ScalpProj(ippant,:) = mean(DEC_Pe_window.scalpproj,1);
            %             GFX_ExpOrders(ippant).d= ExpOrder;
            
            disp(['calc sliding window for ppant num ' num2str(ippant)]);
        end
        %save GFX level data
        cd(eegdatadir)
        cd('GFX')
        
        savenamenow = [savename '_test_' TESTondatatypes{testontype}];
        save(savenamenow, ...
            'GFX_DECA_RT_corr_slid', ...
            'GFX_DECA_Conf_corr_slid',...
            'GFX_DECA_Conf_Subjcorr_slid',...
            'GFX_DecA_ScalpProj', 'winmid', 'plotERPtimes' ,'slideTimes');
        
        
        
        
        
        
    end
end
%%

if job1.plotPFX==1
    
     cd(eegdatadir)
        cd('GFX')

        TESTondatatypes = {'resplocked', 'stimlocked', 'resplocked-stimbase'};
        testontype = 1;%:3%; of the above  -> each now saved with new name
        savenamenow = [savename '_test_' TESTondatatypes{testontype}];
    
        load(savenamenow);
        
    %         error(' plottng all or correct only? update script');
    %plot elements
    
    
    %output to figdir.
    cd(figdir)
    cd('Classifier Results')
    if baselinetype==1
        cd('PFX_Trained on resp Errors in part A, conf x sliding window part B');
    else
        cd('PFX_Trained on resp Errors in part A (wprestim), conf x sliding window part B');
    end
    
    dataprint = TESTondatatypes{testontype};
    
    
    % conf or RTs?
    dataIN= GFX_DECA_Conf_corr_slid;
    ytitle = 'Confidence- correct only';
    
    %         dataIN= GFX_DECA_RT_corr_slid;
    %         ytitle = 'RT- correct only';
    %%
    for ippant=1:length(pfols);
        
        % load ppant data
        plotme = GFX_DECA_Conf_corr_slid(ippant,:);
        plotscalp = GFX_DecA_ScalpProj(ippant,:);
        ExpOrder= GFX_ExpOrders(ippant).d;
        %%
        set(gcf, 'units', 'normalized', 'position', [0.1    .1   .7 .7], 'color', 'w', 'visible', 'on');
        clf
        subplot(1,3,1:2)
        plot(slideTimes,plotme, 'color', 'k', 'linew', 3);
        title({['P' num2str(ippant) ', Classifier trained on ERP A (C vs E) x ERP B'];[ExpOrder{1} '- ' ExpOrder{2} ]});
        xlabel(['Time [ms] after ' dataprint ' in part B']);
        ylabel({['DECODE x ' ytitle ];['[r]']})
        ylim([-.2 .2])
        hold on; plot(xlim, [0 0 ], ['k:'], 'linew', 2)
        hold on; plot([0 0 ], ylim, ['k:'], 'linew', 2)
        set(gca, 'fontsize', 15)
        
        subplot(133)
        topoplot(plotscalp, elocs);
        title([num2str(nIter) 'x Classifier trained [' num2str(DEC_Pe_windowparams.training_window_ms) ']'])
        set(gca, 'fontsize', 15)
        
        %
        if baselinetype==1
        printname = ['Participant ' num2str(ippant) ' Dec A (Pe) sliding confidence correct only'];
        elseif baselinetype==2
            printname = ['Participant ' num2str(ippant) ' Dec A (Pe) sliding confidence correct only train wprestim'];
        end
            
        set(gcf, 'color', 'w')
        print('-dpng', printname)
        
    end
end


dataprint = TESTondatatypes{testontype};
%%
if job1.plotGFX==1
    cd(eegdatadir)
        cd('GFX')

        
        baselinetype=2;
        savename = savenamecell{baselinetype};
        %
        
        TESTondatatypes = {'resplocked', 'stimlocked', 'resplocked-stimbase'};
        testontype = 3;%:3%; of the above  -> each now saved with new name
        savenamenow = [savename '_test_' TESTondatatypes{testontype}];
    
        load(savenamenow);
    
    
    cd(figdir)
    cd('Classifier Results');
    
    
    figure(1); clf; set(gcf, 'color', 'w', 'units', 'normalized', 'position', [0.1 0.1 .8 .7]);
    % plot results across participants:
    showt1 = [200, 350];
    
    ylabsare= {'confidence', 'rt', 'confidence'};
    titlesare= {'corrects', 'errors', 'all'};
    ylimsAre= [-.15 .15; -.2 .2; -.15 .15];
    
    allData= {GFX_DECA_Conf_corr_slid, GFX_DECA_RT_corr_slid,GFX_DECA_Conf_Subjcorr_slid};
    for idata=[1,2,3]%:length(allData)
        ylabis= ylabsare{idata};
        dataIN= allData{idata};
        for itrialtype=1:3
            
            
            subplot(3,3,itrialtype + (3*(idata-1)));
            %%
            dataINt = squeeze(dataIN(:,:,itrialtype));
            %                     ylabis ={['Classifier and ' compis ];['[r]']};
            
            usecol='k';
            
            Ste = CousineauSEM(dataINt);
            
            
            set(gcf, 'color', 'w')
            ylim(ylimsAre(idata,:))
            %place patches (as background) first:
            ytx= get(gca, 'ylim');
            hold on
            %plot topo patches (if not stimlocked EEG), to show the
            %                     training window used for the classifier.
            if testontype~=2
                ph=patch([showt1(1) showt1(1) showt1(2) showt1(2)], [ytx(1) ytx(2) ytx(2) ytx(1) ],  [1 .9 .9]);
                ph.FaceAlpha=.4;
                ph.LineStyle= 'none';
            end
            hold on
            %%%%
            shadedErrorBar(slideTimes, nanmean(dataINt,1), Ste, [usecol],1);
            %                     shadedErrorBar(plotERPtimes, mean(dataINt,1), Ste, [usecol],1);
            shg
            
            
            xlabel(['Time [ms] after ' dataprint ' in part B']);
            ylabel(['p(Error) x ' ylabis])
            
            
            hold on; plot(xlim, [0 0 ], ['k:'], 'linew', 2)
            %                     hold on; plot([0 0 ], ylim, ['k:'], 'linew', 2)
            set(gca, 'fontsize', 15)
            
            title(titlesare{itrialtype}, 'fontsize', 15)
            if idata==3
                title([titlesare{itrialtype} '+ subjcorr only'], 'fontsize', 15)
            end
            
            box on
            % add sig tests:
            %ttests
            pvals= nan(1, length(slideTimes));
            %
            for itime = 1:length(slideTimes)
                [~, pvals(itime)] = ttest(dataIN(:,itime, itrialtype));
                
                if pvals(itime)<.05
                    text(slideTimes(itime), [-.1], '*', 'color', 'k','fontsize', 15);
                    %                             text(slideTimes(itime), [-.07], '*', 'color', 'k','fontsize', 15);
                end
            end
            
            
        end % trialstype
    end % conf and rt
    %%
    % add topoplot of discrim used to aid interpretation.
    %
    %         subplot(1,3,3)
    %         topoplot(mean(GFX_DecA_ScalpProj(:,:)), elocs);
    %         %             title(['Classifier trained [' num2str(DEC_Pe_windowparams.training_window_ms) ']']);
    %         set(gca, 'fontsize', 25)
    %
    %         set(gcf,'color', 'w')
    %%
    cd(figdir)
    cd('Classifier Results')
    cd('PFX_Trained on Correct part A, conf x sliding window part B');
    printname = ['GFX Dec A sliding window confidence correlaiton, for ' ordert ' corr only, nreps 10, test on ' dataprint];
    print('-dpng', printname)
    
end

%%
if job1.plotGFX_MS==1
    
   cd(eegdatadir)
        cd('GFX')

        baselinetype=1;
        savename = savenamecell{baselinetype};
        %
        
        TESTondatatypes = {'resplocked', 'stimlocked', 'resplocked-stimbase'};
        testontype = 1;%:3%; of the above  -> each now saved with new name
        savenamenow = [savename '_test_' TESTondatatypes{testontype}];
    
        load(savenamenow);
    
    % %% what to plot?
    idata=2; 
    allData= {GFX_DECA_Conf_corr_slid, GFX_DECA_RT_corr_slid,GFX_DECA_Conf_Subjcorr_slid};
    ylabis= ylabsare{idata};
    dataIN= allData{idata};
    
    % corrects, errors, or all responses (within above datatypes)
    itrialtype=3; 
    titlesare= {'corrects', 'errors', 'all'};
    
    %
    cd(figdir)
    cd('Classifier Results');
    
    %
    
    figure(1); clf; set(gcf, 'color', 'w', 'units', 'normalized', 'position', [0.1 0.1 .4 .4]);
    % plot results across participants:
    showt1 = [200, 350];
    
    ylabsare= {'confidence', 'rt', 'confidence'};
    
    ylimsAre= [-.15 .15; -.2 .2; -.2 .1];
    
    
    %
    dataINt = squeeze(dataIN(:,:,itrialtype));
    %                     ylabis ={['Classifier and ' compis ];['[r]']};
    
    usecol='k';
    
    Ste = CousineauSEM(dataINt);
    
    
    set(gcf, 'color', 'w')
    ylim(ylimsAre(idata,:))
    %place patches (as background) first:
    ytx= get(gca, 'ylim');
    hold on
    %plot topo patches (if not stimlocked EEG), to show the
    %training window used for the classifier.
    %                     if usetype~=2
    %                         ph=patch([showt1(1) showt1(1) showt1(2) showt1(2)], [ytx(1) ytx(2) ytx(2) ytx(1) ],  [1 .9 .9]);
    %                         ph.FaceAlpha=.4;
    %                         ph.LineStyle= 'none';
    %                     end
    hold on
    %%%%
    shadedErrorBar(slideTimes, nanmean(dataINt,1), Ste, [usecol],1);
    %                     shadedErrorBar(plotERPtimes, mean(dataINt,1), Ste, [usecol],1);
    shg
    
    
    xlabel(['Time after auditory response [ms]']);
    ylabel(['p(Error) x ' ylabis])
    ylabel('Classifier and confidence correlation [r]');
    
    hold on; plot(xlim, [0 0 ], ['k:'], 'linew', 1)
    hold on; plot([0 0 ], ylim, ['k:'], 'linew', 1)
    set(gca, 'fontsize', 15)
    
    title(titlesare{itrialtype}, 'fontsize', 15)
    if idata==3
        title([titlesare{itrialtype} '+ subjcorr only'], 'fontsize', 15)
    end
    
    box on
    % add sig tests:
    %ttests
    pvals= nan(1, length(slideTimes));
    %
    for itime = 1:length(slideTimes)
        [~, pvals(itime)] = ttest(dataIN(:,itime, itrialtype));
        
        if pvals(itime)<.05
            text(slideTimes(itime), [-.2], '*', 'color', 'b','fontsize', 25);
            %                             text(slideTimes(itime), [-.07], '*', 'color', 'k','fontsize', 15);
        end
    end
    
    
    %%
    % add topoplot of discrim used to aid interpretation.
    %
    %         subplot(1,3,3)
    %         topoplot(mean(GFX_DecA_ScalpProj(:,:)), elocs);
    %         %             title(['Classifier trained [' num2str(DEC_Pe_windowparams.training_window_ms) ']']);
    %         set(gca, 'fontsize', 25)
    %
    %         set(gcf,'color', 'w')
    %%
    cd(figdir)
    cd('Classifier Results')
    cd('PFX_Trained on Correct part A, conf x sliding window part B');
    printname = ['GFX Dec A sliding window confidence correlaiton, for ' ordert ' corr only, nreps 10, test on ' dataprint];
    print('-dpng', printname)
    
end
%%

if job1.plotGFX_MS2==1
   cd(eegdatadir)
        cd('GFX')

        %load AUC for split:
        load('GFX_AUC_predicts_EEG', 'storeAUC'); % from plot_type2_AUCpersubj (jobs_BehaviouralAnalysis).
        g1= find(storeAUC<median(storeAUC));
        g2 = find(storeAUC>=median(storeAUC));
    applysplit=1; % to plot the results after median split (1-0).
        baselinetype=1;
        savename = savenamecell{baselinetype};
        %
        
        TESTondatatypes = {'resplocked', 'stimlocked', 'resplocked-stimbase'};
        testontype = 1;%:3%; of the above  -> each now saved with new name
        savenamenow = [savename '_test_' TESTondatatypes{testontype}];
    
        load(savenamenow);
    
    % %% what to plot?
    idata=3; 
    allData= {GFX_DECA_Conf_corr_slid, GFX_DECA_RT_corr_slid,GFX_DECA_Conf_Subjcorr_slid};
    ylabis= ylabsare{idata};
    dataIN= allData{idata};
    clf
    % corrects, errors, or all responses (within above datatypes)
    % note on the 4th plot , we will split by AUC
    subcounter=1;
    for itrialtype=1:3 
    titlesare= {'Correct trials', 'Errors (undetected)', 'All subjectively correct trials'};
    
    %
    cd(figdir)
    cd('Classifier Results');
    
    %
    
    figure(1); 
     set(gcf, 'color', 'w', 'units', 'normalized', 'position', [0.1 0.1 .8 .6]);
    subplot(2,2,subcounter)
     % plot results across participants:
    showt1 = [200, 350];
    
    ylabsare= {'confidence', 'rt', 'confidence'};
    
    ylimsAre= [-.1 .1; -.2 .2; -.1 .1];
    
    
    %
    dataINt = squeeze(dataIN(:,:,itrialtype));
    %                     ylabis ={['Classifier and ' compis ];['[r]']};
    
    % plot together or split
%     if applysplit==0
    usecols={'k', 'r', 'b'};    
    grsare= {1:size(dataINt,1), g1,g2};
    
    
    % plot each subset:
    isubs=1; % plot the total data first (each plot)
        
    Ste = CousineauSEM(dataINt(grsare{isubs},:));
    shadedErrorBar(slideTimes, nanmean(dataINt(grsare{isubs},:),1), Ste, [usecols{isubs}],1);
        
    ylim(ylimsAre(itrialtype,:))
    %place patches (as background) first:
    ytx= get(gca, 'ylim');
    hold on
    
    box on
    % add sig tests:
    %ttests
    pvals= nan(1, length(slideTimes));
    %
    for itime = 1:length(slideTimes)
        [~, pvals(itime)] = ttest(dataINt(grsare{isubs},itime));
        
        if pvals(itime)<.05
            text(slideTimes(itime), [ylimsAre(itrialtype,1)], '*', 'color', usecols{isubs},'fontsize', 25);
            %                             text(slideTimes(itime), [-.07], '*', 'color', 'k','fontsize', 15);
        end
    end
    
    
    subcounter=subcounter+1;
    
    
    xlabel(['Time after auditory response [ms]']);
    ylabel({['Classifier x ' ylabis ];['correlation [\itr\rm]']})
%     ylabel('Classifier and confidence correlation [r]');
    
    hold on; plot(xlim, [0 0 ], ['k:'], 'linew', 1)
    hold on; plot([0 0 ], ylim, ['k:'], 'linew', 1)
    set(gca, 'fontsize', 15)
    
    title(titlesare{itrialtype}, 'fontsize', 15)
    
    
    % if the last one, also plot AUC split.
    if itrialtype==2 % was 3
        subplot(2,2,4)
        shleg=[];
        for isubs=2:3 % plot the total data first (each plot)
            
            Ste = CousineauSEM(dataINt(grsare{isubs},:));
            sh=shadedErrorBar(slideTimes, nanmean(dataINt(grsare{isubs},:),1), Ste, [usecols{isubs}],1);
            sh.mainLine.LineWidth =2
            shleg(isubs-1)= sh.mainLine;
            
            ylim(ylimsAre(itrialtype,:))
            %place patches (as background) first:
            ytx= get(gca, 'ylim');
            hold on
            
            box on
            % add sig tests:
            %ttests
            pvals= nan(1, length(slideTimes));
            %
            for itime = 1:length(slideTimes)
                [~, pvals(itime)] = ttest(dataINt(grsare{isubs},itime));
                
                if pvals(itime)<.05
                    text(slideTimes(itime), [ylimsAre(itrialtype,1)], '*', 'color', usecols{isubs},'fontsize', 25);
                    %                             text(slideTimes(itime), [-.07], '*', 'color', 'k','fontsize', 15);
                end
            end
            
        end
        
    legend([shleg(1), shleg(2)], {'low AUROC2', 'high AUROC2'}, 'autoupdate','off')    
    end
    
    
    
    xlabel(['Time after auditory response [ms]']);
    ylabel({['Classifier x ' ylabis ];['correlation [\itr\rm]']})
%     ylabel('Classifier and confidence correlation [r]');
    
    hold on; plot(xlim, [0 0 ], ['k:'], 'linew', 1)
    hold on; plot([0 0 ], ylim, ['k:'], 'linew', 1)
    set(gca, 'fontsize', 15)
        title(titlesare{itrialtype}, 'fontsize', 15)

    
    end
    %%
    % add topoplot of discrim used to aid interpretation.
    %
    %         subplot(1,3,3)
    %         topoplot(mean(GFX_DecA_ScalpProj(:,:)), elocs);
    %         %             title(['Classifier trained [' num2str(DEC_Pe_windowparams.training_window_ms) ']']);
    %         set(gca, 'fontsize', 25)
    %
    %         set(gcf,'color', 'w')
    %%
    cd(figdir)
    cd('Classifier Results')
    cd('PFX_Trained on Correct part A, conf x sliding window part B');
    printname = ['GFX Dec A sliding window confidence correlaiton, for ' ordert ' corr only, nreps 10, test on ' dataprint];
    print('-dpng', printname)
    
end



