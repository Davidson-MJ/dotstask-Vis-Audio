


cmap = cbrewer('qual', 'Set1', 3);

meanoverChans = [11,12,19,47,46,48,49,32,56,20,31,57]; %response locked. channels.
meanoverChans_VIS = [20:31, 57:64];
meanoverChans_AUD = [4:15,39:52];

elocs= readlocs('BioSemi64.loc');
smoothON=0;
plottopos_sep = 1; % create a separate figure for the topoplots over defined window.
alltopos=[]; topocounter=1;% store topos for plotting a difference topo at end.
%% PLOT Group level ERPs.
cd(eegdatadir)
cd('GFX')
%%
load('GFX_averageERPsxConf.mat');
%%
figure(1); clf;
set(gcf, 'units', 'normalized', 'position', [0 0 1 1]);
%%


%plot types separately. visual - audio, then audio - visual
confis = {'low', 'high'};
for iorder=1%:2 % third case is all together (vis-audio, and audio-vis)
    
    figure(1); clf;
    alltopos=[]; 
    switch iorder
        case 1
            useppants = vis_first;
            orderi = 'part B audio';
        case 2
            useppants = aud_first;
            orderi = 'part B visual';
        case 3
            useppants = 1:size(GFX_conf_x_slEEG,1);
            orderi = 'All';
    end
    
    tcount=1; % topoplot counter.
    for idtype = 1:2
        switch idtype
            case 1
                datacIN = GFX_conf_x_slEEG;
                dtype = 'stimulus locked';
                if iorder==1
                    usechans= meanoverChans_AUD;
                elseif iorder==2                   
                    usechans= meanoverChans_VIS;
                end
                    
            case 2
                datacIN = GFX_conf_x_rlEEG; % response locked
                dtype = 'response locked';
                usechans = meanoverChans;
        end
        
        datac = squeeze(datacIN(useppants,:,:,:));
        
        lg=[];
        
        % no point in plotting the combined sensory ERP s (Vis+AUDIO)
        if iorder==3 && idtype==1 
            
            continue  % skip to resp locked.
            
        end
        for iterc =1:2
            %%
            figure(1); 
          
            %%
%             datatoplot = squeeze(nanmean(datac(:,meanoverChans,:,iterc),2));
            datatoplot = squeeze(nanmean(datac(:,usechans,:,iterc),2));
            
            if smoothON==1
                smwin = diff(dsearchn(plotXtimes', [0 50]'));
                for ip = 1:size(datatoplot,1)
                    datatoplot(ip,:) = smooth(datatoplot(ip,:), smwin);
                end
            end
            
            
            stE = CousineauSEM(datatoplot);
            %plot
            subplot(3,2,[idtype+2, idtype+4])
            hold on
            sh = shadedErrorBar(plotXtimes, squeeze(nanmean(datatoplot,1)), stE, [],1);
            sh.mainLine.Color = cmap(iterc,:);
            sh.mainLine.LineWidth = 4;
            sh.patch.FaceColor=  cmap(iterc,:);
            sh.edge(1).Color =   cmap(iterc,:);
            sh.edge(2).Color =   cmap(iterc,:);
            
            lg(iterc)= sh.mainLine;
            
            set(gca, 'ydir', 'reverse')
            hold on;
            
            xlim([- 500 1000])
            xlabel(['Time from ' dtype ' [ms]'])
            ylabel(['uV']);
            set(gca, 'fontsize', 25);
            ylim([-12 12]);
            plot([0 0], ylim, ['k-'])
            plot(xlim, [0,0], ['k-'])
            
            if iterc==2 && idtype==2
                legend([lg(1) lg(2)], {'lowest confidence', 'highest confidence'}, 'location', 'NorthEast', 'fontsize', 20) ;
                title(['GFX ' dtype ' ' orderi ', (n=' num2str(length(useppants)) ')']);% biosemi64(usechan).labels ]);
                
            end
            title( dtype)
             xlim([-200 1000]) 
             ylim([-12 6])
             box on
            if plottopos_sep ==1
                figure(10);
                subplot(2,4,tcount);
                set(gcf, 'units', 'normalized', 'position', [0 0 1 1]);
                %average over window:
                winav = dsearchn(plotXtimes', [200 350]');
                
                tdata = squeeze(mean(datac(:,:, winav(1):winav(2), iterc),3));
                
                plotme =squeeze(mean(tdata,1));
                keepchans = [20:32, 57:64];
                pmasks = zeros(1,64);
                pmasks(keepchans)=1;
                
                 
                 topoplot(plotme, elocs);%,  'pmask', pmasks);%, 'emarker2', {pmasks, '*', 'w', 10,3});               
                c=colorbar;
%                 caxis([-2 2])
                ylabel(c, 'uV');
                title({['after ' dtype ' ' orderi ];[confis{iterc} ' confidence'];['200-350ms']});
                set(gca, 'fontsize', 15);
                    tcount=tcount+1;

                alltopos(tcount,:) = plotme;
%add difference topo
            if mod(tcount,2)==0
                subplot(2,2,(tcount/2)+2);
                diffT = alltopos(tcount,:)-alltopos(tcount-1,:); % high -low conf.
                topoplot(diffT, elocs);
                c=colorbar;                
                ylabel(c, 'uV');
                title({['high - low'];['200-350ms']});
                set(gca, 'fontsize', 15);                
            end
            %%
        end
        %     legend(lg, {'lowest confidence', 'medium confidence', 'highest confidence'}, 'location', 'SouthEast', 'fontsize', 15) ;
        
      
    end
    end
    %% add label above all subplots.
    st=suptitle(orderi);
    st.FontSize=20;
    %%
    set(gcf, 'color', 'w')
    cd(figdir)
    cd('Confidence x ERPs')
    
    %%
    figure(1);
    set(gcf, 'color', 'w')
    printname = ['GFX partB ERPs x Conf terc for ' orderi ' (NEW)'];
    print('-dpng', printname)
    try
    figure(10);
    set(gcf, 'color', 'w')
    printname = ['GFX partB ERPs x Conf terc for ' orderi ' topoplots (NEW)'];
      print('-dpng', printname)
    catch 
    end
    
    
    
end
%%
% As an extra sanity check, plot the topography for high - low confidence,
% over 250-350 ms window.
%
% [timeav] = dsearchn(plotXtimes_2', [250, 350]');
%
% topo_lowconf= squeeze(mean(datac(:,:,timeav(1):timeav(2),1),3));
% topo_highconf = squeeze(mean(datac(:,:,timeav(1):timeav(2),3),3));
%
% %subtract,
% difftopo = topo_lowconf-topo_highconf;
% %average across subjects and plot
% figure();
% topoplot(squeeze(mean(difftopo,1)), biosemi64); colorbar;
%

