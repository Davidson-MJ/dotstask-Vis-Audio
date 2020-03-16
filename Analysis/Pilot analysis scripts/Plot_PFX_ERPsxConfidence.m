basedir= '/Users/mdavidson/Desktop/dotstask- Vis+Audio EXP/EEG/ver2';

getelocs;
cmap = cbrewer('qual', 'Set1', 3);
% usechan = 31;

meanoverChans = [11,12,19,47,46,48,49,32,56,20,31,57];
smoothON=0;
%%
for ippant=1%:length(pfols)
    cd(basedir)
   clf
    cd(pfols(ippant).name);
    
    %real ppant number:
    lis = pfols(ippant).name;
    ppantnum = str2num(cell2mat(regexp(lis, '\d*', 'Match')));
    
    %PLOT participant level ERPs.
    
    load('part B ERPs by confidence')    
    %%
    figure(2);  clf;
    set(gcf, 'units', 'normalized', 'position', [0 .45 .8 .4]);
    
    for idtype = 1:2
        switch idtype
            case 1
                datac = conf_x_slEEG;
                dtype = 'stimulus onset';
            case 2
                datac = conf_x_rlEEG; % response locked
                dtype = 'response onset';
        end
        
  
    subplot(1,2,idtype)
    
    showt = [50, 300]; % times for topoplots to be displayed.
    lg=[];
    for iterc =1:2%size(datac,3)
        
        
   
        datatoplot = squeeze(nanmean(datac(meanoverChans,:,iterc),1));
        
        if smoothON==1
        winsizet = dsearchn(plotXtimes', [0 100]'); % 100ms smooth window.
            winsize = diff(winsizet);
        datatoplot = smooth(datatoplot, winsize);
        end
        

       lg(iterc)= plot(plotXtimes, datatoplot, 'color', cmap(iterc,:), 'linew', 3);
        hold on;

         set(gca, 'ydir', 'reverse')
        hold on;
        xlim([- 200 600])
        xlabel(['Time from ' dtype ' [ms]'])
        ylabel(['uV']);
        
        set(gca, 'fontsize', 15);
        %%       
        plot([0 0], ylim, ['k-'])
        plot(xlim, [0 0], ['k-'])
        
        set(gca, 'fontsize', 15);
        %%       
    end
    %%
%     legend(lg, {'lowest confidence', 'medium confidence', 'highest confidence'}, 'location', 'SouthEast', 'fontsize', 15)
    legend(lg, {'lowest confidence', 'highest confidence'}, 'location', 'SouthEast', 'fontsize', 15)
    title(['Participant ' num2str(ippant) ' ' dtype ', (' ExpOrder{2} ')' ]);    
    end
    %%   
    cd(basedir);
    cd ../../
    %%
    cd('Figures')
    cd('Confidence x ERPs')
    
    set(gcf, 'color', 'w')
    %%
    printname = ['participant ' num2str(ippant) ' respERPs x Conf terc'];
    print('-dpng', printname)
    
    
  
end
