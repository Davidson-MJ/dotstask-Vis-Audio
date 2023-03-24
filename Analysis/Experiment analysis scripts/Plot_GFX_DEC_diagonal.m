% called from JOBS_ERPdecoder.m
%plot GFX of decoder trained on part A C vs E, on untrained trials.

function Plot_GFX_DEC_diagonal(cfg)



jobs.concat_GFX=cfg.concat;
jobs.plot_GFX=cfg.justplot;
%%
%plotType




useCols= {'b', 'r', 'b', 'r'}; % A B A B;
useln= {'-', '-', ':', ':'}; % corr corr err err;

%loadname determined by type.
loadname = ['Classifier_trained_' cfg.expPart '_' cfg.EEGtype '_diagonal'];
pfols= cfg.pfols;

% for topoplots
topotimes = [-400 -200; 0 200; 400 600];

%>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
%% % load and concat across subjects (if previous step was re-run).
if jobs.concat_GFX==1;
    
    [GFX_classifier_topo,GFX_classifier_diagonal]=deal([]);
%     [GFX_classifierA_topo_Pe,GFX_classifierA_onERP_Pe ]=deal([]);
    
    
    %first concatenate across subjects:
    [vis_first, aud_first] = deal([]);
    for ippant = 1:length(cfg.pfols)
        
        
        cd(cfg.eegdatadir)
        cd(pfols(ippant).name);
        %% load the Classifer and behavioural data:
        load(loadname);
        load('Epoch information', 'ExpOrder');
      
        %take mean over nIterations we have, per participant:
        GFX_classifier_diagonal(ippant,:,:) = squeeze(mean(PFX_classifierA_onERP_diagonal,2));
        GFX_classifier_topo(ippant,:,:) = squeeze(mean(DECout_diagonal_window.scalpproj_perTime,1));
            
        clear PFX_classifierA_onERP_diagonal
        
        if strcmpi(ExpOrder{1}, 'visual')
            vis_first = [vis_first, ippant];
        else
            aud_first= [aud_first, ippant];
        end
        disp(['Fin concat (dec trained on diagonal ' cfg.EEGtype ' in ' cfg.expPart ') for ppant ' num2str(ippant)]);
    end
    %%

    % save!
    cd(cfg.eegdatadir);
    cd('GFX')
    %other plot features:
    Xtimes = DECout_diagonal_window.trainingwindow_centralms;
    nIterations = size(DECout_diagonal_window.scalpproj_perTime,1);
        
    save(['GFX_Classifier_trained_' cfg.expPart '_' cfg.EEGtype '_diagonal'], ...
        'GFX_classifier_diagonal',...
        'GFX_classifier_topo', ...
        'vis_first', 'aud_first', 'Xtimes', 'nIterations');
%     
    
end % concat job

%%%%%%%
%% now plot GFX
if jobs.plot_GFX==1;
    
    %load if necessary.
    cd([cfg.eegdatadir filesep 'GFX']);
    if ~exist('GFX_classifier_diagonal', 'var')
        load(['GFX_Classifier_trained_' cfg.expPart '_' cfg.EEGtype '_diagonal']);
    end
       
    
    
    %for each comparison made:
        figure(1); clf
        set(gcf, 'color', 'w', 'units', 'normalized','position', [.1 .1 .8 .8]);
        shg;
        spots= [1,2,1,2];

        ntrials=[];
        
        % which data type to plot? classifer trained on ERN or Pe, raw vector or scalp projection?
        
            GFX_toplot = GFX_classifier_diagonal;
            testComp='discrimV';
           
%%
            for itestdata=1:4
                useD = squeeze(GFX_classifier_diagonal(:,itestdata,:,:));


                subplot(1,2,spots(itestdata));
                %% take average performance over participants
                avP = squeeze(mean(useD,1));
                stE = CousineauSEM(squeeze(useD));
                stmp = shadedErrorBar(Xtimes(1:length(avP)), avP ,stE, {'color', useCols{itestdata}, 'linestyle', useln{itestdata}, 'linew',2}, 1);
                leg(itestdata)= stmp.mainLine;
                hold on
                ylim([.3 .8]);
                xlim([Xtimes(2) Xtimes(end)])
               %% add ttests:
                hold on

                pvals= nan(1, length(Xtimes));
                for itime = 1:length(Xtimes)
                    [~, pvals(itime)] = ttest(useD(:,itime), .5);

                    if pvals(itime)<.05
                        text(Xtimes(itime), [.30+(0.01*itestdata)], '*', 'color', useCols{itestdata},'fontsize', 25);
                    end
                end
                
                %% add extra plot elements:
                hold on; plot(xlim, [.5 .5], '--', 'color', [.3 .3 .3], 'linew', 3)
                hold on; plot([0 0 ], ylim, '--', 'color', [.3 .3 .3], 'linew', 3)
                title(['trained on ' cfg.EEGtype ' errors in ' cfg.expPart ' (diagonal)'])
                set(gca, 'fontsize', 15)
                xlabel('Time since response (ms)')
                ylabel('prob(Error)');

                if itestdata==1 %
                    %add patch
                    ylims = get(gca, 'ylim');
                    for ipatch = 1:size(topotimes,1)
                        pch = patch([topotimes(ipatch,1) topotimes(ipatch,1) topotimes(ipatch,2) topotimes(ipatch,2)], [ylims(1) ylims(2) ylims(2) ylims(1)], [.6 .6 .6]);
                        pch.FaceAlpha= .1;
                        pch.LineStyle= 'none'
                    end
                end
            end
        %%
        
        
       
        %add patch
        ylims = get(gca, 'ylim');
%         pch = patch([windowvec(1) windowvec(1) windowvec(2) windowvec(2)], [ylims(1) ylims(2) ylims(2) ylims(1)], [.8 .8 .8]);
%         pch.FaceAlpha= .1;
        xlabel(['Time since ' cfg.EEGtype ' (ms)'])
%         ylabel('A.U');
        %
        subplot(121);
        legend([leg(1) leg(3)], {['Correct (visual)'],...           
            ['Error (visual)']}, 'Location', 'NorthEast','autoupdate', 'off');
        subplot(122);
         legend([leg(2) leg(4)], {['Correct (auditory)'],...           
            ['Error (auditory)']},'Location', 'NorthEast','autoupdate', 'off');

        set(gca, 'fontsize', 15)
        
    
        %% print results
       cd(cfg.figdir)
        %%
        cd(['Classifier Results' filesep 'PFX_Trained on ' cfg.EEGtype ' Errors in part ' cfg.expPart]);
        
        %%
        set(gcf, 'color', 'w')
        print('-dpng', ['GFX w-' num2str(nIterations) 'reps (diagonal)' ]);
        shg




        %% also plot mean topo at key time points:
        figure(2); clf;
        set(gcf, 'color', 'w', 'units', 'normalized', 'Position', [.1 .1 .6 .4])
        elocs=getelocs(3);
        for itime= 1:size(topotimes,1);

            subplot(1,length(topotimes), itime);
            mtimes =dsearchn(Xtimes', [topotimes(itime,:)]')
            tData= squeeze(mean(nanmean(GFX_classifier_topo(:,mtimes(1):mtimes(2),:),2),1));

            topoplot(tData, elocs);
            c= colorbar;
            caxis([-.02 .02]);
            ylabel(c, 'a.u.')

            title(['times: ' num2str(topotimes(itime,:))])
        end
        set(gcf,'color','w');
        print('-dpng', ['GFX w-' num2str(nIterations) 'reps (diagonal) Topos' ]);

        
        end % job: plot
end % function.