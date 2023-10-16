%plot type 2 AUC per subj.

% note that we will use the restricted BEH dataset, after epoch rejection.
% This is to prepare to show AUC and decoding accuracy.

%this script plots ROC curve per ppant.

job=[];
job.calcperppant=1;
job.plotperppant=1; % using concat GFX
job.plotGFX =1;

%%
cd(eegdatadir); % note now using the BEH_matched
pfols = dir([pwd filesep '*p_*']);

%%
storeAUC_ax = nan(length(pfols), 2,100); % for plotting.
storeAUC = nan(1,length(pfols)); % AUC
Expmodality = cell(1,length(pfols));

if job.calcperppant
    for ippant = 1:length(pfols)
        
        %%
        cd(eegdatadir);
        cd(pfols(ippant).name);
        
        %%
        load('Epoch information', 'BEH_matched', 'corBindx', 'errBindx', 'ExpOrder');
        
        allB = [corBindx; errBindx];
        allScores = [BEH_matched.confj{allB}];
        allLabels = double([BEH_matched.cor(allB)]); % 1 ior 0.
        
        % calc AUC for all trials.
        [x, y, ~ ,AUC]= perfcurve(allLabels, allScores, 1);
        
        %resample to plot across ppants:
        
        
        xre = imresize(x',[1,100]);
        yre = imresize(y',[1,100]);
        
        %     plot(x,y, 'k', 'linew', 2);
        %     hold on;
        %     plot(xre, yre, 'r');
        %
        
        %store
        storeAUC_ax(ippant, 1, :) = xre;
        storeAUC_ax(ippant, 2, :) = yre;
        storeAUC(ippant) = AUC;
        Expmodality{ippant} = ExpOrder{2};
    end
    %%
    cd(behdatadir)
    %save somewhere?
end %calc job


if job.plotperppant % using concat GFX
    %%
    cd(figdir)
    cd('AUC results');
    figure(1); clf; set(gcf, 'units', 'normalized', 'position', [0 0 .5 .5], 'color', 'w');
    set(gcf, 'color', 'w')
    figure(2); clf; set(gcf, 'units', 'normalized', 'position', [0 0 1 1],'color', 'w');
    
    for ippant = 1:size(storeAUC,2);
        
        figure(1); clf;
        %separate by xmod
        if strcmp(Expmodality{ippant}, 'visual');
            usecol= 'b';
        else
            usecol= 'r';
        end
            
        plot(squeeze(storeAUC_ax(ippant,1,:)), squeeze(storeAUC_ax(ippant,2,:)), 'color', usecol, 'linew', 2);
        ylabel('P(conf|Corr)')
        xlabel('P(conf|Err)')
        hold on;
        plot([0, 1], [0,1], 'k:')
        axis tight; box on;
        title(['Discrimination - participant ' num2str(ippant) '(' Expmodality{ippant} ')']);
        set(gca, 'fontsize', 15);
        
        print('-dpng', ['AUC ppant ' num2str(ippant) '- ' Expmodality{ippant} ])
        
        figure(2);
        subplot(5,5,ippant);
        plot(squeeze(storeAUC_ax(ippant,1,:)), squeeze(storeAUC_ax(ippant,2,:)), 'color', usecol, 'linew', 2);
        ylabel('P(conf|Corr)')
        xlabel('P(conf|Err)'); box on; axis tight;
        title(['p' num2str(ippant) ' AUC:' sprintf('%.2f',storeAUC(ippant))]);
    end
    print('-dpng', 'AUC allppants');
    
    %% also print overlayed in GFX
end % ppant print

if job.plotGFX
    %%
    cd([figdir filesep 'AUC results']);
    
    figure(1); clf; set(gcf, 'units', 'normalized', 'position', [0 0 1 .5], 'color', 'w');
    subplot(121)
    plot(squeeze(storeAUC_ax(:,1,:))', squeeze(storeAUC_ax(:,2,:))');
    
    hold on
    plot([0.01:.01:1], squeeze(mean(storeAUC_ax(:,2,:),1)), 'linew', 4, 'color', 'k');
    
    ylabel('P(conf|Corr)')
    xlabel('P(conf|Err)')
    hold on;
    plot([0, 1], [0,1], 'k:')
    box on; axis tight; axis square
    xlim([0 1]), ylim([0 1]);
    set(gca, 'fontsize', 25)
    
    
    %%
    subplot(122);
    g1= find(storeAUC<median(storeAUC));
    g2 = find(storeAUC>=median(storeAUC));
    
    plot(squeeze(storeAUC_ax(g1,1,:))', squeeze(storeAUC_ax(g1,2,:))', 'color', 'r');
    hold on
    p1=plot([0.01:.01:1], squeeze(mean(storeAUC_ax(g1,2,:),1)), 'linew', 4, 'color', 'r');
    hold on
    plot(squeeze(storeAUC_ax(g2,1,:))', squeeze(storeAUC_ax(g2,2,:))', 'color', 'b');
    p2=plot([0.01:.01:1], squeeze(mean(storeAUC_ax(g2,2,:),1)), 'linew', 4, 'color', 'b');
    plot([0, 1], [0,1], 'k:')
    box on; axis tight;
    box on; axis tight; axis square
    xlim([0 1]), ylim([0 1]);
    set(gca, 'fontsize', 25)
    
    ylabel('P(conf|Corr)')
    xlabel('P(conf|Err)')
    legend([p1, p2], {'low AUC','high AUC'}, 'location', 'SouthEast');
    print('-dpng', 'AUC allppants overlayed');
end

%%
cd([eegdatadir filesep 'GFX']);
save('GFX_AUC_predicts_EEG', 'Expmodality', 'storeAUC_ax', 'storeAUC');