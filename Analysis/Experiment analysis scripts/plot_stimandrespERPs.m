
smoothON=0;  % smooth the output by sliding 50ms window?
%first plot the stimulus locked ERPs.


meanoverChans_RESP = [11,12,19,47,46,48,49,32,56,20,31,57];
meanoverChans_VIS = [20:31, 57:64];
meanoverChans_AUD = [4:15,39:52];


elocs = readlocs('BioSemi64.loc');

job1.plotStimlocked=1;
job1.plotResplocked=0;
%%
for ippant=1:length(pfols)
    
    
    cd(eegdatadir)
    
    
    cd(pfols(ippant).name);
    
    %PLOT participant level ERPs.
    
    load('participant TRIG extracted ERPs.mat');
    load('Epoch information');
    exppart = {'1st half', '2nd half'};
    %%
    
    
    if job1.plotStimlocked==1
        %use stim locke, correct and error split:
        
        
        
        %timevector
        plotXtimes = ([1:size(plotm,2)] ./ 256   -  0.5)*1000; %ms
   
        
        
        figure(2);  clf;
        set(gcf, 'units', 'normalized', 'position', [0 0 1 1]);
        
        
        for ixmod = 1:2
            
            % how many correct and error trials?
            if ixmod==1
                nCor = length(corAindx);
                nErr = length(errAindx);
            else
                nCor = length(corBindx);
                nErr = length(errBindx);
            end
            
            % which modality was first in the exp:
            if strcmpi(ExpOrder{ixmod}, 'audio')
                datac = corr_Aud_sl;
                datae = err_Aud_sl;
                
                showt = [200,400]; %ms;
                plottones=1;
                meanoverChans= meanoverChans_AUD;
                
                
            else
                datac = corr_Vis_sl;
                datae = err_Vis_sl;
                showt = [100,350]; %ms;
                
                plottones=0;
                meanoverChans= meanoverChans_VIS;
            end
            
            %apply smoothing to dataset?:
            %50 ms window.
            if smoothON==1
                printname = [pfols(ippant).name  ' target locked ERP smoothed'];
                winsize =  ceil(256/20); % 50 ms
                [tmpoutc, tmpoute] = deal(zeros(size(datac)));
                for ichan=1:size(datac,1)
                    for itrial = 1:size(datac,3)
                        
                        tmpoutc(ichan,:,itrial) = smooth(squeeze(datac(ichan,:,itrial)), winsize);
                        tmpoute(ichan,:,itrial) = smooth(squeeze(datae(ichan,:,itrial)), winsize);
                    end
                end
                
                datac=tmpoutc;
                datae=tmpoute;
            else
                printname=[pfols(ippant).name ' target locked ERP (long)'];
            end
            %full screen
            
            %auditory times are:
            
            topoX=dsearchn(plotXtimes', showt');
            %
            %% show topo plots at times of interest.
            for plotts = 1:2
                plotspot = plotts + 2*(ixmod-1);
                
                subplot(3,4,plotspot);
                topoplot(mean(datac(:,topoX(plotts),:),3), elocs, 'emarker2', {[meanoverChans], 's' 'w'} );
                c=colorbar;
                ylabel(c, 'uV')
                caxis([-10 10])
                title([num2str(showt(plotts)) 'ms (correct)'])
                set(gca, 'fontsize', 15);
            end
            %% now plot ERP.
            plotspot = [5:6,9:10] + 2*(ixmod-1);
            
            subplot(3,4,plotspot);
            
            
            dataplot = datae-datac; % difference waveform.
            
            
            temp =mean(dataplot,3);
            plotm = squeeze(mean(temp(meanoverChans,:),1));
            
            
            
            plot(plotXtimes, plotm, 'k', 'linew', 5)
            set(gca, 'ydir', 'reverse')
            hold on;
            ylim([-15 15])
            
            ytx= get(gca, 'ylim');
            
            plot([showt(1) showt(1)], [ ytx(1)*.4 ytx(1)*.9], 'color', [.7 .7 .7], 'linew', 4)
            plot([showt(2) showt(2)], [ ytx(1)*.4 ytx(1)*.9], 'color', [.7 .7 .7], 'linew', 4)
            
            %PLOT the Correct and ERRORs separtely.
            %%
            d1 = squeeze(datac(meanoverChans,:));
            d2 = squeeze(datae(meanoverChans,:));
            
            %%
            p1= plot(plotXtimes, squeeze(mean(d1,1)), [':b'], 'linew', 2); hold on
            p2= plot(plotXtimes, squeeze(mean(d2,1)),  [':r'], 'linew', 2);
            

            set(gca, 'ydir', 'reverse')
            
            hold on;
            
            xlabel(['Time from stimulus onset [ms]'])
            ylabel(['uV']);
            legend([p1 p2], {['corr n' num2str(nCor)], ['err n' num2str(nErr)]})
            set(gca, 'fontsize', 15);
            %%
            % also plot tones (patches) to help with interpretation.
            % Note that the tone triggers were sent at tone Onset.
            % 100ms ON ,  500ms break, then 100 ms tone.,
            
            
            
            title([ExpOrder{ixmod}  ' stimulus ' exppart{ixmod}])
            
            plot([0 0], ylim, ['k-'])
        end
        colormap('viridis')
        %%
        cd(figdir)
        cd('Stimulus locked ERPs')
        set(gcf, 'color', 'w')
        %%
        print('-dpng', printname )
        
    end
    
    %% resp locked VErSION.
    
    
    if job1.plotResplocked==1
        
        figure(1);  clf;
        set(gcf, 'units', 'normalized', 'position', [0 0 1 1]);
        %
        meanoverChans=meanoverChans_RESP;
        
        
        for ixmod = 1:2
            
            if ixmod==1
                
                
                dataCOR =  nanmean(resplockedEEG(:,:,corAindx),3);
                dataErr = nanmean(resplockedEEG(:,:,errAindx),3);
                
                nCor= length(corAindx);
                nErr= length(errAindx);
            else
                dataCOR =  nanmean(resplockedEEG(:,:,corBindx),3);
                dataErr = nanmean(resplockedEEG(:,:,errBindx),3);
                
                nCor= length(corBindx);
                nErr= length(errBindx);
            end
            
            if strcmpi(ExpOrder{ixmod}, 'audio')
                titleis = 'Auditory stimulus';
                
            else
                titleis = 'Visual stimulus';
            end
            
            %times for topography
            showt=[60,250];
            topoX=dsearchn(plotXtimes', showt');
            
            if smoothON==1
                %smooth both datasets.
                [tmpout1, tmpout2]= deal(zeros(size(dataCOR)));
                for ichan=1:size(datac,1)
                    tmpout1(ichan,:) = smooth(dataCOR(ichan,:), winsize);
                    tmpout2(ichan,:) = smooth(dataErr(ichan,:), winsize);
                end
                dataCOR = tmpout1;
                dataErr=tmpout2;
                printname = [pfols(ippant).name ' response locked ERP smoothed'];
            else
                printname = [pfols(ippant).name ' response locked ERP'];
            end
            
            
            datac= dataErr-dataCOR;
            
            
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
                topoplot(mean(datac(:,[topot(1):topot(2)]),2), elocs, 'emarker2', {[meanoverChans], 's' 'w'} );
                c=colorbar;
                title([num2str(realt(1)) '-' num2str(realt(2)) 'ms'])
                set(gca, 'fontsize', 15)
                ylabel(c, 'uV')
            end
            
            
            
            
            plotspot = [5:6,9:10] + 2*(ixmod-1);
            
            subplot(3,4,plotspot);
            %PLOT the Correct and ERRORs separtely.
            %%
            d1 = squeeze(dataCOR(meanoverChans,:));
            d2 = squeeze(dataErr(meanoverChans,:));
            
            %%
            p1= plot(plotXtimes, squeeze(mean(d1,1)), [':b'], 'linew', 2); hold on
            p2= plot(plotXtimes, squeeze(mean(d2,1)),  [':r'], 'linew', 2);                        
            set(gca, 'ydir', 'reverse')
            
            hold on;
            
            
            xlabel(['Time from response onset [ms]'])
            ylabel(['uV']);
            set(gca, 'fontsize', 15);
            %         ylim([-10 10])
            title(['Response ERP after ' titleis ' ' exppart{ixmod}])
            
            %         ylim 'auto'
            ylim([-10 10])
            
            ytx= get(gca, 'ylim');
            
            %         plot([showt(1) showt(1)], [ ytx(1)*.4 ytx(1)*.9], 'color', [.7 .7 .7], 'linew', 4)
            %         plot([showt(2) showt(2)], [ ytx(1)*.4 ytx(1)*.9], 'color', [.7 .7 .7], 'linew', 4)
            
            ph=patch([showt1(1) showt1(1) showt1(2) showt1(2)], [ytx(1) ytx(2) ytx(2) ytx(1) ],  [.7 .7 .7]);
            ph.FaceAlpha=.2;
            ph=patch([showt2(1) showt2(1) showt2(2) showt2(2)], [ytx(1) ytx(2) ytx(2) ytx(1) ],  [.7 .7 .7]);
            ph.FaceAlpha=.2;
            
            plot([0 0], ylim, ['k-'])
            plot([xlim], [0 0], ['k-'])
            
            legend(['Correct (n' num2str(nCor) ')'], ['Error (n' num2str(nErr) ')'], 'Err-Corr')
            xlim([- 200 600]);
        end
        %%
        colormap('viridis')
        set(gcf, 'color', 'w')
        %%
        
        cd(figdir)
        cd('Response locked ERPs')
        
        print('-dpng', [printname])
    end
end
