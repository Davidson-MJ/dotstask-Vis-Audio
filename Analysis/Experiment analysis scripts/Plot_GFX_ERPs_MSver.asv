
%PLOT GFX, stim and response locked ERPs, combined for manuscript

cd(eegdatadir)
cd('GFX')
load('GFX_averageERPs TRIG based.mat')
smoothON=0;
hidetopos=1;
%%
figure(1);  clf;
set(gcf, 'units', 'normalized', 'position', [0.05 0.05 .8 .8]);

exppart = {'1st half', '2nd half'};

% meanoverChans = [11,12,19,47,46,48,49,32,56,20,31,57]; % resp
meanoverChans = [4,38,39,11,12,19,47,46,48,49,32,56,20,31,57];
meanoverChans_VIS = [20:31, 57:64];
meanoverChans_AUD = [4:15,39:52];
    
%same colours as beh data?
%separate into Aud and Visual.
cmap = cbrewer('qual', 'Paired',10);
% colormap(cmap)
% viscolour = cmap(3,:);
% audcolour=cmap(9,:);
grCol=cmap(4,:); %greenish
redCol =cmap(6,:); %reddish
elocs = readlocs('BioSemi64.loc'); %%
%
clf
subspots = [1,3];
for ixmod = 1:2
    
    switch ixmod
        case 1
%             datac= GFX_visstimERP(vis_first, :,:);
            datac= GFX_visstimCOR(vis_first, :,:);
            datae= GFX_visstimERR(vis_first, :,:);
            
            showt1 = [345,445]; %ms;
            showt2=[700,800]; % ms 
            titleis=  'Part A (visual)';
         meanoverChans_tmp= meanoverChans_VIS;
         stimbar = [0 300];
         use_xvec = ([1:size(datac,3)] ./ 256 - 0.7 ) * 1000;
         
        case 2
            
%                datac = GFX_audstimERP(vis_first,:,:);
            datac= GFX_audstimCOR(vis_first, :,:);
            datae= GFX_audstimERR(vis_first, :,:);
            
              showt1 = [280,380]; %ms;
            showt2=[600,700];
            titleis=  'Part B (auditory)';
            meanoverChans_tmp= meanoverChans_AUD;
            stimbar = [180 280]; %!Check! 
%             use_xvec = plotXtimes;
            use_xvec = ([1:size(datac,3)] ./ 256 - 0.7 ) * 1000; % (was - .5)
    end
    
    
    %apply smoothing to dataset:
    %50 ms window.
    if smoothON==1
        printname = ['GFX stimulus locked ERP topography smoothed'];
        winsize =  ceil(256/20); % 50 ms
        [tmpoutc, tmpoute] = deal(zeros(size(datac)));
        for ippant=1:size(datac,1)
            for ichan= 1:size(datac,2)
                
                tmpoutc(ippant,ichan,:) = smooth(squeeze(datac(ippant,ichan,:)), winsize);
                tmpoute(ippant,ichan,:) = smooth(squeeze(datae(ippant,ichan,:)), winsize);
            end
        end
        datac=tmpoutc;
        datae=tmpoute;
    else
        printname=['GFX stimulus locked ERP topography no detrend (long)'];
    end
    
    
    %
    %%
     %times for topography
     if ~hidetopos
         topoX1=dsearchn(use_xvec', showt1');
         topoX2=dsearchn(use_xvec', showt2');


         for plotts=1:2
             if plotts ==1
                 topot = topoX1;
                 realt = showt1;
             else
                 topot = topoX2;
                 realt = showt2;
             end

             %prepar topoplots
             plotspot = plotts + 2*(ixmod-1);


             subplot(2,2,plotspot);


             gfx = squeeze(mean(datac,1));

             topoplot(mean(gfx(:,[topot(1):topot(2)]),2), elocs, 'emarker2', {[meanoverChans_tmp], 's' 'w'} );
             c=colorbar;
             title([num2str(realt(1)) '-' num2str(realt(2)) 'ms (corr)'])
             set(gca, 'fontsize', 15)
             ylabel(c, 'uV')

             % add corr and err separately.

         end

     end
    %%
%     
%   
%   PREPARE ERP PLOTS  
%     plotspot = [5:6,9:10] + 2*(ixmod-1);
    
    subplot(2,2,subspots(ixmod));
    
    %place patches first (as background)   
    ylim([-8 8])
    
%place patches (as background) first:
    ytx= get(gca, 'ylim');    
hold on
%plot topo patches.
ph=patch([showt1(1) showt1(1) showt1(2) showt1(2)], [ytx(1) ytx(2) ytx(2) ytx(1) ],  [1 .9 .9]);
ph.FaceAlpha=.4;
ph.LineStyle= 'none';
ph=patch([showt2(1) showt2(1) showt2(2) showt2(2)], [ytx(1) ytx(2) ytx(2) ytx(1) ],  [1 .9 .9]);
ph.FaceAlpha=.4;
ph.LineStyle= 'none';
    
hold on
    
%% difference waveform:
    dataplot = datae-datac; % diff waveform. (error - correct).
    plotme = squeeze(nanmean(dataplot(:,meanoverChans_tmp,:),2));
        
    stERP = CousineauSEM(plotme);
%     sh=shadedErrorBar(use_xvec, mean(plotme,1), stERP, 'k', 1);
    
    
    %% now C and E separate:
    %%
    d1 = squeeze(nanmean(datac(:,meanoverChans,:),2));
    d2 = squeeze(nanmean(datae(:,meanoverChans,:),2));
    
    stE1 = CousineauSEM(d1);
    stE2 = CousineauSEM(d2);
    %%

    sh=shadedErrorBar(use_xvec, squeeze(nanmean(d1,1)), stE1,{'color',grCol, 'linew', 2},1);
    p1= sh.mainLine;
    hold on;
    sh=shadedErrorBar(use_xvec, squeeze(nanmean(d2,1)), stE1,{'color',redCol, 'linew', 2},1);
    p2= sh.mainLine;
    
    diffplot= p2.YData - p1.YData;
%     pd= plot(plotXtimes, diffplot, 'k', 'linew', 2);
    set(gca, 'ydir', 'reverse')
    
    hold on;
    
    
    
    
    set(gca, 'ydir', 'normal')
    hold on;
    set(gca, 'fontsize', 25);
    
    title([titleis])
    plot([0 0], ylim, ['k-'])
   
    
    if ixmod ==1
        xlim([- 200 2000]);
    else
        xlim([- 200 2000]);
    end
    
        
    
    
    xlabel(['Time from stimulus onset [ms]'])
    ylabel(['uV']);
        
     %plot stim bar to aid interp of ERP waveforms
     
     xvs= [stimbar(1) stimbar(1) stimbar(2) stimbar(2)];
     yvs= [-4.95 -5 -5 -4.95];
     pch=patch(xvs, yvs, ['k']);
     if ixmod==2 % add second tone.
     patch(xvs+600, yvs,['k'])
     end
     
%      legend([p1, p2, sh.mainLine, pch], {'cor', 'err', 'diff','stimulus'}, 'location', 'NorthEast')
%      legend([p1, p2, pch], {'cor', 'err', 'stimulus'}, 'location', 'NorthEast')
end
colormap('inferno')
cd(figdir)
cd('Stimulus locked ERPs')
set(gcf, 'color', 'w')
 
%% response locked:

%% have now restricted to just the vis- audio order.
for iorder=1%,2% 3 = all.
   
    switch iorder
        case 1
        useppants = vis_first;
        orderw = 'visual-audio';
        case 2
        useppants = aud_first;
        orderw = 'audio-visual';
        case 3
            useppants = 1:size(GFX_visrespCOR,1);
            orderw = 'All resp';
    end
        
for ixmod = 1:2
    
    if ixmod==1
        g1=GFX_visrespCOR(useppants,:,:);
        g2=GFX_visrespERR(useppants,:,:);
        
        if iorder==1
        titleis = 'Visual response Part A';
        elseif iorder==2
            titleis = 'Visual response, part B';
        elseif iorder==3
            titleis = 'All Visual response locked';
        end
    else
        %         dataCOR = squeeze(nanmean(GFX_visrespCOR,1));
        %         dataErr = squeeze(nanmean(GFX_visrespERR,1));        
           g1=GFX_audrespCOR(useppants,:,:);
           g2=GFX_audrespERR(useppants,:,:);
        if iorder==1
            titleis = 'Auditory response Part B';
        elseif iorder==2
            titleis = 'Auditory response, part A';
        elseif iorder==3
                    titleis = 'All Auditory response locked';
        end
    end
    
    %apply smoothing to dataset, for plotting:
    %50 ms window.
    if smoothON==1
        printname =['GFX response locked compare ERP smoothed'] ;
        winsize = 256/20; % 50 ms.
        
        tmpout1= zeros(size(g1));
        tmpout2= zeros(size(g2));
        
        %corrects.
        for ippanttmp = 1:size(g1,1)
            for ichan=1:size(g1,2)
                tmpout1(ippanttmp,ichan,:) = smooth(g1(ippanttmp,ichan,:), winsize);
            end
        end
        %errors.
        for ippanttmp = 1:size(g2,1)
            for ichan=1:size(g2,2)
                tmpout2(ippanttmp,ichan,:) = smooth(g2(ippanttmp,ichan,:), winsize);
            end
        end
        
        g1=tmpout1; g2=tmpout2;
    else
        printname =['GFX response locked compare ERP (NEW)'] ;
    end
    
    %difference:
    topo1 = g2-g1;
    
    
    %mean difference waveform.
    datac=squeeze(nanmean(topo1,1));
    
    %times for topography
    showt1=[-10,90];
    topoX1=dsearchn(plotXtimes', showt1');
    
    showt2=[250,350];
    topoX2=dsearchn(plotXtimes', showt2');
    for plotts=1:2
        if plotts ==1
            topot = topoX1;
            realt = showt1;
        else
            topot = topoX2;
            realt = showt2;
        end
    
    plotspot = plotts + 2*(ixmod-1);        
    subplot(3,4,plotspot);
%     topoplot(mean(datac(:,[topot(1):topot(2)]),2), elocs);
    topoplot(mean(datac(:,[topot(1):topot(2)]),2), elocs, 'emarker2', {[meanoverChans], 's' 'w'} );
    c=colorbar;        
        title([num2str(realt(1)) '-' num2str(realt(2)) 'ms'])        
        set(gca, 'fontsize', 15)
        ylabel(c, 'uV')
    end
    
    plotspot = [5:6,9:10] + 2*(ixmod-1);
    
    subplot(3,4,plotspot);
    
    %PLOT the Correct and ERRORs separtely.
     %place patches first (as background)   
    ylim([-5 8])
    
%place patches (as background) first:
    ytx= get(gca, 'ylim');    
hold on
%plot topo patches.
ph=patch([showt1(1) showt1(1) showt1(2) showt1(2)], [ytx(1) ytx(2) ytx(2) ytx(1) ],  [1 .9 .9]);
ph.FaceAlpha=.4;
ph.LineStyle= 'none';
ph=patch([showt2(1) showt2(1) showt2(2) showt2(2)], [ytx(1) ytx(2) ytx(2) ytx(1) ],  [1 .9 .9]);
ph.FaceAlpha=.4;
ph.LineStyle= 'none';
    
    
    
    %%
    d1 = squeeze(nanmean(g1(:,meanoverChans,:),2));
    d2 = squeeze(nanmean(g2(:,meanoverChans,:),2));
    
    stE1 = CousineauSEM(d1);
    stE2 = CousineauSEM(d2);
    %%

    sh=shadedErrorBar(plotXtimes, squeeze(nanmean(d1,1)), stE1,{'color',grCol, 'linew', 2},1);
    p1= sh.mainLine;
    hold on;
    sh=shadedErrorBar(plotXtimes, squeeze(nanmean(d2,1)), stE1,{'color',redCol, 'linew', 2},1);
    p2= sh.mainLine;
    
    diffplot= p2.YData - p1.YData;
    pd= plot(plotXtimes, diffplot, 'k', 'linew', 2);
    set(gca, 'ydir', 'reverse')
    
    hold on;
    
    
    xlabel(['Time from response onset [ms]'])
    ylabel(['uV']);
    set(gca, 'fontsize', 25);
    
    %%
    
%     title({[titleis ', (' orderw ')']})
    title(titleis )
     printname =[printname ', ' orderw ];
    
    %%
    plot([0 0], ylim, ['k-'])
    plot([xlim], [0 0], ['k-'])
    
    
    
    legend([p1 p2, pd], {'Correct', 'Error', 'Err-Corr'})
%     legend([p1 p2], {'Correct', 'Error'})
    xlim([- 200 600]);
%     ylim([-5 8])
end
colormap('inferno')
set(gcf, 'color', 'w')
%
cd(figdir)
cd('Response locked ERPs')
set(gcf, 'color', 'w')
%%
% print('-dpng', [printname ])
end

