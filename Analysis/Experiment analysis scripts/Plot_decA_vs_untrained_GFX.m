% called from JOBS_ERPdecoder.m
%plot GFX of decoder trained on part A C vs E, on untrained trials.

[GFX_classifierA_topo,GFX_classifierA_onERP ]=deal([]);

%first concatenate across subjects:
[vis_first, aud_first] = deal([]);
for ippant = 1:length(pfols)
    
    
    cd(eegdatadir)
    cd(pfols(ippant).name);
    %% load the Classifer and behavioural data:
    load('Classifier_objectivelyCorrect');
    load('Epoch information', 'ExpOrder');
    
    GFX_classifierA_onERP(ippant,:,:) = squeeze(mean(PFX_classifierA_onERP,2));
    GFX_classifierA_topo(ippant,:) = squeeze(mean(DEC_Pe_window.scalpproj,1));
    clear PFX_classifierA_onERP;
    
    if strcmpi(ExpOrder{1}, 'visual')
        vis_first = [vis_first, ippant];
    else
        aud_first= [aud_first, ippant];
    end
end
%%
%now plot
Xtimes = DEC_Pe_windowparams.wholeepoch_timevec;
smoothON=1;

elocs = readlocs('BioSemi64.loc');
for iorder = 1%:3
    switch iorder
        case 1
            useppants = vis_first;
            orderis = 'visual-audio';
        case 2
            useppants = aud_first;
            orderis = 'audio-visual';
            
        case 3
            useppants = 1:length(pfols);
            orderis = 'all';
    end
    figure(1); clf;
    set(gcf, 'units', 'normalized', 'Position', [0 0 1 1]); shg
    leg=[];
    subplot(1, 3, 1:2);
    for itestdata = 1:4
        
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
        if itestdata<3
            sh.mainLine.LineWidth = 3;
            sh.mainLine.LineStyle= '-';
        else
            sh.mainLine.LineWidth = 2;
            sh.mainLine.LineStyle= ':';
        end
        
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
        %    pvals(pvals>=.05) = nan;
        %    plot(Xtimes, pvals<.05, '*');
        % %plot sig points.
        % text(Xtimes(pvals<.05), [0.2], '*',  'color', cmap(itestdata,:), 'FontSize', 5)
    end
    
    ylim([.2 .75])
    % add extra plot elements:
    hold on; plot(xlim, [.5 .5], '--', 'color', [.3 .3 .3], 'linew', 3)
    hold on; plot([0 0 ], ylim, '--', 'color', [.3 .3 .3], 'linew', 3)
    
    % add training window
    windowvec = DEC_Pe_windowparams.training_window_ms;
    %add patch
    ylims = get(gca, 'ylim');
    pch = patch([windowvec(1) windowvec(1) windowvec(2) windowvec(2)], [ylims(1) ylims(2) ylims(2) ylims(1)], [.8 .8 .8]);
    pch.FaceAlpha= .1;
    xlabel('Time since response (ms)')
    ylabel('A.U');
    %%
    title({['Order ' orderis ', nreps ' num2str(nIter)];['Time-course of discriminating component, (trained Corr A vs Err A)']}, 'fontsize', 25);
    %%
    legend(leg, {['Corr A'],['Corr B '], ['Err A'], ['Err B']})
    set(gca, 'fontsize', 15)
    
    
    subplot(133);
    topoplot(nanmean(GFX_classifierA_topo,1), elocs);
    title(['GFX, spatial projection'])
    set(gca, 'fontsize', 15)
    %% print results
    cd(figdir)
    cd(['Classifier Results' filesep 'PFX_Trained on Correct part A']);
    
    %%
    set(gcf, 'color', 'w')
    printname = ['GFX classifier trained on Correct part A-Pe,' orderis ', w-' num2str(nIter) 'reps' ];
    
    if smoothON==1
        printname = [printname ', smoothed (NEW)'];
    end
    print('-dpng', printname);
    
end