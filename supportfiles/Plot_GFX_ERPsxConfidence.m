
getelocs;
cmap = cbrewer('qual', 'Set1', 3);
usechan = 31;
    smoothON=0;
    
    
%% PLOT Group level ERPs.    
cd(basedir)
cd('EEG')
cd('GFX')
%%
    load('GFX_averageERPsxConf.mat');    
%%
    figure(2);  clf;
    set(gcf, 'units', 'normalized', 'position', [0 .45 .8 .4]);
    %
    for idtype = 1:2
        switch idtype
            case 1
                datac = GFX_conf_x_slEEG;
                dtype = 'stimulus onset';
            case 2
                datac = GFX_conf_x_rlEEG; % response locked
                dtype = 'response onset';
        end
        
    showt = [50, 300]; % times for topoplots to be displayed.
    lg=[];
    
    subplot(1,2,idtype)
    for iterc =1:3
      
        datatoplot = squeeze(datac(:,usechan,:,iterc));
        
        stE = CousineauSEM(datatoplot);
        sh = shadedErrorBar(plotXtimes_2, squeeze(nanmean(datatoplot,1)), stE, [],1);
        sh.mainLine.Color = cmap(iterc,:);
        sh.mainLine.LineWidth = 4;
        sh.patch.FaceColor=  cmap(iterc,:);
        sh.edge(1).Color =   cmap(iterc,:);
        sh.edge(2).Color =   cmap(iterc,:);

        lg(iterc)= sh.mainLine;
       
        set(gca, 'ydir', 'reverse')
        hold on;
%         plot([showt(1) showt(1)], [ -2 2], 'r', 'linew', 4)
%         plot([showt(2) showt(2)], [ -2 2], 'r', 'linew', 4)
        xlim([- 200 900])
        xlabel(['Time from ' dtype ' [ms]'])
        ylabel(['uV']);
        
        set(gca, 'fontsize', 15);
        %%
       
        plot([0 0], ylim, ['k-'])
    end
    %%
    legend(lg, {'lowest confidence', 'medium confidence', 'highest confidence'}, 'location', 'SouthEast', 'fontsize', 15) ; 
    title(['GFX ' dtype ' ' biosemi64(usechan).labels ]);
    
    set(gca, 'fontsize', 15);
    end
    %%   
    cd(basedir);
    
    cd('Figures')
    cd('Confidence x ERPs')
    set(gcf, 'color', 'w')
    %%
    printname = ['GFX partB ERPs x Conf terc at ' biosemi64(usechan).labels];
    print('-dpng', printname)
    %%
% As an extra sanity check, plot the topography for high - low confidence,
% over 250-350 ms window.
% 
% [timeav] = dsearchn(plotXtimes_2', [250, 350]');
% 
% topo_lowconf= squeeze(mean(datac(:,:,timeav(1):timeav(2),1),3));
% topo_highconf = squeeze(mean(datac(:,:,timeav(1):timeav(2),3),3));
% 
% %subtract, 
% difftopo = topo_lowconf-topo_highconf; 
% %average across subjects and plot
% figure();
% topoplot(squeeze(mean(difftopo,1)), biosemi64); colorbar;
% 

