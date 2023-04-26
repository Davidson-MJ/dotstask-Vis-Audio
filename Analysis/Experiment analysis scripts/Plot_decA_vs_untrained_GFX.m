% called from JOBS_ERPdecoder.m
%plot GFX of decoder trained on part A C vs E, on untrained trials.





jobs.concat_GFX=1;
jobs.plot_GFX=1;
%%
%plotType
job.plotERNorPe=2; % 1 or 2.

useVorScalpProjection= 1;

%>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
%% % load and concat across subjects (if previous step was re-run).
if jobs.concat_GFX==1;
    
    [GFX_classifierA_topo_ERN,GFX_classifierA_onERP_ERN ]=deal([]);
    [GFX_classifierA_topo_Pe,GFX_classifierA_onERP_Pe ]=deal([]);
    
    
    %first concatenate across subjects:
    [vis_first, aud_first] = deal([]);
    for ippant = 1:length(pfols)
        
        
        cd(eegdatadir)
        cd(pfols(ippant).name);
        %% load the Classifer and behavioural data:
        load('Classifier_trained_A_resp_Pe_window');
        load('Epoch information', 'ExpOrder');
        
        if useVorScalpProjection== 1; % use the raw discrim vector.
       %Pe
        GFX_classifierA_onERP_Pe(ippant,:,:) = squeeze(mean(PFX_classifierA_onERP_PEtrained,2));
        GFX_classifierA_topo_Pe(ippant,:) = squeeze(mean(DEC_Pe_window.scalpproj,1));
        else % use the scalp projection of the discrim vector:
%       %Pe
        GFX_classifierA_onERP_Pe(ippant,:,:) = squeeze(mean(PFX_classifierA_onERP_PEtrained_fromscalp,2));
        GFX_classifierA_topo_Pe(ippant,:) = squeeze(mean(DEC_Pe_window.scalpproj,1));
        end
            
        clear PFX_classifierA_onERP_ERNtrained PFX_classifierA_onERP_PEtrained;
        
        if strcmpi(ExpOrder{1}, 'visual')
            vis_first = [vis_first, ippant];
        else
            aud_first= [aud_first, ippant];
        end
        disp(['Fin concat (dec trained on Pe in A) for ppant ' num2str(ippant)]);
    end
    %%
    % save!
    cd(eegdatadir);
    cd('GFX')
    %other plot features:
    Xtimes = DEC_Pe_window.xaxis_ms;
    
%     GFX_classifierA_onERP_Pe_fromscalp = GFX_classifierA_onERP_Pe;
%     save('GFX_DecA_predicts_untrainedtrials', ...
%         'GFX_classifierA_onERP_Pe_fromscalp', '-append');
        
    save('GFX_DecA_Pe_predicts_untrainedtrials', ...
        'GFX_classifierA_onERP_Pe',...
        'GFX_classifierA_topo_Pe', ...
        'vis_first', 'aud_first', 'Xtimes');
%     
    
end % concat job

%%%%%%%
%% now plot GFX
if jobs.plot_GFX==1;
    
    %separate into Aud and Visual.
cmap = cbrewer('qual', 'Paired',10);
colormap(cmap)
% viscolour = cmap(3,:);
% audcolour=cmap(9,:);
grCol=cmap(4,:); %greenish
redCol =cmap(6,:); %reddish
    
    %load if necessary.
    cd([eegdatadir filesep 'GFX']);
    if ~exist('GFX_classifierA_onERP_ERN', 'var');
        load('GFX_DecA_predicts_untrainedtrials');
    end
    
    smoothON=0; % apply moving window av to prettify plot.
    
    elocs = readlocs('BioSemi64.loc');
    
    if job.plotERNorPe==1; % 1 or 2.
       %data
        GFX_classifierA_onERP =GFX_classifierA_onERP_ERN;
        %training window (ms)           
    windowvec = DEC_ERN_windowparams.training_window_ms;
        %scalp topo
        GFX_classifierA_topo =GFX_classifierA_topo_ERN;
        
        winwas= 'ERN';
    elseif job.plotERNorPe==2
        
        
%         GFX_classifierA_onERP =GFX_classifierA_onERP_Pe_fromscalp;
        GFX_classifierA_onERP =GFX_classifierA_onERP_Pe;
        
        % add training window
        windowvec = DEC_Pe_windowparams.training_window_ms;
        GFX_classifierA_topo =GFX_classifierA_topo_Pe;
        winwas= 'Pe';
    end
        
    
for iorder = 1%:3
    switch iorder
        case 1
            useppants = vis_first;
            orderis = 'visual-audio';
        case 2
            useppants = aud_first;
            orderis = 'audio-visual';
            
        case 3
            useppants = 1:length(pfols);
            orderis = 'all';
    end
    figure(1); clf;
    set(gcf, 'units', 'normalized', 'Position', [0.1 0.1 .7 .7]); shg
    leg=[];
    
    for itestdata = 1:6
        
        switch itestdata
            case 1 % corr A
            subplot(2, 2, 1);
            
            usecol = grCol;
            case 2 % corr B
                subplot(2, 2, 3);
            usecol = grCol;
            case 3
                %errA
                subplot(2, 2, 1);
                usecol= redCol;
                title('train visual (Pe): test visual resp ')
            case 4 % err B
                subplot(2, 2, 3);
                title('train visual (Pe): test auditory resp')
                usecol= redCol;
                
        end


            plotdata = squeeze(GFX_classifierA_onERP(useppants,itestdata,:));
      if itestdata==5 % pCorrect
            subplot(2,2,2);
%             %E + inverse Corr.
%             plotdata = squeeze(GFX_classifierA_onERP(useppants,3,:))+ (.5-squeeze(GFX_classifierA_onERP(useppants,1,:)));
            usecol='k';
        elseif itestdata==6
            subplot(2,2,4);
%             plotdata = squeeze(GFX_classifierA_onERP(useppants,4,:))+ (.5-squeeze(GFX_classifierA_onERP(useppants,2,:)));
%             usecol='k';
        end
        % for plots, zero on y axis:
%         plotdata = plotdata-0.5; 
        
        if smoothON==1
            winsize = 256/20;
            for ip = 1:size(plotdata,1)
                plotdata(ip,:) = smooth(plotdata(ip,:), winsize);
            end
        end
        stE = CousineauSEM(plotdata);
        
        sh= shadedErrorBar(Xtimes, squeeze(mean(plotdata,1, 'omitnan')), stE, {'color', usecol},1);
        
        
        if itestdata<3
            sh.mainLine.LineWidth = 3;
            sh.mainLine.LineStyle= '-';
        else
            sh.mainLine.LineWidth = 2;
            sh.mainLine.LineStyle= ':';
        end
        
        leg(itestdata) = sh.mainLine;
        
        hold on
        %ttests
        pvals= nan(1, length(Xtimes));
        for itime = 1:length(Xtimes)
            [~, pvals(itime)] = ttest(plotdata(:,itime), .5);
            
            if pvals(itime)<.05
                text(Xtimes(itime), [.40+(0.01*itestdata)], '*', 'color', usecol,'fontsize', 25);
            end
        end
        %    pvals(pvals>=.05) = nan;
        %    plot(Xtimes, pvals<.05, '*');
        % %plot sig points.
        % text(Xtimes(pvals<.05), [0.2], '*',  'color', cmap(itestdata,:), 'FontSize', 5)
    
    
    ylim([.40 .8])
    % add extra plot elements:
    hold on; plot(xlim, [.5 .5], '--', 'color', [.3 .3 .3], 'linew', 3)
    hold on; plot([0 0 ], ylim, '--', 'color', [.3 .3 .3], 'linew', 3)
    
    if itestdata==1;
        %add patch
        ylims = get(gca, 'ylim');
        pch = patch([windowvec(1) windowvec(1) windowvec(2) windowvec(2)], [ylims(1) ylims(2) ylims(2) ylims(1)], [.8 .8 .8]);
        pch.FaceAlpha= .1;
    end
    xlabel('Time since response (ms)')
    if itestdata<5
        ylabel('p(Error)');
    else
        ylabel('A.U.C.');
    end
    set(gca, 'fontsize', 15)
     set(gca,'ydir', 'normal')
     
     if itestdata>2
        % place legend. 
        legend([leg(1) leg(3)] , {'corrects', 'errors'});
        
     end
    end % itest data
    %%
%     title({['Order ' orderis ', nreps ' num2str(nIterations)];['Time-course of discriminating component, (trained Corr A vs Err A)']}, 'fontsize', 25);
    %%
%     legend(leg, {['Corr A'],['Corr B '], ['Err A'], ['Err B']})
   
    
    
    figure(2);
    topoplot(nanmean(GFX_classifierA_topo,1), elocs);
    title(['GFX, spatial projection'])
    set(gca, 'fontsize', 15)
    %% print results
    cd(figdir)
    cd(['Classifier Results' filesep 'PFX_Trained on resp Errors in part A, Pe window']);
    
    %%
    set(gcf, 'color', 'w')
    printname = ['GFX classifier trained on Correct part A-' winwas ', w-' num2str(nIter) 'reps (fromscalp)' ];
    
    if smoothON==1
        printname = [printname ', smoothed'];
    end
    print('-dpng', printname);
    
end
end % print job.