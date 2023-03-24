% called from JOBS_ERPdecoder.m
%plot GFX of decoder trained on part A C vs E, on untrained trials.
% additionally splits by AUC


% no need to concatenate, we can use previously calculated data, simply
% load and split by AUC scores.

jobs.plot_GFX=1;

%plotType
job.plotERNorPe=2; % 1 or 2.


%%%%%%%

%now plot GFX
if jobs.plot_GFX==1;
    
    %load if necessary.
    cd([eegdatadir filesep 'GFX']);
    %load auc for split, then load the EEG data
    load('GFX_AUC_predicts_EEG.mat', 'storeAUC');
    g1= find(storeAUC<median(storeAUC));
    g2 = find(storeAUC>=median(storeAUC));
    
    
    load('GFX_DecA_predicts_untrainedtrials.mat');
    
    
    smoothON=0; % apply moving window av to prettify plot.
    
    elocs = readlocs('BioSemi64.loc');
    
   if job.plotERNorPe==1; % 1 or 2.
       %data
        GFX_classifierA_onERP =GFX_classifierA_onERP_ERN;
        %training window (ms)           
    windowvec = DEC_ERN_windowparams.training_window_ms;
        %scalp topo
        GFX_classifierA_topo =GFX_classifierA_topo_ERN;
        
        winwas= 'ERN';
    elseif job.plotERNorPe==2
        GFX_classifierA_onERP =GFX_classifierA_onERP_Pe;
        
        % add training window
        windowvec = DEC_Pe_windowparams.training_window_ms;
        GFX_classifierA_topo =GFX_classifierA_topo_Pe;
        winwas= 'Pe';
    end
    
    %%
    figure(1); clf;
    set(gcf, 'units', 'normalized', 'Position', [0 0 1 1]); shg
    leg=[];

groups={'low AUC', 'high AUC'};
testdata={'visual (correct)', 'audio (correct)', 'visual (errors)', 'audio (errors)'};

    for itestdata = 1:4 % A cor, B cor, A err, B err
        
        subplot(2,2,itestdata) % for each data type, plot split by AUC.
        
        for iAUC=1:2;
            if iAUC==1
                useppants=g1;
                
            else
                useppants=g2;
                
            end
            
            plotdata = squeeze(GFX_classifierA_onERP(useppants,itestdata,:));
        
        if smoothON==1
            winsize = 256/20;
            for ip = 1:size(plotdata,1)
                plotdata(ip,:) = smooth(plotdata(ip,:), winsize);
            end
        end
        
        
        stE = CousineauSEM(plotdata);
        
        sh= shadedErrorBar(Xtimes, squeeze(nanmean(plotdata,1)), stE, [],1);
        
        sh.mainLine.Color =  cmap(itestdata,:);
        sh.patch.FaceColor =  cmap(itestdata,:);
        sh.edge(1,2).Color=cmap(itestdata,:);
        if iAUC==1
            sh.mainLine.LineWidth = 2;
            sh.mainLine.LineStyle= ':';
        else
            sh.mainLine.LineWidth = 2;
            sh.mainLine.LineStyle= '-';
        end
        ylim([.2 .75])
        leg(itestdata) = sh.mainLine;
        
        hold on
        %ttests
        pvals= nan(1, length(Xtimes));
        for itime = 1:length(Xtimes)
            [~, pvals(itime)] = ttest(plotdata(:,itime), 0.5);
            
            if pvals(itime)<.05
                text(Xtimes(itime), [0.2+(0.01*itestdata)], '*', 'color', cmap(itestdata,:),'fontsize', 25);
            end
        end
        
      
    
    % add extra plot elements:
    hold on; plot(xlim, [.5 .5], '--', 'color', [.3 .3 .3], 'linew', 3)
    hold on; plot([0 0 ], ylim, '--', 'color', [.3 .3 .3], 'linew', 3)
    
    %add patch
    ylims = get(gca, 'ylim');
    pch = patch([windowvec(1) windowvec(1) windowvec(2) windowvec(2)], [ylims(1) ylims(2) ylims(2) ylims(1)], [.8 .8 .8]);
    pch.FaceAlpha= .1;
    xlabel('Time since response (ms)')
    ylabel('A.U');
    %%
    title({['Trained on visual (errors), test on: ' testdata{itestdata}]}, 'fontsize', 25);
    %%
    
    set(gca, 'fontsize', 15)
        end % AUC.
        legend(leg, {['low AUC'],['high AUC  ']})
        
    end % each data type.
    %%
    cd([figdir filesep 'AUC results']);
    print('-dpng', ['GFX_decA_on_untrained_AUCsplit']);
    
end
