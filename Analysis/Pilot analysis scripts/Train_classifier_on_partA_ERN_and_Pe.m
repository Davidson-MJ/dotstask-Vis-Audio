
%% %create new data set for comparison.
% We will compare the ERN following errors in first half, to detect
% confidence in second half!


% if ~exist('Classifer part A output.mat', 'file')
% first half errors = trigger codes 10,20
% second half confidence will be decoded in the window after.
% eeglab
ALLEEG= pop_loadset('filename', [dload(1).name]);
EEG = eeg_checkset( ALLEEG );


%% create new epochs based on correct and errors (first half of trials)

EEGcor = pop_epoch( EEG, {  '11'  '21'  }, [-.15 .95]);
EEGcor.setname =['p_' sprintf('%02.f', ippant) ' final part A response correct'];

EEGerr = pop_epoch( EEG, {  '10'  '20'  }, [-.15, .95]);
EEGerr.setname =['p_' sprintf('%02.f', ippant) ' final part A response error'];


%save these for easy load later.
pop_saveset(EEGcor,'filename', [EEGcor.setname]);
pop_saveset(EEGerr, 'filename', [EEGerr.setname]);


%%
%% perform classification!
%(analysis, subnum, dataset,chansubset, Xtimes, norm,LOO,matchCE,filtlo,filthi,elec2show)
dec_params.type = 'lr';
dec_params.ppant = ippant;
dec_params.dtype = 0;
dec_params.chans = 1:64;
dec_params.wholeepoch_timevec = EEGcor.times;
dec_params.normtype = 'n1';
dec_params.LOO = 1;
dec_params.matchCE= 1;
dec_params.filtlo= 0;
dec_params.filthi= 0;
dec_params.showchannel= 32;

% analysis parameters:
dec_params.window_frames_ms = [-140 400];  %needs to be shorter than actual epoch, or will error.
dec_params.baseline_ms = [-100 0];
dec_params.training_window_ms= [05 100];


DECODER_ern=my_Classifier_MD(dec_params);


%use separate window for comparison.
dec_params.training_window_ms= [250 350];
DECODER_Pe =my_Classifier_MD(dec_params);
save('Classifer part A output', 'DECODER_ern', 'DECODER_Pe', 'dec_params');
% else
%     load('Classifer part A output', 'DECODER_ern', 'DECODER_Pe', 'dec_params');
% end

% %% plot own performance.
% 
% figure(1); clf
% set(gcf, 'units', 'normalized', 'position', [0 .3 .6 .7])
% for iClass=1:2
%     shleg=[];
%     switch iClass
%         case 1
%             useDD = DECODER_ern;
%             colis= 'b';
%             tis = 'Trained on ERN, (errors)';
%         case 2
%             useDD = DECODER_Pe;
%             colis= 'r';
%             tis = 'Trained on Pe, (errors)';
%     end
% subplot(1,2,iClass)
% dtmp = useDD.err_Discrim_trialperformance;
% 
% stE=CousineauSEM(dtmp');
% sh=shadedErrorBar(useDD.xaxis_Discrim_trialperformance, squeeze(mean(dtmp,2)), stE, [], 1);
% sh.mainLine.Color = colis;
% sh.mainLine.LineWidth = 3;
% shleg(1)= sh.mainLine;
% dtmp = useDD.corr_Discrim_trialperformance;
% stE=CousineauSEM(dtmp');
% hold on
% sh=shadedErrorBar(useDD.xaxis_Discrim_trialperformance, squeeze(mean(dtmp,2)), stE, [], 1);
% sh.mainLine.Color = colis;
% sh.mainLine.LineWidth = 1;
% shleg(2)= sh.mainLine;
% title(tis);
% %>>>>> 
% axis tight
%  ylim([.4 .8])
%  hold on; plot(xlim, [.5 .5 ], ['k-'])
%  hold on; plot([.5 .5 ], ylim, ['k-'])
%  xlabel('Time from response [ms]')
%  ylabel('Az')
%  set(gca, 'fontsize', 25)
%  legend([shleg(1) shleg(2)], {'response-error' , 'response-correct'})
% end
% set(gcf, 'color', 'w')
% print('-dpng', 'Classifier self-performance');