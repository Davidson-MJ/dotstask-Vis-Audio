% called from JOBS_ERPdecoder.m
%plot GFX of decoder trained on part A C vs E, on untrained trials.


baselinetype=1; % normal response locked.
% baselinetype=2; % response locked with prestim baseline


jobs.concat_GFX=0;
jobs.plot_GFX=1;
%%
%plotType
job.plotERNorPe=2; % 1 or 2.

useVorScalpProjection= 1;

%>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
   
if baselinetype==1
    savename= 'GFX_DecA_Pe_predicts_untrainedtrials';
elseif baselinetype==2
    savename= 'GFX_DecA_Pe_predicts_untrainedtrials_wprestim';
end


%% % load and concat across subjects (if previous step was re-run).
if jobs.concat_GFX==1
    
    [GFX_classifierA_topo_ERN,GFX_classifierA_onERP_ERN ]=deal([]);
    [GFX_classifierA_topo_Pe,GFX_classifierA_onERP_Pe ]=deal([]);
    
    
    %first concatenate across subjects:
    [vis_first, aud_first] = deal([]);
    for ippant = 1:length(pfols)
        
        
        cd(eegdatadir)
        cd(pfols(ippant).name);
        %% load the Classifer and behavioural data:
        if baselinetype==1
            load('Classifier_trained_A_resp_Pe_window');
        else
            load('Classifier_trained_A_resp_Pe_window_wprestim');
        end
        
        %%
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
     
    save(savename, ...
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
        
        load(savename);
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
        
    
    
    
    useppants = 1:length(pfols);
    orderis = 'all';
    
    figure(1); 
    set(gcf, 'units', 'normalized', 'Position', [0.1 0.1 .35 .6]); shg
    leg=[];
    fsize=20;
    
    for itestdata = 6 % C,E, diff, C,E,diff.
        
        switch itestdata
            case 1 % corr A
                subplot(2, 2, 1);
                
                usecol = grCol;
                modality= 'visual';
                pheight = .36;
            case 2 % corr B
                subplot(2, 2, 3);
                cla
                usecol = grCol;
                modality= 'auditory';
                pheight = .42;
                
            case 3
                %errA
                subplot(2, 2, 1);
                usecol= redCol;
                title({['\rmtrain on \bfvisual (Pe)'];['\rmtest on \bfvisual \rmresponse']})
                modality= 'visual';
                pheight = .38;
            case 4 % err B
                subplot(2, 2, 3);
                title({['\rmtrain on \bfvisual (Pe)'];['\rmtest on \bfauditory \rmresponse']})
                usecol= redCol;
                modality = 'auditory';
                pheight = .44;
            case 5 
                modality= 'visual';
                pheight = .43; % ylim .35 .8
                pheight2= .39;
            case 6
                modality= 'auditory';
                
                pheight = .44; % ylim .40 .65
                pheight2= .42;
        end

        
        plotdata = squeeze(GFX_classifierA_onERP(useppants,itestdata,:));
        if itestdata==5 % pCorrect
            subplot(2,2,2);
            usecol='k';
        elseif itestdata==6
            subplot(2,2,4); cla
            %             plotdata = squeeze(GFX_classifierA_onERP(useppants,4,:))+ (.5-squeeze(GFX_classifierA_onERP(useppants,2,:)));
            %             usecol='k';
        end
        
        if smoothON==1
            winsize = 256/20; % 50 ms moving average?
            for ip = 1:size(plotdata,1)
                plotdata(ip,:) = smooth(plotdata(ip,:), winsize);
            end
        end
        
        % 
        stE = CousineauSEM(plotdata);        
        sh= shadedErrorBar(Xtimes, squeeze(mean(plotdata,1, 'omitnan')), stE, {'color', usecol},1);




        if mod(itestdata,2)==0
            ylim([.4 .65]);
            % ylim([.35 .8])
        else
            ylim([.35 .8])
        end
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
        [pvals, tvals]= deal(nan(1, length(Xtimes)));

        for itime = 1:length(Xtimes)
            [~, pvals(itime),~, stat] = ttest(plotdata(:,itime), .5);
            
            tvals(itime)=stat.tstat;
            % plot uncorrected?
            if pvals(itime)<.05
                % text(Xtimes(itime), [pheight], '*', 'color', usecol,'fontsize', 25);
            end
        end
        
%temporal cluster correction.
checkcluster=1;
compareTo=0.5;
ttestdata= plotdata;
xvec = Xtimes;
sigcol=usecol;
usesigmod=0.1; % determines placement of the asterisks (if significant). is % of ylim.
if itestdata==3;
    usesigmod=0.15; % determines placement of the asterisks (if significant). is % of ylim.
end

if itestdata~=4
temporalclustercheck;
end

        % qfdr? 
        % if itestdata>=5
        % q= fdr(pvals,.05);
        % sigtimes = find(pvals<=q);
        %     text(Xtimes(sigtimes), ones(1,length(sigtimes)).*(pheight2), '*', 'color', 'b','fontsize', 25);
        % end
        % 
    
    
    
    % add extra plot elements:
    hold on; plot(xlim, [.5 .5], '--', 'color', [.3 .3 .3], 'linew', 3)
    hold on; plot([0 0 ], ylim, '--', 'color', [.3 .3 .3], 'linew', 3)
    
    if itestdata==1;
        %add patch
        ylims = get(gca, 'ylim');
        pch = patch([windowvec(1) windowvec(1) windowvec(2) windowvec(2)], [ylims(1) ylims(2) ylims(2) ylims(1)], [.8 .8 .8]);
        pch.FaceAlpha= .1;
    end
    if baselinetype==1
    xlabel(['Time since ' modality ' response (ms)'])
    elseif baselinetype==2
        xlabel(['Time since ' modality ' response (w/prestim) (ms)'])
        
    end
    
    
    if itestdata<5
        ylabel('p(Error)');
    else
        ylabel('A.U.C.');
    end
    set(gca, 'fontsize', fsize)
     set(gca,'ydir', 'normal')
     
     if itestdata==3
        % place legend. 
        legend([leg(1) leg(3)] , {'corrects', 'errors'}, 'autoupdate', 'off');
        
     end
    end % itest data
    %%
%     title({['Order ' orderis ', nreps ' num2str(nIterations)];['Time-course of discriminating component, (trained Corr A vs Err A)']}, 'fontsize', 25);
    %%
%     legend(leg, {['Corr A'],['Corr B '], ['Err A'], ['Err B']})
   
    
    
    figure(3);
    topoplot(nanmean(GFX_classifierA_topo,1), elocs);
    c=colorbar
    ylabel(c,'a.u.')
%     title(['GFX, spatial projection'])
title([''])
    set(gca, 'fontsize', 24)
    set(gcf,'color','w')
    %% print results
    cd(figdir)
    cd(['Classifier Results' filesep 'PFX_Trained on resp Errors in part A, Pe window']);
    
    %%
    set(gcf, 'color', 'w')

    nIterations = size(DEC_Pe_window.all_trials_y,1);
    if baselinetype==1
    printname = ['GFX classifier trained on Correct part A-' winwas ', w-' num2str(nIterations) 'reps (fromscalp)' ];
    elseif baselinetype==2
            printname = ['GFX classifier trained on Correct part A-' winwas ', w-' num2str(nIterations) 'reps (fromscalp)_wprestim' ];
    end
    %%
    if smoothON==1
        printname = [printname ', smoothed'];
    end
    print('-dpng', printname);
    

end % print job.