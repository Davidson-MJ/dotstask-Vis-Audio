function [DECODERout] = my_Classifier_MD(dec_params)
% A wrapper function to perform different types of classifiers, on separate
% experiments and dataset types. Specifications are as follows:
% Inputs:
%"analysis"
%       'fft',
%       'lr',
%       'svm',
%       'fft', perform fft analysis (main bands)
%       'diff' perform average voltage ROC
% "subnum"
% subject number
% dataset - type of comparsions to make
%
%
% Adapted from NYeung "my_class3.m"
% MDavidson Nov 2019.

dbstop if error
getelocs;
%.>>>>>>>>>>>>>>>>>>>>>> extract input/default params.
if ~isfield(dec_params, 'type'); analysis = 'lr'; else
    analysis = dec_params.type; end

if ~isfield(dec_params,'ppant'); subnum=0; else
    subnum=dec_params.ppant; 
end

if ~isfield(dec_params, 'dtype'); dataset=0; else
    dataset=dec_params.dtype;
end

 if ~isfield(dec_params,'normtype');  norm='n1'; else
     norm = dec_params.normtype; 
 end

if  ~isfield(dec_params, 'LOO'); LOO=1; else
     LOO = dec_params.LOO; end

if  ~isfield(dec_params, 'matchCE'); matchCE=1; else
    matchCE= dec_params.matchCE; end

if  ~isfield(dec_params, 'filtlo'); filtlo=0; else
    filtlo=dec_params.filtlo; end

if  ~isfield(dec_params, 'filthi'); filthi=0; else
    filthi=dec_params.filthi; end

if  ~isfield(dec_params, 'showchannel'); elec2show=47; else
    elec2show=dec_params.showchannel; end

if ~isfield(dec_params, 'wholeepoch_timevec')
    error('Correct time vector needed for classifier analysis')
else
    Xtimes = dec_params.wholeepoch_timevec;
end

%default fold n
if LOO==-1
    folds=2;
else 
    folds=10; 
end

if strcmp(analysis,'fft'); norm='n3';
    filtlo=0; filthi=0; matchCE=0;
    fprintf('Baseline normalization only for FFT analysis.\n');
end


DECODERout=[]; % for output.
clear EEG ALLEEG
% Choose analysis windows

% -------------------------------------------------------------------------



if dataset==0  % Crossmodal confidence paradigm, hardcoded params.
    
    
    framesouttmp = dsearchn(Xtimes', [dec_params.window_frames_ms(1), dec_params.window_frames_ms(2)]');
    frames_out=framesouttmp(1):framesouttmp(2); % data runs from 0:500 (ms)
    
    basetmp = dsearchn(Xtimes', [dec_params.baseline_ms(1) dec_params.baseline_ms(2)]');
    baseline=basetmp(1):basetmp(2);  % this is -100ms to 0
    
    times=Xtimes;
    
    
    %where to begin  and end training window?
    [tmpt] = dsearchn(times', [dec_params.training_window_ms]'); % ms
    init=tmpt(1); endw=tmpt(2);
    %
    
    
    pts=endw-init; % training window length
    
end
%>>>>>>>>>>>>>>>>>>
DECODERout.trainingwindow_ms = times(init):times(endw);
DECODERout.baseline_ms = times(basetmp(1)):times(basetmp(2));
%>>>>>>>>>>>>>>>>>>


% Load up the data and filter if necessary

% -------------------------------------------------------------------------



if dataset==0
    
    
    fprintf('Loading data for subject %d.\n',subnum);
    
    EEG=[];
    ALLEEG=[];
%     eeg_global;
    
    %load correct responses, first half
    dload = dir([ pwd filesep '*part A response correct.set']);
    EEG = pop_loadset( 'filename', [dload.name]);  
    EEG.setname = dload.name;
    EEGcor = eeg_checkset(EEG);

    
    %store
    [ALLEEG] = eeg_store( ALLEEG, EEGcor);
    
    dload = dir([ pwd filesep '*part A response error.set']);
    EEG = pop_loadset( 'filename', [dload.name]);
    EEG.setname = dload.name;
    EEGerr = eeg_checkset(EEG);

    %store
    [ALLEEG] = eeg_store( ALLEEG, EEGerr);
    
end

if filtlo~=0 && filthi~=0 % filter:
    
    for i=1:length(ALLEEG)
        % remove epoched structure, beware edge artefacts.
        ALLEEG(i).data=reshape(ALLEEG(i).data,ALLEEG(i).nbchan,ALLEEG(i).pnts*ALLEEG(i).trials);
        
        if filthi>0
            
            ALLEEG(i).data=eegfilt(ALLEEG(i).data,ALLEEG(i).srate,0,filthi,ALLEEG(i).pnts,floor(ALLEEG(i).pnts/3)); fprintf('.');
            
        end
        
        if filtlo>0
            
            ALLEEG(i).data=eegfilt(ALLEEG(i).data,ALLEEG(i).srate,filtlo,0,ALLEEG(i).pnts,floor(ALLEEG(i).pnts/3)); fprintf('.');
            
        end
        
        ALLEEG(i).data=reshape(ALLEEG(i).data,ALLEEG(i).nbchan,ALLEEG(i).pnts,ALLEEG(i).trials);
        
    end
    
    fprintf('\n');
    
    save('filtered ALLEEG','ALLEEG');
end



% Analysis of original EEG data

% -------------------------------------------------------------------------



if dataset==0
    
    % Epoch runs from -1000 to 3200 relative to fixation
    
    % Analysis epoch = -500 to 1200
    
    fprintf('Analysing time-domain EEG data.\n');
    
    corrects=ALLEEG(1).data;
    
    errors=ALLEEG(2).data;
    
end







% Set some parameters and plot the raw data

% -------------------------------------------------------------------------
%%


chans=size(corrects,1);

frames_in=size(corrects,2);

frames=size(frames_out,2);

C=size(corrects,3);

E=size(errors,3);

srate = EEG.srate;



if ~isfield(dec_params, 'chans'); chansubset=1:chans;    else
    chansubset=dec_params.chans; chans=size(chansubset,2) ;  end    
%%


temp(1:frames_in,1:C)=corrects(elec2show,:,:);

%plot raw and normalized example channel.
figure(1); clf
subplot(2,2,1);

plot(times,mean(temp,2),'color', [0 .5 0]); hold on; erp1=mean(temp,2); clear temp;

temp(1:frames_in,1:E)=errors(elec2show,:,:);

plot(times,mean(temp,2),'r'); hold on; erp2=mean(temp,2); clear temp;

if dataset==0
%     
%     vline(times(frames_out(1)),'b');
%     
%     vline(times(frames_out(end)),'b');
%     
%     vline(times(frames_out(1)+init),'k');
%     
%     vline(times(frames_out(1)+init+pts-1),'k');

%specify vertices clockqise from bottom left.
xverts= [times(frames_out(1)+init),times(frames_out(1)+init), times(frames_out(1)+init+pts-1), times(frames_out(1)+init+pts-1)];
yverts= [-10, 10, 10, -10];

pch=patch(xverts,yverts, 'k');
pch.FaceAlpha=.1;
ylabel('uV');
xlabel('Time from response [ms]')
else
    
    vline(times(init),'k:');
    
    vline(times(init+pts),'k:');
    
end

title(['Raw ERP at ' biosemi64(elec2show).labels]);

set(gcf,'Color',[1,1,1]);
legend('Correct', 'Errors', 'location', 'southeast')


corrects=corrects(:,frames_out,:);

errors=errors(:,frames_out,:);

fprintf('Trials per condition: %d - %d.\n',C,E);





% Normalise the data and reject flat EEG epochs

% -------------------------------------------------------------------------

%%

fprintf('Normalizing EEG data. ');

corrects_norm=zeros(chans,frames,C);

keepers=ones(C,1);

for i=1:C
    
    for elec=1:chans
        
        start=((i-1)*frames)+1; temp(1:frames)=corrects(elec,:,i);
        
        if(min(temp)==max(temp)) keepers(i)=0; end;
        
        if strcmp(norm,'n1')
            
            temp=temp-(0.5*(min(temp)+max(temp)));
            
            if(min(temp)~=max(temp))
                
                temp=temp/max(temp);
                
            end
            
        end
        
        if strcmp(norm,'n2')
            
            temp=temp-mean(temp(baseline));
            
            if(min(temp(baseline))~=max(temp(baseline)))
                
                temp=temp/std(temp(baseline));
                
            end
            
        end
        
        if strcmp(norm,'n3')
            
            temp=temp-mean(temp(baseline));
            
        end
        
        corrects_norm(elec,:,i)=temp;
        
        %temp2=temp;
        
    end
    
end

corrects_norm=corrects_norm(:,:,keepers==1);

fprintf('Rejected %d correct trials and ',C-size(corrects_norm,3));

C=size(corrects_norm,3);


%%
errors_norm=zeros(chans,frames,E);

keepers=ones(E,1);

for i=1:E
    
    for elec=1:chans
        
        start=((i-1)*frames)+1; temp(1:frames)=errors(elec,:,i);
        
        if(min(temp)==max(temp)) keepers(i)=0; end;
        
        if strcmp(norm,'n1')
            
            temp=temp-(0.5*(min(temp)+max(temp)));
            
            if(min(temp)~=max(temp))
                
                temp=temp/max(temp);
                
            end
            
        end
        
        if strcmp(norm,'n2')
            
            temp=temp-mean(temp(baseline));
            
            if(min(temp(baseline))~=max(temp(baseline)))
                
                temp=temp/std(temp(baseline));
                
            end
            
        end
        
        if strcmp(norm,'n3')
            
            temp=temp-mean(temp(baseline));
            
        end
        
        errors_norm(elec,:,i)=temp;
        
        %temp2=temp;
        
    end
    
end

errors_norm=errors_norm(:,:,keepers==1);

fprintf('%d errors.\n',E-size(errors_norm,3));

E=size(errors_norm,3);



clear temp;

temp(1:pts,1:C)=corrects_norm(elec2show,init:init+pts-1,:);

subplot(2,2,2);

plot(times(frames_out(1)+init:frames_out(1)+init+pts-1),mean(temp,2),'g'); hold on; clear temp;

temp(1:pts,1:E)=errors_norm(elec2show,init:init+pts-1,:);

plot(times(frames_out(1)+init:frames_out(1)+init+pts-1),mean(temp,2),'r'); hold on; clear temp;

title('Normalized data epoch');



% Match the size of the data subsets (default is that this is done)
% -------------------------------------------------------------------------

if matchCE
    
    % Select a random subset of the trials to match no. of trials per
    
    % condition
    
    newtrials=find(randperm(max([C;E]))<=min([C;E]));
    
    %newtrials=1:E;
    
    if C>E
        
        corrects_norm=corrects_norm(:,:,newtrials); C=E;
        
    end
    
    if E>C
        
        errors_norm=errors_norm(:,:,newtrials); E=C;
        
    end
    
end



fprintf('Trials per condition: %d - %d.\n',C,E);




% Run logistic regression

% -------------------------------------------------------------------------

% -------------------------------------------------------------------------



if strcmp(analysis,'lr')
    
    
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
    
    truth=[zeros(trainingwindowlength.*C,1); ones(trainingwindowlength.*E,1)];
    
    
    % place subset of both correct and errors in same dimension (3rd).
    x=cat(3,corrects_norm(chansubset,trainingwindowoffset(i):trainingwindowoffset(i)+trainingwindowlength-1,:), errors_norm(chansubset,trainingwindowoffset(i):trainingwindowoffset(i)+trainingwindowlength-1,:));
    
    x=x(:,:)'; % Rearrange data for logist.m [D (T x trials)]'
    
    
    
    v = logist(x,truth,vinit,0,regularize,lambda,lambdasearch,eigvalratio);
    %>>>>>>>>>>>>>>>>>>
    DECODERout.discrimvector = v;
    %>>>>>>>>>>>>>>>>>>
    %% multiply discriminating component by EEG activity
    y = x*v(1:end-1) + v(end);
    %size is trainingwindow*ntrials.
    
    bp = bernoull(1,y);
    %ROC stats of sample window.
    [Az,Ry,Rx] = rocarea(bp,truth);
    
    if showaz
        fprintf('Window Onset: %d; Length: %d;  Az: %6.2f\n',trainingwindowoffset(i),pts,Az);
    end
    
    %compute scalp projection
    a = y \ x;
    
    sp=a'; % consider replacing with asetlist1
    
    h2=subplot(2,2,2); 
    delete(h2);
    h2=subplot(2,2,2);
    topoplot(sp, biosemi64);
    c=colorbar;
    ylabel(c, 'spatial weights [a.u.]')
    
    
    %>>>>>>>>>>>>>>>>>>
    DECODERout.topoweights = sp;
    %>>>>>>>>>>>>>>>>>>
    
    subplot(2,2,3); rocarea(bp,truth);
    
    title('ROC by sample');
    
    
    
    truth2(1:C)=zeros;
    
    truth2(C+1:C+E)=ones;
    
    for i=1:C+E
        
        start=(i-1)*trainingwindowlength+1;
        
        %rearrange
        bpsort(start:start+trainingwindowlength-1)=sort(bp(start:start+trainingwindowlength-1));
        
        trial_bp(i)=mean(bpsort(start:start+trainingwindowlength-1));
        
    end
    
    subplot(2,2,4); rocarea(trial_bp,truth2);
    
    title('ROC by trial average');
    
    set(gcf, 'color', 'w');
    print('-dpng', ['Classifier training output,trained ' num2str(dec_params.training_window_ms) 'ms']) 
    %>>>>>>>>>>>>>>>>>>
    DECODERout.Azbytrialavg=rocarea(trial_bp,truth2);
    %>>>>>>>>>>>>>>>>>>
    
    %% MD addition.
    % now multiply discriminator by whole trial EEG activity, for time course:
    
    
    corrects_norm=corrects_norm(chansubset,:,:);
    
    errors_norm=errors_norm(chansubset,:,:);
    
    %>>>>>>>>>>>>>>>>>>
    DECODERout.corr_ERPnormlzd(:,:,:) = corrects_norm;
    DECODERout.err_ERPnormlzd(:,:,:) = errors_norm;
    %>>>>>>>>>>>>>>>>>>
    
    %% Here we apply the discriminator to the whole frames out: taking diagonal (identity matrix)
    %multiple by all EEG, reshape
    C_act = (v(1:end-1)'*eye(size(chansubset,2)))*reshape(corrects_norm, size(chansubset,2), C*frames);
    C_act = reshape( C_act, size(C_act,1), frames, C);
    
    %
    E_act = (v(1:end-1)'*eye(size(chansubset,2)))*reshape(errors_norm, size(chansubset,2), E*frames);
    E_act = reshape( E_act, size(E_act,1), frames, E);
    
    
    %% take discriminator over time:
    C_bp = bernoull(1, squeeze(C_act));
    E_bp = bernoull(1, squeeze(E_act));
    
    %>>>>>>>>>>>>>>>>>>
    DECODERout.corr_Discrim_trialperformance = C_bp;
    DECODERout.err_Discrim_trialperformance = E_bp;
    DECODERout.xaxis_Discrim_trialperformance = Xtimes(frames_out);
    %>>>>>>>>>>>>>>>>>>
    %%
    figure(4); clf
    plot(Xtimes(frames_out),mean(C_bp,2)); 
    hold on;
    plot(Xtimes(frames_out),mean(E_bp,2), 'r');
    title('discriminatory performance over time');
    
    %%
    
    fid=fopen(['nickloc' int2str(chans) '.loc'],'r');
    %load channel data.
    if fid~=-1
        
        fin=fgetl(fid);
        
        fin(length(fin)+1:25)=' ';
        
        fstore=fin;
        
        for i=2:chans; fin=fgetl(fid); fin(length(fin)+1:25)=' '; fstore=[fstore;fin]; end;
        
        fclose(fid);
        
        fid=fopen('temploc.loc','w');
        
        for i=chansubset; fprintf(fid,'%s\n',fstore(i,:)); end
        
        fclose(fid);
        
        figure; subplot(1,2,1); topoplot(sp,'temploc.loc');
        
        set(gcf,'Color',[1,1,1]);
        
    else
        
        fprintf('Could not open channel file.\n');
        
    end
    
    
    %perform leaveone out analysis?
    if LOO
        
        % LOO
        
        clear y;
        
        N=C+E;
        
        ploo=zeros(N*trainingwindowlength,1);
        
        fprintf('LOO with %d trials. Completed trial: ', length(x)./trainingwindowlength);
        
        for looi=1:length(x)./trainingwindowlength,
            
            if(mod(looi,25)==0); fprintf('%d ',looi); end;
            
            if(mod(looi,300)==0); fprintf('\n'); end;
            
            indx=ones(N*trainingwindowlength,1);
           
            % Test classifer accuracy on unlabelled trial.
            indx((looi-1)*trainingwindowlength+1:looi*trainingwindowlength)=0;
            
            tmp = x(find(indx),:); % LOO data
            
            tmpt = [truth(find(indx))];   % Target
            
            
            %test vector from this LOO version.
            vloo(:,looi)=logist(tmp,tmpt,vinit,show,regularize,lambda,lambdasearch,eigvalratio);
            
            %time-course of discrimination activity:
            y(:,looi) = [x((looi-1)*trainingwindowlength+1:looi*trainingwindowlength,:) ones(trainingwindowlength,1)]*vloo(:,looi);
            
            ymean(looi)=mean(y(:,looi));
            
            %      ploo(find(1-indx)) = bernoull(1,y(:,looi));           
            
            ploo((looi-1)*trainingwindowlength+1:looi*trainingwindowlength) = bernoull(1,y(:,looi));
            
            ploomean(looi)=bernoull(1,ymean(looi));
            
            
        end
        
        truthmean=([zeros(C,1); ones(E,1)]);
        
        [Azloo,Ryloo,Rxloo] = rocarea(ploo,truth);
        
        %     subplot(1,2,2); rocarea(ploo,truth);
        
        [Azloomean,Ryloomean,Rxloomean] = rocarea(ploomean,truthmean);
        
        subplot(1,2,2); rocarea(ploomean,truthmean);
        
        title('Leave-one-out ROC');
        
        fprintf('\nLOO Az: %6.2f\n',Azloomean);
        
    end
    
end







% Run support vector machine

% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
%
%
%
% if strcmp(analysis,'svm');
%
%     v=-1; sp=-1;
%
%     %folds=10;
%
%
%
%     corrects_norm=permute(corrects_norm,[3 1 2]);
%
%     corrects_norm=corrects_norm(:,chansubset,init:init+pts-1);
%
%     corrects_norm=reshape(corrects_norm,C,size(chansubset,2)*pts);
%
%
%
%     errors_norm=permute(errors_norm,[3 1 2]);
%
%     errors_norm=errors_norm(:,chansubset,init:init+pts-1);
%
%     errors_norm=reshape(errors_norm,E,size(chansubset,2)*pts);
%
%
%
%     data=[corrects_norm; errors_norm];
%
%
%
%     labels(1:C)=-1;
%
%     labels(C+1:C+E)=1;
%
%
%
%     %inputs
%
%     % data: rows - samples, columns - features
%
%     % labels: two classes
%
%     % TS: timestamps
%
%     % second_units: how many samples constitute a second
%
%
%
%     %process class labels
%
%     classes = unique(labels); if length(classes) ~= 2, disp('only binary classification supported by this code'); return; end;
%
%     fprintf('%d-fold cross validation on %dx%dx%d data: ',folds,C+E,size(chansubset,2),pts);
%
%
%
%     %fold_id = round(1 + (folds - 1) .* rand(1, length(labels))); %determine data to be part of each fold
%
%     fold_id = 1+floor((randperm(length(labels))-1)/(length(labels)/folds));
%
%     c_output = zeros(1, length(labels)); %initialize variable to hold output
%
%
%
%     for i = 1:1:folds
%
%         fprintf('%d ',i);
%
%         if(folds~=2)
%
%             train_ids = find(fold_id ~= i); %use data assigned to current fold for training
%
%         else
%
%             train_ids = find(fold_id == i); % used to check whether initial SVM actually worked
%
%         end
%
%         test_ids  = find(fold_id == i); %use rest of data for testing
%
%         training_data = data(train_ids, :); training_labels = labels(train_ids); %extract labels for training;
%
%         testing_data = data(test_ids,:); testing_labels = labels(test_ids); %extract data for testing;
%
%
%
%         %example svm
%
%         param1 = [0.05, 0.1, 0.5, 1, 5, 10]; % kernel size
%
%         param2 = [10^0,10^1,10^2,10^3,10^4,10^5];% penalty parameter C
%
%         params.kernel_type = 'rbf';
%
%         params.kernel_size = 1; %pick one of the suggested kernel sizes
%
%         params.slack_C = 1;% pick one of the suggested slack parameter values
%
%         rbfsvm = svm((size(training_data,2)), params.kernel_type, params.kernel_size, params.slack_C, 0, 'loqo'); % create a SVM
%
% %         rbfsvm = svmtrain(rbfsvm , training_data, training_labels',[],0); % train SVM
%   rbfsvm = fitsvm(rbfsvm , training_data, training_labels',[],0); % train SVM
%
%
%         [decision,c_output(test_ids)] = svmfwd(rbfsvm,testing_data); % test SVM
%
%     end
%
%     fprintf('\n');
%
%
%
%     [Az,tp,fp,fc] = rocarea(c_output,labels);
%
%     subplot(2,2,3); rocarea(c_output,labels); title(['Result' int2str(folds) '-fold cross validation']);
%
%     subplot(2,2,4); boxplot(c_output,labels); title(['Result' int2str(folds) '-fold cross validation']);
%
%     fprintf('Az: %5.2f.\n',Az);
%
% end



% Perform FFT

% -------------------------------------------------------------------------

% -------------------------------------------------------------------------



% corrects=corrects(:,frames_out,:);

% errors=errors(:,frames_out,:);

%
%
% if strcmp(analysis,'fft');
%
%     %fprintf('Performing FFT on data from.\n');
%
%     lorange=[0.499 4 8 12]; hirange=[4 8 12 20]; titles=['delta'; 'theta'; 'alpha'; 'beta '];
%
%     elecs=[7 12 17 22 27];
%
%     elecname=['fz '; 'fcz'; 'cz '; 'cpz'; 'pz '];
%
%
%
%     f=srate*(0:(pts/2))/pts;
%
%     if dataset==1
%
%         labels(1:C)=1; labels(C+1:C+E)=0;
%
%     else
%
%         labels(1:C)=0; labels(C+1:C+E)=1;
%
%     end
%
%
%
% %     figure;
%
% %     set(gcf,'Color',[1,1,1]);
%
%
%
%     for elec=1:5
%
%         data(1:pts,1:C)=corrects_norm(elecs(elec),init:init+pts-1,:);
%
%         EEG=fft(data);
%
%         for i=1:C
%
%             powC(:,i)=EEG(:,i).*conj(EEG(:,i))/pts;
%
%         end
%
%         powC=sqrt(powC);
%
%
%
%         clear data;
%
%         data(1:pts,1:E)=errors_norm(elecs(elec),init:init+pts-1,:);
%
%         EEG=fft(data);
%
%         for i=1:E
%
%             powE(:,i)=EEG(:,i).*conj(EEG(:,i))/pts;
%
%         end
%
%         powE=sqrt(powE);
%
%
%
%         topval=min([size(f,2);30]);
%
%
%
%         figure;
%
%         set(gcf,'Color',[1,1,1]);
%
%         for i=1:4
%
%             c_output=[mean(powC(find((f>lorange(i)).*(f<=hirange(i))),:)) ...
%
%                 mean(powE(find((f>lorange(i)).*(f<=hirange(i))),:))];
%
%             subplot(2,2,i);
%
%             rocarea(c_output,labels);
%
%             title([titles(i,:) ' - ' elecname(elec,:)]);
%
%         end
%
%
% %
% % %         for i=1:4
% %
% % %             powval(i,:)=[mean(powC(find((f>lorange(i)).*(f<=hirange(i))),:)) ...
% %
% % %                 mean(powE(find((f>lorange(i)).*(f<=hirange(i))),:))];
% %
% % %         end
% %
% % %             % Engagement index = beta/(alpha+theta)
% %
% % %         c_output=powval(3,:)./(powval(1,:)+powval(2,:));
% %
% % %         subplot(2,3,elec);
% %
% % %         rocarea(c_output,labels);
% %
% % %         title(['EI ROC - ' elecname(elec,:)]);
% %
% %
%
%     end
%
% end







% Perform avg voltage ROC

% -------------------------------------------------------------------------

% -------------------------------------------------------------------------



% corrects=corrects(:,frames_out,:);

% errors=errors(:,frames_out,:);

%
%
% if strcmp(analysis,'diff');
%
%     %fprintf('Performing FFT on data from.\n');
%
%     elecs=[7 12 17 22 27];
%
%     elecname=['fz '; 'fcz'; 'cz '; 'cpz'; 'pz '];
%
%
%
%     labels(1:C)=1; labels(C+1:C+E)=0;
%
%
%
%     figure;
%
%     set(gcf,'Color',[1,1,1]);
%
%     for elec=1:5
%
%         dat1(1:C)=mean(corrects_norm(elecs(elec),init:init+pts-1,:));
%
%         dat2(1:E)=mean(errors_norm(elecs(elec),init:init+pts-1,:));
%
%         %fprintf('%s: Corr = %0.2f uV; Err = %0.2f.\n',elecname(elec,:),mean(dat1), mean(dat2));
%
%         c_output=[dat1 dat2];
%
%
%
%         subplot(2,3,elec);
%
%         rocarea(c_output,labels);
%
%         title(['Voltage at ' elecname(elec,:)]);
%
%     end
%
% end






end %function
%enter classifer function here:
