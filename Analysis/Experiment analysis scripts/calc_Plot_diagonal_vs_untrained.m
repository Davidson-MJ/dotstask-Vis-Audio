function calc_Plot_diagonal_vs_untrained(cfg)
%called from JOBS_ERPdecoder

% this script is a close match to the prev, now saving the diagonal
% train-test combination.

dbstop if error
elocs= readlocs('BioSemi64.loc');


cmap = cbrewer('qual', 'Dark2', 10);
cmap = cmap(5:10,:);
cmap(cmap>1)=1;

jobs.calculate_perppant =cfg.crunchPPant;

jobs.plot_perppant=cfg.justplot;


useCols= {'b', 'r', 'b', 'r'}; % A B A B;
useln= {'-', '-', ':', ':'}; % corr corr err err;

normON=0;
% for plots: use raw discrim vector or scalp projection:


%loadname determined by type.
loadname = ['Classifier_trained_' cfg.expPart '_' cfg.EEGtype '_diagonal'];
pfols= cfg.pfols;
    %% called from JOBS_ERPdecoder.m
    for ippant = 1:length(pfols)
        
      
        [PFX_classifierA_onERP_fromscalp, PFX_classifierA_onERP] =deal([]); % note that there will be an extra dimension, for each iteration.
        
        cd(cfg.eegdatadir)
        cd(pfols(ippant).name);
        sstr= pfols(ippant).name;
        %% load the Classifer and behavioural data:
        load(loadname);
        load('Epoch information', 'corAindx', 'corBindx', 'errAindx', 'errBindx');
%         load('participant TRIG extracted ERPs.mat', 'resplockedEEG');
        load('participant EEG preprocessed.mat', 'stimlockedEEG', 'resplockedEEG');
        
        %how many times was the classifier repeated?
        nIterations = size(DECout_diagonal_window.scalpproj_perTime,1);
        %% %%%%%%%%%% Crunch per ppant.  
        if jobs.calculate_perppant==1
            
          
              if strcmp(cfg.EEGtype, 'resp')
                  useEEG = resplockedEEG;
              else
                  useEEG = stimlockedEEG;
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

                    for nIter= 1:10 % for each of the 10 reps,

                    
                    
                    % Note that if we need to remove trials used in the training
                    % data set. so remove the training trials from our
                    % consideration.
                  
                    if strcmp(cfg.expPart, 'A')
                        % compare trained trials to indx
                    trainedtrials_c = corAindx(DECout_diagonal_window.Correctindices_usedintraining(nIter,:));
                      trainedtrials_e = errAindx(DECout_diagonal_window.Errorindices_usedintraining(nIter,:));

                    else
                        trainedtrials_c = corBindx(DECout_diagonal_window.Correctindices_usedintraining(nIter,:));
                      trainedtrials_e = errBindx(DECout_diagonal_window.Errorindices_usedintraining(nIter,:));


                    end
% 
%                     if any(ismember(trainedtrials_c, trainedtrials_e))
%                         error('check code');
%                     end
%                         trainedtrials = [trainedtrials_c, trainedtrials_e] ;
%                         
%                         remtrials = ismember(tmptrials,trainedtrials);
%                         
%                         %so use the trials that werent in training:
%                         untrained = tmptrials(remtrials==0);
%                         
%                         useDATA = useEEG(:,:,untrained);
%                     
%                     
useDATA=useEEG(:,:,tmptrials);
                  [nchans, nsamps, ntrials]= size(useDATA);

                    % normalize by rescaling.
                    if normON==1
                        data_norm = zeros(size(useDATA));
                        for ichan = 1:nchans
                            for itrial=1:ntrials
                                temp = useDATA(ichan,:,itrial);
                                % rescale
                                temp=temp-(0.5*(min(temp)+max(temp)));
                                if(min(temp)~=max(temp))
                                    temp=temp/max(temp);
                                end
                                
                                data_norm(ichan,:,itrial) = temp;
                            end
                        end
                        useDATA= data_norm;
                    end
                    
                    
                    
                    %reshape for multiplication
%                     testdata = reshape(useDATA, nchans, nsamps* ntrials)';%
                    %% multiply by discrim vector:


                    for iwin = 2:length(DECout_diagonal_window.trainingwindow_centralms);

                        %this v
                        vtime = squeeze(DECout_diagonal_window.discrimvector_perTime(nIter,iwin,:));
                        %samps trained:
                        nwinsamps = DECout_diagonal_window.trainingwindow_frames(iwin,:);
                        %        sampsize= nsamps(2)-nsamps(1);
                        %so extract only self tested window:
                        testON= useDATA(:,nwinsamps (1):nwinsamps (2),:);
                        %reshape for matrix mult.
                        [nchans, sampsize, ntrials] =size(testON);

                        testdataON = reshape(testON, nchans, sampsize* ntrials)';%
                        %%
                        ytest = testdataON * vtime(1:end-1) + vtime(end);
                        %convert to prob:
                        bptest = bernoull(1,ytest);
                        %% reshape for plotting.
                       
                        bptest = reshape(bptest, sampsize, ntrials);

                        %NOTE if we are working with Correct trials. then
                        % a low probability is favourable. So convert to prob of 'Correct'
                        if itestdata ==1 ||itestdata==2
                            %                         bptest= 1-bptest;
                        end

                        % store for averaging over each iteration.
                        PFX_classifierA_onERP(itestdata,nIter,iwin) = mean(mean(bptest,2),1);


                    end %
               
                end % % nIteration
            end 
%             test type (corA, corB etc).
          
            %% also save PFX for later concatenation and group effects.
           PFX_classifierA_onERP_diagonal = PFX_classifierA_onERP;
                save(loadname, 'PFX_classifierA_onERP_diagonal', '-append')
           
                disp(['Finished saving ppant ' num2str(ippant)])
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%
        %% > plot PFX
          %%
        if jobs.plot_perppant
       

        cd(cfg.eegdatadir)
        cd(pfols(ippant).name);
        sstr= pfols(ippant).name;
        %% load the Classifer and behavioural data:
        load(loadname);
        load('Epoch information.mat', 'ExpOrder', 'corrAindx', 'corrBindx', 'errAindx', 'errBindx');
        leg=[];        
        Xtimes = DECout_diagonal_window.trainingwindow_centralms;
        
        %for each comparison made:
        figure(1); clf
        set(gcf, 'color', 'w', 'units', 'normalized','position', [.1 .1 .8 .8]);
        shg;
        spots= [1,2,1,2];

        ntrials=[];
        
        % which data type to plot? classifer trained on ERN or Pe, raw vector or scalp projection?
        
            PFX_toplot = PFX_classifierA_onERP_diagonal;
            testComp='discrimV';
           
            %topoplot
%             mtopo = mean(DECout_diagonal_window.scalpproj,1); % will have topos x times.
            
        for itestdata=1:4    
            if itestdata<5
                useD = PFX_toplot(itestdata,:,:);
            elseif itestdata==5
                % display the combined score for discrim C from E

                %pError + not pCorr.
                useD = PFX_toplot(3,:,:) + (PFX_toplot(1,:,:));
            elseif itestdata==6
                
                useD = PFX_toplot(4,:,:) + (PFX_toplot(2,:,:));

            end

            subplot(1,2,spots(itestdata));
        %% take average performance over all iterations.
        avP = squeeze(mean(useD,2));
        stE = CousineauSEM(squeeze(useD));
        stmp = shadedErrorBar(Xtimes(1:length(avP)), avP ,stE, {'color', useCols{itestdata}, 'linestyle', useln{itestdata}, 'linew',2}, 1);
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
            case 5 
                ntrials(5) =  length(corAindx) + length(errAindx);
            case 6
                ntrials(6) =  length(corBindx) + length(errBindx);
                
                
        end
%         xlim([-200 500])
        ylim([0 1]);
        %% add extra plot elements:
        hold on; plot(xlim, [.5 .5], '--', 'color', [.3 .3 .3], 'linew', 3)
        hold on; plot([0 0 ], ylim, '--', 'color', [.3 .3 .3], 'linew', 3)
        title(['trained on ' cfg.EEGtype ' errors in ' cfg.expPart ' (diagonal)'])
         set(gca, 'fontsize', 15)
         xlabel('Time since response (ms)')
        ylabel('prob(Error)');
                xlabel(['Time since ' cfg.EEGtype ' (ms)'])

end
        
        %
        legend(leg, {['Corr A (' ExpOrder{1} ') n' num2str(ntrials(1))],...
            ['Corr B (' ExpOrder{2} ') n' num2str(ntrials(2))],...
            ['Err A, (' ExpOrder{1} ') trained n' num2str(ntrials(3))],...
            ['Err B, (' ExpOrder{2} ') n' num2str(ntrials(4))]}, 'Location', 'South');%,...
%             'All A', 'All B']})%
        set(gca, 'fontsize', 15)
        
        %%
        
%         subplot(133);
%         topoplot(mtopo, elocs);
%         title([sstr  ', mean spatial projection'], 'interpreter', 'none')
%         set(gca, 'fontsize', 15)
        %% print results
       cd(cfg.figdir)
        %%
        cd(['Classifier Results' filesep 'PFX_Trained on ' cfg.EEGtype ' Errors in part ' cfg.expPart]);
        
        %%
        set(gcf, 'color', 'w')
        print('-dpng', [sstr ', w-' num2str(nIterations) 'reps (diagonal)' ]);
        shg
        
        end % job: plot
    end % ippant