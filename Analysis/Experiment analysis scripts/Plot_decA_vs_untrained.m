
    %% called from JOBS_ERPdecoder.m
    for ippant = 1:length(pfols)
        
        PFX_classifierA_onERP =[];
        cd(basedir)
        cd(pfols(ippant).name);
        %% load the Classifer and behavioural data:
        load('Classifier_objectivelyCorrect');
        load('Epoch information');
        load('participant TRIG extracted ERPs.mat');
        
        %plot time-course of discriminating component for all untrained trials:
        v= DEC_Pe_window.discrimvector;
        
        %%
        figure(1); clf;
        set(gcf, 'units', 'normalized', 'Position', [0 1 .6 .35]); shg
        leg=[];
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
            
            % Note that if we need to remove trials used in the training
            % data set. so remove the training trials from our
            % consideration.
            if itestdata~=3
            remtrials = ismember(tmptrials,DEC_Pe_window.trainingtrials_vector);
            %so use the trials that werent in training:
            untrained = tmptrials(remtrials==0);
            
            useDATA = resplockedEEG(:,:,untrained);
            else
                useDATA = resplockedEEG(:,:,tmptrials);
            end
                
            [nchans, nsamps, ntrials] =size(useDATA);
            
            %reshape for multiplication
            testdata = reshape(useDATA, nchans, nsamps* ntrials)';%
            %%
            
            ytest = testdata * v(1:end-1) + v(end);
            %% reshape for plotting.
            ytest_trials = reshape(ytest,nsamps,ntrials);
            
            %% check probs:
            bptest = bernoull(1,ytest);
            %reshape for plotting
            bptest = reshape(bptest, nsamps, ntrials);
            
            
            Xtimes = DEC_Pe_windowparams.wholeepoch_timevec;
            
            subplot(1, 3, 1:2);
            leg(itestdata)= plot(Xtimes, (mean(bptest,2)), 'color', cmap(itestdata,:), 'linew', 3);
            % leg(itestdata)= plot(Xtimes, (mean(ytest_trials,2)), 'color', cmap(itestdata,:), 'linew', 3);
            hold on
            
            PFX_classifierA_onERP(itestdata,:) = mean(bptest,2);
        end
        
        %% also save PFX for later concatenation and group effects.
        save('Classifier_objectivelyCorrect', 'PFX_classifierA_onERP', '-append')
        
        %%
        ylim 'auto';
        %% add extra plot elements:
        hold on; plot(xlim, [.5 .5], '--', 'color', [.3 .3 .3], 'linew', 3)
        hold on; plot([0 0 ], ylim, '--', 'color', [.3 .3 .3], 'linew', 3)
        
        % add training window
        windowvec = DEC_Pe_windowparams.training_window_ms;
        %add patch
        ylims = get(gca, 'ylim');
        pch = patch([windowvec(1) windowvec(1) windowvec(2) windowvec(2)], [ylims(1) ylims(2) ylims(2) ylims(1)], [.8 .8 .8]);
        pch.FaceAlpha= .1;
        xlabel('Time since response (ms)')
        ylabel('A.U');
        %%
        title({['Time-course of discriminating component, (trained Corr A vs Err A)']}, 'fontsize', 25);
        legend(leg, {['Corr A (' ExpOrder{1} ')'],['Corr B (' ExpOrder{2} ')'], ['Err A, (' ExpOrder{1} ') trained'], ['Err B, (' ExpOrder{2} ')']})
        set(gca, 'fontsize', 15)
        
        %%
        
        subplot(133);
        topoplot(DEC_Pe_window.scalpproj, biosemi64);
        title(['Participant ' num2str(ippant) ', spatial projection'])
        set(gca, 'fontsize', 15)
        %% print results
        cd(basedir);
        cd ../../
        %%
        cd(['Figures' filesep 'Classifier Results' filesep 'PFX_Trained on Correct part A']);
        
        %%
        set(gcf, 'color', 'w')
        print('-dpng', ['Participant ' num2str(ippant)]);%', ERP weighted' ]);
        
        
        
    end % ippant