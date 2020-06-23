
%PLOT GFX, stim and response locked ERPs

basedir= '/Users/mdavidson/Desktop/dotstask- Vis+Audio EXP';
cd(basedir)
cd('EEG')
cd('GFX')
load('GFX_averageERPs TRIG based.mat')
smoothON=1;

figure(1);  clf;
set(gcf, 'units', 'normalized', 'position', [0 .35 .7 .6]);
%
getelocs;

exppart = {'1st half', '2nd half'};


usechan = 31;

for ixmod = 1:2
    
    switch ixmod
        case 1
            datac = GFX_audstimERP;
            showt = [300,500]; %ms;
            titleis=  'Auditory stimulus';
            
        case 2
            datac= GFX_visstimERP;
            showt = [80,190]; %ms;
            titleis=  'Visual stimulus';
    end
    
    
    %apply smoothing to dataset:
    %50 ms window.
    if smoothON==1
        printname = ['GFX stimulus locked ERP topography smoothed'];
        winsize =  ceil(250/20); % 50 ms
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
    
    for plotts = 1:2
        plotspot = plotts + 2*(ixmod-1);
        
        subplot(3,4,plotspot);
        topoplot(nanmean(datac(:,:,topoX(plotts)),1), biosemi64);
        c=colorbar;
        ylabel(c, 'uV')
        caxis([-5 5])
        title([num2str(showt(plotts)) 'ms'])
        set(gca, 'fontsize', 15);
    end
    
    plotspot = [5:6,9:10] + 2*(ixmod-1);
    
    subplot(3,4,plotspot);
    
    plot(plotXtimes, squeeze(nanmean(datac,1)), 'k')
    set(gca, 'ydir', 'reverse')
    hold on;
    plot([showt(1) showt(1)], [ -2 2], 'r', 'linew', 4)
    plot([showt(2) showt(2)], [ -2 2], 'r', 'linew', 4)
    
    xlabel(['Time from stimulus onset [ms]'])
    ylabel(['uV']);
    
    set(gca, 'fontsize', 15);
    ylim([-12 5])
    title([titleis])
    plot([0 0], ylim, ['k-'])
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

%% >>>>>>>>>>>>>>>>> now response locked.

%
%
% figure(1);  clf;
% set(gcf, 'units', 'normalized', 'position', [0 .35 .7 .6], 'color', 'w');
% %
% getelocs;
%
%
% for ixmod = 1:2
%
%     if ixmod==1
% %         dataCOR = squeeze(nanmean(GFX_audrespCOR,1));
% %         dataErr = squeeze(nanmean(GFX_audrespERR,1));
%         g1=GFX_audrespCOR;
%         g2=GFX_audrespERR;
%         titleis = 'Auditory stimulus';
%     else
% %         dataCOR = squeeze(nanmean(GFX_visrespCOR,1));
% %         dataErr = squeeze(nanmean(GFX_visrespERR,1));
%         g1=GFX_visrespCOR;
%         g2=GFX_visrespERR;
%         titleis = 'Visual stimulus';
%     end
% %     datac= dataErr-dataCOR;
%
%     tmp1 = g2-g1;
%     datac=squeeze(mean(tmp1,1));
%
%      %apply smoothing to dataset, for plotting:
%     %50 ms window.
%     if smoothON==1
%         printname =['GFX response locked diff-ERP topography smoothed'] ;
%      winsize = 250/20;
%     tmpout= zeros(size(datac));
%     for ichan=1:size(datac,1)
%         tmpout(ichan,:) = smooth(datac(ichan,:), winsize);
%     end
%
%     datac=tmpout;
%     else
%        printname =['GFX response locked diff-ERP topography'] ;
%     end
%
%
%
%     %times for topography
%     showt=[60,250];
%     topoX=dsearchn(plotXtimes', showt');
%
%
%
%     for plotts = 1:2
%         plotspot = plotts + 2*(ixmod-1);
%
%         subplot(3,4,plotspot);
%         topoplot(datac(:,topoX(plotts)), biosemi64);
%         colorbar
%         caxis([-5 5])
%         title([num2str(showt(plotts)) 'ms'])
%     end
%
%     plotspot = [5:6,9:10] + 2*(ixmod-1);
%
%     subplot(3,4,plotspot);
%
%     plot(plotXtimes, datac, 'k')
%     set(gca, 'ydir', 'reverse')
%     hold on;
%     plot([showt(1) showt(1)], [ -2 2], 'r', 'linew', 4)
%     plot([showt(2) showt(2)], [ -2 2], 'r', 'linew', 4)
%
%
%     xlabel(['Time from response onset [ms]'])
%     ylabel(['uV']);
%     set(gca, 'fontsize', 15);
%    ylim([-12 5])
%     title(['Error - correct after ' titleis])
%     plot([0 0], ylim, ['k-'])
% end
% colormap('magma')
% %%
% basedir= '/Users/mdavidson/Desktop/dotstask- Vis+Audio EXP';
% cd(basedir);
% cd('Figures')
% cd('Response locked ERPs')
% set(gcf, 'color', 'w')
% print('-dpng', printname)

%% alternate plot
figure(1);  clf;
set(gcf, 'units', 'normalized', 'position', [0 .35 .7 .6], 'color', 'w');
%
getelocs;
%%
for ixmod = 1:2
    
    if ixmod==1
        g1=GFX_audrespCOR;
        g2=GFX_audrespERR;
        titleis = 'Auditory stimulus';
    else
        %         dataCOR = squeeze(nanmean(GFX_visrespCOR,1));
        %         dataErr = squeeze(nanmean(GFX_visrespERR,1));
        g1=GFX_visrespCOR;
        g2=GFX_visrespERR;
        titleis = 'Visual stimulus';
    end
    %     datac= dataErr-dataCOR;
    
    topo1 = g2-g1;
    
    %mean difference waveform.
    datac=squeeze(nanmean(topo1,1));
    
    %apply smoothing to dataset, for plotting:
    %50 ms window.
    if smoothON==1
        printname =['GFX response locked compare ERP topography smoothed'] ;
        winsize = 250/10;
        tmpout= zeros(size(datac));
        for ichan=1:size(datac,1)
            tmpout(ichan,:) = smooth(datac(ichan,:), winsize);
        end
        
        datac=tmpout;
    else
        printname =['GFX response locked compare ERP topography no detrend'] ;
    end
    
    
    
    %times for topography
    showt=[60,250];
    topoX=dsearchn(plotXtimes', showt');
    
    
    
    for plotts = 1:2
        plotspot = plotts + 2*(ixmod-1);
        
        subplot(3,4,plotspot);
        topoplot(datac(:,topoX(plotts)), biosemi64);
        c=colorbar;
        %         caxis([-5 5])
        title([num2str(showt(plotts)) 'ms'])
        set(gca, 'fontsize', 15)
        ylabel(c, 'uV')
    end
    
    plotspot = [5:6,9:10] + 2*(ixmod-1);
    
    subplot(3,4,plotspot);
    
    %PLOT the Correct and ERRORs separtely.
    %%
    d1 = squeeze((g1(:,usechan,:)));
    d2 = squeeze((g2(:,usechan,:)));
    
    stE1 = CousineauSEM(d1);
    stE2 = CousineauSEM(d2);
    %%
    p1= plot(plotXtimes, squeeze(nanmean(d1,1)), 'b', 'linew', 2); hold on
    p2= plot(plotXtimes, squeeze(nanmean(d2,1)), 'color', 'r', 'linew', 2);
    
    diffplot= p2.YData - p1.YData;
    plot(plotXtimes, diffplot, 'k', 'linew', 4)
    set(gca, 'ydir', 'reverse')
    
    hold on;
    
    
    xlabel(['Time from response onset [ms]'])
    ylabel(['uV']);
    set(gca, 'fontsize', 15);
    ylim([-10 10])
    title(['Response ERP at ' biosemi64(usechan).labels  ' after ' titleis])
    plot([0 0], ylim, ['k-'])
    plot([xlim], [0 0], ['k-'])
    ytx= get(gca, 'ylim');
    
    plot([showt(1) showt(1)], [ ytx(1)*.4 ytx(1)*.9], 'color', [.7 .7 .7], 'linew', 4)
    plot([showt(2) showt(2)], [ ytx(1)*.4 ytx(1)*.9], 'color', [.7 .7 .7], 'linew', 4)
    ylim([-12 5])
    legend('Correct', 'Error', 'Err-Corr')
end
colormap('magma')
set(gcf, 'color', 'w')
%
basedir= '/Users/mdavidson/Desktop/dotstask- Vis+Audio EXP';
cd(basedir);
cd('Figures')
cd('Response locked ERPs')
set(gcf, 'color', 'w')
print('-dpng', printname)

