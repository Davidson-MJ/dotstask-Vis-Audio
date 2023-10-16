function Plot_GFX_DEC_timegen_msver1(cfg)
%% % load and concat across subjects (if previous step was re-run).




jobs.concat_GFX=cfg.concat;
jobs.plot_GFX=cfg.justplot;
%%
%plotType
performClust=1;

train_name = ['Classifier_trained_' cfg.expPart_train '_' cfg.EEGtype_train '_diagonal'];
savename = ['Classifier_trained_' cfg.expPart_train '_' cfg.EEGtype_train '_tested_' cfg.expPart_test '_' cfg.EEGtype_test ' timegen'];

if jobs.concat_GFX==1;
    
    [GFX_classifier_timegen]=deal([]);
    GFX_culsterstats=[]; % save the results of our perm, to avoid rerunning each time (time consuming)
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
        'GFX_classifier_timegen','Xtimes','GFX_culsterstats','-append');
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
        figure(1); 
        set(gcf, 'color', 'w', 'units', 'normalized','position', [.1 .1 .8 .8]);
        shg;

        cmap = cbrewer('div', 'RdBu', 10);
        colormap(flipud(cmap));
%
ytests = {'correct', 'error', '(test)'}; 
ytrain = {'error', 'error', '(train)'};
iplot=3; % AUC from all corrects and error.
        useD= squeeze(GFX_classifier_timegen(:, iplot,:,:));


% permute to have train on the Y axis.
         useD= permute(useD, [1,3,2]);
    subplot(2,2,cfg.pcounter);
    
    meanD= squeeze(mean(useD,1));
    imagesc(Xtimes, Xtimes, meanD);
  
    % add extra plot elements:
    hold on; plot(xlim, [.5 .5], ':', 'color', 'w', 'linew', 1)
    hold on; plot([0 0 ], ylim, ':', 'color', 'w', 'linew', 1)
    ylabel([ytrain{iplot} ' ' modtrain ' ' cfg.EEGtype_train '-locked' ])
    xlabel([ ytests{iplot} ' ' modtest ' ' cfg.EEGtype_test '-locked' ])
    set(gca, 'fontsize', 15,'ydir', 'normal')
caxis([.45 .55]);
  xlim([Xtimes(2), Xtimes(end)])
  ylim([Xtimes(2), Xtimes(end)])

%   title({[ytests{iplot} ' trials:']; ['cross classification']})
colorbar
  axis square
  plot([Xtimes(1) Xtimes(end)] , [Xtimes(1) Xtimes(end)], 'w')
% ttest all

nhst=[];
pvals=[];
for irow= 1:size(useD,2);
    for icol= 1:size(useD,3);

        [nhst(irow, icol), pvals(irow, icol),~,stat]= ttest(useD(:, irow, icol), .5, 'alpha', .05);
        teststats(irow,icol)= stat.tstat;
       
    end
end



% Extract the boundaries of the clusters
B_obs = bwboundaries(nhst);
%% work out the largest observed cluster statistic (retain).
clusttestStat = [];

for k = 1:length(B_obs)
    boundary = B_obs{k};
    clustertestStat(k) = abs(sum(nansum(teststats(boundary(:,2), boundary(:,1)))));
    
    
end
obsV = max(clustertestStat);
%%
GFX_clusterstats(iplot).maxObserved = obsV;

if performClust==1% perform time-consuming cluster on last plot only.
% what is the CV cutoff for a perm version?
% should shuffle labels in this case the comparison (other group) is chance
% performance.
group1= useD;
group2= repmat(0.5, size(useD));
% for nperms, recalc the largest observed cluster stat, if group assignment
% is random.
nPerm=1000;
allsub= 1:size(group1,1);
clusterResults=[];

%check it hasn't been completed!

if ~isfield(GFX_clusterstats(iplot), 'criticalQuantiles') || GFX_clusterstats(iplot).nPerm ~=nPerm;
    
    for iperm= 1:nPerm

% shuffle assignment?
%         %flip half the participants each time (at random)
%         nshuff= floor(max(allsub)/2);
%         %shuffle order:
%         shfforder = randperm(21);
%         
%         %flip these ppants:
%         flippants= shfforder(1:nshuff);
%         
%         %swaap:
%         group1tmp= group1;
%         group2tmp= group2;
%         
%         group1tmp(flippants,:,:) = group2(flippants,:,:);
%         group2tmp(flippants,:,:)= group1(flippants,:,:);
%         
%         % now with our null, perform the stats test and retain largest cluster.
%         
%         pvals=[];
%         for irow= 1:size(useD,2);
%             for icol= 1:size(useD,3);
%                 
%                 [nhst(irow, icol), pvals(irow, icol),~,stat]= ttest(group1tmp(:, irow, icol), group2tmp(:,irow,icol), 'alpha', .05);
%                 teststats(irow,icol)= stat.tstat;
%                 
%             end
%         end
        
        %% or shuffle the assignment or rows and cols?
%         group1tmp= group1(:, randperm(size(group1,2)),randperm(size(group1,3)));
        
        % shuffle at the ppant level, otherwise we are just permuting the
        % GFX result. 
        group1tmp=[];
        for ippant = 1:size(group1,1)
            
            group1tmp(ippant,:,:) = group1(ippant,randperm(size(group1,2)),randperm(size(group1,3)));
        end
        
         % now with our null, perform the stats test and retain largest cluster.
        
        pvals=[];
        for irow= 1:size(useD,2);
            for icol= 1:size(useD,3);
                
                [nhst(irow, icol), pvals(irow, icol),~,stat]= ttest(group1tmp(:, irow, icol), 0.5, .05);
                teststats(irow,icol)= stat.tstat;
                
            end
        end
        
        
        
        %cluster extraction:
        B_shuff = bwboundaries(nhst);
        %% work out the largest observed cluster statistic (retain).
        clusttestStat_shuff = [];
        
        for k = 1:length(B_shuff)
            boundary = B_shuff{k};
            clustertestStat_shuff(k) = abs(sum(nansum(teststats(boundary(:,2), boundary(:,1)))));
            
            
        end
        clusterResults(iperm) = max(clustertestStat_shuff);
        disp(['fin perm ' num2str(iperm)]);
    end
    %% %
    figure(10); clf
    histogram(clusterResults, nPerm);
    hold on;
    plot([obsV,obsV], ylim, 'r-');
    y= quantile(clusterResults,[.01 .5 .99]);
    for iy=1:length(y);
        plot([y(iy),y(iy)], ylim, 'b-');
        %
    end
    GFX_clusterstats(iplot).nPerm = nPerm;
    GFX_clusterstats(iplot).criticalQuantiles = y;
      
    save(['GFX_' savename], ...
        'GFX_clusterstats','-append');
else % already completed.
    %%
    disp(['using presaved null distribution cluster quantiles']);
    y = GFX_clusterstats(iplot).criticalQuantiles;
    
end
%%
figure(1);

%%
% only use those clusters which exceed our 95% CV
plotcluster= clustertestStat>=y(3);
% Overlay the boundaries on the image
Bplot= B_obs(plotcluster);
hold on
for k = 1:length(Bplot)
    boundary = Bplot{k};
    % determine if pos or negative:
      
    Gm= squeeze(mean(useD(:,boundary(:,2), boundary(:,1)),1));
    posNeg= mean(Gm(:));
    if posNeg<0.5
        clustCol= [.7 .7 1];
    else

        clustCol= [1 .7 .7];
    end
clustCol= 'w';
    plot(Xtimes(boundary(:,2)), Xtimes(boundary(:,1)), 'color',clustCol, 'LineWidth', 2)
end


elseif iplot==3  && performClust==0 % just plot the (non corrected) cluster.
    %%
    Bplot= B_obs;
    hold on
    for k = 1:length(Bplot)
        boundary = Bplot{k};
        % determine if pos or negative:
        
        Gm= squeeze(mean(useD(:,boundary(:,2), boundary(:,1)),1));
        posNeg= mean(Gm(:));
        if posNeg<0.5
            clustCol= [.7 .7 1];
        else
            
            clustCol= [1 .7 .7];
        end
        clustCol= 'b';
        plot(Xtimes(boundary(:,2)), Xtimes(boundary(:,1)), 'color',clustCol, 'LineWidth', 2)
    end
    
    shg
end

% cluster
if iplot==3
    c=colorbar;
    ylabel(c, 'A.U.C')
end


        %% print results
        cd(cfg.figdir)
        %
       try  cd(['Classifier Results' filesep 'PFX_Trained on ' cfg.EEGtype_train ' Errors in part ' cfg.expPart_train ' timegen']);
       catch 
           mkdir(['Classifier Results' filesep 'PFX_Trained on ' cfg.EEGtype_train ' Errors in part ' cfg.expPart_train ' timegen']);
       cd(['Classifier Results' filesep 'PFX_Trained on ' cfg.EEGtype_train ' Errors in part ' cfg.expPart_train ' timegen']);
       end
        %%
        set(gcf, 'color', 'w');
        nIterations= 20;
        if cfg.pcounter==4
        printname= ['GFX, w-' num2str(nIterations) 'reps ',...
            '(timegen ' cfg.EEGtype_train ' ' cfg.expPart_train ' on '...
            cfg.EEGtype_test ' ' cfg.expPart_test ' )' ];
        print('-dpng',[printname '_MS']) ;
        end
    
    



end
