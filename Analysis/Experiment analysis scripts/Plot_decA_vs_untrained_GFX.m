% called from JOBS_ERPdecoder.m
%plot GFX of decoder trained on part A C vs E, on untrained trials.



jobs.concat_GFX=1;
jobs.plot_GFX=1;

%plotType
job.plotERNorPe=2; % 1 or 2.

%%% load and concat across subjects (if previous step was re-run).
if jobs.concat_GFX==1;
    
    [GFX_classifierA_topo_ERN,GFX_classifierA_onERP_ERN ]=deal([]);
    [GFX_classifierA_topo_Pe,GFX_classifierA_onERP_Pe ]=deal([]);
    
    %first concatenate across subjects:
    [vis_first, aud_first] = deal([]);
    for ippant = 1:length(pfols)
        
        
        cd(eegdatadir)
        cd(pfols(ippant).name);
        %% load the Classifer and behavioural data:
        load('Classifier_objectivelyCorrect');
        load('Epoch information', 'ExpOrder');
        
        %ERN
        GFX_classifierA_onERP_ERN(ippant,:,:) = squeeze(mean(PFX_classifierA_onERP_ERNtrained,2));
        GFX_classifierA_topo_ERN(ippant,:) = squeeze(mean(DEC_ERN_window.scalpproj,1));
        %Pe
        GFX_classifierA_onERP_Pe(ippant,:,:) = squeeze(mean(PFX_classifierA_onERP_PEtrained,2));
        GFX_classifierA_topo_Pe(ippant,:) = squeeze(mean(DEC_Pe_window.scalpproj,1));
        
        clear PFX_classifierA_onERP_ERNtrained PFX_classifierA_onERP_PEtrained;
        
        if strcmpi(ExpOrder{1}, 'visual')
            vis_first = [vis_first, ippant];
        else
            aud_first= [aud_first, ippant];
        end
    end
    
    % save!
    cd(eegdatadir);
    cd('GFX')
    %other plot features:
    Xtimes = DEC_Pe_windowparams.wholeepoch_timevec;
    save('GFX_DecA_predicts_untrainedtrials', ...
        'GFX_classifierA_onERP_ERN','GFX_classifierA_onERP_Pe',...
        'GFX_classifierA_topo_ERN', 'GFX_classifierA_topo_Pe', ...
        'vis_first', 'aud_first', 'Xtimes');
    
    
end % concat job

%%%%%%%
%now plot GFX
if jobs.plot_GFX==1;
    
    %load if necessary.
    cd([eegdatadir filesep 'GFX']);
    if ~exist('GFX_classifierA_onERP_ERN', 'var');
        load('GFX_DecA_predicts_untrainedtrials');
    end
    
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
    
    %add patch
    ylims = get(gca, 'ylim');
    pch = patch([windowvec(1) windowvec(1) windowvec(2) windowvec(2)], [ylims(1) ylims(2) ylims(2) ylims(1)], [.8 .8 .8]);
    pch.FaceAlpha= .1;
    xlabel('Time since response (ms)')
    ylabel('A.U');
    %%
    title({['Order ' orderis ', nreps ' num2str(nIterations)];['Time-course of discriminating component, (trained Corr A vs Err A)']}, 'fontsize', 25);
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
    printname = ['GFX classifier trained on Correct part A-' winwas ',' orderis ', w-' num2str(nIter) 'reps' ];
    
    if smoothON==1
        printname = [printname ', smoothed'];
    end
    print('-dpng', printname);
    
end
end % print job.