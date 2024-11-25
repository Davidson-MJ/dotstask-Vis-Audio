function Plot_decA_diagonal_timegen(cfg)
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

normON=1;
% for plots: use raw discrim vector or scalp projection:


%loadname determined by type.
train_name = ['Classifier_trained_' cfg.expPart_train '_' cfg.EEGtype_train '_diagonal'];
savename = ['Classifier_trained_' cfg.expPart_train '_' cfg.EEGtype_train '_tested_' cfg.expPart_test '_' cfg.EEGtype_test ' timegen'];

pfols= cfg.pfols;
%% called from JOBS_ERPdecoder.m
for ippant = 1:length(pfols)


    [ PFX_timegen_tmp,PFX_timegen_CvsE] =deal([]); % note that there will be an extra dimension, for each iteration.

    cd(cfg.eegdatadir)
    cd(pfols(ippant).name);
    sstr= pfols(ippant).name;
    %% load the Classifer and behavioural data:

    load(train_name); % this loads the classifier in question.
    DEC_trainer = DECout_diagonal_window; % this has a discrim vector for each time point.


    load('Epoch information', 'corAindx', 'corBindx', 'errAindx', 'errBindx');
    %         load('participant TRIG extracted ERPs.mat', 'resplockedEEG');
    load('participant EEG preprocessed.mat', 'resplockedEEG', 'stimlockedEEG');
    if strcmp(cfg.EEGtype_test, 'stim')
        testEEG = stimlockedEEG;

    else
        testEEG = resplockedEEG;
    end
    %how many times was the classifier repeated?
    nIterations = size(DEC_trainer.scalpproj_perTime,1);
    %% %%%%%%%%%% Crunch per ppant.
    if jobs.calculate_perppant==1


        %% use the vector and untrained trials:
        if strcmp(cfg.expPart_test, 'A')
            test_corIndx = corAindx;
            test_errIndx= errAindx;

        else
            test_corIndx = corBindx;
            test_errIndx= errBindx;


        end

        % prepare the case for when testing all together:
         tmptrials= zeros(1,size(testEEG,3));
                    tmptrials(test_corIndx)=1;
                    tmptrials(test_errIndx)=1;

                    truth= zeros(1,length(tmptrials));
                    truth(test_errIndx)=1;
                    %back to indx.
                    test_allIndx= find(tmptrials);
                    truth= truth(test_allIndx);

        testindices= {test_corIndx, test_errIndx,test_allIndx};
       
        % % % (NEED to sort out the training / trial allocation.
        % make sure the untrained trials are correct!

        for  iCvsE = 1:3 % test each separately, then combine for overall accuracy?


            testthesetrials=testindices{iCvsE};


             if cfg.singleorAvIterations ==1
                 testIter=nIterations;
             else
                 testIter= 1;
             end

             PFX_timegen_tmp=[]; % trial sizes change per Cvs E.

            for nIter= 1:testIter%:nIterations % for each of the 10 reps,

                %             tmptrials= sort([corIndx; errIndx]);
                %             tmptrials_type= [zeros(1, length(corIndx)), ones(1,length(errIndx))];
                %
                %
                %             % Note that if we need to remove trials used in the training
                %             % data set. so remove the training trials from our
                %             % consideration.
                %
                %             trainedtrials = DEC_trainer.Correctindices_usedintraining(nIter,:);
                %
                %             remtrials = ismember(tmptrials,trainedtrials);
                %
                %             %so use the trials that werent in training:
                %             untrained = tmptrials(remtrials==0);

                useDATA = testEEG(:,:,testthesetrials);

                %             useDATA_type = tmptrials_type(untrained); % keep the order.
                %
                %             errinEEG= find(useDATA_type==1);
                %             corrinEEG= find(useDATA_type==0);

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


                %% multiply by discrim vector:

                % for each trained window, test on all;
                for iwintrain = 1:length(DECout_diagonal_window.trainingwindow_centralms);

                    %this v
                    if cfg.singleorAvIterations ==1

                        vtime = squeeze(DECout_diagonal_window.discrimvector_perTime(nIter,iwintrain,:));
                    else
                        vtime = squeeze(mean(DECout_diagonal_window.discrimvector_perTime(:,iwintrain,:),1));
                    end
                  

                    for iwintest = 1:length(DECout_diagonal_window.trainingwindow_centralms);
                        nwinsamps_test = DECout_diagonal_window.trainingwindow_frames(iwintest,:);
                        
                        % should we test on the mean within this window?
                        
                        testON= useDATA(:,nwinsamps_test(1):nwinsamps_test(2),:);
                        %reshape for matrix mult.
                        [nchans, sampsize, ntrials] =size(testON);

                        testdataON = reshape(testON, nchans, sampsize* ntrials)';%
                        %%
                        ytest = testdataON * vtime(1:end-1) + vtime(end);
                        %convert to prob:
                        bptest = bernoull(1,ytest);
                        %% reshape for plotting.

                        bptest = reshape(bptest, sampsize, ntrials);

                        % here we can extract the corrects, and flip the sign.
                        %                 bptest_corr = bptest(:,corrinEEG);
                        %                 bptest_err = bptest(:,errinEEG);
                        %                 bptest(:,corrinEEG)=  0.5-bptest(:,corrinEEG);


                        % store for averaging over each iteration.
                        if iCvsE<3
                            %mean over samples and trials:
                        PFX_timegen_tmp(nIter,iwintrain,iwintest) = mean(mean(bptest,1),2);
                        else % AUC
                            %use mean over samples:
                            tmpP = mean(bptest,1); % trials separate.

                            [Az,~,~] = rocarea(tmpP, truth);
                            PFX_timegen_tmp(nIter,iwintrain,iwintest)= Az;

                        end

                    end % testwindow.
                end % train window
                disp(['Fin iteration: ' num2str(nIter)]);
            end % % nIteration
            % take mean over iterations, and convert if necessary.

            timeGen_mean = squeeze(mean(PFX_timegen_tmp,1));
            PFX_timegen_CvsE(iCvsE,:,:) = timeGen_mean;

           
            %%
        end
    
      
        %% sanity check:
%         
%                 clf;
%                 Xtimes= DEC_trainer.trainingwindow_centralms;    
%                 for isub= 1:3
%                     subplot(2,3,isub);
%                    
%                     pD= squeeze(PFX_timegen_CvsE(isub,:,:));
% 
%                     imagesc(pD);
%                     set(gca,'ydir', 'normal');
%                     colorbar;
%                     caxis([.5 .75]);
%                     axis square;
%                     subplot(2,3,isub+3);
% 
%                     d= smooth(diag(pD));
%                     
%                     plot(Xtimes, d, 'k');
%                     hold on;
%                     if isub==1
%                     plot(Xtimes, 1-d, ':');
%                     tmpr= 1-d;
%                     elseif isub==2
%                    plot(Xtimes, tmpr, ':');
%                     end    
%                     ylim([.4 .8]);
%                     hold on; 
%                     plot(xlim, [.5 .5])
% 
%                 end
        %% also save PFX for later concatenation and group effects.
        Xtimes= DECout_diagonal_window.trainingwindow_centralms;
        save(savename, 'PFX_timegen_CvsE', 'Xtimes')

        disp(['Finished saving timegen ppant ' num2str(ippant)])
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    %% > plot PFX
    %%
    if jobs.plot_perppant


        cd(cfg.eegdatadir)
        cd(pfols(ippant).name);
        sstr= pfols(ippant).name;
        %% load the Classifer and behavioural data:
        load(savename);
        load('Epoch information.mat');
        leg=[];

        %for each comparison made:
        figure(1); clf
        set(gcf, 'color', 'w', 'units', 'normalized','position', [.1 .1 .8 .8]);
        shg;


        % which data type to plot? classifer trained on ERN or Pe, raw vector or scalp projection?

%         PFX_timegen_CvsE;
%%
ytests = {'correct', 'error', 'combined'}; 
for iplot=1:3
   
        useD= squeeze(PFX_timegen_CvsE(iplot,:,:));
    %
%%
    subplot(2,3,iplot);
    
    imagesc(Xtimes, Xtimes, useD);
  
    % add extra plot elements:
    hold on; plot(xlim, [.5 .5], ':', 'color', 'w', 'linew', 1)
    hold on; plot([0 0 ], ylim, ':', 'color', 'w', 'linew', 1)
    xlabel(['trained on ' cfg.EEGtype_train ' errors in ' cfg.expPart_train])
    ylabel(['tested on ' cfg.EEGtype_test ' ' ytests{iplot} ' in ' cfg.expPart_test])
    set(gca, 'fontsize', 15,'ydir', 'normal')
caxis([.5 .7])
colorbar
  axis square
  plot([Xtimes(1) Xtimes(end)] , [Xtimes(1) Xtimes(end)], 'w')
% 
  subplot(2,3,iplot+3);
  d= diag(useD);
  plot(Xtimes, d); 
  hold on;
  plot(xlim, [.5 .5]); title('diagonal for comparison');
%   colorbar
end % each plot.

%%
        %% print results
        cd(cfg.figdir)
        %
        try cd(['Classifier Results' filesep 'PFX_Trained on ' cfg.EEGtype_train ' Errors in part ' cfg.expPart_train ' timegen']);
        catch
            mkdir(['Classifier Results' filesep 'PFX_Trained on ' cfg.EEGtype_train ' Errors in part ' cfg.expPart_train ' timegen'])
            cd(['Classifier Results' filesep 'PFX_Trained on ' cfg.EEGtype_train ' Errors in part ' cfg.expPart_train ' timegen'])
        end
        %%
        set(gcf, 'color', 'w');
        printname= [sstr ', w-' num2str(nIterations) 'reps ',...
            '(timegen ' cfg.EEGtype_train ' ' cfg.expPart_train ' on '...
            cfg.EEGtype_test ' ' cfg.expPart_test ' )' ];
        print('-dpng',printname) ;
        shg

    end % job: plot
end % ippant