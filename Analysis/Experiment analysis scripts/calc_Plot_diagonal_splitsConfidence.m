% plot classifer trained on part B (C vs E), to predict confidence.
%called from JOBS_ERPdecoder.m
% function calc_Plot_diagonal_splitsConfidence(cfg);
elocs = readlocs('BioSemi64.loc');

cmap = flip(cbrewer('seq', 'RdPu', 5));
%%




%     cfg.crunchPPant = 1;
%     cfg.justplot= 1;

% job1.calcandconcat_PFX = cfg.crunchPPant;
% 
% job1.plotPFX=cfg.plotPFX;
% job1.plotGFX=cfg.plotGFX;



job1.calcandconcat_PFX = 1;

job1.plotPFX=0;
job1.plotGFX=0;





normON = 1; % normalize EEG data. (prior to applying classifier).



pfols = cfg.pfols;

loadname = ['Classifier_trained_' cfg.expPart '_' cfg.EEGtype '_diagonal.mat'];

%%
if job1.calcandconcat_PFX ==1



    GFX_DEC_Conf_Bsplit=[];

    for ippant = 1:length(pfols)
        cd(eegdatadir)
        cd(pfols(ippant).name);
        %% load the Classifer and behavioural data:
        load(loadname);
        load('participant EEG preprocessed.mat', 'resplockedEEG', 'plotERPtimes');
        load('Epoch information.mat');
        %%
        %
        Xtimes = DECout_diagonal_window.trainingwindow_centralms  ;
        DEC_x_rlEEG =[];% zeros(size(ytest_trials,1), 2);


         for ilist= 1:2
            switch ilist
                case 1
                    partBindx = sort([corBindx]);
                case 2
                      partBindx = sort([errBindx]);
            end

        PFX_classifier_onERPsplit=[]; % changes size based on ntrials.

        partBdata = resplockedEEG(:,:,partBindx);
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


        %%
        % collect confj for this dataset
        %confidence is from sure incorrect (neg) to sure correct (pos).
        zconfj= zscore([BEH_matched.confj{partBindx}]);

        %before continuing, we want to apply the spatial discrim to each trial.
        %% we are using the decoder from part A (correct vs Errors)
    
        %we want to take the probability, when this decoder is applied to a
        %sliding window across part B epochs.
%         testdata = reshape(partBdata, nchans, nsamps* ntrials)';%
        %% multiply data by classifier:

        % for each point in the sliding window, (or one point, multiply
        % classifier).

        useDATA= partBdata;
        for iwin = 1:length(DECout_diagonal_window.trainingwindow_centralms);

            %this v
            vtime = squeeze(mean(DECout_diagonal_window.discrimvector_perTime(:,iwin,:),1));
            %samps trained:
            nwinsamps = DECout_diagonal_window.trainingwindow_frames(iwin,:);
            %        sampsize= nsamps(2)-nsamps(1);
            %so extract only self tested window:
            testON= useDATA(:,nwinsamps (1):nwinsamps(2),:);
            %reshape for matrix mult.
            [nchans, sampsize, ntrials] =size(testON);

            testdataON = reshape(testON, nchans, sampsize* ntrials)';%
            %%
            ytest = testdataON * vtime(1:end-1) + vtime(end);
            %convert to prob:
                                    bptest = bernoull(1,ytest);
            %% reshape for plotting.

                                    bptest = reshape(bptest, sampsize, ntrials);

            % reshape for single trial decoding

            ytest_trials = reshape(ytest,sampsize,ntrials);

            % store for averaging over each iteration. % mean over the
            % samples of this sliding window:
            PFX_classifier_onERPsplit(iwin,:) = mean(bptest,1);
%              PFX_classifier_onERPsplit(iwin,:) = mean(bptest,1);


        end %
     

        %% now take terciles of confidence:

      quants = quantile(zconfj, [3]); %quartiles
        quants= quantile(zconfj, [.5]); % median split
        terclists=[];

        if length(quants)>1
        if diff(quants)==0 % can't separate into terciles.
            %instead,  save as high/low after median split.
            %just skip
%             continue
              quants = quantile(zconfj, [.5]);
               t1 = nan;
               t2 = find(zconfj<=quants(1));
               t3= find(zconfj>quants(1));
               t4 = nan;
            disp(['Warning: using median split for ppant ' num2str(ippant)]);   
        else
            
        %now we have all the data, and confidence rows per quartile:
        %split EEEG into terciles:
        %lowest
        t1 = find(zconfj<=quants(1));
        %middle
        t2a = find(zconfj>quants(1));
        t2b = find(zconfj<=quants(2));
        t2= intersect(t2a, t2b); 
        %next
        t3a = find(zconfj>quants(2));
        t3b = find(zconfj<=quants(3));
        t3= intersect(t3a, t3b); 
        
        %highest
        t4 = find(zconfj>quants(3));
        end

        %store for easy access.
        terclists(1).list = t1;
        terclists(2).list = t2;
        terclists(3).list = t3;
        terclists(4).list = t4; 
        else
    % MEDIAN SPLIT:


    if quants == max(zconfj)
    
         t1 = find(zconfj<quants(1));
         t2 = find(zconfj>=quants(1));
    else
         t1 = find(zconfj<=quants(1));
         t2 = find(zconfj>quants(1));
         
    end
      terclists(1).list = t1;
        terclists(2).list = t2;
        end

        %now for each tercile, take the mean EEG
        %%
        for iterc=1:length(terclists)

            try
                %take mean corr ERP for this tercile:
                tempERP = squeeze(nanmean(PFX_classifier_onERPsplit(:,terclists(iterc).list),2));
                %% now store:
                DEC_x_rlEEG (:,iterc, ilist) =tempERP;
            catch
                DEC_x_rlEEG (:,iterc, ilist) =repmat(nan, [1, size(PFX_classifier_onERPsplit,1)]);;

            end
        end % each tercile/quantile.
         end % each list.

         % after corrects and errors, we can also combine in the third dimension for
        %overall performance split by confidence.
        % % similar to how we plot the Pe GFX.
         tmpComb= squeeze(DEC_x_rlEEG(:,:,2))+ (.5-squeeze(DEC_x_rlEEG(:,:,1)));
%            
clf
         subplot(131);
         plot(squeeze(DEC_x_rlEEG(:,:,1))); title('corr x conf');

         subplot(132);
         plot(squeeze(DEC_x_rlEEG(:,:,2))); title('err x conf');
        

         subplot(133);
         plot(tmpComb); title('all x conf');
DEC_x_rlEEG(:,:,3)= tmpComb;
        %% store output participants:
        GFX_DEC_Conf_Bsplit(ippant,:,:,:) = DEC_x_rlEEG;
        GFX_DEC_ScalpProj(ippant,:,:,:) = squeeze(mean(DECout_diagonal_window.scalpproj_perTime,1));
%         GFX_ExpOrders(ippant).d= ExpOrder;

        disp([' Fin calc conf split for decA on resp B... ppant ' num2str(ippant)]);
    end
%%
    cd(eegdatadir)
    cd('GFX')
    save(['GFX_Dec' cfg.expPart '_predictsConfidencesplit'], 'GFX_DEC_Conf_Bsplit', 'GFX_DEC_ScalpProj', 'plotERPtimes');

end
if job1.plotPFX==1
    if ~exist('GFX_DECA_Conf_corr_slid','var')
        cd(eegdatadir);
        cd('GFX')
        load(['GFX_Dec' cfg.expPart '_predictsConfidencesplit']);
    end

    cd(figdir)
    cd('Classifier Results')
    cd(['PFX_Trained on ' cfg.EEGtype ' Errors in part ' cfg.expPart ' x part B conf split']);
    %%
    figure(1)
    set(gcf, 'units', 'normalized', 'position',[0.1 0.1 .7 .7], 'color', 'w', 'visible', 'off');
    cmap= cbrewer('seq', 'Purples',10);
       colsare= cmap(5:10,:);
    %%
    for ippant = 1:length(pfols);

        clf
        plotdata = squeeze(GFX_DEC_Conf_Bsplit(ippant,:,:));
        plotscalp = GFX_DEC_ScalpProj(ippant,:);
        legh=[];
       for iterc=1:4
        subplot(1,3,1:2)
       legh(iterc)= plot(Xtimes, plotdata(:,iterc), 'color', colsare(iterc,:), 'linew', 3); hold on
       end
%         %%
        title({['P' num2str(ippant) ', Classifier trained on visual (diagonal)  x ERP B (corr only)']});
        xlabel(['Time [ms] after response in part B']);
        ylabel('Accuracy ')
        ylim([.2 .8])
% ylim([-.5 .5])
% axis tight
        hold on; plot(xlim, [0.5 0.5 ], ['k:'], 'linew', 2)
        hold on; plot([0 0 ], ylim, ['k:'], 'linew', 2)
        set(gca, 'fontsize', 15)
        legend(legh, {'lowest', 'low',' higher', 'highest conf'})
        %%
         topotimes = [-200 0; 200 400; 600 800];
        for itimes= 1:3
            avOver = dsearchn(Xtimes', [topotimes(itimes,:)]');

            % add patch?
        subplot(3,3,3*itimes)
        tData= squeeze(mean(GFX_DEC_ScalpProj(ippant,avOver(1):avOver(2),:),2));
        topoplot(tData, elocs);
        title(['time: ' num2str(topotimes(itimes,:))]);
        set(gca, 'fontsize', 10)
        c=colorbar;
%         caxis([-.02 .02])
        end
        %%
shg;
        set(gcf, 'color', 'w')
        printname = ['Participant ' num2str(ippant) ' classifier A resp (diagonal) x ERP B (corrects by confidence)'];
        print('-dpng', printname)
    end % ppant
end % job

if job1.plotGFX==1
    %% plot results across participants:
    
       figure(1); clf
        set(gcf, 'units', 'normalized', 'position',[0.1 0.1 .7 .7], 'color', 'w', 'visible', 'on');
        lgh=[];


        nQuants= size(GFX_DEC_Conf_Bsplit,3);
        dtypes={'correct', 'error', 'all'};

        colsAre= {'r', 'b'};

      for idata= 1:size(GFX_DEC_Conf_Bsplit,4)
          
          dataIN = GFX_DEC_Conf_Bsplit(:,:,:, idata); % Corrects, errors, combiend.
        
          if smoothON==1
              winsizet = dsearchn(Xtimes', [0 40]'); % 100ms smooth window.
              winsize = diff(winsizet);
              dataout= zeros(size(dataIN));
              for isubj=1:size(dataIN,1)
                  for iterc= 1:size(dataIN,3)
                      dataout(isubj,:,iterc) = smooth(squeeze(dataIN(isubj,:, iterc)), winsize);
                  end
              end
              dataIN=dataout;
              disp(['HAVE SMOOTHED at participant level!']);
          end


          for iterc=1:nQuants

              Ste = CousineauSEM(dataIN(:,:,iterc));

              subplot(1,4,idata)
              set(gcf, 'color', 'w')
              sh= shadedErrorBar(Xtimes, nanmean(dataIN(:,:,iterc),1), Ste, {'color', colsAre{iterc}},1);
              sh.mainLine.LineWidth= 1;
              lgh(iterc) = sh.mainLine;
              shg
              hold on
          end

          if nQuants==2
        legend([lgh], {'low confidence', 'high confidence'},'autoupdate', 'off');
          else
legend([lgh], {'lowest confidence', 'lower confidence',...
            'higher confidence', 'highest confidence'}, 'autoupdate', 'off');
          end
        xlabel(['Time [ms] after response in part B']);
        ylabel('p(Error)')
        ylim([.4 .6])
% ylim([-.5 .5])
        hold on; plot(xlim, [.5 .5 ], ['k:'], 'linew', 2)
        hold on; plot([0 0 ], ylim, ['k:'], 'linew', 2)
        set(gca, 'fontsize', 12)
        title({['Trained vis (diagonal):'];['test aud ' dtypes{idata}]}, 'fontsize', 12)
        %
        % add sig tests:
        %ttests
        pvals= nan(1, length(Xtimes));

        for itime = 1:length(Xtimes)
            [~, pvals(itime)] = ttest(dataIN(:,itime,1),dataIN(:,itime,2));

            if pvals(itime)<.05 && Xtimes(itime)>0
                text(plotXtimes(itime), [.41], '*', 'color', 'k','fontsize', 25, 'HorizontalAlignment', 'center');
            end
        end
      end
%         xlim([-200 600])
        %%
        % add topoplot of discrim used to aid interpretation.
% figure(2);
tspots= [4,8,12];
topotimes= [-400 -200; 0 200; 300 500];
for itopo=1:3        
subplot(3,4,tspots(itopo))
ttimes= dsearchn(Xtimes', topotimes(itopo,:)')
topoData= squeeze(mean(GFX_DEC_ScalpProj(:, ttimes(1):ttimes(2),:),2));
        topoplot(mean(topoData,1), elocs);
        title(['Classifier @ [' num2str(topotimes(itopo,:)) ']']);
        set(gca, 'fontsize', 12)
end

        set(gcf,'color', 'w')
        %%
        cd(figdir)
        cd('Classifier Results')
        cd('PFX_Trained on Correct part A, conf x part B conf split');
        printname = ['GFX Dec A predicts confidence split, for ' ordert '(new)'];
        print('-dpng', printname)
    
end
%%
