% Plot_GFX_ERPsxReactiontime
elocs= getelocs(3); % biosemi

cmap = flipud(cbrewer('seq', 'Blues', 5));
smoothON=1;

meanoverChans_FC = [4,38,39,11,12,19,47,46,48,49,32,56,20,31,57];
% meanoverChans_RESP_POCC= 

meanoverChans_POCC = [20:31, 57:64];
hidetopos=1;



showt1 = [250 450]; % ms for topo averages
topospots= [1,3,5,2,4,6];% order for topoplots in FIgure 4
tcounter=1;
% PLOT Group level ERPs.
cd(eegdatadir)
fntsize= 12;
cd('GFX')
%
load('GFX_averageERPsxRT.mat');
use_xvec = plotXtimes(1:size(GFX_rt_x_slEEG,3)); % adjusting for preprocessed length
%
figure(1);  clf;
set(gcf, 'units', 'normalized', 'position', [0.1 .1 .8 .8]);
%
icounter=1;
for ipart = 1:2  
     xmodwas ={'visual', 'audio'};

for idtype = 1:2
        switch idtype
            case 1
                datac = GFX_rt_x_slEEG;
                dtype = [xmodwas{ipart} ' stimulus onset'];
                usechans = [meanoverChans_FC, meanoverChans_POCC];
            case 2
                datac = GFX_rt_x_rlEEG; % response locked
                dtype = [xmodwas{ipart} ' response onset'];
                usechans = meanoverChans_POCC;
        end
        
    showt = [50, 300]; % times for topoplots to be displayed.
    lg=[];
    figure(1); hold on;

    subplot(2,2,icounter); hold on
    ylim([-4 4]);
    % show patch first:
    ytx= get(gca, 'ylim');
    hold on
    %plot topo patches.
    ph=patch([showt1(1) showt1(1) showt1(2) showt1(2)], [ytx(1) ytx(2) ytx(2) ytx(1) ],  [1 .9 .9]);
    ph.FaceAlpha=.4;
    ph.LineStyle= 'none';



    for iterc =1:4
      
        datatoplot = squeeze(mean(datac(:,usechans,:,iterc,ipart),2));
        
         if smoothON==1
        winsizet = dsearchn(use_xvec', [0 100]'); % 100ms smooth window.
            winsize = diff(winsizet);
            for isubj= 1:size(datatoplot,1)
        datatoplot(isubj,:) = smooth(datatoplot(isubj,:), winsize);
            end
            %
            disp(['HAVE SMOOTHED at participant level!']);
         end

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
        xlim([- 200 900])
        xlabel(['Time from ' dtype ' [ms]'])
        ylabel(['\muV']);
        
        set(gca, 'fontsize', 15);
        %%
       
        plot([0 0], ylim, ['k-'])

        if ~hidetopos
        figure(4); hold on;
        pspot = topospots(tcounter);
        subplot(3,2,pspot);

        %convert showt to topotime:
        topot  =dsearchn(use_xvec', showt1');
        gfx= squeeze(nanmean(datac(:,:,:,iterc),1)); % mean over participants.
             topoData =nanmean(gfx(:,[topot(1):topot(2)]),2) ;% mean within time points:
             topoplot(topoData, elocs, 'emarker2', {[usechans], '.' 'w'} );
%              c=colorbar;
             title([num2str(showt1(1)) '-' num2str(showt1(2)) 'ms (' dtype ' terc: ' num2str(iterc) ')'])
             set(gca, 'fontsize', fntsize/2)
%              ylabel(c, '\muV')
             caxis([-2 2]);
            figure(1); hold on;

            tcounter=tcounter+1;
        end
        end % terc
    %%
    legend(lg, {'shortest rt', 'shorter rt', 'longer rt', 'longest rt'}, 'location', 'SouthEast', 'fontsize', 15) ; 
    title(['GFX ' dtype ]);
    

    set(gca, 'fontsize', 15);
icounter=icounter+1;
end % datatypeax
    end % ipart
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
