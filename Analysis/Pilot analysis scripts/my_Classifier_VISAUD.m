function  DECODERout=my_Classifier_VISAUD(dec_params)
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

%where to begin  and end training window?
[tmpt] = dsearchn(times', [dec_params.training_window_ms]'); % ms
init=tmpt(1); endw=tmpt(2);
%



pts=endw-init; % training window length


%>>>>>>>>>>>>>>>>>>
DECODERout.trainingwindow_ms = times(init):times(endw);
DECODERout.baseline_ms = times(basetmp(1)):times(basetmp(2));
DECODERout.xaxis_ms = Xtimes;
%>>>>>>>>>>>>>>>>>>

%start analyzing data:

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

%now normalize EEG data for comparison:
    fprintf('Warning: Now normalizing data: Corrects and Errors normd together.\n');
    
    
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
    
    
    
    if C>E
        corrects_normtest=corrects_norm(:,:,newtrials);
        errors_normtest = errors_norm;%
    end
    
    
    %%
    %>>>>> RUN logistic regression
    %>>>>>>>>>>>>>>>>>>
    DECODERout.type = 'lr';
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
    %>>>>>>>>>>>>>>>>>>
    DECODERout.discrimvector(nIteration,:) = v;
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
    DECODERout.scalpproj(nIteration,:) = sp;
    %>>>>>>>>>>>>>>>>>>
    
    
    
   
    
    %% % apply to all (matched) training set
    truth2(1:Ctmp)=zeros;
    truth2(Ctmp+1:Ctmp+Etmp)=ones;
    
    % apply to the data from all trials:
    for i=1:Ctmp+Etmp
        
        %index of trialdata for testing:
        start=(i-1)*trainingwindowlength+1;
        endidx= start+trainingwindowlength-1;
        %?
        bpsort(start:endidx)=sort(bp(start:endidx));
        trial_bp(i)=mean(bpsort(start:endidx)); % trial wise bernoulli, testing only the specified window.
        
    end
    
    
    [Az]=    rocarea(trial_bp,truth2);
    fprintf('Window Onset: %f \nAz for training set (ROC by trial average): %6.2f\n',times(tmpt(1)), Az);
    
    
    %%
    % now apply to all data (incl. untrained trials).
    %from Boldt: size(testdata) = [samps * alltrials, nchans]
    % testdata = reshape(data_norm(chansubset,:,testing==1),size(chansubset,2),size(data_norm,2)*size(data_norm(chansubset,:,testing==1),3))';
    testdata=cat(3,corrects_norm, errors_norm);
    
    [nchans, nsamps, ntrials] =size(testdata);
    testdata = reshape(testdata, nchans, nsamps* ntrials)';%
    %%
    
    ytest = testdata * v(1:end-1) + v(end);
    
    %this output will leave the folder
    bptest = bernoull(1,ytest);
    bptest = reshape(bptest, nsamps, ntrials);
    
    %% reshape for plotting.
    ytest_trials = reshape(ytest,nsamps,ntrials);
     %separate into correct and error:
        corr_y = ytest_trials(:, [1:size(corrects_norm,3)]);
        err_y = ytest_trials(:, [size(corrects_norm,3)+1:end]);
        corr_ybp = bptest(:, [1:size(corrects_norm,3)]);
        err_ybp = bptest(:, [size(corrects_norm,3)+1:end]);
       
    %this output will leave the function (all trials).
    % (contains both correct and error trials).
    
    testedvector = [DECODERout.Correctindices_usedintraining(nIteration,:), find(dec_params.error_index)];
    
    %>>>>>>>>>>>>>>>>>>
    DECODERout.all_trials_bp(nIteration,:,:)= bptest;
    DECODERout.all_trials_y(nIteration,:,:)= ytest_trials;
    DECODERout.trainingtrials_vector(nIteration,:) = testedvector;
    %>>>>>>>>>>>>>>>>>>
    
    disp(['Completed iteration: ' num2str(nIteration) ' of ' num2str(dec_params.nIter)])

    if dec_params.dispprogress==1
        %% Now plot raw ERP, and later the normalized version, for comparison.
        %Raw first: plot corrects:
        temp = squeeze(mean(corrects_test(dec_params.showchannel, :,:),1));
        
        figure(1); clf;
        subplot(2,4,1)
        plot(Xtimes, mean(temp,2), 'color', [0 .5 0]);
        % plot errors:
        clear temp; hold on
        temp = squeeze(mean(errors_test(dec_params.showchannel, :,:),1));
        
        xlim([ - 100 700]);
        plot(Xtimes, mean(temp,2), 'color', 'r');
        %add patch for classifier window
        %specify vertices clockwise from bottom left.
%         axis tight
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
        topoplot(mean(tempDiff(:,[tmpt(1):tmpt(2)]),2), elocs, 'emarker2',{dec_params.showchannel} );
        hold on;
        
        title('Raw Data, difference error-corr'); %colorbar
        
        
        %%
    end
    
    %% now plot the normalized data for comparison.
    if dec_params.dispprogress==1
        temp = squeeze(mean(corrects_normtest(dec_params.showchannel, :,:),1));
        subplot(2,4,2)
        plot(Xtimes, mean(temp,2), 'color', [0 .5 0]);
        % plot errors:
        clear temp; hold on
        temp = squeeze(mean(errors_normtest(dec_params.showchannel, :,:),1));
        plot(Xtimes, mean(temp,2), 'color', 'r');
        %% add patch for classifier window
        %specify vertices clockwise from bottom left.
        xverts= [times(frames_out(1)+init),times(frames_out(1)+init), times(frames_out(1)+init+pts-1), times(frames_out(1)+init+pts-1)];
%         axis tight
        xlim([-100 700]);
yx = get(gca, 'ylim');
        yverts= [yx(1), yx(2), yx(2), yx(1)];
        
        pch=patch(xverts,yverts, 'k');
        pch.FaceAlpha=.1;
        ylabel('uV');
        xlabel('Time from response [ms]');
        set(gca, 'YDir', 'reverse'); legend('corrects', 'errors');
        
        title({['Normalized ERP ']});
    end
    if dec_params.dispprogress==1
         %plot ROC by this testing window.
    subplot(2,4,5); rocarea(bp,truth);
    title('ROC by sample window');
    %ROC stats of sample window.
    [Az,Ry,Rx] = rocarea(bp,truth);
    
%     fprintf('Window Onset: %d; Length: %d;  Az: %6.2f\n',trainingwindowoffset(i),pts,Az);
        subplot(2,4,6);
        rocarea(trial_bp,truth2);
        title('ROC by sample average within trial (training C+E)');
        
        %% now apply to all (tested) trials (all time points).
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
        xlim([ - 100 700]);

        plot(times,mean(err_y,2),'r'); hold on;
        title('y - matched training trials');
        
        
        subplot(248);
        topoplot(sp, elocs);
        title('scalp projection');
    end 
 if dec_params.dispprogress==1
        subplot(2,4,7); cla
%         plot(times,mean(corr_y,2),'g'); hold on; clear temp;
        hold on
        xlim([ - 100 700]);
        set(gca,'YDir', 'normal')
%         plot(times,mean(err_y,2),'r'); hold on;
         hold on;
%          yyaxis right
         hold on;
        plot(times,mean(corr_ybp,2),'b'); hold on; clear temp;
        plot(times,mean(err_ybp,2),'color','b', 'linestyle',':'); hold on; clear temp;
        legend('correct',' error');
        ylim([.4 .8])
        title('bernouilli prob - all trials');
 end


end % niterations

% 
