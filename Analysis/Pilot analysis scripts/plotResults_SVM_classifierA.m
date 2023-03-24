
% first calculate (concatenate, accuracy), across participants. then plot.

job.plotPFX=0;
job.plotGFX=1;


plottype = 2; % 1 for A (CvsE), 2 for A (trained C vs E), test on B.
for ippant = 1:length(pfols)

% prep output:
  
        cd(eegdatadir)
        
        cd(pfols(ippant).name);
        %% load the Classifer and behavioural data:
        if plottype == 1
            load(['SVM_Results_ERPbased_' pfols(ippant).name '.mat'], 'svmECOC');
            twas = 'trained and tested E vs C (partA)';
        elseif plottype ==2
            load(['SVM_Results_ERPbased_crossmodal' pfols(ippant).name '.mat'], 'svmECOC');
            twas = 'trained E vs C (partA), tested E vs C (part B)';
        end
        % Decoding Parameters (must match svmECOC object)  
Nblock = svmECOC.nBlocks; % cross-validation
Nitr = svmECOC.nIter; % iteration
Ntp = length(svmECOC.time); % # of time points
NBins = svmECOC.nBins; % # of stimulus bins 
  
% Obtain predictions from SVM-ECOC model
    svmPrediction = squeeze(svmECOC.modelPredict);
    tstTargets = squeeze(svmECOC.targets);
    
%output prep:
DecodingAccuracy = nan(Ntp,Nblock,Nitr);
         %% Compute decoding accuracy of each decoding trial
    for block = 1:Nblock
        for itr = 1:Nitr
            for tp = 1:Ntp  

                prediction = squeeze(svmPrediction(itr,tp,block,:)); % this is predictions from models
                TrueAnswer = squeeze(tstTargets(itr,tp,block,:)); % this is real answer, from class labels.
                Err = TrueAnswer - prediction; %compute error. No error = 0
                ACC = mean(Err==0); %Correct hit = 0 (avg propotion of vector of 1s and 0s)
                DecodingAccuracy(tp,block,itr) = ACC; % average decoding accuracy at tp & block

            end
        end
    end
        % Average across block and iterations
     grandAvg = squeeze(mean(mean(DecodingAccuracy,2),3));
    
     % Perform temporal smoothing (5 point moving avg) 
     smoothed = smooth(grandAvg,5);
    
     % Save smoothed data
     AverageAccuracy(ippant,:) =smoothed; % average across iteration and block
     
        %% 
end
%%
if job.plotPFX==1
    %%
    figure(1); clf;
        set(gcf, 'units', 'normalized', 'Position', [0 1 .6 .35]); shg
        leg=[];
        % plot output per ppant:
        
        
        for ippant = 1:length(pfols);
            subplot(3,4,ippant);
        plot(svmECOC.time, AverageAccuracy(ippant,:));
        end
    
    
end

vis_first=[2,3,6:18];
aud_first = [1,4,5];

if job.plotGFX==1
    %%   
    figure(1); clf;
        set(gcf, 'units', 'normalized', 'Position', [0 1 .6 .35]); shg
        leg=[];
        
        mP = squeeze(nanmean(AverageAccuracy(vis_first,:),1));
        stE= CousineauSEM(AverageAccuracy(vis_first,:));
        
        sh= shadedErrorBar(svmECOC.time, mP, stE, [], 1);
        
    
        hold on; 
        plot(xlim, [.5 .5], ['k:'])
        ylim([.45 1]);
    xlabel('time after response');
    ylabel('svm-classifier accuracry');
    title(twas)
    
    pvals =[];
    for itime = 1:length(mP)
    [h,pvals(itime)] = ttest(AverageAccuracy(vis_first,itime), 0.5);
    
    if pvals(itime)<.05
        text(svmECOC.time(itime), 0.48, '*');
    end
    end
    set(gcf, 'color', 'w')
    set(gca, 'fontsize', 15)
    
end

