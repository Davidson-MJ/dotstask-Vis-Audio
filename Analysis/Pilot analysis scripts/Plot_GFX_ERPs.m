
%PLOT GFX, stim and response locked ERPs

job1.plotStimlocked =0;
job1.plotResplocked =0;

basedir= '/Users/mdavidson/Desktop/dotstask- Vis+Audio EXP';
cd(basedir)
cd('EEG')
%
cd('ver2')
cd('GFX')
load('GFX_averageERPs TRIG based.mat')
smoothON=0;
%%
figure(1);  clf;
set(gcf, 'units', 'normalized', 'position', [0 .35 .7 .6]);
%
getelocs;

exppart = {'1st half', '2nd half'};

meanoverChans = [11,12,19,47,46,48,49,32,56,20,31,57];
meanoverChans_VIS = [20:31, 57:64];
meanoverChans_AUD = [4:15,39:52];
    
%%
if job1.plotStimlocked ==1
clf
for ixmod = 1:2
    
    switch ixmod
        case 1
            datac= GFX_visstimERP(vis_first, :,:);
            showt1 = [345,445]; %ms;
            showt2=[500,600];
            titleis=  'Part A (visual)';
         meanoverChans_tmp= meanoverChans_VIS;
         stimbar = [0 300];
         
        case 2
            
               datac = GFX_audstimERP(vis_first,:,:);
              showt1 = [280,380]; %ms;
            showt2=[600,700];
            titleis=  'Part B (auditory)';
            meanoverChans_tmp= meanoverChans_AUD;
            stimbar = [180 280];
    end
    
    
    %apply smoothing to dataset:
    %50 ms window.
    if smoothON==1
        printname = ['GFX stimulus locked ERP topography smoothed'];
        winsize =  ceil(256/20); % 50 ms
        tmpout = zeros(size(datac));
        for ippant=1:size(datac,1)
            for ichan= 1:size(datac,2)
                
                tmpout(ippant,ichan,:) = smooth(squeeze(datac(ippant,ichan,:)), winsize);
            end
        end
        datac=tmpout;
    else
        printname=['GFX stimulus locked ERP topography no detrend'];
    end
    
    topoX=dsearchn(plotXtimes', showt');
    %
    %%
     %times for topography
  
    topoX1=dsearchn(plotXtimes', showt1');    
    topoX2=dsearchn(plotXtimes', showt2');
    
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

    subplot(3,4,plotspot);     
  
    gfx = squeeze(mean(datac,1));
    
    topoplot(mean(gfx(:,[topot(1):topot(2)]),2), biosemi64, 'emarker2', {[meanoverChans_tmp], 's' 'w'} );
    c=colorbar;        
        title([num2str(realt(1)) '-' num2str(realt(2)) 'ms'])        
        set(gca, 'fontsize', 15)
        ylabel(c, 'uV')
    end
    %%
%     
%   
%   PREPARE ERP PLOTS  
    plotspot = [5:6,9:10] + 2*(ixmod-1);
    
    subplot(3,4,plotspot);
    
    %place patches first (as background)   
    ylim([-12 5])
    
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
    
    plotme = squeeze(nanmean(datac(:,meanoverChans_tmp,:),2));
        
    stERP = CousineauSEM(plotme);
    sh=shadedErrorBar(plotXtimes, mean(plotme,1), stERP, 'k', 1);
    
%     plot(plotXtimes, plotm, 'k', 'linew', 3)
    
    set(gca, 'ydir', 'reverse')
    hold on;
    set(gca, 'fontsize', 25);
    ylim([-12 5])
    title([titleis])
    plot([0 0], ylim, ['k-'])
     xlim([- 200 1000]);
    
    
    xlabel(['Time from stimulus onset [ms]'])
    ylabel(['uV']);
        
     %plot stim bar to aid interp of ERP waveforms
     
     xvs= [stimbar(1) stimbar(1) stimbar(2) stimbar(2)];
     yvs= [4 5 5 4];
     pch=patch(xvs, yvs, ['k']);
     if ixmod==2 % add second tone.
     patch(xvs+600, yvs,['k'])
     end
     legend(pch, 'stimulus', 'location', 'SouthWest')
end
colormap('magma')
%%
basedir= '/Users/mdavidson/Desktop/dotstask- Vis+Audio EXP';
cd(basedir);

cd('Figures')
cd('Stimulus locked ERPs')
set(gcf, 'color', 'w')
 
%%

print('-dpng', printname)
end



if job1.plotResplocked ==1
%% >>>>>>>>>>>>>>>>> now response locked.

figure(1);  clf;
set(gcf, 'units', 'normalized', 'position', [0 .35 .7 .6], 'color', 'w');
%
getelocs;
%
for iorder=1%:2
   
    if iorder==1
        useppants = vis_first;
        orderw = 'visual-audio';
    else
        useppants = aud_first;
        orderw = 'audio-visual';
    end
        
for ixmod = 1:2 % which order to use?
    
    if ixmod==1
     g1=GFX_visrespCOR(useppants,:,:);
        g2=GFX_visrespERR(useppants,:,:);
        titleis = 'Visual response Part A';
    else
        %         dataCOR = squeeze(nanmean(GFX_visrespCOR,1));
        %         dataErr = squeeze(nanmean(GFX_visrespERR,1));        
           g1=GFX_audrespCOR(useppants,:,:);
        g2=GFX_audrespERR(useppants,:,:);
        titleis = 'Auditory response, part B';
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
        printname =['GFX response locked compare ERP'] ;
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
    topoplot(mean(datac(:,[topot(1):topot(2)]),2), biosemi64, 'emarker2', {[meanoverChans], 's' 'w'} );
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
    p1= plot(plotXtimes, squeeze(nanmean(d1,1)), [':b'], 'linew', 2); hold on
    p2= plot(plotXtimes, squeeze(nanmean(d2,1)), [':r'], 'linew', 2);
    
    diffplot= p2.YData - p1.YData;
    pd= plot(plotXtimes, diffplot, 'k', 'linew', 6);
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
    xlim([- 200 600]);
%     ylim([-5 8])
end
colormap('magma')
set(gcf, 'color', 'w')
%
basedir= '/Users/mdavidson/Desktop/dotstask- Vis+Audio EXP';
cd(basedir);
cd('Figures')
cd('Response locked ERPs')
set(gcf, 'color', 'w')
%%
print('-dpng', [printname ])
end
end
