% plot classifer trained on part B (C vs E), to predict confidence.
%called from JOBS_ERPdecoder.m
getelocs;
cmap = flip(cbrewer('seq', 'RdPu', 5));
%%





job1.calcandconcat_PFX =1; % using correlation
job1.plotGFX=1;





normON = 0; % normalize EEG data.





%%
if job1.calcandconcat_PFX ==1
    
    
    set(gcf, 'units', 'normalized', 'position', [-0.5151    0.1380    0.5000    0.5512], 'color', 'w');
    
    GFX_DECA_RTs_slid =nan(length(pfols), 28);
    GFX_DecA_ScalpProj=nan(length(pfols), 64);
    
    for ippant = 1:length(pfols)
        cd(basedir)
        cd(pfols(ippant).name);
        %% load the Classifer and behavioural data:
        load('Classifier_objectivelyCorrect');
        load('participant TRIG extracted ERPs.mat');
        load('Epoch information.mat');
        %%
        %
        % correct only!
        partAindx = sort([corAindx]);
        
        partAdata = resplockedEEG(:,:,partAindx);
        [nchans, nsamps, ntrials] =size(partAdata);
        
        
        if normON==1
            data_norm = zeros(size(partAdata));
            for ichan = 1:nchans
                for itrial=1:ntrials
                    temp = partAdata(ichan,:,itrial);
                    % rescale
                    temp=temp-(0.5*(min(temp)+max(temp)));
                    if(min(temp)~=max(temp))
                        temp=temp/max(temp);
                    end
                    
                    data_norm(ichan,:,itrial) = temp;
                end
            end
            partAdata= data_norm;
        end
        
        %%
        % collect RTs for this dataset
        allRTs= zscore([alltrials_matched(partAindx).rt]);
        alltruths = [alltrials_matched(partAindx).cor];
        
        
        %as an extra step, since we had the bug, only look at RTs outside bug
        %window.
        
        %before continuing, we want to apply the spatial discrim to each trial.
        
        %% now take ROC, for terciles based on RT.
        %now take terciles, based on conf judgements:
        quants = quantile(allRTs, 3);
        
        %now we have all the data, and confidence rows per quartile:
        %         %split into terciles:
        %         %lowest
        t1 = find(allRTs<quants(1));
        %         %middle
        t2a = find(allRTs>=quants(1));
        t2b = find(allRTs<quants(2));
        t2= intersect(t2a, t2b);
        %         %highest
        t3 = find(allRTs>=quants(2));
        
        %store for easy access.
        terclists(1).list = t1;
        terclists(2).list = t2;
        terclists(3).list = t3;
        
        %% we are using the decoder from part A (correct vs Errors)
        % prepare classifier analysis.
        v = DEC_Pe_window.discrimvector;
        %reshape
        testdata = reshape(partAdata, nchans, nsamps* ntrials)';%
        %%
        for iterc=1:3            %compare for subsets of trials based on RT.
            
            tmpdata = partAdata(:,:, terclists(iterc).list);
            %reshape
            tmpIN = tmpdata(:,:)';
            %% multiply data by classifier:
            ytest_tmp = tmpIN* v(1:end-1) + v(end);
            
            %take the prob
            ytest_bp= bernoull(1,ytest_tmp);
            
            %
            %construct 'truth' values for ROC curve.
            truths_tmp = alltruths(terclists(iterc).list);
            truthval= [];
            for itrial = 1:length(truths_tmp)
                
                if truths_tmp(itrial) ==1
                    truthvaltmp=[ones(trainingwindowlength,1)];
                    
                    
                    subplot(2,3,iterc); rocarea(ytest_bp,truths_tmp);
                    
                    
                    % reshape for single trial decoding
                    %     ytest_trials = reshape(ytest_tmp,nsamps,ntrials);
                    %
                    %            tmp_prob = squeeze(ytest_trials(:, terclists(iterc).list));
                    %            %reshape:
                    %            tmp_in = tmp_prob(:,:)';
                    %
                    %
                end
                
            end
        end
                %%
                set(gcf, 'units', 'normalized', 'position',[-.5 0 .5 .5], 'color', 'w');
                clf
                subplot(1,3,1:2)
                plot(plotXtimes(winmid),outgoing, 'color', 'k', 'linew', 3);
                title({['P' num2str(ippant) ', Classifier A (C vs E) x rt in A'];[ExpOrder{1} '- ' ExpOrder{2} ]});
                xlabel(['Time [ms] after response in part B']);
                ylabel('prob x rt, correlation, [r]')
                ylim([-.2 .2])
                hold on; plot(xlim, [0 0 ], ['k:'], 'linew', 2)
                hold on; plot([0 0 ], ylim, ['k:'], 'linew', 2)
                set(gca, 'fontsize', 15)
                
                subplot(1,3,3)
                topoplot(DEC_Pe_window.scalpproj, biosemi64);
                title(['Classifier trained [' num2str(DEC_Pe_windowparams.training_window_ms) ']'])
                set(gca, 'fontsize', 15)
                shg
                %%
                
                
                cd(basedir);
                cd ../../Figures/
                cd('Classifier Results')
                cd('PFX_Trained on Correct part A, RTs x sliding window part A');
                printname = ['Participant ' num2str(ippant) ' Dec A sliding window RT correlaiton' ExpOrder{1} '- ' ExpOrder{2}];
                print('-dpng', printname)
                
                
                %% store output participants:
                GFX_DECA_RTs_slid(ippant,:) = outgoing;
                GFX_DecA_ScalpProj(ippant,:) = DEC_Pe_window.scalpproj;
            end
            save('GFX_DecA_slidingwindow_predictsRTs', 'GFX_DECA_RTs_slid', 'GFX_DecA_ScalpProj', 'winmid', 'plotXtimes');
            
        end
        %%
        if job1.plotGFX==1
            %% plot results across participants:
            for iorder =1%:3
                figure(1); clf
                set(gcf, 'units', 'normalized', 'position', [-0.5151    0.1380    0.5000    0.5512], 'color', 'w');
                switch iorder
                    case 1
                        useppants = vis_first;
                        ordert='visual-audio';
                    case 2
                        useppants = aud_first;
                        ordert= 'audio-visual';
                    case 3
                        useppants = 1:size(GFX_DECA_RTs_slid,1);
                        ordert= 'all combined';
                end
                
                dataIN = squeeze(GFX_DECA_RTs_slid(useppants,:));
                
                Ste = CousineauSEM(dataIN);
                
                subplot(1,3,1:2)
                set(gcf, 'color', 'w')
                ylim([-.1 .075])
                %add patch as background first:
                %plot topo patches, showing the training window used.
                ytx= get(gca, 'ylim');
                showt1= DEC_Pe_windowparams.training_window_ms;
                ph=patch([showt1(1) showt1(1) showt1(2) showt1(2)], [ytx(1) ytx(2) ytx(2) ytx(1) ],  [1 .9 .9]);
                ph.FaceAlpha=.4;
                ph.LineStyle= 'none';
                hold on
                
                box on
                shadedErrorBar(plotXtimes(winmid), mean(dataIN,1), Ste, ['k'],1);
                shg
                
                
                xlabel(['Time [ms] after response in part A']);
                ylabel('Part A (prob) and RTs [r]')
                
                hold on; plot(xlim, [0 0 ], ['k:'], 'linew', 2)
                hold on; plot([0 0 ], ylim, ['k:'], 'linew', 2)
                set(gca, 'fontsize', 25)
                % title({['Classifier trained on ERP A (C vs E) x ERP B'];[ordert ', n=' num2str(length(useppants))]}, 'fontsize', 20)
                title('')
                % add sig tests:
                %ttests
                pvals= nan(1, length(winmid));
                
                for itime = 1:length(winmid)
                    [~, pvals(itime)] = ttest(dataIN(:,itime));
                    
                    if pvals(itime)<.05
                        text(plotXtimes(winmid(itime)), [-0.1], '*', 'color', 'k','fontsize', 25);
                    end
                end
                % add topoplot of discrim used to aid interpretation.
                
                subplot(1,3,3)
                topoplot(mean(GFX_DecA_ScalpProj(useppants,:)), biosemi64);
                title({['Part A classifier projection ']});%;[ num2str(DEC_Pe_windowparams.training_window_ms) ]});
                
                set(gca, 'fontsize', 20)
                
                set(gcf,'color', 'w')
                %%
                cd(basedir);
                cd ../../Figures/
                cd('Classifier Results')
                cd('PFX_Trained on Correct part A, RTs x sliding window part A');
                printname = ['GFX Dec A sliding window RT A correlaiton, for ' ordert ', correct +error'];
                print('-dpng', printname)
            end
        end
        %%
