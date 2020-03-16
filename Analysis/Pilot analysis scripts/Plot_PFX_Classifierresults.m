% Plot_PFX_Classiferresults
%plot data for ERPs:
clear variables
close all
basedir= '/Users/mdavidson/Desktop/dotstask- Vis+Audio EXP';
addpath([basedir filesep 'Analysis'])
cd([basedir filesep 'EEG']);
eegdir=pwd;
cd([basedir filesep 'Exp_output' filesep 'DotsandAudio_behaviour']);
behdir=pwd;

%how many participants?


job.linkBehtoEEG_saveinFolder =0;

%plot results from classifer trained on Part A of exp, correct vs
%incorrect.

job.plot_A_vs_Untrainedtrials= 0;       %  PFX_ Plots the results of discrim component Cor vs Err in A, on all response locked ERP.
job.plot_A_vs_Untrainedtrials_GFX= 0;    %  GFX_ of above


%plot results from classifier trained on part B of exp, on predicting
%confidence.

job.plot_B_vs_Confidence =0; % uses the amplitude of discriminator performance (in quantiles), to collect confidence 

job.plot_A_vs_ConfQuantile =0;  % using the A vector, multiple part B ERP, and see if we see quantile definition in confidence.


% job.plot_individualERPs=0;
%
% job.concat_allGFXERPs = 0;
%
% job.plot_GFXERPs =0;
%%
if job.linkBehtoEEG_saveinFolder ==1
    
    %how many participants?
    cd(eegdir);
    pfol=dir([pwd filesep 'p_*']);
    
    %find and save BEH data in eeg dir.
    
    for ippant=1:length(pfol)
        
        %% load the trial information for this participant:
        cd(behdir)
        
        %real ppant number:
        lis = pfol(ippant).name;
        ppantnum = str2num(cell2mat(regexp(lis, '\d*', 'Match')));
        
        if ppantnum<10
            str = ['0' num2str(ppantnum)]; else str = num2str(ppantnum);
        end
        
        %load correct folder.
        pfol_behav= dir([pwd filesep '*_p' str]);
        cd(pfol_behav.name);
        %load final data.
        lme = dir([pwd filesep '*final.mat']);
        load(lme.name, 'alltrials_final');
        
        
        
        
        %reorient to EEG.
        cd(eegdir);
        cd(pfol(ippant).name)
                
        % take care to adjust for rejected EEG epochs.
        load('Epoch information.mat');        
        
        %we need to know which behavioural data shold also be excluded:
        %first, extract the epoch order from eeglab (total).
%         allepochs = [allTriggerEvents.epoch]; % eeglab order
        
%         rejme = ismember(allepochs, rejected_trials); % check which rows need rejecting.
        
        % now we can extract the corresponding number in our experiment.
%         rejBEH = unique(allTriggerEvents.epoch_in_exp(rejme==1));        
        %only unique trials:        
%         reject_from_BEH = rejBEH;
        %save with EEG data.
        save('Epoch information.mat', 'alltrials_final', '-append');%, 'reject_from_BEH','-append')
    end
    
end






%% PFX 
if job.plot_A_vs_Untrainedtrials==1
    %
     cd(eegdir);
    pfol=dir([pwd filesep 'p_*']);
    getelocs;
    cmap = flip(cbrewer('div', 'Spectral', 4));
    for ippant = 1:length(pfol)

        PFX_classifierA_onERP =[];
    cd(eegdir)
    cd(pfol(ippant).name);
    %% load the Classifer and behavioural data:
    load('Classifier_objectivelyCorrect');
    load('participant TRIG extracted ERPs.mat');
    
    %plot time-course of discriminating component for all untrained trials:
    v= DEC_Pe_window.discrimvector;
    
    
    figure(1); clf;
    set(gcf, 'units', 'normalized', 'Position', [0 1 .6 .35]); shg
    leg=[];
    for itestdata = 1:4
        switch itestdata
            case 1
                useDATA = EEG_cor_A;
            case 2
                useDATA = EEG_cor_B;
            case 3
                useDATA = EEG_err_A;
            case 4
                useDATA = EEG_err_B;
        end
    
    % Note that if we are using 
    

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
    
    
    ylim([.2 1])
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
    legend(leg, {['Corr A (' ExpOrder{1} ')'],['Corr B (' ExpOrder{2} ')'], ['Err A, (' ExpOrder{1} ')'], ['Err B, (' ExpOrder{2} ')']})
    set(gca, 'fontsize', 15)
    
    %% 
    
    subplot(133);
    topoplot(DEC_Pe_window.scalpproj, biosemi64); 
    title(['Participant ' num2str(ippant) ', spatial projection'])
    set(gca, 'fontsize', 15)
    %% print results
    cd(basedir); cd ../ ; cd(['Figures' filesep 'Classifier Results' filesep 'PFX_Trained on Correct part A']); 
    
    %%
    set(gcf, 'color', 'w')
    print('-dpng', ['Participant ' num2str(ippant)]);%', ERP weighted' ]);
    
    
    
    end % ippant
    
end


if job.plot_A_vs_Untrainedtrials_GFX==1
    
      cd(eegdir);
    pfol=dir([pwd filesep 'p_*']);
    getelocs;
    cmap = flip(cbrewer('div', 'Spectral', 4));
    % concat group effects
    [GFX_classifierA_topo,GFX_classifierA_onERP ]=deal([]);
    
    for ippant = 1:length(pfol)

        
    cd(eegdir)
    cd(pfol(ippant).name);
    %% load the Classifer and behavioural data:
    load('Classifier_objectivelyCorrect');
    
    GFX_classifierA_onERP(ippant,:,:) = PFX_classifierA_onERP;
    GFX_classifierA_topo(ippant,:) = DEC_Pe_window.scalpproj;
clear PFX_classifierA_onERP;
    end
    
    %now plot
 Xtimes = DEC_Pe_windowparams.wholeepoch_timevec;
    figure(1); clf;
    set(gcf, 'units', 'normalized', 'Position', [0 1 .6 .35]); shg
    leg=[];
    subplot(1, 3, 1:2);
    for itestdata = 1:4
        
        plotdata = squeeze(GFX_classifierA_onERP(:,itestdata,:));
        stE = CousineauSEM(plotdata);
        
        sh= shadedErrorBar(Xtimes, squeeze(nanmean(plotdata,1)), stE, [],1);
        
        sh.mainLine.Color =  cmap(itestdata,:);
        sh.patch.FaceColor =  cmap(itestdata,:);
        sh.edge(1,2).Color=cmap(itestdata,:);
        
        sh.mainLine.LineWidth = 3;
        
        leg(itestdata) = sh.mainLine;
        
        hold on

    end
    
    ylim([.2 1])
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
    legend(leg, {['Corr A'],['Corr B '], ['Err A'], ['Err B']})
    set(gca, 'fontsize', 15)
    
    
    
    subplot(133);
    topoplot(nanmean(GFX_classifierA_topo,1), biosemi64); 
    title(['GFX, spatial projection'])
    set(gca, 'fontsize', 15)
    %% print results
    cd(basedir); cd ../ ; cd(['Figures' filesep 'Classifier Results' filesep 'PFX_Trained on Correct part A']); 
    
    %%
    set(gcf, 'color', 'w')
    print('-dpng', ['GFX classifier trained on Correct part A-Pe']);%', ERP weighted' ]);
    
    
    
end

if job.plot_B_vs_Confidence ==1
  
    cd(eegdir);
    pfol=dir([pwd filesep 'p_*']);
    getelocs;
    cmap = flip(cbrewer('seq', 'RdPu', 5));
    %%
    
    
    [cjmean, cjse, cjdistr]=deal([]);
    
    
    for ippant = 1:length(pfol)
    cd(eegdir)
    cd(pfol(ippant).name);
    %% load the Classifer and behavioural data:
    load('Classifier_objectivelyCorrect');
    load('participant TRIG extracted ERPs.mat');
    load('Epoch information.mat', 'alltrials_final');
   %% 
    % we already have the output, applied to all part B trials.
    partBdata = DEC_Pe_B_window.all_trials_bp;
    
    %partB is comprised of CorB and ErrB, with associated Beh data as:
    partBindx = [EEG_cor_B_index; EEG_err_B_index];
    
    %remove any nans.
    remnan = find(isnan(partBindx));
    
    partBdata(:,remnan)=[];
    partBindx(remnan)=[];
    
    % collect confj for this dataset
        allconfj= [alltrials_final(partBindx).confj];
 %%
    if length(allconfj) ~= size(partBdata,2)
        error('check trial counts')
    end
    
    % now we need to remove the trials that were part of practice, from
    % our EEG data set.
    practice = find([alltrials_final.isprac]);   
    remprac = ismember(partBindx,practice);
    
    %also account for those used in training the classifier:
    
    %training trials:
    trainCor=DEC_Pe_B_window.Correctindices_usedintraining;
    
    %combine these two indexes, or trials to go:
    remalltrials = unique([find(remprac); trainCor']);
    
    %% now we can remove these trials from both the Beh CJ data, and from the EEG, before plotting
    
    temp = partBdata;    
    temp(:,remalltrials)=[];
    partB_untrained=temp;
    
    % collect confj for this dataset
    temp= allconfj;
   temp(:,remalltrials)=[];
   allconfj = temp;
       
    %since we are only looking at correct trials, we can take the absolute
    %of confj (which atm has negative values for left side responses).
    partB_untrained_CJ=abs(temp);
    
    %take z score of CJ values:
    partB_untrained_CJ_z= zscore(partB_untrained_CJ);
    
    %now we can compare the discriminator accuracy, based on later
    %confidence judgement. Like Boldt & Yeung, we'll smooth over a 50ms
    %window.
    
    ms50 = diff(dsearchn(DEC_Pe_B_window.xaxis_ms', [0 50]'));
    slidwin = ceil(ms50/2);
    %%
    for i=slidwin+1:size(partB_untrained,1)-slidwin
        
        %take the mean across this time window, within each trial.
        temp_DEC=mean(partB_untrained(i-slidwin:i+slidwin,:),1);
        
        %take quantile limits of discriminator performance across trials
        quants=quantile(temp_DEC,[0 0.2 0.4 0.6 0.8 1]);
        
        for j=1:5
            % subselect the confidence data, using trial index for each
            % quantile based on discriminator.
            
            cellnow=partB_untrained_CJ_z(find(quants(j)<temp_DEC & temp_DEC<=quants(j+1)));
            
            if (j==1) % if first quartile, look for minimum
                cellnow=[cellnow partB_untrained_CJ_z(find(min(temp_DEC)==temp_DEC))]; 
            end
            
            %store that confidence judgement for each value in time-series
            cjmean(ippant,i-slidwin,j)=mean(cellnow);
            cjse(ippant,i-slidwin,j)=std(cellnow)/sqrt(size(cellnow,2));
            cjdistr(ippant,i-slidwin,j,:)=[size(cellnow(cellnow==1),2) size(cellnow(cellnow==2),2) size(cellnow(cellnow==3),2) size(cellnow(cellnow==4),2) size(cellnow(cellnow==5),2) size(cellnow(cellnow==6),2)];
        end
    end
    %%
    
    figure(1); clf;
    set(gcf, 'units', 'normalized', 'Position', [0 1 .6 .35]); shg
    leg=[];
    
    
    Xtimes = DEC_Pe_windowparams.wholeepoch_timevec(slidwin+1:size(partB_untrained,1)-slidwin);
    
    for icj= 1:5
        
        leg(icj)= plot(Xtimes, cjmean(ippant,:,icj), 'color', cmap(icj,:), 'linew', 3);
        hold on
    end
    
    % leg(itestdata)= plot(Xtimes, (mean(ytest_trials,2)), 'color', cmap(itestdata,:), 'linew', 3);
    hold on
    
%     ylim([.2 1])
    %% add extra plot elements:
%     hold on; plot(xlim, [.5 .5], '--', 'color', [.3 .3 .3], 'linew', 3)
    hold on; plot([0 0 ], ylim, '--', 'color', [.3 .3 .3], 'linew', 3)
    
    % add training window 
    windowvec = DEC_Pe_windowparams.training_window_ms;
    %add patch
    ylims = get(gca, 'ylim');
    pch = patch([windowvec(1) windowvec(1) windowvec(2) windowvec(2)], [ylims(1) ylims(2) ylims(2) ylims(1)], [.8 .8 .8]);
    pch.FaceAlpha= .1;
    xlabel('Time since response (ms)')
    ylabel('Confidence [z]');
    %
    title({['Moving average confidence (50 ms window) for quintiles of discriminating components, (trained Corr B vs Err B)']}, 'fontsize', 25);
    legend(leg, {'Q1', 'Q2', 'Q3', 'Q4', 'Q5'});
    set(gca, 'fontsize', 15)
    
    %% 
    
    %% print results
    cd(basedir); cd ../ ; cd(['Figures' filesep 'Classifier Results' filesep 'PFX_Trained on Correct part B']); 
    
    %%
    set(gcf, 'color', 'w')
    print('-dpng', ['Participant ' num2str(ippant) ', moving average confidence by quintiles']);%', ERP weighted' ]);
    end % ippant
end