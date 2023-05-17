%plot_stimandrespERPs_butterfly
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
    
    %PLOT participant level all trials.
    
    load('participant EEG preprocessed.mat');
    load('PFX ERPs.mat');
    load('Epoch information');
    exppart = {'1st half', '2nd half'};
    %%


    if job1.plotStimlocked==1
        %use stim locke, correct and error split:
        useData = stimlockedEEG;
        printname=[pfols(ippant).name ' target locked butterfly plot'];
        outputdir= 'Stimulus locked Butterfly plots';

        xlabis = 'stimulus';
    elseif job1.plotResplocked ==1
        useData = resplockedEEG;
        printname=[pfols(ippant).name ' response locked butterfly plot'];
        outputdir = 'Response locked Butterfly plots';
        xlabis = 'response';
    end


        
        figure(2);  clf;
        set(gcf, 'units', 'normalized', 'position', [.1 .1 .8 .8]);
        
        
        for ixmod = 1:2
            
            % how many correct and error trials?
            if ixmod==1
                nCor = length(corAindx);
                nErr = length(errAindx);

                datac_all = useData(:,:,corAindx);
                datae_all = useData(:,:,errAindx);

            else
                nCor = length(corBindx);
                nErr = length(errBindx);


                datac_all = useData(:,:,corBindx);
                datae_all = useData(:,:,errBindx);
            end
            


% we will actually combine (show all corrects and errors)
data_all = cat(3, datac_all, datae_all);

            % which modality are we showing :
            if strcmpi(ExpOrder{ixmod}, 'audio')
                
                showt = [300,900]; %ms;
                plottones=1;
                meanoverChans= meanoverChans_AUD;
                
            else
               
                showt = [200,350]; %ms;                
                plottones=0;
                meanoverChans= meanoverChans_VIS;

            end
            
            if job1.plotResplocked ==1 % same windows for response locked ERP topos
                               showt = [50,250]; %ms;    ERN Pe?  
                               meanoverChans=meanoverChans_RESP;
            end
            
            %full screen
            
            %auditory times are:
            plotXtimesPLOT = plotXtimes(1:size(data_all,2));
            topoX=dsearchn(plotXtimes', showt');
            %
            %% show topo plots at times of interest.
            for plotts = 1:2
                plotspot = plotts + 2*(ixmod-1);
                
                subplot(3,4,plotspot);
                topoplot(mean(data_all(:,topoX(plotts),:),3), elocs, 'emarker2', {[meanoverChans], '.' 'w'} );
                c=colorbar;
                ylabel(c, 'uV')
                caxis([-10 10])
                title([num2str(showt(plotts)) 'ms (all)'])
                set(gca, 'fontsize', 15);
            end
            %% imagesc
            plotspot = [5:6] + 2*(ixmod-1);
subplot(3,4, plotspot)
            %take mean over chans: 
            bERP = squeeze(mean(data_all(meanoverChans,:,:),1));
            imagesc(plotXtimesPLOT , 1:size(data_all,3), bERP');
            title(['all epochs n=' num2str(size(data_all,3))])
            %% now plot ERP.

            plotspot = [9:10] + 2*(ixmod-1);
            
            subplot(3,4,plotspot);
            
            
%             dataplot = datae-datac; % difference waveform.
            plot(plotXtimesPLOT , bERP' )
            axis tight
            ytx= get(gca, 'ylim');
            hold on;
            plot([showt(1) showt(1)], [ ytx(1)*.4 ytx(1)*.9], 'color', [.7 .7 .7], 'linew', 4)
            plot([showt(2) showt(2)], [ ytx(1)*.4 ytx(1)*.9], 'color', [.7 .7 .7], 'linew', 4)
            %%
            hold on
            yyaxis right
            plot(plotXtimesPLOT, mean(bERP,2), 'k', 'LineWidth',2);
            
           
            ylim([- 15 15])
            xlabel([ 'Time from ' xlabis ' onset [ms]'])
            ylabel(['uV']);
            set(gca, 'fontsize', 15, 'ycolor', 'k');
            %%
            % also plot tones (patches) to help with interpretation.
            % Note that the tone triggers were sent at tone Onset.
            % 100ms ON ,  500ms break, then 100 ms tone.,
            
            
            
            title([ExpOrder{ixmod}  ' ' xlabis ' ' exppart{ixmod}])
            
            plot([0 0], ylim, ['k-'])
        end
        colormap('viridis')
        %%
        cd(figdir)
        cd(outputdir)
        set(gcf, 'color', 'w')
        %%
        print('-dpng', printname )
        
    end
    
    

