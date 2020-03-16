% plot classifer trained on part B (C vs E), to predict confidence.
%called from JOBS_ERPdecoder.m
    getelocs;
    cmap = flip(cbrewer('seq', 'RdPu', 5));
    %%
    
    
    [cjmean, cjse, cjdistr]=deal([]);
    
    
    for ippant = 1:length(pfols)
    cd(basedir)
    cd(pfols(ippant).name);
    %% load the Classifer and behavioural data:
    load('Classifier_objectivelyCorrect');
    load('participant TRIG extracted ERPs.mat');
    load('Epoch information.mat');
   %% 
    %
    partBindx = contains({alltrials_matched.ExpType}, 'B');
    partBdata = resplockedEEG(:,:,partBindx);
    
    % collect confj for this dataset
    allconfj= zscore([alltrials_matched(partBindx).confj]);

    %before continuing, we want to apply the spatial discrim to each trial.
    %%
    v = DEC_Pe_B_window.discrimvector;
    [nchans, nsamps, ntrials] =size(partBdata);
    testdata = reshape(partBdata, nchans, nsamps* ntrials)';%
%%

    ytest = testdata * v(1:end-1) + v(end);

%this output will leave the folder
    bptest = bernoull(1,ytest);
    bptest = reshape(bptest, nsamps, ntrials);

%% reshape for plotting.
    ytest_trials = reshape(ytest,nsamps,ntrials);
       
    %% Plot by confidence:
    
    %now take terciles, based on conf judgements:        
        quants = quantile(allconfj, [.33 .66]);
        terclists=[];
        if diff(quants)==0 % can't separate into terciles.
            %instead,  save as high/low.
              quants = quantile(allconfj, [.5]);
               t1 = find(allconfj<quants(1));
               t2 = nan;
               t3 = find(allconfj>=quants(1));
               
        else
            
        %now we have all the data, and confidence rows per quartile:
        %split EEEG into terciles:
        %lowest
        t1 = find(allconfj<quants(1));
        %middle
        t2a = find(allconfj>=quants(1));
        t2b = find(allconfj<quants(2));
        t2= intersect(t2a, t2b); 
        %highest
        t3 = find(allconfj>=quants(2));
        end
        %store for easy access.
        terclists(1).list = t1;
        terclists(2).list = t2;
        terclists(3).list = t3;
        
        %% now for each tercile, take the mean EEG      
conf_x_discrimB_EEG = nan(size(ytest_trials,1), 3);
        for iterc=1:3            
           
            try
                %take mean corr ERP for this tercile:
                tempERP = squeeze(nanmean(ytest_trials(:,terclists(iterc).list),2));
                %% now store:
                conf_x_discrimB_EEG(:,iterc) =tempERP;
             
            catch
                conf_x_discrimB_EEG(:,iterc) =nan;
                
            end
        end
      
%% PLOT RESULTS
% % sanity check    
% ptimes=DEC_Pe_B_windowparams.wholeepoch_timevec;
 figure(1); clf;
    set(gcf, 'units', 'normalized', 'Position', [0 1 .6 .6]); shg
    leg=[];
subplot(2,1,1)
plot(DEC_Pe_B_windowparams.wholeepoch_timevec, conf_x_discrimB_EEG); 
      hold on; plot([0 0 ], ylim, '--', 'color', [.3 .3 .3], 'linew', 3)
    
    % add training window 
    windowvec = DEC_Pe_windowparams.training_window_ms;
    %add patch
    ylims = get(gca, 'ylim');
    pch = patch([windowvec(1) windowvec(1) windowvec(2) windowvec(2)], [ylims(1) ylims(2) ylims(2) ylims(1)], [.8 .8 .8]);
    pch.FaceAlpha= .1;
    ylabel(['a.u.']);
    xlabel('Time since response (ms)')
title('Discrim vector X EEG, split by confidence');
legend('Conf 1', 'Conf 2', 'Conf 3');
set(gca, 'fontsize', 15, 'ydir', 'reverse')
  %% now we can compare the discriminator accuracy, based on later
    %confidence judgement. Like Boldt & Yeung, we'll smooth over a 50ms
    %window.
    
    ms50 = diff(dsearchn(DEC_Pe_B_window.xaxis_ms', [0 50]'));
    slidwin = ceil(ms50/2);
    %%
    for i=slidwin+1:size(ytest_trials,1)-slidwin
        
        %take the mean across this time window, within each trial.
        temp_DEC=mean(ytest_trials(i-slidwin:i+slidwin,:),1);
        
        %take quantile limits of discriminator performance across trials
        quants=quantile(temp_DEC,[0 0.2 0.4 0.6 0.8 1]);
        
        for j=1:5
            % subselect the confidence data, using trial index for each
            % quantile based on discriminator.
            
            cellnow=allconfj(find(quants(j)<temp_DEC & temp_DEC<=quants(j+1)));
            
            if (j==1) % if first quartile, look for minimum
                cellnow=[cellnow allconfj(find(min(temp_DEC)==temp_DEC))]; 
            end
            
            %store that confidence judgement for each value in time-series
            cjmean(ippant,i-slidwin,j)=mean(cellnow);
            cjse(ippant,i-slidwin,j)=std(cellnow)/sqrt(size(cellnow,2));
            cjdistr(ippant,i-slidwin,j,:)=[size(cellnow(cellnow==1),2) size(cellnow(cellnow==2),2) size(cellnow(cellnow==3),2) size(cellnow(cellnow==4),2) size(cellnow(cellnow==5),2) size(cellnow(cellnow==6),2)];
        end
    end
    %%
    
   
    
    
    Xtimes = DEC_Pe_windowparams.wholeepoch_timevec(slidwin+1:size(ytest_trials,1)-slidwin);
    
    subplot(2,1,2)

    for icj= 1:5
        
        leg(icj)= plot(Xtimes, cjmean(ippant,:,icj), 'color', cmap(icj,:), 'linew', 3);
        hold on
    end
    
    % leg(itestdata)= plot(Xtimes, (mean(ytest_trials,2)), 'color', cmap(itestdata,:), 'linew', 3);
    hold on
    
%     ylim([.2 1])
    %% add extra plot elements:
%     hold on; plot(xlim, [.5 .5], '--', 'color', [.3 .3 .3], 'linew', 3)
    hold on; plot([0 0 ], ylim, '--', 'color', [.3 .3 .3], 'linew', 3)
    
    % add training window 
    windowvec = DEC_Pe_windowparams.training_window_ms;
    %add patch
    ylims = get(gca, 'ylim');
    pch = patch([windowvec(1) windowvec(1) windowvec(2) windowvec(2)], [ylims(1) ylims(2) ylims(2) ylims(1)], [.8 .8 .8]);
    pch.FaceAlpha= .1;
    xlabel('Time since response (ms)')
    ylabel('Confidence [z]');
    %
    title({['Moving average confidence (50 ms window) for quintiles of discriminating components, (trained Corr B vs Err B)']}, 'fontsize', 25);
    legend(leg, {'Q1', 'Q2', 'Q3', 'Q4', 'Q5'});
    set(gca, 'fontsize', 15)
    xlim([- 200 600]);
    %% 
    
    %% print results
    cd(basedir); 
    cd ../../;
     cd(['Figures' filesep 'Classifier Results' filesep 'PFX_Trained on Correct part B']); 
    
    %%
    set(gcf, 'color', 'w')
    print('-dpng', ['Participant ' num2str(ippant) ', moving average confidence by quintiles']);%', ERP weighted' ]);
    end % ippant