figure(1);
clf
dbstop if error

for ipart = 1:2
    switch ipart
        case 1
            %use part A data.
            nblocks = cfg.nblocks_partA;
            expt= 'A';
            trstart=1;
            stimdiff=UpDownStruct_partA.xCurrent;
        case 2
            nblocks= cfg.nblocks_partB;
            expt= 'B';
            trstart = cfg.nblocks_partA*cfg.ntrials + cfg.nblocksprac* cfg.ntrialsprac;
            
            stimdiff=UpDownStruct_partB.xCurrent;
    end
    
    %practice blocks part A
    npractr = cfg.ntrialsprac * cfg.nblocksprac;
    ncols = nblocks + cfg.nblocksprac;
    plotspot = (1:cfg.nblocksprac) + ncols*(ipart-1);
    subplot(2,ncols,plotspot);
    
    %plot all practice accuracy:
    tmptrialsPrac = [trstart:trstart+npractr-1];
    blockcor = double([usetrials(tmptrialsPrac).cor]);
    runnacc = cumsum(blockcor) ./ [1:npractr];
    title(['part ' expt ' practice (' cfg.stimTypes{ipart} ')']); hold on
    plot(tmptrialsPrac, runnacc, 'k', 'linew', 3);
    axis tight
    ylabel('Accuracy')
    xlabel('Trial n')
    set(gca, 'fontsize', 16)
    ylim([.5 1])
    % plot block performance on top.
    for ibl = 1:cfg.nblocksprac
        tmptrials = [trstart:(trstart+cfg.ntrialsprac-1)] +(cfg.ntrialsprac*(ibl-1));
        blockcor = double([usetrials(tmptrials).cor]);
        runnacc = cumsum(blockcor) ./ [1:cfg.ntrialsprac];
        subplot(2,ncols,plotspot);
        %     title(['block ' num2str(usetrials(tmptrials(1)).blockcount)]); hold on
        plot(tmptrials, runnacc);
        
        set(gca, 'fontsize', 16)
        ylabel('Accuracy')
        xlabel('Trial n')
        axis tight
    end
    ylim([.2 1])
    
    % part exp real
    bl = cfg.nblocksprac+1;
    bl_end = (bl-1)+ nblocks;
    plotspot = (bl:bl_end) +  ncols*(ipart-1);
    
    endprac = tmptrialsPrac(end);
    
    %
    expTrials = cfg.ntrials*nblocks;
    
    subplot(2,ncols,plotspot);
    tmptrials = [endprac:(endprac+expTrials-1)];% +(endprac);%+ cfg.ntrials*(bl-1));
    %
    blockcor = double([usetrials(tmptrials).cor]);
    runnacc = cumsum(blockcor) ./ [1:length(blockcor)];
    title(['part ' expt ', stim diff = ' num2str(stimdiff)]); hold on
    try plot(tmptrials, runnacc, 'k', 'linew', 3);
    catch
        plot(tmptrials(1:length(runnacc)), runnacc, 'k', 'linew', 3);
        text(median(tmptrials), 0.6, 'trials missing','color', 'r', 'fontsize', 26)
    end
    axis tight
    ylim([.2 1]);
    
    
    xlabel('Trial n')
    hold on
    %plot block performance on top:
    for ibl = 1:nblocks
        tmptrials = [1:cfg.ntrials] + endprac + cfg.ntrials*(ibl-1);
        blockcor = double([usetrials(tmptrials).cor]);
        try
            runnacc = cumsum(blockcor) ./ [1:cfg.ntrials];
            %    plotspot = plotspot(1)+(1*(ibl-1));
            subplot(2,ncols,plotspot);
            plot(tmptrials, runnacc);
        catch
            text(median(tmptrials), 0.6, 'trials missing','color', 'r', 'fontsize', 26)
            
        end
        ylim([.2 1])
    end
    set(gca, 'fontsize', 16)
end

%% print output.
cd(homedir)
cd('Figures')
cd('Accuracy plots')
set(gcf, 'color', 'w', 'Units', 'normalized', 'position', [0 0 .5 .5]);

print('-dpng', ['Participant ' num2str(ippant) ', all experiment running accuracy '])
%%
figure(2); clf
startA= npractr+1;
endA= (npractr+ cfg.nblocks_partA*cfg.ntrials);
startB= endA+npractr;
endB = startB+cfg.nblocks_partB*cfg.ntrials;
alltrialsA= [usetrials(startA:endA).cor];
alltrialsB= [usetrials(startB:endB).cor];

Aacc= sum(alltrialsA)./length(alltrialsA);
Bacc= sum(alltrialsB)./length(alltrialsB);

errorsA = length(alltrialsA) - sum(alltrialsA);
errorsB = length(alltrialsB) - sum(alltrialsB);


bar([Aacc,Bacc]); shg
hold on;
text(0.9, Aacc+.05, ['Nerr = ' num2str(errorsA)])
text(1.9, Bacc+.05, ['Nerr = ' num2str(errorsB)])
set(gca, 'xticklabel', {'part A', 'part B'})
ylabel('Accuracy');
title('Average accuracy')
ylim([0 1])
%%
set(gcf, 'color', 'w');
set(gca, 'fontsize', 16)
print('-dpng', ['Participant ' num2str(ippant) ', accuracy summary'])
%% store for  across participant averaging:
Accuracy_byAorB(ippant, :) = [Aacc,Bacc];
