dbstop if error
elocs= readlocs('BioSemi64.loc');

jobs.useERNorPe =2; % 1 or 2.
jobs.calculate_perppant =0;
jobs.plot_perppant=1;


% for plots: use raw discrim vector or scalp projection:
useVorScalpProjection= 1;

    %% called from JOBS_ERPdecoder.m
    for ippant = 1:length(pfols)
        
      
        [PFX_classifierA_onERP_fromscalp, PFX_classifierA_onERP] =deal([]); % note that there will be an extra dimension, for each iteration.
        
        cd(eegdatadir)
        cd(pfols(ippant).name);
        sstr= pfols(ippant).name;
        %% load the Classifer and behavioural data:
        load('Classifier_objectivelyCorrect');
        load('Epoch information');
        load('participant TRIG extracted ERPs.mat');
        
        %how many times was the classifier repeated?
        nIterations = size(DEC_Pe_window.scalpproj,1);
        %% %%%%%%%%%% Crunch per ppant.  
        if jobs.calculate_perppant==1;
            for nIter= 1:nIterations; % for each of the 10 reps,
                
                if jobs.useERNorPe ==1.
                v= DEC_ERN_window.discrimvector(nIter,:)';
                winwas= 'ERN';
                elseif jobs.useERNorPe==2;
                v= DEC_Pe_window.discrimvector(nIter,:)';
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
                    
                    
                    
                    % Note that if we need to remove trials used in the training
                    % data set. so remove the training trials from our
                    % consideration.
                    if itestdata~=3
                        %training trials *this* iteration
                        % (contains correct and errors -matched in size per
                        % iteration).
                        trainedtrials = DEC_Pe_window.trainingtrials_vector(nIter,:);
                        
                        remtrials = ismember(tmptrials,trainedtrials);
                        
                        %so use the trials that werent in training:
                        untrained = tmptrials(remtrials==0);
                        
                        useDATA = resplockedEEG(:,:,untrained);
                    else % for the errA indx, all trials were used in training.
                        useDATA = resplockedEEG(:,:,tmptrials);
                    end
                    
                    [nchans, nsamps, ntrials] =size(useDATA);
                    
                    %reshape for multiplication
                    testdata = reshape(useDATA, nchans, nsamps* ntrials)';%
                    %% multiply by discrim vector:
                    
                    ytest = testdata * v(1:end-1) + v(end);
                    %% reshape for plotting.
                    ytest_trials = reshape(ytest,nsamps,ntrials);
                    
                    %% conver classifier projection to probability.
                    bptest = bernoull(1,ytest);
                    %reshape for plotting
                    bptest = reshape(bptest, nsamps, ntrials);
                    
                    % store for averaging over each iteration.
                    PFX_classifierA_onERP(itestdata,nIter,:) = mean(bptest,2);
                    
                    
                    %% debugging:
                    % compare to using scalp proj.
                sc_v= DEC_Pe_window.scalpproj(nIter,:);
                ytest_sc = testdata * sc_v';
                ytest_bp_sc= bernoull(1,ytest_sc); 
                ytest_trials = reshape(ytest_bp_sc,nsamps,ntrials);
                    PFX_classifierA_onERP_fromscalp(itestdata,nIter,:) = mean(ytest_trials,2);
                    
                end % test type (corA, corB etc).
            end % nIteration
            
            %% also save PFX for later concatenation and group effects.
            if jobs.useERNorPe==1;
                PFX_classifierA_onERP_ERNtrained = PFX_classifierA_onERP;
                PFX_classifierA_onERP_ERNtrained_fromscalp = PFX_classifierA_onERP_fromscalp;
                save('Classifier_objectivelyCorrect', 'PFX_classifierA_onERP_ERNtrained', ...
                    'PFX_classifierA_onERP_ERNtrained_fromscalp','-append')
            elseif jobs.useERNorPe==2;
                
                PFX_classifierA_onERP_PEtrained = PFX_classifierA_onERP;
                PFX_classifierA_onERP_PEtrained_fromscalp = PFX_classifierA_onERP_fromscalp;
                save('Classifier_objectivelyCorrect', 'PFX_classifierA_onERP_PEtrained', ...
                    'PFX_classifierA_onERP_PEtrained_fromscalp','-append')
            end
        end
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
        ntrials=[];
        
        % which data type to plot? classifer trained on ERN or Pe, raw vector or scalp projection?
        
        if jobs.useERNorPe==1;
            % data
            if useVorScalpProjection== 1;
            PFX_toplot = PFX_classifierA_onERP_ERNtrained;
            testComp='discrimV';
            else
                PFX_toplot = PFX_classifierA_onERP_ERNtrained_fromscalp;
                testComp='scalpProj';
            end
             % add training window
            windowvec = DEC_ERN_windowparams.training_window_ms;
            %topoplot
            mtopo = mean(DEC_ERN_window.scalpproj,1);
            
        elseif jobs.useERNorPe==2;
            if useVorScalpProjection==1
            PFX_toplot = PFX_classifierA_onERP_PEtrained;
            testComp='discrimV';
            else
                PFX_toplot = PFX_classifierA_onERP_PEtrained_fromscalp;
                testComp='scalpProj';
            end
                
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
                ntrials(1) = length(corAindx);
            case 2
                ntrials(2) = length(corBindx);
            case 3
                ntrials(3) = length(errAindx);
            case 4
                ntrials(4) = length(errBindx);
                
                
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
        title({['Trained part A(error)' ];[num2str(nIterations) ' iterations, testing ' testComp]}, 'fontsize', 25);
        legend(leg, {['Corr A (' ExpOrder{1} ') n' num2str(ntrials(1))],...
            ['Corr B (' ExpOrder{2} ') n' num2str(ntrials(2))],...
            ['Err A, (' ExpOrder{1} ') trained n' num2str(ntrials(3))],...
            ['Err B, (' ExpOrder{2} ') n' num2str(ntrials(4))]})
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
        print('-dpng', [sstr ', w-' num2str(nIter) 'reps (' winwas ')' testComp]);
        
        
        end % job: plot
    end % ippant