% plot classifer trained on part B (C vs E), to predict confidence or RT
% with a sliding window analysis

%called from JOBS_ERPdecoder.m

cmap = flip(cbrewer('seq', 'RdPu', 5));

%% Note that this script can save a sliding window of classifier performance, correlated
% with RT or confidence in part B.

%amended 23/06/20 -MD


job1.calcandconcat_PFX =0;
job1.plotPFX=0;
job1.plotGFX=1;
permTest=0;


elocs = readlocs('BioSemi64.loc');

normON = 1; % 0,1 ; normalize EEG data.
plotRTorConf =2;  %1, 2 for GFX
smoothON=1;

pfols = cfg.pfols;

%loadname determined by type.
train_name = ['Classifier_trained_' cfg.expPart_train '_' cfg.EEGtype_train '_diagonal'];
savename = ['Classifier_trained_' cfg.expPart_train '_' cfg.EEGtype_train '_tested_' cfg.expPart_test '_' cfg.EEGtype_test ' timegen_predictsB_Behav'];

if strcmp(cfg.expPart_train, 'A');
    modtrain= '\bfvisual\rm';
else
    modtrain= '\bfauditory\rm';
end
if strcmp(cfg.expPart_test, 'A');
    modtest= '\bfvisual\rm';
else
    modtest= '\bfauditory\rm';
end
%%
if job1.calcandconcat_PFX ==1

    %         [GFX_DECA_Conf_corr_slid ,GFX_DECA_RT_corr_slid ]=deal(nan(length(pfols), 28));

    [GFX_DECA_Conf_corr_slid ,GFX_DECA_RT_corr_slid,GFX_DECA_RT_Subjcorr_slid ]=deal([]);
    GFX_DecA_ScalpProj=nan(length(pfols), 64);


    for ippant = 1:length(pfols)
        cd(eegdatadir)
        cd(pfols(ippant).name);
        %% load the Classifer and behavioural data:
        load(train_name);
        DEC_trainer = DECout_diagonal_window; % this has a discrim vector for each time point.

        load('participant EEG preprocessed');
        load('Epoch information.mat');

        if strcmp(cfg.EEGtype_test, 'stim')
            testEEG = stimlockedEEG;

        else
            testEEG = resplockedEEG;
        end
        %%
        %
        %how many iterations were used in classifier training?
        Xtimes = DECout_diagonal_window.trainingwindow_centralms  ;
        %how many times was the classifier repeated?
        nIterations = size(DEC_trainer.scalpproj_perTime,1);

        %% use the vector and untrained trials:
        if strcmp(cfg.expPart_test, 'A')
            test_corIndx = corAindx;
            test_errIndx= errAindx;

        else
            test_corIndx = corBindx;
            test_errIndx= errBindx;


        end

        %% both or corr only?
        for ilist=1:3
            switch ilist
                case 1
                    partBindx = sort(test_corIndx);
                case 2
                    partBindx = sort(test_errIndx); %
                case 3
                    partBindx= sort([test_corIndx; test_errIndx]);
            end


            partBdata= testEEG(:,:,partBindx);


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

                disp(['sliding DV ' num2str(iSLIDE)]);
                
                % collect relevant behavioural data per ppant.
                switch iSLIDE
                    case 1
                        %note that confjmnts are from sure error - to sure correct.

                        allBEH= zscore(abs([BEH_matched.confj{partBindx}]));
                        % why abs?
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

                % note, use the average discrim vector, and here a sliding
                % window approach:
                PFX_classifier_timegen_ERP=[];

                % for each trained window, test on all;
                for iwintrain = 1:length(DECout_diagonal_window.trainingwindow_centralms);

                    %this v
                    if cfg.singleorAvIterations ==1

                        vtime = squeeze(DECout_diagonal_window.discrimvector_perTime(nIter,iwintrain,:));
                    else
                        vtime = squeeze(mean(DECout_diagonal_window.discrimvector_perTime(:,iwintrain,:),1));
                    end

                    for iwintest = 1:length(DECout_diagonal_window.trainingwindow_centralms)
                        nwinsamps_test = DECout_diagonal_window.trainingwindow_frames(iwintest,:);
                        testON= slidepartBdata(:,nwinsamps_test(1):nwinsamps_test(2),:);
                        %reshape for matrix mult.
                        [nchans, sampsize, ntrials] =size(testON);

                        testdataON = reshape(testON, nchans, sampsize* ntrials)';%
                        %%
                        ytest = testdataON * vtime(1:end-1) + vtime(end);
                        %convert to prob:
                        bptest = bernoull(1,ytest);
                        %% reshape for plotting.

                        bptest = reshape(bptest, sampsize, ntrials);

                        % here we can extract the corrects, and flip the sign.
                        %                 bptest_corr = bptest(:,corrinEEG);
                        %                 bptest_err = bptest(:,errinEEG);
                        %                 bptest(:,corrinEEG)=  0.5-bptest(:,corrinEEG);


                        % store for averaging over each iteration.
                        PFX_classifier_timegen_ERP(iwintrain,iwintest,:) = mean(bptest,1);


                    end % testwindow.
                end % train window
                %                 %%
                %% now take correlation with confidence, in a sliding window:

                % show corr
                corr1= zeros(size(PFX_classifier_timegen_ERP,1),size(PFX_classifier_timegen_ERP,1));

                for iwin1= 1:size(PFX_classifier_timegen_ERP,1)
                    for iwin2= 1:size(PFX_classifier_timegen_ERP,2);

%                  confidence (all trials)
                    [R,p] = corrcoef(PFX_classifier_timegen_ERP(iwin1,iwin2,:), allBEH);
                    corr1(iwin1,iwin2)= R(1,2);
                    end
                end


%                 if smoothON==1
%                     corr1= smooth(corr1,5); % closer match to Fs of Pe classifier.
%                 end
                
                slideTimes= Xtimes;

                %% %% store output participants:
                if iSLIDE==1
                    GFX_DECA_Conf_corr_slid(ippant,:,:, ilist) = corr1;
                elseif iSLIDE==2
                    GFX_DECA_RT_corr_slid(ippant,:,:,ilist) = corr1;
                elseif iSLIDE==3
                    GFX_DECA_RT_Subjcorr_slid(ippant,:,:,ilist) = corr1;
                end

            end % iSLIDE
        end % corrects errors, all

        %% sanity check.
%             clf
%             tsare={'corrects', 'errors', 'all'};
%             for i=1:3
%             subplot(2,3,i);
%         imagesc(slideTimes, slideTimes, squeeze(GFX_DECA_Conf_corr_slid(ippant,:,:,i)))
%         hold on; plot(xlim, [0 0], 'w');
%         set(gca,'ydir', 'normal')
% %         ylim([-.4 .4]);
% %         ylabel('p(Error) and conf')
%         title(tsare{i})
%             subplot(2,3,i+3);
%         imagesc(slideTimes,slideTimes,squeeze(GFX_DECA_RT_corr_slid(ippant,:,:,i)))
%         hold on; plot(xlim, [0 0],'w');
% %         ylim([-.4 .4]);
% %         ylabel('p(Error) and rt');
%         set(gca,'ydir', 'normal')
%             end
%             shg
        %%



%         GFX_DecA_ScalpProj(ippant,:) = mean(DEC_Pe_window.scalpproj,1);
        %             GFX_ExpOrders(ippant).d= ExpOrder;

        disp(['calc timegen x sliding Corr  for ppant num ' num2str(ippant)]);
    end
    %save GFX level data
    cd(eegdatadir)
    cd('GFX')

    save(['GFX_' savename], ...
        'GFX_DECA_RT_corr_slid', ...
        'GFX_DECA_Conf_corr_slid',...
        'GFX_DECA_RT_Subjcorr_slid',...
        'GFX_DecA_ScalpProj', 'slideTimes' );







end
%%

if job1.plotPFX==1
    % load if needed
    cd(eegdatadir);
    cd('GFX')
    load(['GFX_' savename ]);
    
    %output to figdir.
    cd(figdir)
    cd('Classifier Results')
    cd('PFX_Trained on resp Errors in part A, conf x sliding window part B');

    dataprint = TESTondatatypes{usetype};


    % conf or RTs?
    dataIN= GFX_DECA_Conf_corr_slid;


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
        plot(plotXtimes(winmid),plotme, 'color', 'k', 'linew', 3);
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
        printname = ['Participant ' num2str(ippant) ' Dec A (Pe) sliding confidence correct only'];

        set(gcf, 'color', 'w')
        print('-dpng', printname)

    end
end


%%
if job1.plotGFX==1

    %load if needed
    
    cd(eegdatadir);
    cd('GFX')
    load(['GFX_' savename ]);
    %%
    cd(figdir)
    cd('Classifier Results');

    %%

    figure(1); clf; set(gcf, 'color', 'w', 'units', 'normalized', 'position', [0.1 0.1 .8 .7]);
    % plot results across participants:
    showt1 = [200, 350];

    ylabsare= {'confidence', 'rt', 'confidence'};
    titlesare= {'correct', 'error', 'all'};

    allData= {GFX_DECA_Conf_corr_slid, GFX_DECA_RT_corr_slid,GFX_DECA_RT_Subjcorr_slid};
    for idata=3%1:3
        ylabis= ylabsare{idata};
        dataIN= allData{idata};
        for itrialtype=3%1:3
%             subplot(3,3,itrialtype + (3*(idata-1)));
            dataINt = squeeze(dataIN(:,:,:,itrialtype));
%%

            % change orientation so that training is on the Y axis
            dataINt= permute(dataINt, [1,3,2]);
            set(gcf, 'color', 'w')
           
            hold on
            %%%%
           imagesc(slideTimes, slideTimes, squeeze(mean(dataINt,1)));
ylabel(['trained ' modtrain ' ' cfg.EEGtype_train ])
    xlabel(['Tested ' modtest ' ' cfg.EEGtype_test])
    
            hold on; plot(xlim, [0 0 ], ['w:'], 'linew', 2)
            hold on; plot([0 0 ], ylim, ['w:'], 'linew', 2)
            set(gca, 'fontsize', 12, 'ydir', 'normal');
            
            title({[titlesare{itrialtype} ' trials'];['p(Error) x ' ylabsare{idata}  ' correlation']}, 'fontsize', 12)
            if idata==3
                title({[titlesare{itrialtype} ' + subjCorr trials'];['p(Error) x ' ylabsare{idata}  ' correlation']}, 'fontsize', 12)
                
            end

           colorbar; 
           %centre color axis.
           cl= get(gca, 'clim');
           caxis([ -diff(cl)/2 diff(cl)/2])
%            caxis([-.04 .04]) 
           % add sig tests:
            %ttests
            [nhst,pvals]= deal(zeros(size(dataINt,1), size(dataINt,1)));
            %
            for itime1 = 1:length(slideTimes)
                for itime2= 1:length(slideTimes)
                [nhst(itime1,itime2), pvals(itime1,itime2), ~, stat] = ttest(dataINt(:,itime1,itime2));
                teststats(itime1, itime2)= stat.tstat;
                end
            end

            % show the boundaries of significant regions:


            % Extract the boundaries of the clusters
            B_obs = bwboundaries(nhst);
            permTest=0;
            if permTest==1 % perform time-consuming cluster correction on last plot only.
                %% work out the largest observed cluster statistic (retain).
                clusttestStat_obs = [];
                
                for k = 1:length(B_obs)
                    boundary = B_obs{k};
                    clustertestStat_obs(k) = abs(sum(nansum(teststats(boundary(:,2), boundary(:,1)))));
                    
                    
                end
                %%
                
                % what is the CV cutoff for a perm version?
                % should shuffle labels in this case the comparison (other group) is chance
                % performance.
                group1= dataINt;
                group2= repmat(0, size(group1));
                % for nperms, recalc the largest observed cluster stat, if group assignment
                % is random.
                nPerm=200;
                allsub= 1:size(group1,1);
                
                try % see if the cluster has already been performed at this level
                    y= clusterResults_shuff(idata,itrialtype).(['nPerm_' num2str(nPerm) '_quantiles']);
                    clusterResults = clusterResults_shuff(idata,itrialtype).(['nPerm_' num2str(nPerm) 'results']);
                catch
                    disp('performing cluster computation, might be slow')
                    clusterResults=[]; % compute anew
                    for iperm= 1:nPerm
                        
                        %flip half the participants each time (at random)
                        nshuff= floor(max(allsub)/2);
                        %shuffle order:
                        shfforder = randperm(21);
                        
                        %flip these ppants:
                        flippants= shfforder(1:nshuff);
                        
                        %swaap:
                        group1tmp= group1;
                        group2tmp= group2;
                        
                        group1tmp(flippants,:,:) = group2(flippants,:,:);
                        group2tmp(flippants,:,:)= group1(flippants,:,:);
                        
                        % now with our null, perform the stats test and retain largest cluster.
                        
                        pvals=[];
                        
                        for irow= 1:size(group1,2);
                            for icol= 1:size(group1,3);
                                
                                %pick at random.
                                [nhst(irow, icol), pvals(irow, icol),~,stat]= ttest(group1tmp(:, irow, icol), group2tmp(:,irow,icol), 'alpha', .05);
                                teststats(irow,icol)= stat.tstat;
                                
                            end
                        end
                        
                        %cluster extraction:
                        B_shuff = bwboundaries(nhst);
                        %% work out the largest observed cluster statistic (retain).
                        clusttestStat_shuff = [];
                        
                        for k = 1:length(B_shuff)
                            boundary = B_shuff{k};
                            clustertestStat_shuff(k) = abs(sum(nansum(teststats(boundary(:,2), boundary(:,1)))));
                            
                            
                        end
                        clusterResults(iperm) = max(clustertestStat_shuff);
                        disp(['fin perm ' num2str(iperm)]);
                    end
                    %% %
                    figure(10); clf
                    histogram(clusterResults, nPerm);
                    hold on;
                    plot([obsV,obsV], ylim, 'r-');
                    y= quantile(clusterResults,[.05 .5 .95]);
                    for iy=1:length(y)
                        plot([y(iy),y(iy)], ylim, 'b-');
                        
                    end
                    %%
                    % save our hard work:
                    clusterResults_shuff(idata,itrialtype).(['nPerm_' num2str(nPerm) '_quantiles']) = y;
                    clusterResults_shuff(idata,itrialtype).(['nPerm_' num2str(nPerm) 'results']) = clusterResults;
                    % append:
                    save(['GFX_' savename], 'clusterResults_shuff', '-append');
                end % end of catch statemen
% 
%%
figure(1);

%%
% only use those clusters which exceed our 95% CV
plotcluster= clustertestStat_obs>=y(3);
plotclusterStats= clustertestStat_obs(plotcluster);
% Overlay the boundaries on the image
Bplot= B_obs(plotcluster);
hold on
for k = 1:length(Bplot)
    boundary = Bplot{k};
    % determine if pos or negative:
%       
clustCol= 'w';
    plot(Xtimes(boundary(:,2)), Xtimes(boundary(:,1)), 'color',clustCol, 'LineWidth', 2)
end
%%

            else % dont correct, just plot og
              
                hold on
                for k = 1:length(B_obs)
                   boundary= B_obs{k};
                   plot(Xtimes(boundary(:,2)), Xtimes(boundary(:,1)), 'w', 'linew',2);
                   
             
                    
                end
                
            end % permtest.
% axis square
        end % trialstype
    end % conf and rt
    %%
    % add topoplot of discrim used to aid interpretation.
    %
    %         subplot(1,3,3)
    %         topoplot(mean(GFX_DecA_ScalpProj(useppants,:)), elocs);
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



