
% elocs= getelocs(3); % biosemi

cmap = flipud(cbrewer('seq', 'Reds', 5));
smoothON=0;

meanoverChans_RESP = [4,38,39,11,12,19,47,46,48,49,32,56,20,31,57];
% meanoverChans_RESP_POCC=

meanoverChans_POCC = [20:31, 57:64];

% meanoverChans_Pe = [12:14,17:32, 48:51, 54:64];
% tr= table((1:length(elocs))',{elocs(:).labels}' );
% disp(tr)
% elocs list
%       1     {'FP1'}
%       2     {'AF7'}
%       3     {'AF3'}
%       4     {'F1' }
%       5     {'F3' }
%       6     {'F5' }
%       7     {'F7' }
%       8     {'FT7'}
%       9     {'FC5'}
%      10     {'FC3'}
%      11     {'FC1'}
%      12     {'C1' }
%      13     {'C3' }
%      14     {'C5' }
%      15     {'T7' }
%      16     {'TP7'}
%      17     {'CP5'}
%      18     {'CP3'}
%      19     {'CP1'}
%      20     {'P1' }
%      21     {'P3' }
%      22     {'P5' }
%      23     {'P7' }
%      24     {'P9' }
%      25     {'PO7'}
%      26     {'PO3'}
%      27     {'O1' }
%      28     {'IZ' }
%      29     {'OZ' }
%      30     {'POZ'}
%      31     {'PZ' }
%      32     {'CPZ'}
%      33     {'FPZ'}
%      34     {'FP2'}
%      35     {'AF8'}
%      36     {'AF4'}
%      37     {'AFZ'}
%      38     {'FZ' }
%      39     {'F2' }
%      40     {'F4' }
%      41     {'F6' }
%      42     {'F8' }
%      43     {'FT8'}
%      44     {'FC6'}
%      45     {'FC4'}
%      46     {'FC2'}
%      47     {'FCZ'}
%      48     {'CZ' }
%      49     {'C2' }
%      50     {'C4' }
%      51     {'C6' }
%      52     {'T8' }
%      53     {'TP8'}
%      54     {'CP6'}
%      55     {'CP4'}
%      56     {'CP2'}
%      57     {'P2' }
%      58     {'P4' }
%      59     {'P6' }
%      60     {'P8' }
%      61     {'P10'}
%      62     {'PO8'}
%      63     {'PO4'}
%      64     {'O2' }

% showt1 = [800 900]; % ms for topo averages

tcounter=1;
% PLOT Group level ERPs.
cd(eegdatadir)
fntsize= 20;
cd('GFX')
%
load('GFX_averageERPsxConf.mat');
use_xvec = plotXtimes(1:size(GFX_conf_x_slEEG,3)); % adjusting for preprocessed length
%
figure(1);  clf;
set(gcf, 'color', 'w', 'units', 'normalized', 'position', [0.1 0.1 .35 .6]);
fsize=20;

% set(gcf, 'units', 'normalized', 'position', [0.1 .1 .8 .3],'color', 'w');
figure(4); clf;

%     use_xvec =

tpcounter=1; % topoplot counter.
for idtype = [3,4]%[3,4]%1:3 (stim locked, resp locked, rl subjcorr)
    usechans = [meanoverChans_RESP, meanoverChans_POCC];
    switch idtype
        case 1
            datac = GFX_conf_x_slEEG;
            dtype = 'auditory stimulus onset';
            %                 usechans = [meanoverChans_RESP, meanoverChans_POCC];
        case 2
            datac = GFX_conf_x_rlEEG; % response locked
            dtype = 'auditory response onset';
            %                 usechans = meanoverChans_POCC;
            %                 usechans = meanoverChans_RESP;
            %                 usechans = meanoverChans_Pe;
        case 3

            datac = GFX_conf_x_slEEG_subjCorr; % response locked
            dtype = 'auditory stimulus onset';
            showtoppotimes = [250 450]; % ms for topo averages

        case 4

            datac = GFX_conf_x_rlEEG_subjCorr; % response locked
            showtoppotimes = [750 950]; % ms for topo averages

            dtype = 'auditory response onset';
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



    lg=[];

    figure(1); hold on;

    subplot(2,2,idtype-2); hold on
    
    ylim([-4 6]);
    % show patch first:
    ytx= get(gca, 'ylim');
    hold on
    %plot topo patches.

    for itwin= 1:size(showtoppotimes,1)
        ph=patch([showtoppotimes(itwin,1) showtoppotimes(itwin,1) showtoppotimes(itwin,2) showtoppotimes(itwin,2)], [ytx(1) ytx(2) ytx(2) ytx(1) ],  [.9 .9 .9]);
        % ph.FaceAlpha=.4;
        ph.LineStyle= 'none';
    end



    %%
    nQuants= size(GFX_conf_x_slEEG,4);
    if nQuants==4
        topospots= [1,3,5,7,9,11, 2,4,6,8,10,12];% order for topoplots in FIgure 4
    else
        topospots= [1,2,3,4];
    end
    %%

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
        %         xlim([- 500 950])
        xlabel(['Time from ' dtype ' [ms]'])
        ylabel(['\muV']);

        set(gca, 'fontsize', fsize);
        %%

        plot([0 0], ylim, ['k-'])

        figure(4); hold on;
        %         pspot = topospots(tcounter);
        % ncols=nQuants*size(showtoppotimes,1)*3;
        ncols=4
        for itwin = 1:size(showtoppotimes,1)
            subplot(2,2,topospots(tcounter));

            %convert showt to topotime:
            topot  =dsearchn(use_xvec', showtoppotimes(itwin,:)');
            gfx= squeeze(nanmean(datac(:,:,:,iterc),1)); % mean over participants.
            % or difference
            tmpD= squeeze(datac(:,:,:,2)-datac(:,:,:,1));
            gfx=squeeze(nanmean(tmpD,1));
            
            topoData =nanmean(gfx(:,[topot(1):topot(2)]),2) ;% mean within time points:
            topoplot(topoData, elocs, 'emarker2', {[usechans], '.' 'w'} );
            %              c=colorbar;
            % title([num2str(showtoppotimes(1)) '-' num2str(showtoppotimes(2)) 'ms (' dtype ' terc: ' num2str(iterc) ')'])
            % title(['split: ' num2str(iterc) ' time: ' num2str(itwin)])
            c=colorbar;
            ylabel(c,'\muV', 'fontsize', 25);
            set(c,'fontsize',25)
            
            if idtype==3;
            caxis([-1 1]);
            elseif idtype==4
                caxis([-1 1])
            end
            set(gca, 'fontsize', fntsize/2)
            % caxis([-2 2]);
            set(gcf,'color', [.9 .9 .9])
            tcounter=tcounter+1;


        end
        %%
        figure(10);
        subplot(4,1,idtype);
        topoData= ones(1,length(elocs));
        topoplot(topoData, elocs, 'emarker2', {[usechans], '.' 'm'}, 'whitebk', 'on' ,'conv', 'on','numcontour',1);
        cmapG=[.9 .9 .9];
        colormap(cmapG);
        shg


        figure(1); hold on;
        %              tpcounter= tpcounter+1;

        % ifr
    end
    %%
    if idtype==4

        hold on;
        p=plot([800 800], [0 2], ['b-'],'linewidth',3, 'MarkerFaceColor', 'b');
        p=plot([800 800], [.3 .3], ['bv'], 'MarkerFaceColor', 'b','Markersize',10);

    end

    %% add ttests if nquants ==2
    % subplot(2,2, idtype+2); % plot diff for sanity check.
    % diffP = datap(:,:,2) - datap(:,:,1);
    % stE- CousineauSEM(diffP);
    %  sh = shadedErrorBar(use_xvec, squeeze(nanmean(diffP,1)), stE, [],1);
    %  xlim([- 500 950])
    %%

    figure(1);
    if nQuants==2

        pvals=[];
        tvals=[];

        for itime= 1:length(use_xvec)
            [h, pvals(itime),~,stats]= ttest(squeeze(datap(:, itime,1)), squeeze(datap(:, itime, 2)));

            tvals(itime) = stats.tstat;

            %plot uncorrected?
            if pvals(itime)<= .05
                % text(use_xvec(itime), -3, '*', 'HorizontalAlignment','center')

            end


        end

        if idtype==4
        %% temporal cluster based correction:
        ttestdata = datap; %(size = ppants, timepoints, groups)
        compareTo=0; % null dataset ?
        %note that pvals and tvals are fed in:
        temporalclustercheck_2group;
        end



    end
    %
    % [q,thresh]=FDR(pvals);
    % pcorr= find(pvals<thresh);
    % if ~isempty(pcorr)
    %
    % text(use_xvec(pcorr), repmat(-3, [1, length(pcorr)]), '*', 'fontsize',20,'HorizontalAlignment', 'center');
    % end
    %%
    hold on;
    plot(xlim, [0 0], 'k:')
    if idtype==2 && nQuants==4
        legend(lg, {'lowest confidence', 'lower confidence', 'higher confidence', 'highest confidence'}, 'location', 'NorthEast', 'fontsize', 12) ;
    elseif idtype==3 && nQuants ==2
        legend(lg, {'low confidence', 'high confidence'}, 'location','NorthWest');
    end
    set(gca, 'fontsize', fsize);

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
