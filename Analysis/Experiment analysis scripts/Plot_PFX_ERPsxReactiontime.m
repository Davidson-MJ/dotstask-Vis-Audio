% Plot_PFX_ERPsxReactiontime%
cmap = flipud(cbrewer('seq', 'Blues', 5));
% usechan = 31;

elocs = getelocs(3);%

% meanoverChans = [11,12,19,47,46,48,49,32,56,20,31,57];
meanoverChans_RESP = [4,38,39,11,12,19,47,46,48,49,32,56,20,31,57];

smoothON=0;
%%
for ippant=1:length(pfols)
    cd(eegdatadir)
    clf
    cd(pfols(ippant).name);
    
    %real ppant number:
    lis = pfols(ippant).name;
    ppantnum = str2num(cell2mat(regexp(lis, '\d*', 'Match')));
    
    %PLOT participant level ERPs.
        load('part A and B ERPs by reaction time')   ;
        load('Epoch information');

        use_xvec = plotXtimes(1:size(stimlockedEEG,2));
    %%
    figure(2);  clf;
    set(gcf, 'units', 'normalized', 'position', [0 0 1 1]);
    icounter=1;
    for ipart=1:2  % A and B of exp.

        xmodwas ={'visual', 'audio'};
        terclistsAll= {terclists_partA, terclists_partB};
    for idtype = 1:2
        switch idtype
            case 1
                datac = rt_x_slEEG;
                dtype = 'stimulus onset';
            case 2
                datac = rt_x_rlEEG; % response locked
                dtype = 'response onset';
        end
        
  
                
    subplot(2,2,icounter)
    
    showt = [50, 300]; % times for topoplots to be displayed.
    %%
    lg=[];
    for iterc =1:size(datac,3)
        
        
        ntrials = length(terclists(iterc).list);
        datatoplot = squeeze(nanmean(datac(meanoverChans_RESP,:,iterc, ipart),1));
        
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
         xlim([- 200 1000])
        ylim([-10 10]);
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
    legend(lg, {['shortest rt n' num2str(length(terclistsAll{ipart}(1).list))], ...
        ['n' num2str(length(terclistsAll{ipart}(2).list))],...
        ['n' num2str(length(terclistsAll{ipart}(3).list))],...
        ['longest rt  n ' num2str(length(terclistsAll{ipart}(1).list))]}, 'location', 'SouthEast', 'fontsize', 15)
    
%     legend(lg, {'lowest confidence', 'highest confidence'}, 'location', 'SouthEast', 'fontsize', 15)
    title(['Participant ' num2str(ippant) ' ' dtype ', (' xmodwas{ipart} ')' ]);    
    icounter=icounter+1;
        end % ipart
    end % stim-resp
    %%   
    cd(figdir)
    cd('Reactiontimes x ERPs')
    
    set(gcf, 'color', 'w')
    %%
    printname = ['participant ' num2str(ippant) ' ERPs x rt terc'];
    print('-dpng', printname)
    
    
  
end
