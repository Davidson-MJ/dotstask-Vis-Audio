% plot classifer trained on part B (C vs E), to predict confidence.
%called from JOBS_ERPdecoder.m

elocs = readlocs('BioSemi64.loc');

cmap = flip(cbrewer('seq', 'RdPu', 5));
%%





job1.calcandconcat_PFX =1;

job1.plotPFX=0;
job1.plotGFX=1;





normON = 1; % normalize EEG data. (prior to applying classifier).



smoothON=1; % for final plot (not stats)

%%
if job1.calcandconcat_PFX ==1


   GFX_DECA_Pe_Conf_Bsplit=[];    
   GFX_DecA_ScalpProj=nan(length(pfols), 64);

    for ippant = 1:length(pfols)
        cd(eegdatadir)
        cd(pfols(ippant).name);
        %% load the Classifer and behavioural data:
        load('Classifier_trained_A_resp_Pe_window.mat');
        load('participant EEG preprocessed.mat');
        load('Epoch information.mat');
        %%
        %
        PFX_classifier_onERPsplit=[];

        DEC_x_rlEEG =[];% zeros(size(ytest_trials,1), 2);
        for ilist= 1:3
            switch ilist
                case 1
                    partBindx = sort([corBindx]);
                case 2
                      partBindx = sort([errBindx]);
                case 3
                    tmptrials= zeros(1,size(resplockedEEG,3));
                    tmptrials(corBindx)=1;
                    tmptrials(errBindx)=1;

                    truth= zeros(1,length(tmptrials));
                    truth(errBindx)=1;
                    %back to indx.
                    partBindx= find(tmptrials);
                    truth= truth(partBindx);
            end

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
        vtime = squeeze(mean(DEC_Pe_window.discrimvector,1))'; % take mean over iterations

        %we want to take the probability, when this decoder is applied to a
        %sliding window across part B epochs.
%         testdata = reshape(partBdata, nchans, nsamps* ntrials)';%
        %% multiply data by classifier:

        % for each point in the sliding window, (or one point, multiply
        % classifier).

            testdataON = reshape(partBdata, nchans, nsamps* ntrials)';%
            %%
            ytest = testdataON * vtime(1:end-1) + vtime(end);
            %convert to prob:
                                    bptest = bernoull(1,ytest);
            %% reshape for plotting.

                                    bptest = reshape(bptest, nsamps, ntrials);

            % reshape for single trial decoding

            ytest_trials = reshape(ytest,nsamps,ntrials);

            % store for averaging over each iteration.
%             PFX_classifier_onERPsplit = ytest_trials;
            PFX_classifier_onERPsplit = bptest;


     

        %% now take terciles of confidence:

%       quants = quantile(zconfj, [3]); %quartiles
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

    if quants==max(zconfj)
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
%        
        for iterc=1:length(terclists)

            try
            %take mean corr ERP for this tercile:
            tempERP = squeeze(nanmean(PFX_classifier_onERPsplit(:,terclists(iterc).list),2));
            %% now store:
            DEC_x_rlEEG(:,iterc,ilist) =tempERP;

            % unless we can take AUC:

            if ilist==3
                for itime= 1:size(PFX_classifier_onERPsplit,1)

                    [Az,Ry,Rx] = rocarea(PFX_classifier_onERPsplit(itime,terclists(iterc).list),truth(terclists(iterc).list));
                    DEC_x_rlEEG(itime,iterc,ilist) =Az;

                end
            end


            
            catch
                DEC_x_rlEEG (:,iterc,ilist) =repmat(nan, [1, size(PFX_classifier_onERPsplit,1)]);

            end
        end % each tercile/quantile.
        end 
        % after corrects and errors, we can also combine in the third dimension for
        %overall performance split by confidence.
        % % similar to how we plot the Pe GFX.
%          tmpComb= squeeze(DEC_x_rlEEG(:,:,2))+ (.5-squeeze(DEC_x_rlEEG(:,:,1)));
           
%          subplot(131);
%          plot(squeeze(DEC_x_rlEEG(:,:,1))); title('corr x conf');
% 
%          subplot(132);
%          plot(squeeze(DEC_x_rlEEG(:,:,2))); title('err x conf');
%           
%          subplot(133);
%         
%           plot(squeeze(DEC_x_rlEEG(:,:,3))); title('AUC x conf');
%         
% %          subplot(133);
%          plot(tmpComb); title('all x conf');
% DEC_x_rlEEG(:,:,3)= tmpComb;
        %% store output participants:
        GFX_DECA_Pe_Conf_Bsplit(ippant,:,:,:) = DEC_x_rlEEG;
        GFX_DecA_ScalpProj(ippant,:) = mean(DEC_Pe_window.scalpproj,1);
%         GFX_ExpOrders(ippant).d= ExpOrder;

        disp([' Fin calc conf split for decA on resp B... ppant ' num2str(ippant)]);
    end

    cd(eegdatadir)
    cd('GFX')
    save('GFX_DecA_Pe_predicts_Confidencesplit_normERPs', 'GFX_DECA_Pe_Conf_Bsplit', 'GFX_DecA_ScalpProj');

end
if job1.plotPFX==1
    if ~exist('GFX_DECA_Pe_Conf_Bsplit','var')
        cd(eegdatadir);
        cd('GFX')
        load('GFX_DecA_Pe_predicts_Confidencesplit');
    end

    cd(figdir)
    cd('Classifier Results')
    cd('PFX_Trained on resp Errors in part A x part B conf split');
    %%
    figure(1)
    set(gcf, 'units', 'normalized', 'position',[0.1 0.1 .7 .7], 'color', 'w', 'visible', 'on');
    cmap= cbrewer('seq', 'Purples',10);
       colsare= cmap(5:10,:);
       nQuants= size(GFX_DECA_Pe_Conf_Bsplit,3);
    %%
    for ippant = 1:length(pfols);

        clf
        plotdata = squeeze(GFX_DECA_Pe_Conf_Bsplit(ippant,:,:));
        plotscalp = GFX_DecA_ScalpProj(ippant,:);
        legh=[];
       for iterc=1:nQuants
        subplot(1,3,1:2)
       legh(iterc)= plot(plotERPtimes, plotdata(:,iterc), 'color', colsare(iterc,:), 'linew', 3); hold on
       end
%         %%
        title({['P' num2str(ippant) ', Classifier trained on visual Pe  x ERP B (corr only)']});
        xlabel(['Time [ms] after response in part B']);
        ylabel('Accuracy ')
%         ylim([.2 .8])
ylim([-.5 .5])
% axis tight
        hold on; plot(xlim, [0.5 0.5 ], ['k:'], 'linew', 2)
        hold on; plot([0 0 ], ylim, ['k:'], 'linew', 2)
        set(gca, 'fontsize', 15)
        if nQuants==4
        legend(legh, {'lowest', 'low',' higher', 'highest conf'})
        else
        legend(legh, {'low conf', 'high conf'})
        end

        %%
        subplot(1,3,3)
        topoplot(plotscalp, elocs);
        title(['Classifier trained [' num2str(DEC_Pe_windowparams.training_window_ms) ']'])
        set(gca, 'fontsize', 15)

        %%
shg;
        set(gcf, 'color', 'w')
        printname = ['Participant ' num2str(ippant) ' classifier A resp (Pe) x ERP B (corrects by confidence) normERPs'];
        print('-dpng', printname)
    end % ppant
end % job

if job1.plotGFX==1
    %% plot results across participants:
    for iorder =1%:3
        
        figure(1); clf
        set(gcf, 'units', 'normalized', 'position',[0.1 0.1 .7 .7], 'color', 'w', 'visible', 'on');
        lgh=[];


        nQuants= size(GFX_DECA_Pe_Conf_Bsplit,3);
        dtypes={'correct', 'error', 'all'};

        colsAre= {'r', 'b'};

      for idata= 1:size(GFX_DECA_Pe_Conf_Bsplit,4)
          
          dataIN = GFX_DECA_Pe_Conf_Bsplit(:,:,:, idata); % Corrects, errors, combiend.
        
          if smoothON==1
              winsizet = dsearchn(plotERPtimes', [0 40]'); % 100ms smooth window.
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

              subplot(1,3,idata)
              set(gcf, 'color', 'w')
              sh= shadedErrorBar(plotERPtimes, nanmean(dataIN(:,:,iterc),1), Ste, {'color', colsAre{iterc}},1);
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
        title({['Trained vis (Pe): test aud ' dtypes{idata}]}, 'fontsize', 12)
        %
        % add sig tests:
        %ttests
        pvals= nan(1, length(plotERPtimes));

        for itime = 1:length(plotERPtimes)
            [~, pvals(itime)] = ttest(dataIN(:,itime,1),dataIN(:,itime,2));

            if pvals(itime)<.05 && plotERPtimes(itime)>0
                text(plotXtimes(itime), [.41], '*', 'color', 'k','fontsize', 25, 'HorizontalAlignment', 'center');
            end
        end
      end
%         xlim([-200 600])
        %%
        % add topoplot of discrim used to aid interpretation.
figure(2);
%         subplot(1,3,3)
        topoplot(mean(GFX_DecA_ScalpProj(useppants,:)), elocs);
        title(['Classifier trained [' num2str(DEC_Pe_windowparams.training_window_ms) ']']);
        set(gca, 'fontsize', 12)

        set(gcf,'color', 'w')
        %%
      cd(figdir)
    cd('Classifier Results')
    cd('PFX_Trained on resp Errors in part A x part B conf split');
        printname = ['GFX classifier A resp (Pe) x ERP B (corrects by confidence)'];
        print('-dpng', printname);
    end
end
%%
