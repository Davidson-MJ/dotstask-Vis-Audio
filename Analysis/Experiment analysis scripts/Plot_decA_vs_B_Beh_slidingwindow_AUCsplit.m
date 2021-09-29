% plot classifer trained on part B (C vs E), to predict confidence or RT
% with a sliding window analysis

%called from JOBS_ERPdecoder.m

cmap = flip(cbrewer('seq', 'RdPu', 5));

%% Note that this script can save a sliding window of classifier performance, correlated
% with RT or confidence in part B.

% no need to calc or plot PFX (done in prev job). Here we reload the
% calculated sliding windows, and simply plot after splitting by AUC.
job1.plotGFX=1;



elocs = readlocs('BioSemi64.loc');

normON = 0; % normalize EEG data.

%load if necessary.
cd([eegdatadir filesep 'GFX']);
%load auc for split, then load the EEG data
load('GFX_AUC_predicts_EEG.mat', 'storeAUC');
g1= find(storeAUC<median(storeAUC));
g2 = find(storeAUC>=median(storeAUC));

TESTondatatypes = {'resplocked', 'stimlocked', 'resplocked-stimbase'};
%%
for usetype = 1%1:3; of the above ^
    
    
    
    
    %% %%%%%
    vis_first=[2,3,6:25];
    aud_first = [1,4,5];
    dataprint = TESTondatatypes{usetype};
    
    if job1.plotGFX==1
        
        %load if needed
        if ~exist('GFX_DECA_Conf_corr_slid','var')
            cd(eegdatadir);
            cd('GFX')
            load('GFX_DecA_slidingwindow_predictsB_Behav');
        end
        
        cd(figdir)
        cd('Classifier Results');
        
        
        %plot Conf or RT correlation?
        dataIN = GFX_DECA_Conf_corr_slid;
        %         dataIN = GFX_DECA_RT_corr_slid;
        
        
        figure(1); clf; set(gcf, 'color', 'w', 'units', 'normalized', 'position', [0 0 1 1]);
        %% plot results across participants:
        showt1 = [200, 350];
        dtmp=[]; % data for ttests
        leg=[]; % legend holder.
        for iorder =1%:3
            figure(1); clf
            switch iorder
                case 1
                    useppants = vis_first;
                    ordert='visual-audio';
                case 2
                    useppants = aud_first;
                    ordert= 'audio-visual';
                case 3
                    useppants = 1:size(GFX_DECA_Conf_corr_slid,1);
                    ordert= 'all combined';
            end
            
            
            subplot(1,3,1:2)
            % limit to order type:
            dataINtmp = squeeze(dataIN(useppants,:));
            %further limit by AUC:
            for iAUC=1:2
                if iAUC==1;
                    useppants=g1;
                    
                else
                    useppants=g2;
                end
                dataINt = squeeze(dataINtmp(useppants,:));
                ylabis ={['DECODER and Conf'];['(correct only) [r]']};
                usecol = 'b';
                
                
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
                sh=shadedErrorBar(plotXtimes(winmid), mean(dataINt,1), Ste, [usecol],1);
                sh.mainLine.LineWidth=3;
                if iAUC==1;
                    sh.mainLine.LineStyle=':';
                end
                leg(iAUC)= sh.mainLine;
                shg
                
                
                xlabel(['Time [ms] after ' dataprint ' in part B']);
                ylabel(ylabis)
            
                %store data for ttests:
                dtmp(iAUC,:,:) = dataINt;
            end % AUC 
            %%
            legend([leg(1) leg(2)], {'low AUC', 'high AUC'});
            hold on; plot(xlim, [0 0 ], ['k:'], 'linew', 2)
            hold on; plot([0 0 ], ylim, ['k:'], 'linew', 2)
            set(gca, 'fontsize', 25)
            title({['Trained on visual (errors), tested on audio (correct) x Conf']; ['n=' num2str(length(useppants))]}, 'fontsize', 20)
            
            box on
            % add sig tests:
                        %ttests
                        pvals= nan(1, length(winmid));
                        %%
                        for itime = 1:length(winmid)
                            [~, pvals(itime)] = ttest(dtmp(1,:,itime),dtmp(2,:,itime));
            
                            if pvals(itime)<.05
                                text(plotXtimes(winmid(itime)), [-.1], '*', 'color', 'k','fontsize', 45);
                            end
                        end
            %
            %%
            
        end % order of crossmodal session
    end % job
    %%
end % resp, or stim locked