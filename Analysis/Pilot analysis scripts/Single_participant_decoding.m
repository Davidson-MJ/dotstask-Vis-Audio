% Single_participant_Decoding


% attempt to see if classifer trained on correct / error, can distinguish
% confidence in second half.

clear all
close all
basedir= '/Users/mdavidson/Desktop/dotstask- Vis+Audio EXP';
addpath([basedir filesep 'Analysis'])
cd(basedir);
cd('EEG');
pfol=dir([pwd filesep 'p_*']);

%skip ppant 3, 6 not enough errors in second half.
% ippant =4;

GFX_decoding= zeros(length(pfol), 2, 2,2,281);
[nppants, trainedon, correctErr, Confhilo, npnts]= size(GFX_decoding);

pcounter=1; %participant counte for gFX.
 for ippant=[1:2,4]

cd(basedir)
cd('EEG')

cd(pfol(ippant).name);

%real ppant number:
lis = pfol(ippant).name;
ppantnum = str2num(cell2mat(regexp(lis, '\d*', 'Match')));

dload = dir([ pwd filesep '*pruned with ICA chanrej.set']);


Train_classifier_on_partA_ERN_and_Pe;

%%
% we now have the trained discrimator:
% Need to multiply by the new EEG to retrieve across condition decoding.

%extract ERPs following presentation of second stimulus:
%first presentation
newname = ['p_' sprintf('%02.f', ippant) ' part B pre conf judgmnt'];
EEG_stim2a= pop_epoch( ALLEEG(1), {  '202'  '203'  }, [-.15 .95], 'newname', newname, 'epochinfo', 'yes');

newEpochtimes = dsearchn(EEG.times', [-150, 950]');

plotXtimes = EEG.times(newEpochtimes(1):newEpochtimes(2)-1);
%%first, extract the relevant data
EEGd = double(EEG_stim2a.data(dec_params.chans,:,:));

%now normalize?
EEGd_norm=zeros(size(EEGd));

keepers=ones(size(EEGd,3),1); %trial indx

frames = size(EEGd,2);
%%
for i=1:size(EEGd,3) %trial
    for elec=1:size(EEGd,1)
        % nro
        start=((i-1)*frames)+1;
        temp(1:frames)=EEGd(elec,:,i);
        
        %ignore trials normd to 1 throughout
        if(min(temp)==max(temp))
            keepers(i)=0; end
        
        %         if strcmp(norm,'n1')
        temp=temp-(0.5*(min(temp)+max(temp)));
        %normalize
        if(min(temp)~=max(temp))
            temp=temp/max(temp);
        end
        %         end
        EEGd_norm(elec,:,i)=temp;
    end
end

EEGd_norm=EEGd_norm(:,:,keepers==1);
% EEGd_norm = EEGd;
%%
%now that we have our final EEG trials. we need to know the confidence rating in
%each.
%load ppant epoch info.
load('Epoch information');
% gather event indices in EEG trace.
eventorder=[EEG_stim2a.event(:).urevent];
% now extract 'when' these events happened.
whole_eventlist = allTriggerEvents.urevent;

%find row index, in allTriggerEvents, of our retained epochs:
eventplace = find(ismember(whole_eventlist, eventorder));

%now gather which epoch this was, in our behavioural data:
%remove duplicates.
beh_epoch = unique(allTriggerEvents.epoch_in_exp(eventplace));

if length(beh_epoch)~= length(keepers)
    error('check eeg indexing above');
end

%note that it is possible that the n epochs in EEG > nepochs in BEH.
% This is due to extra practice trials at the beginning
% to adjust, simply change the EEG 'count' to reflect these extra practice
% runs.
ntotal = 720; % actual max trials.
if max(beh_epoch>ntotal)
    %adjust.
    npracextra = max(beh_epoch) - ntotal;
    beh_epochadj = beh_epoch - npracextra;
else
    beh_epochadj =beh_epoch;
end



%% now gather confidence information:
%first redirect to correct participant directory:
cd(basedir)
cd(['Exp_output' filesep 'DotsandAudio_behaviour' ])
%find correct participant data:
pfolBEH = dir([pwd filesep  '*p' sprintf('%02.f', ppantnum)]);
cd([pfolBEH.name filesep 'behaviour']);
loadf= dir([pwd filesep  '*final.mat']);
load(loadf.name);

%% focus only on real trials (not practice), correct responses, and gather confidence judgments.
tmpEpoch_specs=[];

alltrtype = [alltrials(beh_epochadj).trialid];

%restrict EEG to only experimental epochs (not practice), when stim
%presented
ntrials = find(alltrtype>=1);
ISeekinfo = find([alltrials(beh_epochadj).ISeek]);

restrictedtrials = intersect(ntrials, ISeekinfo);

beh_epochadj= beh_epochadj(restrictedtrials);
%% so now, we can shrink EEG to just this size.
EEGtest = EEGd_norm(:,:,restrictedtrials);

% now perform response based separation:
%now which of these trials, were correct vs incorrect.
allrespacc = [alltrials(beh_epochadj).confj_cor];
correct_EEGindx= find(allrespacc); % correct = 1;
error_EEGindx= find(allrespacc==0); %


%extract conf information (allretained trials)
ConfJudmnts = [alltrials(beh_epochadj).confj];
%%

% now apply discriminating vector to this dataset:
%%

figure();clf
set(gcf, 'units', 'normalized', 'position', [0 0 .5 1])


%% compare discrim, errors, correc, by median conf.
icounter=1;
for iClass= 1:2
    switch iClass
        case 1
            v=DECODER_ern.discrimvector;
            
            traind = 'ERN';
        case 2
            v=DECODER_Pe.discrimvector;
            
            traind = 'Pe';
    end
    
    
    for iRESP=1:2
        switch iRESP
            case 1 % use correct responses.
                useidx=correct_EEGindx;
                respw = 'correct';
            case 2
                useidx=error_EEGindx;
                respw = 'errors';
        end
        
        % subselect EEG data, and perform median split based on confidence.
        Confwas = ConfJudmnts(useidx);
        medc = median(Confwas);
        shLeg=[];
        for iconf = 1:2
            switch iconf
                case 1 % low confidence.
                    CID= find(Confwas<=medc);
                    col='r';
                case 2 % high confidence.
                    CID= find(Confwas>medc);
                    col = 'b';
            end
            %now plot
            
            tmpd1 = EEGtest(:,:,useidx(CID));
            [nchans, frames, tcount ]= size(tmpd1);
            C_act = (v(1:end-1)'*eye(nchans))*reshape(tmpd1, nchans, tcount*frames);
            C_act = reshape( C_act, size(C_act,1), frames, tcount);
            
            %% take discriminator over time:
            C_bp = bernoull(1, squeeze(C_act));
            
            %plot stE
            subplot(2,2, icounter)
            stE=CousineauSEM(C_bp');
            sh=shadedErrorBar(plotXtimes, mean(C_bp,2), stE,[],1); hold on;
            sh.mainLine.Color = col;
            sh.patch.FaceColor = col;
            sh.edge(1).Color= col;
            sh.edge(2).Color= col;
            title([cfg.stimTypes{1} ' ' traind ' trained, ...decoding ' cfg.stimTypes{2} ' ' respw ])
            shLeg(iconf)=sh.mainLine;
            ylim([.4 1])
            xlabel({['Time from final stimulus onset [ms]'];['(see again trials)']})
            hold on
            plot([0 0], ylim, ['k:']);
            plot([xlim], [.5 .5], ['k-'], 'linew', 2);
            
            
            %check for sig:
            
            GFX_decoding(pcounter, iClass, iRESP, iconf, :) = mean(C_bp,2);
        end
        
        set(gca, 'fontsize', 15);
        legend([shLeg(1), shLeg(2)], {'High Conf', 'low Conf'})
        icounter=icounter+1;
    end
    
end
set(gcf, 'color', 'w');
%%

cd(basedir)
cd('Figures')
cd('Classifer ERN-Pe, tested on final stimulus to conf interval')
print('-dpng', ['Participant ' num2str(ppantnum) ' summary']);
pcounter=pcounter+1;
 end

 %% plot across GFX.
 traindON ={'ERN', 'Pe'};
 RESPwas = {'correct', 'error'};
 colsare = {'b', 'r'};
 icounter=1;
 figure();
 for iClass=1:2     
     
     for iRESP=1:2
         subplot(2,2,icounter);
         
         for iConf = 1:2
             
             col=colsare{iConf};
             
         dis = squeeze(GFX_decoding(1:pcounter-1,iClass, iRESP, iConf,:));
         stE = CousineauSEM(dis);
                  
         sh=shadedErrorBar(plotXtimes, mean(dis,1), stE,[],1); hold on;
         
         sh.mainLine.Color = col;
         sh.patch.FaceColor = col;
         sh.edge(1).Color= col;
         sh.edge(2).Color= col;
         title([ traindON{iClass} ' trained, ...decoding '  RESPwas{iRESP} ])
         shLeg(iconf)=sh.mainLine;
         ylim([.4 1])
         xlabel({['Time from final stimulus onset [ms]'];['(see again trials)']})
         hold on
         plot([0 0], ylim, ['k:']);
         plot([xlim], [.5 .5], ['k-'], 'linew', 2);
 
         end
         icounter=icounter+1;
     end
 end
 