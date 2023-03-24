% called from JOBS_ERPdecoder.m
%plot GFX of decoder trained on part A C vs E, on untrained trials.

function Plot_GFX_DEC_diagonal_MSVer1(cfg)



%loadname determined by type.
loadname = ['Classifier_trained_' cfg.expPart '_' cfg.EEGtype '_diagonal'];
pfols= cfg.pfols;

% for topoplots
topotimes = [-400 -200; 0 200; 400 600];

%>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
%% % load and concat across subjects (if previous step was re-run).

%%%%%%%
    %load if necessary.
    cd([cfg.eegdatadir filesep 'GFX']);
    if ~exist('GFX_classifier_diagonal', 'var')
        load(['GFX_Classifier_trained_' cfg.expPart '_' cfg.EEGtype '_diagonal']);
    end
       
    
    
    %for each comparison made:
        figure(1); clf
        set(gcf, 'color', 'w', 'units', 'normalized', 'Position', [.1 .1 .6 .4])
        shg;
        spots= [1,1,2];

        ntrials=[];
        
        % which data type to plot? classifer trained on ERN or Pe, raw vector or scalp projection?
        
            GFX_toplot = GFX_classifier_diagonal;
            testComp='discrimV';
           
%%
% note that the data to use will either be 1-2 (part A), or 3-4 (part B).
% no cross-testing.
if strcmp(cfg.expPart,'A')
    useDims= [1,3]; % correct, then error
    useCol= 'b';

else
    useDims= [2,4];
useCol= 'r';
end

uselns= {'-', ':', '-'};

         for iplot = 1:3

             if iplot<3
             useD = squeeze(GFX_classifier_diagonal(:,useDims(iplot),:,:));
             else
                % take average of both after converting c to prob correct.
                d1= squeeze(GFX_classifier_diagonal(:,useDims(1),:,:));
                d2= squeeze(GFX_classifier_diagonal(:,useDims(2),:,:));

                useD = (d2 + (1- d1))./2;
                useCol= 'k';
             end
figure(1);
                subplot(1,2,spots(iplot));
                %% take average performance over participants
                avP = squeeze(mean(useD,1));
                stE = CousineauSEM(squeeze(useD));
                stmp = shadedErrorBar(Xtimes(1:length(avP)), avP ,stE, {'color', useCol, 'linestyle', uselns{iplot}, 'linew',2}, 1);
                leg(iplot)= stmp.mainLine;
                hold on
                ylim([.3 .8]);
                xlim([Xtimes(2) Xtimes(end)])
               %% add ttests:
                hold on

                pvals= nan(1, length(Xtimes));
                for itime = 1:length(Xtimes)
                    [~, pvals(itime)] = ttest(useD(:,itime), .5);

                    if pvals(itime)<.05
                        text(Xtimes(itime), [.30+(0.01*iplot)], '*', 'color', useCol,'fontsize', 25);
                    end
                end
                
                %% add extra plot elements:
                hold on; plot(xlim, [.5 .5], '--', 'color', [.3 .3 .3], 'linew', 3)
                hold on; plot([0 0 ], ylim, '--', 'color', [.3 .3 .3], 'linew', 3)
                title(['trained on ' cfg.EEGtype ' errors in ' cfg.expPart ' (diagonal)'])
                set(gca, 'fontsize', 15)
                xlabel('Time since response (ms)')
                ylabel('prob(Error)');

                if iplot==1 %
                    %add patch
                    ylims = get(gca, 'ylim');
                    for ipatch = 1:size(topotimes,1)
                        pch = patch([topotimes(ipatch,1) topotimes(ipatch,1) topotimes(ipatch,2) topotimes(ipatch,2)], [ylims(1) ylims(2) ylims(2) ylims(1)], [.6 .6 .6]);
                        pch.FaceAlpha= .1;
                        pch.LineStyle= 'none'
                    end
                elseif iplot==2

                    legend([leg(1) leg(2)], {'corrects', 'errors'});
                end
            end
        %%
        
        
       
        ylims = get(gca, 'ylim');
        xlabel(['Time since ' cfg.EEGtype ' (ms)'])
        
        ylabel('Average classifier accuracy');
        title('combined');
        subplot(121);
%         legend([leg(1) leg(3)], {['Correct (visual)'],...           
%             ['Error (visual)']}, 'Location', 'NorthEast','autoupdate', 'off');
%         subplot(122);
%          legend([leg(2) leg(4)], {['Correct (auditory)'],...           
%             ['Error (auditory)']},'Location', 'NorthEast','autoupdate', 'off');

        set(gca, 'fontsize', 15)
        
    
        %% print results
       cd(cfg.figdir)
        %%
        cd(['Classifier Results' filesep 'PFX_Trained on ' cfg.EEGtype ' Errors in part ' cfg.expPart]);
        
        %%
        set(gcf, 'color', 'w')
        print('-dpng', ['GFX w-' num2str(nIterations) 'reps (diagonal) MSver1' ]);
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
        print('-dpng', ['GFX w-' num2str(nIterations) 'reps (diagonal) Topos MSver1' ]);

        
       
end % function.