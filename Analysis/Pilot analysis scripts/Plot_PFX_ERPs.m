
    basedir= '/Users/mdavidson/Desktop/dotstask- Vis+Audio EXP';

for ippant=1:length(pfol)
    cd(basedir)
    cd('EEG')
    
    cd(pfol(ippant).name);
    
    %real ppant number:
    lis = pfol(ippant).name;
    ppantnum = str2num(cell2mat(regexp(lis, '\d*', 'Match')));
    
    %PLOT participant level ERPs.
    smoothON=0;
    load('participant TRIG extracted ERPs.mat');
    
    %%
    figure(2);  clf;
    set(gcf, 'units', 'normalized', 'position', [0 .35 .7 .6]);
    %
    getelocs;
    
    exppart = {'1st half', '2nd half'};
    
    for ixmod = 1:2
        
        if strcmp(ExpOrder{ixmod}, 'auditory')
            
            datac = EEG_audstim;
            showt = [300,500]; %ms;
            
            plottones=1;
            
        else
            
            datac= EEG_visstim;
            showt = [100,350]; %ms;
            
            plottones=0;
        end
        
        
        
        %apply smoothing to dataset:
        %50 ms window.
        if smoothON==1
            printname = ['Participant' num2str(ppantnum) ' target locked ERP topography smoothed'];
            winsize =  ceil(250/20); % 50 ms
            tmpout = zeros(size(datac));
            for ichan=1:size(datac,1)
                for itrial = 1:size(datac,3)
                    
                    tmpout(ichan,:,itrial) = smooth(squeeze(datac(ichan,:,itrial)), winsize);
                end
            end
            
            datac=tmpout;
        else
            printname=['Participant' num2str(ppantnum) ' target locked ERP topography no detrend'];
        end
        %full screen
        
        %auditory times are:
        
        topoX=dsearchn(plotXtimes', showt');
        %
        %%
        for plotts = 1:2
            plotspot = plotts + 2*(ixmod-1);
            
            subplot(3,4,plotspot);
            topoplot(mean(datac(:,topoX(plotts),:),3), biosemi64);
            c=colorbar;
            ylabel(c, 'uV')
            caxis([-10 10])
            title([num2str(showt(plotts)) 'ms'])
            set(gca, 'fontsize', 15);
        end
        %%
        plotspot = [5:6,9:10] + 2*(ixmod-1);
        
        subplot(3,4,plotspot);
        
        plot(plotXtimes, mean(datac,3), 'k')
        set(gca, 'ydir', 'reverse')
        hold on;
        plot([showt(1) showt(1)], [ -2 2], 'r', 'linew', 4)
        plot([showt(2) showt(2)], [ -2 2], 'r', 'linew', 4)
        
        xlabel(['Time from stimulus onset [ms]'])
        ylabel(['uV']);
        
        set(gca, 'fontsize', 15);
        %%
        % also plot tones (patches) to help with interpretation.
        % Note that the tone triggers were sent at tone Onset.
        % 100ms ON ,  500ms break, then 100 ms tone.,
        if plottones==1
            %patch tone 1
            patch([0 0 100 100], [-5 5 5 -5], [.9 .9 .9], 'FaceAlpha', .1 );
            patch([500 500 600 600], [-5 5 5 -5], [.9 .9 .9], 'FaceAlpha', .1 );
        end
        
        ylim 'auto'
        title([ExpOrder{ixmod}  ' stimulus ' exppart{ixmod}])
        plot([0 0], ylim, ['k-'])
    end
    colormap('viridis')
    %%
    basedir= '/Users/mdavidson/Desktop/dotstask- Vis+Audio EXP';
    cd(basedir);
    
    cd('Figures')
    cd('Stimulus locked ERPs')
    set(gcf, 'color', 'w')
    %%
    print('-dpng', printname )
    
    %% >>>>>>>>>>>>>>>>> now response locked.
    
    %
    %
    % figure(1);  clf;
    % set(gcf, 'units', 'normalized', 'position', [0 .35 .7 .6]);
    % %
    % getelocs;
    %
    %
    %
    % for ixmod = 1:2
    %
    %     if ixmod==1
    %         dataCOR = squeeze(nanmean(EEG_cor_A,3));
    %         dataErr = squeeze(nanmean(EEG_err_A,3));
    %
    %     else
    %         dataCOR = squeeze(nanmean(EEG_cor_B,3));
    %         dataErr = squeeze(nanmean(EEG_err_B,3));
    %     end
    %
    %     if strcmp(ExpOrder{ixmod}, 'auditory')
    %         titleis = 'Auditory stimulus';
    %
    %     else
    %         titleis = 'Visual stimulus';
    %     end
    %
    %     %times for topography
    %     showt=[60,250];
    %     topoX=dsearchn(plotXtimes', showt');
    %
    %     datac= dataErr-dataCOR;
    %     if smoothON==1
    %     tmpout= zeros(size(datac));
    %     for ichan=1:size(datac,1)
    %         tmpout(ichan,:) = smooth(datac(ichan,:), winsize);
    %     end
    %     datac=tmpout;
    %     end
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
    %     xlabel(['Time from response onset [ms]'])
    %     ylabel(['uV']);
    %     set(gca, 'fontsize', 15);
    %     ylim([-15 15])
    %     title(['Error - correct after ' titleis ' ' exppart{ixmod}])
    %     plot([0 0], ylim, ['k-'])
    % end
    % colormap('viridis')
    % %%
    % basedir= '/Users/mdavidson/Desktop/dotstask- Vis+Audio EXP';
    % cd(basedir);
    % cd('Figures')
    % cd('Response locked ERPs')
    %
    % print('-dpng', printname)
    
    %% ALTERNATE VErSION.
    
    
    
    
    figure(1);  clf;
    set(gcf, 'units', 'normalized', 'position', [0 .35 .7 .6]);
    %
    getelocs;
    
    
    usechan = 31 ; % Pz;
    for ixmod = 1:2
        
        if ixmod==1
            dataCOR = squeeze(nanmean(EEG_cor_A,3));
            dataErr = squeeze(nanmean(EEG_err_A,3));
            
        else
            dataCOR = squeeze(nanmean(EEG_cor_B,3));
            dataErr = squeeze(nanmean(EEG_err_B,3));
        end
        
        if strcmp(ExpOrder{ixmod}, 'auditory')
            titleis = 'Auditory stimulus';
            
        else
            titleis = 'Visual stimulus';
        end
        
        %times for topography
        showt=[60,250];
        topoX=dsearchn(plotXtimes', showt');
        
        datac= dataErr-dataCOR;
        if smoothON==1
            tmpout= zeros(size(datac));
            for ichan=1:size(datac,1)
                tmpout(ichan,:) = smooth(datac(ichan,:), winsize);
            end
            datac=tmpout;
        end
        
        for plotts = 1:2
            plotspot = plotts + 2*(ixmod-1);
            
            subplot(3,4,plotspot);
            topoplot(datac(:,topoX(plotts)), biosemi64);
            colorbar
            caxis([-2 2])
            title([num2str(showt(plotts)) 'ms'])
        end
        
        plotspot = [5:6,9:10] + 2*(ixmod-1);
        
        subplot(3,4,plotspot);
        %PLOT the Correct and ERRORs separtely.
        %%
        d1 = squeeze(dataCOR(usechan,:));
        d2 = squeeze(dataErr(usechan,:));
        
        %%
        p1= plot(plotXtimes, squeeze(mean(d1,1)), 'b', 'linew', 2); hold on
        p2= plot(plotXtimes, squeeze(mean(d2,1)), 'color', 'r', 'linew', 2);
        
        diffplot= p2.YData - p1.YData;
        plot(plotXtimes, diffplot, 'k', 'linew', 4)
        set(gca, 'ydir', 'reverse')
        
        hold on;
        
        
        xlabel(['Time from response onset [ms]'])
        ylabel(['uV']);
        set(gca, 'fontsize', 15);
        ylim([-10 10])
        title(['Response ERP at ' biosemi64(usechan).labels  ' after ' titleis ' ' exppart{ixmod}])
        
        ylim([-15 15])
        
        ytx= get(gca, 'ylim');
        
        plot([showt(1) showt(1)], [ ytx(1)*.4 ytx(1)*.9], 'color', [.7 .7 .7], 'linew', 4)
        plot([showt(2) showt(2)], [ ytx(1)*.4 ytx(1)*.9], 'color', [.7 .7 .7], 'linew', 4)
        plot([0 0], ylim, ['k-'])
        plot([xlim], [0 0], ['k-'])
        
        legend('Correct', 'Error', 'Err-Corr')
    end
    %%
    colormap('viridis')
    set(gcf, 'color', 'w')
    %%
    basedir= '/Users/mdavidson/Desktop/dotstask- Vis+Audio EXP';
    
    cd(basedir);
    cd ../
    
    cd('Figures')
    cd('Response locked ERPs')
    printname = ['Participant' num2str(ippant) ' response locked ERP no detrend'];
    print('-dpng', [printname])
end
