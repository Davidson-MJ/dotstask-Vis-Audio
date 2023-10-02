function  DECODERout=my_Classifier_VISAUD_diagonal(dec_params)
%from within:
% getelocs;
DECODERout=[]; % for output.
elocs = readlocs('BioSemi64.loc');
%
   %% set basic parameters based on dec_params input:
    %size of window to view:
    times = dec_params.wholeepoch_timevec;
    
    
    basetmp = dsearchn(times', [dec_params.baseline_ms(1) dec_params.baseline_ms(2)]');
    baseline=basetmp(1):basetmp(2);  % baseline in pnts
    
    
%start analyzing data, set up decoder params which we can hold constant,
%before sliding the analysis window:

%first step is to normalize all:
% extract all data.
allD = dec_params.data;
%which data are correct vs errors:
error_index = logical(dec_params.error_index);
correct_index = logical(dec_params.correct_index);

corrects=allD(:,:,correct_index);
errors=allD(:,:,error_index);

C=size(corrects,3);
E=size(errors,3);

% tmp values of nC and nE, updated within iteration loop:

maxE = E;%ceil(E*.95); % we will only train on X% of error data. (test on rest)
% Test whether equal number of corrects and incorrects.
Ctmp = C;
Etmp= maxE;

%%
fprintf('Trials per condition: %d and %d.\n',C,E);
if C~= E
    fprintf('Warning: Each condition should contain the same number of data points.\n');
    fprintf('Warning: Matching size of datasets now .\n');
    disp(['Warning: Will repeat this process over n = ' num2str(dec_params.nIter) 'iterations']);
end



% first, normalize the full dataset, then each iteration will take a
% subselection of ERPs.
 

for iCandE = 1:2
    switch iCandE
        case 1
            allDt = corrects;
        case 2
            allDt=errors;
    end
    data_norm = zeros(size(allDt));

    for elec=dec_params.chans
        for trial=1:size(allDt,3)

            temp=allDt(elec,:,trial);
            %remove baseline if specified:
            if dec_params.removebaseline
                if sum(baseline)>1
                    temp=temp-mean(temp(baseline));
                end
            end
            %perform normalization by specified type.
            if strcmp(dec_params.normtype, 'n1')
                % rescale
                temp=temp-(0.5*(min(temp)+max(temp)));
                if(min(temp)~=max(temp))
                    temp=temp/max(temp);
                end
            elseif  strcmp(dec_params.normtype, 'n2')
                %             if(min(temp(baseline==1))~=max(temp(baseline==1)))
                %                 temp=temp/std(temp(baseline==1));
                %             end
                error('Warning: Now normalizing data, but incorrect norm method selected.\n');
            end

            data_norm(elec,:,trial) = temp;

        end
    end

    switch iCandE
        case 1
            corrects_norm = data_norm;
        case 2
            errors_norm = data_norm;

    end
end




% Match the size of the data subsets (default is that this is done)
% -------------------------------------------------------------------------

allDiag_corr=[];
allDiag_err=[]; % for plotting.


 %% which channels to plot?
    if ~isfield(dec_params, 'chans'); chansubset=1:chans;  
    else
        chansubset=dec_params.chans; 
        chans=size(chansubset,2) ; 
    end
    

for nIteration = 1:dec_params.nIter
    
%     disp(['Performing iteration: ' num2str(nIteration) ' of ' num2str(dec_params.nIter)]);
    
    if dec_params.matchCE
        % Select a random subset of the trials to match no. of trials per
        % condition
        tmpOrder_c = randperm(max([C;maxE]));


        newtrials_corr=find(tmpOrder_c <=min([C;maxE]));
        
        corrects_test=corrects(:,:,newtrials_corr);
        %match sizes.
        Ctmp=Etmp;
        %select a random bunch of errors:
        tmpOrder_e= randperm(E);
        newtrials_err= find(tmpOrder_e <=maxE);
        errors_test = errors(:,:,newtrials_err);
        
        
        DECODERout.Correctindices_usedintraining(nIteration,:)=newtrials_corr;
        DECODERout.Errorindices_usedintraining(nIteration,:)=newtrials_err;
        
        
    end
    
    %make sure to save the trial indices used in training.
    Training_index = [tmpOrder_c(newtrials_corr),tmpOrder_e(newtrials_err)];
    
    DECODERout.Trainingtrials_index = Training_index;
    
    
  
    
    % use the below subset: otherwise corrects_norm is all data.
   % update normd data we will use;
        corrects_normtest=corrects_norm(:,:,newtrials_corr);
        errors_normtest = errors_norm(:,:,newtrials_err);%
    
    
    
    %%
    %>>>>> RUN logistic regression
    %>>>>>>>>>>>>>>>>>>
    DECODERout.type = 'lr';
    %>>>>>>>>>>>>>>>>>>
    
    %% loop these params, this iteration, for all time points
 
    % using a sliding window:

Fs = dec_params.Fs;
movingwin= dec_params.movingWin;
Nwin=round(Fs*movingwin(1)); % number of samples in window
Nstep=round(movingwin(2)*Fs); % number of samples to step through
nsamps = size(data_norm,2);
winstart=1:Nstep:nsamps-Nwin+1;
nw=length(winstart);
%%

% centre values:
winmid=winstart+round(Nwin/2);
DECODERout.trainingwindow_centralframe= winmid;
    DECODERout.trainingwindow_centralms= times(winmid);

    for itimestep =1:nw

          indx=winstart(itimestep):winstart(itimestep)+Nwin-1;
    
        init= indx(1);
        endw=indx(end);
    %
    pts=endw-init; % training window length
        
    %>>>>>>>>>>>>>>>>>>
    DECODERout.trainingwindow_ms(itimestep,:) = [times(init),times(endw)];
    DECODERout.trainingwindow_frames(itimestep,:) = [init,endw];

%     DECODERout.baseline_ms = times(basetmp(1)):times(basetmp(2));
%
    %>>>>>>>>>>>>>>>>>>

    
    trainingwindowoffset=init; 
    trainingwindowlength=pts; 
    i=1;
    showaz=1;
    
    
    show=0;
    regularize=0; % if suspecting two similar sources, improves sensitivity to error.
    lambda=1.00e-06;
    lambdasearch=0;
    eigvalratio=1.00e-06;
    vinit=zeros(size(chansubset,2)+1,1);
    
    % errors as true, corrects as false.
    truth=[zeros(trainingwindowlength.*Ctmp,1); ones(trainingwindowlength.*Etmp,1)];
    
    
    % difference for Boldt decoding:
    %   truthnow = kron(truths(training==1)', ones(size(window(window==1),2),1));
    
    
    % place subset of both correct and errors in same dimension (3rd).
    correct_traindata=corrects_normtest(chansubset,trainingwindowoffset(i):trainingwindowoffset(i)+trainingwindowlength-1,:);
    error_traindata= errors_normtest(chansubset,trainingwindowoffset(i):trainingwindowoffset(i)+trainingwindowlength-1,:);
    
    x=cat(3,correct_traindata, error_traindata);
    
    x=x(:,:)'; % Rearrange data for logist.m [D (T x trials)]'
    
    
    
    v = logist(x,truth,vinit,0,regularize,lambda,lambdasearch,eigvalratio);
    
    % this is the main piece we need: for subsequent tests against other
    % trial types:
    %>>>>>>>>>>>>>>>>>>
    DECODERout.discrimvector_perTime(nIteration,itimestep,:) = v;
    %>>>>>>>>>>>>>>>>>>
    
    %% multiply discriminating component by EEG activity
    % the normalized test set first:
    y = x*v(1:end-1) + v(end);
    %size is trainingwindow*ntrials.
    bp = bernoull(1,y);
    
%     p = bernoull(1,[x 1]*v);
    
    a = y \ x; 
    
%     !!!
    sp=a'; %scalp projection.
    
%     !!!!
    
    %>>>>>>>>>>>>>>>>>>
    DECODERout.scalpproj_perTime(nIteration,itimestep,:) = sp;
    %>>>>>>>>>>>>>>>>>>
    
    end % timestep % all timesteps, have stored the scalp proj and discrim v
%%
    
   
    
     if dec_params.dispprogress==1
        %% Now plot raw ERP, and later the normalized version, for comparison.
        %Raw first: plot corrects:
        temp = squeeze(mean(corrects_test(dec_params.showchannel, :,:),1));
    
        
        figure(1); clf;
        subplot(2,4,1)
        plot(times, mean(temp,2), 'color', [0 .5 0]);
        % plot errors:
        clear temp; hold on
        temp = squeeze(mean(errors_test(dec_params.showchannel, :,:),1));
        
        plot(times, mean(temp,2), 'color', 'r');
        %add patch for classifier window
        %specify vertices clockwise from bottom left.
        axis tight
%         xverts= [times(frames_out(1)+init),times(frames_out(1)+init), times(frames_out(1)+init+pts-1), times(frames_out(1)+init+pts-1)];
%         yx = get(gca, 'ylim');
%         yverts= [yx(1), yx(2), yx(2), yx(1)];
%         
%         pch=patch(xverts,yverts, 'k');
%         pch.FaceAlpha=.1;
        ylabel('uV');
        xlabel('Time from response [ms]');
        set(gca, 'YDir', 'reverse'); legend('corrects', 'errors');
        
        title({['Raw ERP at ' elocs(dec_params.showchannel).labels ','];['ntrials (matched) = ' num2str(Ctmp)]});
        
        %% now plot the topography, of the difference, in our window of interest.
        tempC =  squeeze(nanmean(corrects_test(:, :,:),3));
        tempE =  squeeze(nanmean(errors_test(:, :,:),3));
        
        % take difference per channel:
        tempDiff = tempE-tempC;
        tmpt= dsearchn(times', [250,350]')
        %plot
        subplot(2,4,4);
        topoplot(mean(tempDiff(:,[tmpt(1):tmpt(2)]),2), elocs);
        title({['Raw Data, difference error-corr'];[num2str(round(times(tmpt))) ' ms']}); %colorbar
        %%
  
    %% now plot the normalized data for comparison.
   
        temp = squeeze(mean(corrects_normtest(dec_params.showchannel, :,:),1));
        subplot(2,4,2)
        plot(times, mean(temp,2), 'color', [0 .5 0]);
        % plot errors:
        clear temp; hold on
        temp = squeeze(mean(errors_normtest(dec_params.showchannel, :,:),1));
        plot(times, mean(temp,2), 'color', 'r');      
        ylabel('uV');
        xlabel('Time from response [ms]');
        set(gca, 'YDir', 'reverse'); legend('corrects', 'errors');
        
        title({['Normalized ERP ']});
  

   

   % % after timesteps. can we plot the diagonal?
   %% the trick is to only plot the result on self tested windows.
   %% all trials (including untested:)
     testdata=cat(3,corrects_norm, errors_norm); % C then E

     corrIndx= 1:size(corrects_norm,3);
     errIndx= corrIndx(end)+1:size(testdata,3);

   [corr_Diag_Y, corr_Diag_bp]=deal(nan(1,length(winmid)));
   [err_Diag_Y,err_Diag_bp]=deal(nan(1,length(winmid)));

   for iwin = 1:length(DECODERout.trainingwindow_centralms);
    
       %this v
       vtime = squeeze(DECODERout.discrimvector_perTime(nIteration,iwin,:));
       %samps trained:
       nsamps = DECODERout.trainingwindow_frames(iwin,:);
%        sampsize= nsamps(2)-nsamps(1);
       %so extract only self tested window:
       testON= testdata(:,nsamps(1):nsamps(2),:);
       %reshape for matrix mult.
       [nchans, sampsize, ntrials] =size(testON);

       testdataON = reshape(testON, nchans, sampsize* ntrials)';%
       %%
       ytest = testdataON * vtime(1:end-1) + vtime(end);
       %convert to prob:
    bptest = bernoull(1,ytest);
       %% reshape for plotting.
       ytest_trials = reshape(ytest,sampsize,ntrials);
      
       ytest_corr = mean(ytest_trials(:,corrIndx),2);
        ytest_err = mean(ytest_trials(:,errIndx),2);
  
    bptest = reshape(bptest, sampsize, ntrials);
 
%     %store for next plots:
%     corr_Diag_bp(nsamps(1):nsamps(2)) = mean(bptest(:,corrIndx),2);
%     err_Diag_bp(nsamps(1):nsamps(2))=  mean(bptest(:,errIndx),2);
% 
%     %store for next plots:
%     corr_Diag_Y(nsamps(1):nsamps(2)) = ytest_corr;
%     err_Diag_Y(nsamps(1):nsamps(2))=  ytest_err;


    corr_Diag_bp(iwin) = mean(mean(bptest(:,corrIndx),2));
    err_Diag_bp(iwin)=  mean(mean(bptest(:,errIndx),2));

    %store for next plots:
    corr_Diag_Y(iwin) = mean(ytest_corr);
    err_Diag_Y(iwin)=  mean(ytest_err);
      
   end
   %%
   subplot(2,4,3)

   plot(times(winmid), err_Diag_Y,'o-', 'color', 'r'); hold on;
      plot(times(winmid), corr_Diag_Y, 'o-','color', [0 .5 0]); hold on;
%       plot(xlim,[.5 .5], ['k:'], 'LineWidth',1)

   subplot(2,4,5:6)

   plot(times(winmid), err_Diag_bp,'o-', 'color', 'r'); hold on;
      plot(times(winmid), corr_Diag_bp, 'o-','color', [0 .5 0]); hold on;
      plot(xlim ,[.5 .5], ['k:'], 'LineWidth',1)
   %%
   
    allDiag_corr(nIteration,:) = corr_Diag_bp;
    allDiag_err(nIteration,:) = err_Diag_bp;
     end
    
    
disp(['Completed iteration: ' num2str(nIteration) ' of ' num2str(dec_params.nIter)])
%     disp(['timestep  ' num2str(itimestep) ' of ' num2str(length(bins)-1)])
end % niterations
%%
if dec_params.dispprogress
figure(2); 

%
   plot(times(winmid), mean(allDiag_err,1),'o-', 'color', 'r'); hold on;
      plot(times(winmid), mean(allDiag_corr,1), 'o-','color', [0 .5 0]); hold on;
      ylabel('prob(Error)');
      hold on
plot(xlim, [.5 .5]);
shg
end
   %%
% 
return