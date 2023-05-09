
elocs= getelocs(3); % biosemi

cmap = flipud(cbrewer('seq', 'Reds', 5));
smoothON=1;

meanoverChans_RESP = [4,38,39,11,12,19,47,46,48,49,32,56,20,31,57];
% meanoverChans_RESP_POCC= 

meanoverChans_POCC = [20:31, 57:64];




showt1 = [250 450]; % ms for topo averages
tcounter=1;
% PLOT Group level ERPs.
cd(eegdatadir)
fntsize= 12;
cd('GFX')
%
load('GFX_averageERPsxConf.mat');
use_xvec = plotXtimes(1:size(GFX_conf_x_slEEG,3)); % adjusting for preprocessed length
%
figure(1);  clf;
set(gcf, 'units', 'normalized', 'position', [0 .45 .8 .4]);
figure(4); clf;

set(gcf, 'units', 'normalized', 'position', [0 .45 .8 .4]);
%     use_xvec =
    for idtype = 1:2
        switch idtype
            case 1
                datac = GFX_conf_x_slEEG;
                dtype = 'auditory stimulus onset';
                usechans = [meanoverChans_RESP, meanoverChans_POCC];
            case 2
                datac = GFX_conf_x_rlEEG; % response locked
                dtype = 'auditory response onset';
                usechans = meanoverChans_POCC;
%                 usechans = meanoverChans_RESP;
        end
        
     


        datap = squeeze(mean(datac(:, usechans,:,:),2)); % mean over chans
    
           if smoothON==1
            winsizet = dsearchn(use_xvec', [0 100]'); % 100ms smooth window.
            winsize = diff(winsizet);
             dataout= zeros(size(datap));
            for isubj=1:size(datap,1)
                for iterc= 1:size(datap,3)
                dataout(isubj,:,iterc) = smooth(squeeze(datap(isubj,:, iterc)), winsize);
                end
            end
            datap=dataout;
            disp(['HAVE SMOOTHED at participant level!']);
           end

        
        showt = [50, 300]; % times for topoplots to be displayed.
    lg=[];

    figure(1); hold on;
    subplot(1,2,idtype); hold on
    ylim([-4 3]);
% show patch first:
ytx= get(gca, 'ylim');
hold on
%plot topo patches.
if idtype==2
ph=patch([showt1(1) showt1(1) showt1(2) showt1(2)], [ytx(1) ytx(2) ytx(2) ytx(1) ],  [1 .9 .9]);
ph.FaceAlpha=.4;
ph.LineStyle= 'none';
end

nQuants= size(GFX_conf_x_slEEG,4);
if nQuants==4
topospots= [1,3,5,7,2,4,6,8];% order for topoplots in FIgure 4
else
    topospots= [1,3,2,4];
end
    for iterc =1:nQuants
      
        datatoplot = squeeze(datap(:,:,iterc));
        
        
        stE = CousineauSEM(datatoplot);
        sh = shadedErrorBar(use_xvec, squeeze(nanmean(datatoplot,1)), stE, [],1);
        sh.mainLine.Color = cmap(iterc,:);
        sh.mainLine.LineWidth = 4;
        sh.patch.FaceColor=  cmap(iterc,:);
        sh.edge(1).Color =   cmap(iterc,:);
        sh.edge(2).Color =   cmap(iterc,:);

        lg(iterc)= sh.mainLine;
       
        set(gca, 'ydir', 'normal')
        hold on;
%         plot([showt(1) showt(1)], [ -2 2], 'r', 'linew', 4)
%         plot([showt(2) showt(2)], [ -2 2], 'r', 'linew', 4)
        xlim([- 500 950])
        xlabel(['Time from ' dtype ' [ms]'])
        ylabel(['\muV']);
        
        set(gca, 'fontsize', 15);
        %%
       
        plot([0 0], ylim, ['k-'])

        figure(4); hold on;
        pspot = topospots(tcounter);
        subplot(nQuants,2,pspot);

        %convert showt to topotime:
        topot  =dsearchn(use_xvec', showt1');
        gfx= squeeze(nanmean(datac(:,:,:,iterc),1)); % mean over participants.
             topoData =nanmean(gfx(:,[topot(1):topot(2)]),2) ;% mean within time points:
             topoplot(topoData, elocs, 'emarker2', {[usechans], '.' 'w'} );
%              c=colorbar;
%              title([num2str(showt1(1)) '-' num2str(showt1(2)) 'ms (' dtype ' terc: ' num2str(iterc) ')'])
             title(['split: ' num2str(iterc) ])

set(gca, 'fontsize', fntsize/2)
%           
% ylabel(c, '\muV')
             caxis([-2 2]);set(gcf,'color', 'w')
            figure(1); hold on;
tcounter=tcounter+1;
    end

%% add ttests if nquants ==2
figure(1);
if nQuants==2
    pvals=[];
    for itime= 1:length(use_xvec)
        [h, pvals(itime)]= ttest(datap(:, itime,1), datap(:, itime, 2));

        if pvals(itime)< .05
            text(use_xvec(itime), -3, '*', 'HorizontalAlignment','center')

        end


    end
end


    %%
    hold on;
    plot(xlim, [0 0], 'k:')
    if idtype==2 && nQuants==4
    legend(lg, {'lowest confidence', 'lower confidence', 'higher confidence', 'highest confidence'}, 'location', 'NorthEast', 'fontsize', 12) ; 
    elseif idtype==2 && nQuants ==2
        legend(lg, {'low confidence', 'high confidence'});
    end
    set(gca, 'fontsize', 15);
    end
    %%   
    cd(figdir);
        cd('Confidence x ERPs')
    set(gcf, 'color', 'w')
    %%
    printname = ['GFX partB ERPs x Conf terc '];
    figure(1);
    print('-dpng', printname)
figure(4);
    printname = ['GFX partB ERPs x Conf topos '];
        print('-dpng', printname)

    %%
