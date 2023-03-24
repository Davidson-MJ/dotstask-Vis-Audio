
%PLOT

cd(eegdatadir)
cd('GFX')
load('GFX_averageERPs TRIG based.mat')
smoothON=0;
hidetopos=1;
%%

exppart = {'1st half', '2nd half'};

%ERP channels for plotting: (averages over the list).
meanoverChans_RESP = [4,38,39,11,12,19,47,46,48,49,32,56,20,31,57];
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
% subspots = [1,3];

%%  2 figures first the stim locked:
% then the Resp locked
titlesAre = {'visual', 'auditory'};

for idata= 1:2

figure(idata);  clf;
set(gcf, 'units', 'normalized', 'position', [0.05 0.05 .8 .8]);

if idata==1
    corrDataA = GFX_visstimCOR;
    errDataA = GFX_visstimERR;
    corrDataB = GFX_audstimCOR;
    errDataB = GFX_audstimERR;
    xlabis= 'stimulus';
    outputdir= 'Stimulus locked ERPs';

     showt1=[50,150];  % approx 
     showt2=[250,350]; % approx % change per stim

     
else % resp locked:

    corrDataA = GFX_visrespCOR;
    errDataA = GFX_visrespERR;
    corrDataB = GFX_audrespCOR;
    errDataB = GFX_audrespERR;
    xlabis= 'response';
    outputdir= 'Response locked ERPs';
% times for topoplots:
        showt1=[-10,90];  % approx ERN
     showt2=[250,350]; % approx Pe

end


for ixmod = 1:2 % Visual AUditory
    
    if ixmod==1
        g1=corrDataA;
        g2=errDataA;
        meanoverChans= meanoverChans_VIS;
    else
        g1=corrDataB;
        g2=errDataB;
        meanoverChans= meanoverChans_AUD;
    end
    
    % unless RESP< then overwrite:
    if idata==2

        meanoverChans= meanoverChans_RESP;
    end
    %apply smoothing to dataset, for plotting:
    %50 ms window.
    if smoothON==1
        printname =['GFX ' xlabis ' locked compare ERP smoothed'] ;
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
        printname =['GFX ' xlabis ' locked compare ERP'] ;
    end
    
    %difference:
    topo1 = g2-g1; %(errors - correct)
    
    
    %mean difference waveform.
    datac=squeeze(nanmean(topo1,1));
    
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
    
    %plot data from Corrects?
tD = squeeze(nanmean(g1,1));


    plotspot = plotts + 2*(ixmod-1);        
    subplot(3,4,plotspot);
    topoplot(mean(tD(:,[topot(1):topot(2)]),2), elocs, 'emarker2', {[meanoverChans], '.' 'w'} );
    c=colorbar;        
        title([num2str(realt(1)) '-' num2str(realt(2)) 'ms (Corr)'])        
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


    sh=shadedErrorBar(plotERPtimes, squeeze(nanmean(d1,1)), stE1,{'color',grCol, 'linew', 2},1);
    p1= sh.mainLine;
    hold on;
    sh=shadedErrorBar(plotERPtimes, squeeze(nanmean(d2,1)), stE1,{'color',redCol, 'linew', 2},1);
    p2= sh.mainLine;
    
    diffplot= p2.YData - p1.YData;
    pd= plot(plotERPtimes, diffplot, 'k', 'linew', 2);
    set(gca, 'ydir', 'reverse')
    
    hold on;
    
    
    xlabel(['Time from response onset [ms]'])
    ylabel(['uV']);
    set(gca, 'fontsize', 25);
    
    %%
    
%     title({[titleis ', (' orderw ')']})
    title(titlesAre{ixmod});
    
    %%
    plot([0 0], ylim, ['k-'])
    plot([xlim], [0 0], ['k-'])
end
%%
    
    
    legend([p1 p2, pd], {'Correct', 'Error', 'Err-Corr'})
%     legend([p1 p2], {'Correct', 'Error'})
%     xlim([- 200 600]);
%     ylim([-5 8])

colormap('inferno')
set(gcf, 'color', 'w')
%
cd(figdir)
cd(outputdir)
set(gcf, 'color', 'w')
%%
print('-dpng', [printname ])
%% 
end

