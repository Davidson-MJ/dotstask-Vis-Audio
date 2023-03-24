function Plot_GFX_DEC_timegen(cfg)
%% % load and concat across subjects (if previous step was re-run).




jobs.concat_GFX=cfg.concat;
jobs.plot_GFX=cfg.justplot;
%%
%plotType

train_name = ['Classifier_trained_' cfg.expPart_train '_' cfg.EEGtype_train '_diagonal'];
savename = ['Classifier_trained_' cfg.expPart_train '_' cfg.EEGtype_train '_tested_' cfg.expPart_test '_' cfg.EEGtype_test ' timegen'];

if jobs.concat_GFX==1;
    
    [GFX_classifier_timegen]=deal([]);
    
    for ippant = 1:length(cfg.pfols)
        
        
        cd(cfg.eegdatadir)
        cd(cfg.pfols(ippant).name);
        %% load the Classifer and behavioural data:
        load(savename);
      
        %take mean over nIterations we have, per participant:
        GFX_classifier_timegen(ippant,:,:,:) = PFX_timegen_CvsE;
%           
        clear PFX_timegen_CvsE
        
        
        disp(['Fin concat (dec timegen ' cfg.EEGtype_train ' in ' cfg.expPart_train ') for ppant ' num2str(ippant)]);
    end
    %%

    % save!
    cd(cfg.eegdatadir);
    cd('GFX')
    %other plot features:
        
    save(['GFX_' savename], ...
        'GFX_classifier_timegen','Xtimes');
%     
    
end % concat job


%%%%%%%
%% now plot GFX
if jobs.plot_GFX==1;
    

    if strcmp(cfg.expPart_train, 'A');
        modtrain= '\bfvisual\rm';
    else
        modtrain= '\bfauditory\rm';
    end
    if strcmp(cfg.expPart_test, 'A');
        modtest= '\bfvisual\rm';
    else
        modtest= '\bfauditory\rm';
    end

    %load if necessary.
    cd([cfg.eegdatadir filesep 'GFX']);
    if ~exist('GFX_classifier_timegen', 'var')
        load(['GFX_' savename]);
    end
         %for each comparison made:
        figure(2); clf
        set(gcf, 'color', 'w', 'units', 'normalized','position', [.1 .1 .8 .8]);
        shg;

        cmap = cbrewer('div', 'RdBu', 10);
        colormap(flipud(cmap));
%
ytests = {'correct', 'error', 'all'}; 
ytrain = {'error', 'error', 'both'};
for iplot=1:3
        useD= squeeze(GFX_classifier_timegen(:, iplot,:,:));


% permute to have train on the Y axis.
         useD= permute(useD, [1,3,2]);
    subplot(2,3,iplot);
    
    meanD= squeeze(mean(useD,1));
    imagesc(Xtimes, Xtimes, meanD);
  
    % add extra plot elements:
    hold on; plot(xlim, [.5 .5], ':', 'color', 'w', 'linew', 1)
    hold on; plot([0 0 ], ylim, ':', 'color', 'w', 'linew', 1)
    ylabel(['trained ' modtrain ' ' cfg.EEGtype_train ' ' ytrain{iplot}])
    xlabel(['Tested ' modtest ' ' cfg.EEGtype_test ' ' ytests{iplot}])
    set(gca, 'fontsize', 15,'ydir', 'normal')
caxis([.45 .55]);
  xlim([Xtimes(2), Xtimes(end)])
  ylim([Xtimes(2), Xtimes(end)])

  title({[ytests{iplot} ' trials:']; ['cross classification']})
colorbar
  axis square
  plot([Xtimes(1) Xtimes(end)] , [Xtimes(1) Xtimes(end)], 'w')
% ttest all

nhst=[];
pvals=[];
for irow= 1:size(useD,2);
    for icol= 1:size(useD,3);

        [nhst(irow, icol), pvals(irow, icol)]= ttest(useD(:, irow, icol), .5, 'alpha', .05);

       
    end
end


% Extract the boundaries of the clusters
B = bwboundaries(nhst);

% Overlay the boundaries on the image
hold on
for k = 1:length(B)
    boundary = B{k};
    % determine if pos or negative:
      
    Gm= squeeze(mean(useD(:,boundary(:,2), boundary(:,1)),1));
    posNeg= mean(Gm(:));
    if posNeg<0.5
        clustCol= [.7 .7 1];
    else

        clustCol= [1 .7 .7];
    end
clustCol= 'k';
    plot(Xtimes(boundary(:,2)), Xtimes(boundary(:,1)), 'color',clustCol, 'LineWidth', 2)
end

if iplot==3
    c=colorbar;
ylabel(c, 'A.U.C')
end




hold off
  subplot(2,3,iplot+3);
  dall=[];
  for ip = 1:size(useD,1);
dall(ip,:)= diag(squeeze(useD(ip,:,:)));
  end
%   d= diag(meanD);
%   plot(Xtimes, d); 
shadedErrorBar(Xtimes, squeeze(mean(dall,1)), CousineauSEM(dall))
  hold on;
  plot(xlim, [.5 .5]); title('diagonal for comparison');

  xlim([Xtimes(2), Xtimes(end)])
ylim([.4 .6]);

for itime = 1:length(dall)

    [h, p, ci, stt]= ttest(dall(:,itime), 0.5);
    if p<.05;
        text(Xtimes(itime), .475, '*');
    end

end
ylim([0.45 0.6]);
ylabel('p(Error)')
if iplot==3;
    ylabel('classifier accuracy');

end
  %% stats?
%   colorbar
end % each 

% plot.

%%
        %% print results
        cd(cfg.figdir)
        %
        cd(['Classifier Results' filesep 'PFX_Trained on ' cfg.EEGtype_train ' Errors in part ' cfg.expPart_train ' timegen']);

        %%
        set(gcf, 'color', 'w');
        printname= ['GFX, w-' num2str(nIterations) 'reps ',...
            '(timegen ' cfg.EEGtype_train ' ' cfg.expPart_train ' on '...
            cfg.EEGtype_test ' ' cfg.expPart_test ' )' ];
        print('-dpng',printname) ;
        shg
    
    



end
