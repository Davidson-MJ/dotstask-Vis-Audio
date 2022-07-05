function  DECODERout=my_Classifier_VISAUD_diagonal(dec_params)
%from within:
% getelocs;
DECODERout=[]; % for output.
elocs = readlocs('BioSemi64.loc');
%
   %% set basic parameters based on dec_params input:
    %size of window to view:
    Xtimes = dec_params.wholeepoch_timevec;
    
    framesouttmp = dsearchn(Xtimes', [dec_params.window_frames_ms(1), dec_params.window_frames_ms(2)]');
    frames_out=framesouttmp(1):framesouttmp(2); % data runs from 0:500 (ms)
    
    basetmp = dsearchn(Xtimes', [dec_params.baseline_ms(1) dec_params.baseline_ms(2)]');
    baseline=basetmp(1):basetmp(2);  % baseline in pnts
    
    times=Xtimes;
    
    bins = dec_params.timebins;
    
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
Ctmp = C;
Etmp= E;

% Test whether equal number of corrects and incorrects.

%%
fprintf('Trials per condition: %d and %d.\n',C,E);
if C~= E
    fprintf('Warning: Each condition should contain the same number of data points.\n');
    fprintf('Warning: Matching size of datasets now .\n');
    disp(['Warning: Will repeat this process over n = ' num2str(dec_params.nIter) 'iterations']);
end

% Match the size of the data subsets (default is that this is done)
% -------------------------------------------------------------------------

for nIteration = 1:dec_params.nIter
    
    disp(['Performing iteration: ' num2str(nIteration) ' of ' num2str(dec_params.nIter)]);
    
    if dec_params.matchCE
        % Select a random subset of the trials to match no. of trials per
        % condition
        
        newtrials=find(randperm(max([C;E]))<=min([C;E]));
        
        corrects_test=corrects(:,:,newtrials);
        %match sizes.
        Ctmp=Etmp;
        errors_test = errors;
        
        
        DECODERout.Correctindices_usedintraining(nIteration,:)= newtrials;
        
        if E>C
            error('more errors than correct trials!')
            %         errors_test=errors(:,:,newtrials);
            %         E=C;
            %         corrects_test = corrects;
        end
        
    end
    
    %make sure to save the trial indices used in training.
    Training_index = [newtrials, find(error_index)];
    
    DECout.Trainingtrials_index = Training_index;
    
    
    %%
    if ~isfield(dec_params, 'chans'); chansubset=1:chans;    else
        chansubset=dec_params.chans; chans=size(chansubset,2) ;  end
    
    if dec_params.dispprogress==1
        %% Now plot raw ERP, and later the normalized version, for comparison.
        %Raw first: plot corrects:
        temp = squeeze(corrects_test(dec_params.showchannel, :,:));
    
        
        figure(1); clf;
        subplot(2,4,1)
        plot(Xtimes, mean(temp,2), 'color', [0 .5 0]);
        % plot errors:
        clear temp; hold on
        temp = squeeze(errors_test(dec_params.showchannel, :,:));
        
        plot(Xtimes, mean(temp,2), 'color', 'r');
        %add patch for classifier window
        %specify vertices clockwise from bottom left.
        axis tight
        xverts= [times(frames_out(1)+init),times(frames_out(1)+init), times(frames_out(1)+init+pts-1), times(frames_out(1)+init+pts-1)];
        yx = get(gca, 'ylim');
        yverts= [yx(1), yx(2), yx(2), yx(1)];
        
        pch=patch(xverts,yverts, 'k');
        pch.FaceAlpha=.1;
        ylabel('uV');
        xlabel('Time from response [ms]');
        set(gca, 'YDir', 'reverse'); legend('corrects', 'errors');
        
        title({['Raw ERP at ' elocs(dec_params.showchannel).labels ','];['ntrials (matched) = ' num2str(Ctmp)]});
        
        %% now plot the topography, of the difference, in our window of interest.
        tempC =  squeeze(nanmean(corrects_test(:, :,:),3));
        tempE =  squeeze(nanmean(errors_test(:, :,:),3));
        
        % take difference per channel:
        tempDiff = tempE-tempC;
        
        %plot
        subplot(2,4,4);
        topoplot(mean(tempDiff(:,[tmpt(1):tmpt(2)]),2), elocs);
        title('Raw Data, difference error-corr'); %colorbar
        %%
    end
    %now normalize EEG data for comparison:
%     fprintf('Warning: Now normalizing data: Corrects and Errors normd together.\n');
    
    
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
                
                if sum(baseline)>1
                    temp=temp-mean(temp(baseline));
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
    
    
    
    if C>E
        corrects_normtest=corrects_norm(:,:,newtrials);
        errors_normtest = errors_norm;%
    end
    
    
    
    %% now plot the normalized data for comparison.
    if dec_params.dispprogress==1
        temp = squeeze(corrects_normtest(dec_params.showchannel, :,:));
        subplot(2,4,2)
        plot(Xtimes, mean(temp,2), 'color', [0 .5 0]);
        % plot errors:
        clear temp; hold on
        temp = squeeze(errors_normtest(dec_params.showchannel, :,:));
        plot(Xtimes, mean(temp,2), 'color', 'r');
        %% add patch for classifier window
        %specify vertices clockwise from bottom left.
        xverts= [times(frames_out(1)+init),times(frames_out(1)+init), times(frames_out(1)+init+pts-1), times(frames_out(1)+init+pts-1)];
        axis tight
        yx = get(gca, 'ylim');
        yverts= [yx(1), yx(2), yx(2), yx(1)];
        
        pch=patch(xverts,yverts, 'k');
        pch.FaceAlpha=.1;
        ylabel('uV');
        xlabel('Time from response [ms]');
        set(gca, 'YDir', 'reverse'); legend('corrects', 'errors');
        
        title({['Baseline corrected, Normalized ERP ']});
    end
    %%
    %>>>>> RUN logistic regression
    %>>>>>>>>>>>>>>>>>>
    DECODERout.type = 'lr';
    %>>>>>>>>>>>>>>>>>>
    
    % loop these params, this iteration, for all time points
 

    for itimestep = 1:length(bins)-1
    
        training_window_ms = [bins(itimestep) bins(itimestep+1)];
        
    %where to begin  and end training window?
    [tmpt] = dsearchn(times', [training_window_ms]'); % ms
    init=tmpt(1); endw=tmpt(2);
    %
    pts=endw-init; % training window length
        
    %>>>>>>>>>>>>>>>>>>
    DECODERout.trainingwindow_ms(itimestep,:) = [times(init),times(endw)];
    DECODERout.baseline_ms = times(basetmp(1)):times(basetmp(2));
    DECODERout.xaxis_ms = Xtimes;
    %>>>>>>>>>>>>>>>>>>

    
    trainingwindowoffset=init; trainingwindowlength=pts; i=1; showaz=1;
    
    
    show=0;
    regularize=0; % if suspecting two similar sources, improves sensitivity to error.
    lambda=1.00e-06;
    lambdasearch=0;
    eigvalratio=1.00e-06;
    vinit=zeros(size(chansubset,2)+1,1);
    
    %
    truth=[zeros(trainingwindowlength.*Ctmp,1); ones(trainingwindowlength.*Etmp,1)];
    
    
    % difference for Boldt decoding:
    %   truthnow = kron(truths(training==1)', ones(size(window(window==1),2),1));
    
    
    % place subset of both correct and errors in same dimension (3rd).
    x=cat(3,corrects_normtest(chansubset,trainingwindowoffset(i):trainingwindowoffset(i)+trainingwindowlength-1,:), errors_normtest(chansubset,trainingwindowoffset(i):trainingwindowoffset(i)+trainingwindowlength-1,:));
    
    x=x(:,:)'; % Rearrange data for logist.m [D (T x trials)]'
    
    
    
    v = logist(x,truth,vinit,0,regularize,lambda,lambdasearch,eigvalratio);
    
    % this is the main piece we need: for subsequent tests against other
    % trial types:
    %>>>>>>>>>>>>>>>>>>
    DECODERout.discrimvector(nIteration,itimestep,:) = v;
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
    DECODERout.scalpproj(nIteration,itimestep,:) = sp;
    %>>>>>>>>>>>>>>>>>>
    
    
    
   
    
   
    
    if dec_params.dispprogress==1
         %plot ROC by this testing window.
    subplot(2,4,5); rocarea(bp,truth);
    title('ROC by sample');
    %ROC stats of sample window.
    [Az,Ry,Rx] = rocarea(bp,truth);
    
%     fprintf('Window Onset: %d; Length: %d;  Az: %6.2f\n',trainingwindowoffset(i),pts,Az);
        subplot(2,4,6);
        rocarea(trial_bp,truth2);
        title('ROC by trial average (training C+E)');
        
        %% now apply to all (tested) trials.
        testdata=cat(3,corrects_normtest, errors_normtest);
        
        [nchans, nsamps, ntrials] =size(testdata);
        testdata = reshape(testdata, nchans, nsamps* ntrials)';%
        %%
        ytest = testdata * v(1:end-1) + v(end);
        
        %% reshape for plotting.
        ytest_trials = reshape(ytest,nsamps,ntrials);
        
        
        %separate into correct and error:
        corr_y = ytest_trials(:, [1:size(corrects_normtest,3)]);
        err_y = ytest_trials(:, [size(corrects_normtest,3)+1:end]);
        
        subplot(2,4,3);
        plot(times,mean(corr_y,2),'g'); hold on; clear temp;
        set(gca,'YDir','reverse');
        hold on
        
        plot(times,mean(err_y,2),'r'); hold on;
        title('y - matched training trials');
        
        
        subplot(248);
        topoplot(sp, elocs);
        title('scalp projection');
    end
    %%
    
    %%
     
    %this output will leave the folder (might not be needed, just the scalp
    %proj is used in subsequent analysis (testing on untrained trials).
    
    % can now apply to all data (incl. untrained trials).
    %from Boldt: size(testdata) = [samps * alltrials, nchans]
    % testdata = reshape(data_norm(chansubset,:,testing==1),size(chansubset,2),size(data_norm,2)*size(data_norm(chansubset,:,testing==1),3))';
%     
 %% % apply to all (matched) training set
%     truth2(1:Ctmp)=zeros;
%     truth2(Ctmp+1:Ctmp+Etmp)=ones;
%     
%     for i=1:Ctmp+Etmp
%         
%         start=(i-1)*trainingwindowlength+1;
%         bpsort(start:start+trainingwindowlength-1)=sort(bp(start:start+trainingwindowlength-1));
%         trial_bp(i)=mean(bpsort(start:start+trainingwindowlength-1));
%         
%     end
%     
%     
%     [Az]=    rocarea(trial_bp,truth2);
%     fprintf('Window Onset: %f \nAz for training set (ROC by trial average): %6.2f\n',times(tmpt(1)), Az);
%     
%     testdata=cat(3,corrects_norm, errors_norm);
    
%     [nchans, nsamps, ntrials] =size(testdata);
%     testdata = reshape(testdata, nchans, nsamps* ntrials)';%
%     ytest = testdata * v(1:end-1) + v(end);
   
%     bptest = bernoull(1,ytest);
%     bptest = reshape(bptest, nsamps, ntrials);
%     
%     %% reshape for plotting.
%     ytest_trials = reshape(ytest,nsamps,ntrials);
%     
%     %this output will leave the function (all trials).
%     % (contains both correct and error trials).
%     
    testedvector = [DECODERout.Correctindices_usedintraining(nIteration,:), find(dec_params.error_index)];
%     
%     %>>>>>>>>>>>>>>>>>>
%     DECODERout.all_trials_bp(nIteration,itimestep,:,:)= bptest;
%     DECODERout.all_trials_y(nIteration,itimestep,:,:)= ytest_trials;
    DECODERout.trainingtrials_vector(nIteration,:) = testedvector;
%     %>>>>>>>>>>>>>>>>>>
    
    
    
end % timestep
disp(['Completed iteration: ' num2str(nIteration) ' of ' num2str(dec_params.nIter)])
%     disp(['timestep  ' num2str(itimestep) ' of ' num2str(length(bins)-1)])
end % niterations

% 
