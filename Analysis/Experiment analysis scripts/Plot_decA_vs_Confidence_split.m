% plot classifer trained on part B (C vs E), to predict confidence.
%called from JOBS_ERPdecoder.m
getelocs;
cmap = flip(cbrewer('seq', 'RdPu', 5));
%%





job1.calcandconcat_PFX =1;
job1.plotGFX=1;





normON = 0; % normalize EEG data.





%%
if job1.calcandconcat_PFX ==1



GFX_DECA_Conf_Bsplit=nan(length(pfols), 384,2);
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

    partBindx = sort([corBindx]);
    
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
    zconfj= zscore([alltrials_matched(partBindx).confj]);
    
    %before continuing, we want to apply the spatial discrim to each trial.
    %% we are using the decoder from part A (correct vs Errors)
    v = DEC_Pe_window.discrimvector;
    
    %we want to take the probability, when this decoder is applied to a
    %sliding window across part B epochs.
    testdata = reshape(partBdata, nchans, nsamps* ntrials)';%
    %% multiply data by classifier:
    
    ytest_tmp = testdata* v(1:end-1) + v(end);
    
    
    %take the prob
        ytest_tmp= bernoull(1,ytest_tmp);
    
        
%         ?smooth?
% ytest_tmp_f = eegfilt(ytest_tmp', 256,0, 8);
    
% reshape for single trial decoding
    
    ytest_trials = reshape(ytest_tmp,nsamps,ntrials);
    
    %% now take terciles of confidence: 
    
     quants = quantile(zconfj, [.5]);
         t1 = find(zconfj<quants(1));
         t2 = find(zconfj>=quants(1));
         

        %store for easy access.
        terclists(1).list = t1;
        terclists(2).list = t2;
%         terclists(3).list = t3;
        
        %now for each tercile, take the mean EEG      
    %%
        DEC_x_rlEEG = zeros(size(ytest_trials,1), 2);
        for iterc=1:2
           
%             try
                %take mean corr ERP for this tercile:
                tempERP = squeeze(nanmean(ytest_trials(:,terclists(iterc).list),2));
                %% now store:
                DEC_x_rlEEG (:,iterc) =tempERP;
%                 
%                 %now take mean for stimulus locked equivalent.
%                 tempERP = squeeze(nanmean(stimEEGd(:,:,terclists(iterc).list),3));
%                 conf_x_slEEG(:,:,iterc) =tempERP;
% %       
        end
      
    %%
    set(gcf, 'units', 'normalized', 'position',[-.5 0 .5 .5], 'color', 'w', 'visible', 'off');
    clf
    subplot(1,3,1:2)
    plot(plotXtimes, DEC_x_rlEEG(:,1), 'color', 'r', 'linew', 3); hold on
    plot(plotXtimes, DEC_x_rlEEG(:,2), 'color', 'b', 'linew', 3);
    %%
    title({['P' num2str(ippant) ', Classifier trained on ERP A (C vs E) x ERP B (cor only)'];[ExpOrder{1} '- ' ExpOrder{2} ]});
xlabel(['Time [ms] after response in part B']);
ylabel('Accuracy ')
ylim([.2 .8])
hold on; plot(xlim, [0.5 0.5 ], ['k:'], 'linew', 2)
hold on; plot([0 0 ], ylim, ['k:'], 'linew', 2)
set(gca, 'fontsize', 15)
legend('low conf', 'high conf')
%%
subplot(1,3,3)
 topoplot(DEC_Pe_window.scalpproj, biosemi64);
 title(['Classifier trained [' num2str(DEC_Pe_windowparams.training_window_ms) ']'])
 set(gca, 'fontsize', 15)
    
  %%

    
cd(basedir);
cd ../../Figures/
cd('Classifier Results')
cd('PFX_Trained on Correct part A, conf x part B conf split');
printname = ['Participant ' num2str(ippant) ' Dec A, part B conf ' ExpOrder{1} '- ' ExpOrder{2}];
print('-dpng', printname)


%% store output participants:
  GFX_DECA_Conf_Bsplit(ippant,:,:) = DEC_x_rlEEG;
  GFX_DecA_ScalpProj(ippant,:) = DEC_Pe_window.scalpproj;
end

save('GFX_DecA_predictsConfidencesplit', 'GFX_DECA_Conf_Bsplit', 'GFX_DecA_ScalpProj',  'plotXtimes');

end

if job1.plotGFX==1
%% plot results across participants:
for iorder =1%:3
    figure(1); clf
    lgh=[];
    switch iorder
        case 1            
            useppants = vis_first;
            ordert='visual-audio';
        case 2
            useppants = aud_first;
            ordert= 'audio-visual';
        case 3
            useppants = 1:size(GFX_DECA_Conf_Bsplit,1);
            ordert= 'all combined';
    end
    
    dataIN = squeeze(GFX_DECA_Conf_Bsplit(useppants,:,:));
    
    colsare = {'r', 'b'};
    for iterc=1:2
        
        
Ste = CousineauSEM(dataIN(:,:,iterc));

subplot(1,3,1:2)
set(gcf, 'color', 'w')
sh= shadedErrorBar(plotXtimes, mean(dataIN(:,:,iterc),1), Ste, colsare{iterc},1);
sh.mainLine.LineWidth= 3;
lgh(iterc) = sh.mainLine;
shg
hold on
    end
    legend([lgh(1) lgh(2)], {'low confidence', 'high confidence'}, 'autoupdate', 'off');
%
xlabel(['Time [ms] after response in part B']);
ylabel('Decoder accuracy')
ylim([.375 .6])
hold on; plot(xlim, [.5 .5 ], ['k:'], 'linew', 2)
hold on; plot([0 0 ], ylim, ['k:'], 'linew', 2)
set(gca, 'fontsize', 25)
title({['Classifier trained on ERP A (C vs E) x ERP B'];[ordert ', n=' num2str(length(useppants))]}, 'fontsize', 20)
%
% add sig tests:
%ttests
pvals= nan(1, length(plotXtimes));

for itime = 1:length(plotXtimes)
    [~, pvals(itime)] = ttest(dataIN(:,itime,1),dataIN(:,itime,2));
    
    if pvals(itime)<.05 && plotXtimes(itime)>0
        text(plotXtimes(itime), [.39], '*', 'color', 'k','fontsize', 25);
    end
end
xlim([-200 600])
%%
% add topoplot of discrim used to aid interpretation.

subplot(1,3,3)
topoplot(mean(GFX_DecA_ScalpProj(useppants,:)), biosemi64);
title(['Classifier trained [' num2str(DEC_Pe_windowparams.training_window_ms) ']']);
set(gca, 'fontsize', 25)

set(gcf,'color', 'w')
%%
cd(basedir);
cd ../../Figures/
cd('Classifier Results')
cd('PFX_Trained on Correct part A, conf x part B conf split');
printname = ['GFX Dec A predicts confidence split, for ' ordert];
print('-dpng', printname)
end
end
%%
