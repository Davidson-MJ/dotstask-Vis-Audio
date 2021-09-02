%% This script is similar to Plot_decA_vs_untrained,
%% except here, instead of using each of n iterations, and taking the average across iterations,
%% with each iteration being a separate classifier projection, we take the mean projection,
%% and compute the result. Should be cleaner results.
dbstop if error
elocs= readlocs('BioSemi64.loc');

jobs=[]; % clear jobs from other scripts.

jobs.useERNorPe =2; % 1 or 2.
jobs.calculate_perppant =0;
jobs.plot_perppant=1;
jobs.concat_GFX=1;
jobs.plot_GFX=1;


nPerm= 500; % 
cmap = flip(cbrewer('div', 'Spectral', 4));

% show result after smoothing over 20ms window
smoothON=1;
winsize = ceil(256/20);
    %% called from JOBS_ERPdecoder.m
    for ippant = 1:length(pfols)
        
      
        PFX_classifierA_onERP =zeros(4, nPerm, 384);%[type, perms, samps]
        PFX_classifierA_onERP =[];% smooth
        cd(eegdatadir)
        cd(pfols(ippant).name);
        sstr= pfols(ippant).name;
        %% load the Classifer and behavioural data:
        disp(['Loading ppant ' num2str(ippant)]);
        load('Classifier_objectivelyCorrect');
        load('Epoch information');
        load('participant TRIG extracted ERPs.mat');
        
        
        
        
        % to improve stability.
        if smoothON==1
            %reshape
            [nchans, nsamps, ntrials] =size(resplockedEEG);
            
            %reshape for multiplication
            testdata = reshape(resplockedEEG, nchans, nsamps* ntrials);%
            sm=[];
            
            for ichan = 1:size(testdata,1);
                sm(ichan,:) = smooth(testdata(ichan,:), winsize);
            end
            
            resplockedEEG = reshape(sm, nchans, nsamps, ntrials);
            
            
        end
        %% %%%%%%%%%% Crunch per ppant.  
        if jobs.calculate_perppant==1;
           
                % take the MEAN vector (not v for each iteration).
                if jobs.useERNorPe ==1.
                v= nanmean(DEC_ERN_window.discrimvector,1)';
                winwas= 'ERN';
                elseif jobs.useERNorPe==2;
                v= nanmean(DEC_Pe_window.discrimvector,1)';
                winwas= 'Pe';
                end
                %% use the vector and untrained trials:
                for itestdata = 1:4
                    switch itestdata
                        case 1
                            tmptrials = corAindx;
                        case 2
                            tmptrials = corBindx;
                        case 3
                            tmptrials = errAindx;
                        case 4
                            tmptrials = errBindx;
                    end
                    
                    
                    % instead of dropping 'tested' trials, 
                    % perform cross-validation. 
                    % select a subset of trials, without replacement, and
                    % compute many many times.
                    
                    % use the nerrAindx. since that was the size of training
                    % data.
                    nSelect = length(errAindx);
                    nAvail = length(tmptrials);
                    
                    if nSelect > nAvail; % will error, not enough errB's, so use those instead as the minimum length
                        nSelect = length(errBindx);
                        disp(['Warning: cross-validation on n' num2str(length(errBindx)) ' trials (errB)',...
                            ' n' num2str(length(errAindx)) ' trials in errA']);
                    end
                    tmpResults=[];
                    disp('Beginning permutations...')
                    for nPerm= 1:500 
                        
                        % each perm, grab a matched size subset.
                        thisGrabindx = randperm(nAvail, nSelect);
                        thisGrab = tmptrials(thisGrabindx); 
                        
                        
                        if itestdata~=3 %(errA)
                            useDATA=resplockedEEG(:,:,thisGrab);
                        
                        else % for the errA indx, all trials were used in training.
                            useDATA = resplockedEEG(:,:,tmptrials);
                        end
                    
                        [nchans, nsamps, ntrials] = size(useDATA);
                        
                        
                        %reshape for multiplication
                        testdata = reshape(useDATA, nchans, nsamps* ntrials)';%
                        
                    %%
                    
                    ytest = testdata * v(1:end-1) + v(end);
                    %% reshape for plotting.
                    ytest_trials = reshape(ytest,nsamps,ntrials);
                    
                    %% conver classifier projection to probability.
                    bptest = bernoull(1,ytest);
                    %reshape for plotting
                    bptest = reshape(bptest, nsamps, ntrials);
                    
%                     tmpResults(nPerm, :)=mean(bptest,2);
                    PFX_classifierA_onERP(itestdata,nPerm,:) = mean(bptest,2);
                    end % nPerm
                    
                    % store average over perms, per type. 
%                     PFX_classifierA_onERP(itestdata,:) = mean(tmpResults,1);
                    disp(['Fin response type ' num2str(itestdata)])
                end % test type (corA, corB etc).
            
            
            %% also save PFX for later concatenation and group effects.
            disp(['savin...'])
            if jobs.useERNorPe==1;
                PFX_classifierA_onERP_ERNtrained_pooled = PFX_classifierA_onERP;
                save('Classifier_objectivelyCorrect', 'PFX_classifierA_onERP_ERNtrained_pooled', '-append')
            elseif jobs.useERNorPe==2;
                PFX_classifierA_onERP_PEtrained_pooled = PFX_classifierA_onERP;
                save('Classifier_objectivelyCorrect', 'PFX_classifierA_onERP_PEtrained_pooled', '-append')
            end
        end % calc per ppant.
        %%%%%%%%%%%%%%%%%%%%%%%%%%
        %% > plot PFX
          %%
        if jobs.plot_perppant
            
        
        figure(1); clf;
        set(gcf, 'units', 'normalized', 'Position', [0 0 1 1]); shg
        leg=[];        
        Xtimes = DEC_Pe_windowparams.wholeepoch_timevec;
        
        %for each comparison made:
        subplot(1, 3, 1:2);
        ntrials_leg=[]; % legend
        
        % which data type to plot? classifer trained on ERN or Pe.
        if jobs.useERNorPe==1;
            % data
            PFX_toplot = PFX_classifierA_onERP_ERNtrained_pooled;
             % add training window
            windowvec = DEC_ERN_windowparams.training_window_ms;
            %topoplot
            mtopo = mean(DEC_ERN_window.scalpproj,1);
        elseif jobs.useERNorPe==2;
            PFX_toplot = PFX_classifierA_onERP_PEtrained_pooled;
            windowvec = DEC_Pe_windowparams.training_window_ms;
            mtopo = mean(DEC_Pe_window.scalpproj,1);
        end
        
        
        for itestdata=1:4       
        % take average performance over all iterations.
        avP = squeeze(mean(PFX_toplot(itestdata,:,:),2));
        stE = CousineauSEM(squeeze(PFX_toplot(itestdata,:,:)));
        stmp = shadedErrorBar(Xtimes, avP ,stE, {'color', cmap(itestdata,:)}, 1);
        leg(itestdata)= stmp.mainLine;
        hold on
        %% include ntrial info.
        switch itestdata
            case 1
                ntrials_leg(1) = length(corAindx);
            case 2
                ntrials_leg(2) = length(corBindx);
            case 3
                ntrials_leg(3) = length(errAindx);
            case 4
                ntrials_leg(4) = length(errBindx);
                
                
        end
        end
        ylim 'auto';
        %% add extra plot elements:
        hold on; plot(xlim, [.5 .5], '--', 'color', [.3 .3 .3], 'linew', 3)
        hold on; plot([0 0 ], ylim, '--', 'color', [.3 .3 .3], 'linew', 3)
        
       
        %add patch
        ylims = get(gca, 'ylim');
        pch = patch([windowvec(1) windowvec(1) windowvec(2) windowvec(2)], [ylims(1) ylims(2) ylims(2) ylims(1)], [.8 .8 .8]);
        pch.FaceAlpha= .1;
        xlabel('Time since response (ms)')
        ylabel('A.U');
        %%
        title({['Time-course of discriminating component, (trained Corr A vs Err A)'];[num2str(nPerm) ' iterations']}, 'fontsize', 25);
        legend(leg, {['Corr A (' ExpOrder{1} ') n' num2str(ntrials_leg(1))],...
            ['Corr B (' ExpOrder{2} ') n' num2str(ntrials_leg(2))],...
            ['Err A, (' ExpOrder{1} ') trained n' num2str(ntrials_leg(3))],...
            ['Err B, (' ExpOrder{2} ') n' num2str(ntrials_leg(4))]})
        set(gca, 'fontsize', 15)
        
        %%
        
        subplot(133);
        topoplot(mtopo, elocs);
        title([sstr  ', mean spatial projection'], 'interpreter', 'none')
        set(gca, 'fontsize', 15)
        %% print results
       cd(figdir)
        %%
        cd(['Classifier Results' filesep 'PFX_Trained on Correct part A']);
        
        %%
        set(gcf, 'color', 'w')
        printname = [sstr ', w-' num2str(nPerm) 'reps (' winwas ') pooled ver'];
        if smoothON
            printname = [printname ', pre smoothed'];
        end
        print('-dpng', printname);
        
        
        end % job: plot
    end % ippant
    
    

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
        load('Classifier_objectivelyCorrect', 'PFX_classifierA_onERP_PEtrained_pooled', 'DEC_Pe_window');
        
        load('Epoch information', 'ExpOrder');
        
        %ERN
%         GFX_classifierA_onERP_ERN(ippant,:,:) = squeeze(mean(PFX_classifierA_onERP_ERNtrained_pooled,2));
%         GFX_classifierA_topo_ERN(ippant,:) = squeeze(mean(DEC_ERN_window.scalpproj,1));
        %Pe
        GFX_classifierA_onERP_Pe(ippant,:,:) = squeeze(mean(PFX_classifierA_onERP_PEtrained_pooled,2));
        GFX_classifierA_topo_Pe(ippant,:) = squeeze(mean(DEC_Pe_window.scalpproj,1));
        
        clear PFX_classifierA_onERP_ERNtrained_pooled PFX_classifierA_onERP_PEtrained_pooled;
        
        if strcmpi(ExpOrder{1}, 'visual')
            vis_first = [vis_first, ippant];
        else
            aud_first= [aud_first, ippant];
        end
        disp(['Concat ' num2str(ippant) '/' num2str(length(pfols))]);
    end
    
    % save!
    cd(eegdatadir);
    cd('GFX')
    %other plot features:
    Xtimes = DEC_Pe_windowparams.wholeepoch_timevec;
    save('GFX_DecA_predicts_untrainedtrials_pooled', ...
        'GFX_classifierA_onERP_Pe','GFX_classifierA_topo_Pe', ...
        'vis_first', 'aud_first', 'Xtimes');
    
    
end % concat job


%% %%%%%
%now plot GFX
if jobs.plot_GFX==1;
    
    %load if necessary.
    cd([eegdatadir filesep 'GFX']);
    if ~exist('GFX_classifierA_onERP_Pe', 'var');
        load('GFX_DecA_predicts_untrainedtrials_pooled');
    end
    
%     smoothON=1; % apply moving window av to prettify plot.
    
    elocs = readlocs('BioSemi64.loc');
    
    if jobs.useERNorPe==1; % 1 or 2.
       %data
        GFX_classifierA_onERP =GFX_classifierA_onERP_ERN;
        %training window (ms)           
    windowvec = DEC_ERN_windowparams.training_window_ms;
        %scalp topo
        GFX_classifierA_topo =GFX_classifierA_topo_ERN;
        
        winwas= 'ERN';
    elseif jobs.useERNorPe==2
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
    set(gcf, 'units', 'normalized', 'Position', [0 0 1 1]); shg
    leg=[];
    subplot(1, 3, 1:2);
    for itestdata = 1:4
        
        plotdata = squeeze(GFX_classifierA_onERP(useppants,itestdata,:));
%         
%         if smoothON==1
%             winsize = ceil(256/20);
%             for ip = 1:size(plotdata,1)
%                 plotdata(ip,:) = smooth(plotdata(ip,:), winsize);
%             end
%         end
        stE = CousineauSEM(plotdata);
        
        sh= shadedErrorBar(Xtimes, squeeze(nanmean(plotdata,1)), stE, [],1);
        
        sh.mainLine.Color =  cmap(itestdata,:);
        sh.patch.FaceColor =  cmap(itestdata,:);
        sh.edge(1,2).Color=cmap(itestdata,:);
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
            [~, pvals(itime)] = ttest(plotdata(:,itime), 0.5);
            
            if pvals(itime)<.05
                text(Xtimes(itime), [0.2+(0.01*itestdata)], '*', 'color', cmap(itestdata,:),'fontsize', 25);
            end
        end
        %    pvals(pvals>=.05) = nan;
        %    plot(Xtimes, pvals<.05, '*');
        % %plot sig points.
        % text(Xtimes(pvals<.05), [0.2], '*',  'color', cmap(itestdata,:), 'FontSize', 5)
    end
    
    ylim([.2 .75])
    % add extra plot elements:
    hold on; plot(xlim, [.5 .5], '--', 'color', [.3 .3 .3], 'linew', 3)
    hold on; plot([0 0 ], ylim, '--', 'color', [.3 .3 .3], 'linew', 3)
    
    %add patch
    ylims = get(gca, 'ylim');
    pch = patch([windowvec(1) windowvec(1) windowvec(2) windowvec(2)], [ylims(1) ylims(2) ylims(2) ylims(1)], [.8 .8 .8]);
    pch.FaceAlpha= .1;
    xlabel('Time since response (ms)')
    ylabel('A.U');
    %%
    title({['Order ' orderis ', nreps ' num2str(nPerm)];['Time-course of discriminating component, (trained Corr A vs Err A)']}, 'fontsize', 25);
    %%
    legend(leg, {['Corr A'],['Corr B '], ['Err A'], ['Err B']})
    set(gca, 'fontsize', 15)
    
    
    subplot(133);
    topoplot(nanmean(GFX_classifierA_topo,1), elocs);
    title(['GFX, spatial projection'])
    set(gca, 'fontsize', 15)
    %% print results
    cd(figdir)
    cd(['Classifier Results' filesep 'PFX_Trained on Correct part A']);
    
    %%
    set(gcf, 'color', 'w')
    printname = ['GFX classifier trained on Correct part A-' winwas ',' orderis ', w-' num2str(nPerm) ' pooled' ];
    
    if smoothON==1
        printname = [printname ', smoothed'];
    end
    print('-dpng', printname);
    
end
end % print job.