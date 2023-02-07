
cmap = cbrewer('seq', 'Reds', 4);
% usechan = 31;

elocs = readlocs('BioSemi64.loc'); %%

meanoverChans = [11,12,19,47,46,48,49,32,56,20,31,57];
smoothON=0;
%%
for ippant=1%length(pfols)
    cd(eegdatadir)
    clf
    cd(pfols(ippant).name);
    
    %real ppant number:
    lis = pfols(ippant).name;
    ppantnum = str2num(cell2mat(regexp(lis, '\d*', 'Match')));
    
    %PLOT participant level ERPs.
    
%     load('part B ERPs by confidence')    
    load('part B Long ERPs by confidence')    
    %%
    figure(2);  clf;
    set(gcf, 'units', 'normalized', 'position', [0 0 1 1]);
    
    for idtype = 1:2
        switch idtype
            case 1
                datac = conf_x_slEEG;
                dtype = 'stimulus onset';
                use_xvec = ([1:size(conf_x_slEEG,2)]./ 256 - 0.5 ) *1000 ;
            case 2
                datac = conf_x_rlEEG; % response locked
                dtype = 'response onset';
                use_xvec = plotXtimes;
        end
        
  
    subplot(1,2,idtype)
    
    showt = [50, 300]; % times for topoplots to be displayed.
    %%
    lg=[];
    for iterc =1:size(datac,3)
        
        
        ntrials = length(terclists(iterc).list);
        datatoplot = squeeze(nanmean(datac(meanoverChans,:,iterc),1));
        
        if smoothON==1
        winsizet = dsearchn(use_xvec', [0 100]'); % 100ms smooth window.
            winsize = diff(winsizet);
        datatoplot = smooth(datatoplot, winsize);
        end
        
        try
            lg(iterc)= plot(use_xvec, datatoplot, 'color', cmap(iterc,:), 'linew', 3);
        catch
            lg(iterc) = plot(0,0,'k.');
        end
        hold on;

         set(gca, 'ydir', 'reverse')
        hold on;
        if idtype==1
         xlim([- 200 2000])
        else
        xlim([- 200 1000])
        end
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
    legend(lg, {['lowest confidence n' num2str(length(terclists(1).list))], ...
        ['n' num2str(length(terclists(2).list))],...
        ['n' num2str(length(terclists(3).list))],...
        ['highest confidence n ' num2str(length(terclists(1).list))]}, 'location', 'SouthEast', 'fontsize', 15)
    
%     legend(lg, {'lowest confidence', 'highest confidence'}, 'location', 'SouthEast', 'fontsize', 15)
    title(['Participant ' num2str(ippant) ' ' dtype ', (' ExpOrder{2} ')' ]);    
    end
    %%   
    cd(figdir)
    cd('Confidence x ERPs')
    
    set(gcf, 'color', 'w')
    %%
    printname = ['participant ' num2str(ippant) ' respERPs x Conf terc (long NEW)'];
    print('-dpng', printname)
    
    
  
end
