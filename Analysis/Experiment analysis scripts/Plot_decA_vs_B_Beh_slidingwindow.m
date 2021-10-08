% plot classifer trained on part B (C vs E), to predict confidence or RT
% with a sliding window analysis

%called from JOBS_ERPdecoder.m

cmap = flip(cbrewer('seq', 'RdPu', 5));

%% Note that this script can save a sliding window of classifier performance, correlated
% with RT or confidence in part B.

%amended 23/06/20 -MD


job1.calcandconcat_PFX =1;
job1.plotPFX=0;
job1.plotGFX=1;



elocs = readlocs('BioSemi64.loc');

normON = 1; % 0,1 ; normalize EEG data.
useAllorCorronly=2; %1,2;
plotRTorConf =1;  %1, 2 for GFX

TESTondatatypes = {'resplocked', 'stimlocked', 'resplocked-stimbase'};
%%
for usetype = 1%1:3; of the above ^
    
    
    %%
    if job1.calcandconcat_PFX ==1
        
        %         [GFX_DECA_Conf_corr_slid ,GFX_DECA_RT_corr_slid ]=deal(nan(length(pfols), 28));
        
        [GFX_DECA_Conf_corr_slid ,GFX_DECA_RT_corr_slid ]=deal([]);
        GFX_DecA_ScalpProj=nan(length(pfols), 64);
        GFX_ExpOrders=[];
        
        for ippant = 1:length(pfols)
            cd(eegdatadir)
            cd(pfols(ippant).name);
            %% load the Classifer and behavioural data:
            load('Classifier_objectivelyCorrect');
            load('participant TRIG extracted ERPs.mat');
            load('Epoch information.mat');
            %%
            %
            %how many iterations were used in classifier training?
            
            nIter = size(DEC_Pe_window.scalpproj,1);
            %% both or corr only?
            if useAllorCorronly==1
                partBindx = sort([errBindx,corBindx]);
            elseif useAllorCorronly==2
                partBindx = sort(corBindx); % correct only.
            end
            
            switch usetype
                case 1
                    partBdata = resplockedEEG(:,:,partBindx);
                case 2
                    partBdata = stimlockedEEG(:,:,partBindx);
                case 3
                    partBdata = resplockedEEG_stimbaserem(:,:,partBindx);
            end
            dataprint = TESTondatatypes{usetype};
            
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
            
            
            
            for iSLIDE = 1:2 % compare classifier output based on RT and confidence.
                
                % collect relevant behavioural data per ppant.
                switch iSLIDE
                    case 1
                        %note that confjmnts are from sure error - to sure correct.
                        
                        allBEH= zscore(abs([BEH_matched(partBindx).confj]));
                    case 2
                        %these RTs are incorrect (need to be adjusted, as
                        %in prev script).
                        allBEH= zscore([BEH_matched(partBindx).rt]);
                        %analysis:
                        
                        %remove RTs > 5s.
                        keepvec1 = allBEH<5;
                        
                        %adjust auditory RTs
                        if strcmpi(ExpOrder{1}, 'visual') % part B auditory RTs.
                            
                            %remove implausible values, any RTs recorded before second tone begins.
                            keepvec2 = allBEH >.6;
                            
                            %which trials to save overall?
                            keepvec = intersect(find(keepvec1),find(keepvec2));
                            %extract RTs and to start RT after second tone ONSET.
                            allBEH = allBEH(keepvec) - .6;
                            
                            
                        else % no adjustment for visual conf
                            keepvec = find(keepvec1);
                            allBEH = allBEH(keepvec); % no adjustment for visual RTs.
                        end
                        
                        % zscore for aross ppant comparison
                        allBEH= zscore(allBEH);
                        %ensure EEG is reduced to match:
                        partBdata = partBdata(:,:,keepvec);
                end
                [nchans, nsamps, ntrials] = size(partBdata);
                %before continuing, we want to apply the spatial discrim to each trial.
                %% we are using the decoder from part A (correct vs Errors)
                %note, use the average discrim vector!
                v = mean(DEC_Pe_window.discrimvector,1)';
                
                
                %                 v = DEC_Pe_window.discrimvector(1,:)'
                %we want to take the probability, when this decoder is applied to a
                %sliding window across part B epochs.
                testdata = reshape(partBdata, nchans, nsamps* ntrials)';%
                %% multiply data by classifier:
                %if using vector
                ytest_tmp = testdata* v(1:end-1) + v(end);
                %take the prob
                ytest_bp= bernoull(1,ytest_tmp);
                % reshape for single trial decoding
                ytest_trials = reshape(ytest_bp,nsamps,ntrials);
                
                %
%                 %% if using scalp proj.
%                 sc_v= mean(DEC_Pe_window.scalpproj,1);
%                 ytest_sc = testdata * sc_v';
%                 ytest_bp_sc= bernoull(1,ytest_sc);
%                 ytest_trials = reshape(ytest_bp_sc,nsamps,ntrials);%                 %% if using scalp proj.
%                 sc_v= mean(DEC_Pe_window.scalpproj,1);
%                 ytest_sc = testdata * sc_v';
%                 ytest_bp_sc= bernoull(1,ytest_sc);
%                 ytest_trials = reshape(ytest_bp_sc,nsamps,ntrials);

                %% debugging,
                %                 %% plot results using discrim vector and scalp proj.
                %                 figure(1); clf;
                %                 subplot(221)
                %                 plot(plotXtimes, mean(ytest_trials,2)); title('mean using discrim (v)');
                %                 subplot(222);
                %                 plot(plotXtimes, mean(ytest_trials_sc,2)); title('mean using scalp proj.');
                %                 subplot(223);
                %                 topoplot(v(1:64), elocs); title('mean vector,'); colorbar;
                %                 subplot(224);
                %                 sc_v= mean(DEC_Pe_window.scalpproj,1);
                %                 topoplot(sc_v, elocs); title('meanproj'); colorbar
                %
                
                
                %% now take correlation with confidence, in a sliding window:
                
                % set up the sliding window. 100ms window, 10 ms steps.
                movingwin = [.1, .01];
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
                
                
                %                  %% DEBUG plots
                %                  figure(2);
                %                  subplot(121);
                %                  plot(plotXtimes(winmid), outgoing); title('corr. using scalp');
                %%
                %                  subplot(122);
                %                  plot(plotXtimes(winmid), outgoing); title('corr. using sp');
                %% %% store output participants:
                if iSLIDE==1
                    GFX_DECA_Conf_corr_slid(ippant,:) = outgoing;
                else
                    GFX_DECA_RT_corr_slid(ippant,:) = outgoing;
                end
                
            end % iSLIDE
            
            GFX_DecA_ScalpProj(ippant,:) = mean(DEC_Pe_window.scalpproj,1);
            GFX_ExpOrders(ippant).d= ExpOrder;
            
            disp(['calc sliding window for ppant num ' num2str(ippant)]);
        end
        %save GFX level data
        cd(eegdatadir)
        cd('GFX')
     
        if useAllorCorronly==1
            GFX_DECA_RT_corr_slid_alltrials=GFX_DECA_RT_corr_slid;
            GFX_DECA_Conf_corr_slid_alltrials=GFX_DECA_Conf_corr_slid;
             
            save('GFX_DecA_slidingwindow_predictsB_Behav', ...            
            'GFX_DECA_RT_corr_slid_alltrials', ...
            'GFX_DECA_Conf_corr_slid_alltrials',... 
            'GFX_DecA_ScalpProj', 'GFX_ExpOrders', 'winmid', 'plotXtimes', '-append');
        elseif useAllorCorronly==2
             GFX_DECA_RT_corr_slid_corronly=GFX_DECA_RT_corr_slid;
            GFX_DECA_Conf_corr_slid_corronly=GFX_DECA_Conf_corr_slid;
         
            save('GFX_DecA_slidingwindow_predictsB_Behav', ...            
            'GFX_DECA_RT_corr_slid_corronly', ...
            'GFX_DECA_Conf_corr_slid_corronly',...    
            'GFX_DecA_ScalpProj', 'GFX_ExpOrders', 'winmid', 'plotXtimes', '-append');
        end
        
     
        
        
        
    end
    %%
    
    if job1.plotPFX==1
        % load if needed
        if ~exist('GFX_DECA_Conf_corr_slid','var')
            cd(eegdatadir);
            cd('GFX')
            load('GFX_DecA_slidingwindow_predictsB_Behav');
        end
        
        error(' plottng all or correct only? update script');
        %plot elements
        t=winmid/256; %Fs
        
        %output to figdir.
        cd(figdir)
        cd('Classifier Results')
        cd('PFX_Trained on Correct part A, conf x sliding window part B');
        
        dataprint = TESTondatatypes{usetype};
        
        
        % conf or RTs?
        dataIN= GFX_DECA_Conf_corr_slid;
        ytitle = 'Confidence- correct only';
        
        %         dataIN= GFX_DECA_RT_corr_slid;
        %         ytitle = 'RT- correct only';
        for ippant=1:length(pfols);
            
            % load ppant data
            plotme = GFX_DECA_Conf_corr_slid(ippant,:);
            plotscalp = GFX_DecA_ScalpProj(ippant,:);
            ExpOrder= GFX_ExpOrders(ippant).d;
            %%
            set(gcf, 'units', 'normalized', 'position', [0    1    1 1], 'color', 'w', 'visible', 'off');
            clf
            subplot(1,3,1:2)
            plot(plotXtimes(winmid),plotme, 'color', 'k', 'linew', 3);
            %             title({['P' num2str(ippant) ', Classifier trained on ERP A (C vs E) x ERP B'];[ExpOrder{1} '- ' ExpOrder{2} ]});
            xlabel(['Time [ms] after ' dataprint ' in part B']);
            ylabel({['DECODE x ' ytitle ];['[r]']})
            ylim([-.2 .2])
            hold on; plot(xlim, [0 0 ], ['k:'], 'linew', 2)
            hold on; plot([0 0 ], ylim, ['k:'], 'linew', 2)
            set(gca, 'fontsize', 15)
            
            subplot(133)
            topoplot(plotscalp, elocs);
            %             title([num2str(nIter) 'x Classifier trained [' num2str(DEC_Pe_windowparams.training_window_ms) ']'])
            set(gca, 'fontsize', 15)
            
            %
            printname = ['Participant ' num2str(ippant) ' Dec A sliding confidence corr',...
                ExpOrder{1} '- ' ExpOrder{2} ', ' dataprint  '(new)'];
            
            print('-dpng', printname)
            
        end
    end
    
    
    dataprint = TESTondatatypes{usetype};
    %%
    if job1.plotGFX==1
        
        %load if needed
        if ~job1.calcandconcat_PFX && ~exist('GFX_DECA_Conf_corr_slid','var')
            cd(eegdatadir);
            cd('GFX')
            load('GFX_DecA_slidingwindow_predictsB_Behav');
        end
        %%
        cd(figdir)
        cd('Classifier Results');
        
        if (plotRTorConf ==1 && useAllorCorronly==1)
            dataIN = GFX_DECA_RT_corr_slid_alltrials;
            
            compis= 'RTs';
            tis= 'All trials';
            usecol = 'k';
        elseif  plotRTorConf ==1 && useAllorCorronly==2;
            
            dataIN = GFX_DECA_RT_corr_slid_corronly;
            compis= 'RTs';
            tis= 'Correct only';
            usecol = 'k';
        elseif (plotRTorConf ==2 && useAllorCorronly==1)
            dataIN = GFX_DECA_Conf_corr_slid_alltrials;
            compis= 'Confidence';
            tis= 'All trials';
            usecol = 'b';
        elseif (plotRTorConf ==2 && useAllorCorronly==2)
            dataIN = GFX_DECA_Conf_corr_slid_corronly;
            compis= 'Confidence';
            tis= 'Correct only';
            usecol = 'b';
        end
            
        
        figure(1); clf; set(gcf, 'color', 'w', 'units', 'normalized', 'position', [0 0 1 1]);
        % plot results across participants:
        showt1 = [200, 350];
        
        figure(1); clf
        
        ordert= 'all combined';
        
        
        
        subplot(1,3,1:2)
        dataINt = dataIN;
        ylabis ={['Classifier and ' compis ];['[r]']};
        
        
        
        Ste = CousineauSEM(dataINt);
        
        
        set(gcf, 'color', 'w')
        ylim([-.1 .1])
        %place patches (as background) first:
        ytx= get(gca, 'ylim');
        hold on
        %plot topo patches (if not stimlocked EEG), to show the
        %training window used for the classifier.
        if usetype~=2
            ph=patch([showt1(1) showt1(1) showt1(2) showt1(2)], [ytx(1) ytx(2) ytx(2) ytx(1) ],  [1 .9 .9]);
            ph.FaceAlpha=.4;
            ph.LineStyle= 'none';
        end
        hold on
        %%%%
        shadedErrorBar(plotXtimes(winmid), mean(dataINt,1), Ste, [usecol],1);
        shg
        
        
        xlabel(['Time [ms] after ' dataprint ' in part B']);
        ylabel(ylabis)
        
        
        hold on; plot(xlim, [0 0 ], ['k:'], 'linew', 2)
        hold on; plot([0 0 ], ylim, ['k:'], 'linew', 2)
        set(gca, 'fontsize', 25)
        title(tis, 'fontsize', 20)
        
        box on
        % add sig tests:
        %ttests
        pvals= nan(1, length(winmid));
        %
        for itime = 1:length(winmid)
            [~, pvals(itime)] = ttest(dataIN(:,itime));
            
            if pvals(itime)<.05
                text(plotXtimes(winmid(itime)), [-.1], '*', 'color', 'k','fontsize', 25);
            end
        end
        
        %%
        % add topoplot of discrim used to aid interpretation.
        %
        subplot(1,3,3)
        topoplot(mean(GFX_DecA_ScalpProj(useppants,:)), elocs);
        %             title(['Classifier trained [' num2str(DEC_Pe_windowparams.training_window_ms) ']']);
        set(gca, 'fontsize', 25)
        
        set(gcf,'color', 'w')
        %%
        cd(figdir)
        cd('Classifier Results')
        cd('PFX_Trained on Correct part A, conf x sliding window part B');
        printname = ['GFX Dec A sliding window confidence correlaiton, for ' ordert ' corr only, nreps 10, test on ' dataprint];
        print('-dpng', printname)
        
    end
    %%
end

%% ID plot;
clf;
for ip=1:size(dataIN,1)
    
    plot(plotXtimes(winmid), dataIN(ip,:));
    hold on;
end

