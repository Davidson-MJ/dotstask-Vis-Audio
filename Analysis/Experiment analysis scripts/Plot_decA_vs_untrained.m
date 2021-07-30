
elocs= readlocs('BioSemi64.loc');

    %% called from JOBS_ERPdecoder.m
    for ippant = 1:length(pfols)
        
        PFX_classifierA_onERP =[]; % note that there will be an extra dimension, for each iteration.
        cd(eegdatadir)
        cd(pfols(ippant).name);
        %% load the Classifer and behavioural data:
        load('Classifier_objectivelyCorrect');
        load('Epoch information');
        load('participant TRIG extracted ERPs.mat');
        
        %plot time-course of discriminating component for all untrained trials:
       
      
        %how many times was the classifier repeated?
        nIterations = size(DEC_Pe_window.scalpproj,1);
        
        for nIter= 1:nIterations
             
            v= DEC_Pe_window.discrimvector(nIter,:)';
        
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
            %training trials *this* iteration
            trainedtrials = DEC_Pe_window.trainingtrials_vector(nIter,:);
                
            remtrials = ismember(tmptrials,trainedtrials);
            
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
            
            
            
                        
            PFX_classifierA_onERP(itestdata,nIter,:) = mean(bptest,2);
        
        end % test type.
        end % nIteration
        
        %% also save PFX for later concatenation and group effects.
        save('Classifier_objectivelyCorrect', 'PFX_classifierA_onERP', '-append')
        
        %% > plot PFX
          %%
        figure(1); clf;
        set(gcf, 'units', 'normalized', 'Position', [0 0 1 1]); shg
        leg=[];        
        Xtimes = DEC_Pe_windowparams.wholeepoch_timevec;
        
        %for each comparison made:
        subplot(1, 3, 1:2);
        for itestdata=1:4       
        % take average performance over all iterations.
        avP = squeeze(mean(PFX_classifierA_onERP(itestdata,:,:),2));
        stE = CousineauSEM(squeeze(PFX_classifierA_onERP(itestdata,:,:)));
        stmp = shadedErrorBar(Xtimes, avP ,stE, {'color', cmap(itestdata,:)}, 1);
        leg(itestdata)= stmp.mainLine;
        hold on
        end
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
        title({['Time-course of discriminating component, (trained Corr A vs Err A)'];[num2str(nIter) ' iterations']}, 'fontsize', 25);
        legend(leg, {['Corr A (' ExpOrder{1} ')'],['Corr B (' ExpOrder{2} ')'], ['Err A, (' ExpOrder{1} ') trained'], ['Err B, (' ExpOrder{2} ')']})
        set(gca, 'fontsize', 15)
        
        %%
        
        subplot(133);
        topoplot(mean(DEC_Pe_window.scalpproj,1), elocs);
        title(['Participant ' num2str(ippant) ', mean spatial projection'])
        set(gca, 'fontsize', 15)
        %% print results
       cd(figdir)
        %%
        cd(['Classifier Results' filesep 'PFX_Trained on Correct part A']);
        
        %%
        set(gcf, 'color', 'w')
        print('-dpng', ['Participant ' num2str(ippant) ', w-' num2str(nIter) 'reps (new)']);
        
        
        
    end % ippant