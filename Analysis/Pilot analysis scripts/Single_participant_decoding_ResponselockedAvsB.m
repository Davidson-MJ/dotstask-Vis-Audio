% Single_participant_Decoding


% attempt to see if classifer trained on correct / error in first half, can distinguish
% confidence in second half.

%

clear all
close all
basedir= '/Users/mdavidson/Desktop/dotstask- Vis+Audio EXP';
addpath([basedir filesep 'Analysis'])
cd(basedir);
cd('EEG');
pfol=dir([pwd filesep 'p_*']);


GFX_decoding= zeros(length(pfol), 2, 2,281);
[nppants, trainedon, correctErr, npnts]= size(GFX_decoding);

% ippant =4;
pcounter=1;
for ippant=4%:length(pfol)

cd(basedir)
cd('EEG')

cd(pfol(ippant).name);

%real ppant number:
lis = pfol(ippant).name;
ppantnum = str2num(cell2mat(regexp(lis, '\d*', 'Match')));

dload = dir([ pwd filesep '*pruned with ICA.set']);

%%

ALLEEG= pop_loadset('filename', [dload(1).name]);
EEG = eeg_checkset( ALLEEG );

Train_classifier_on_partA_ERN_and_Pe;

%%
% we now have the trained discrimator:
% Need to multiply by the new EEG to retrieve across condition decoding.

%extract ERPs following presentation of second stimulus:
%first presentation
for icorr=1:2
    switch icorr
        case 1
            newname = ['p_' sprintf('%02.f', ippant) ' final part B response correct'];
            EEG_stim2_tmp= pop_epoch( ALLEEG(1), {  '111'  '121'  }, [-.15 .95], 'newname', newname, 'epochinfo', 'yes');
            
        case 2
            newname = ['p_' sprintf('%02.f', ippant) ' final part B response error'];
            EEG_stim2_tmp= pop_epoch( ALLEEG(1), {  '110'  '120'  }, [-.15 .95], 'newname', newname, 'epochinfo', 'yes');
    end
    
    newEpochtimes = dsearchn(EEG.times', [-150, 950]');
    
    plotXtimes = EEG.times(newEpochtimes(1):newEpochtimes(2)-1);
    %%first, extract the relevant data
    EEGd = double(EEG_stim2_tmp.data(dec_params.chans,:,:));
    
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
    
    %store final output for testing:
    switch icorr
        case 1
            EEG2_cor = EEGd_norm;
        case 2
            EEG2_err = EEGd_norm;
    end
end
        
%% now apply discriminating vector to these datasets:
%%
load('participant extracted ERPs.mat', 'ExpOrder');

figure();clf
set(gcf, 'units', 'normalized', 'position', [0 0 .5 1])


%% compare discrim, errors, correc, by median conf.
icounter=1;
for iClass= 1:2
    switch iClass
        case 1
v=DECODER_ern.discrimvector;
trainingwindowlength = length(DECODER_ern.trainingwindow_ms);

traind = 'ERN';
        case 2
v=DECODER_Pe.discrimvector;
trainingwindowlength = length(DECODER_Pe.trainingwindow_ms);
traind = 'Pe';
    end

    shLeg=[];
    for iRESP=1:2
        switch iRESP
            case 1 % use correct responses.
                tmpd1=EEG2_cor;
                respw = 'correct';
                col='r';
            case 2
                tmpd1=EEG2_err;
                respw = 'errors';
                col='b';
        end
        
        
        
        %Test Classifer on new Data
        %reshape data into one long source
        
        x=tmpd1(:,:)'; % Rearrange data for logist.m [D (T x trials)]'
    
        
           %now plot
        [nchans, frames, tcount ]= size(tmpd1);
        
        C_act = (v(1:end-1)'*eye(nchans))*reshape(tmpd1, nchans, tcount*frames);
        C_act = reshape( C_act, size(C_act,1), frames, tcount);
        
        %% take average over time:
        C_bp = bernoull(1, squeeze(C_act));
        
        
        %plot stE
        subplot(2,1, icounter)
        stE=CousineauSEM(C_bp');
        sh=shadedErrorBar(plotXtimes, mean(C_bp,2), stE,[],1); hold on;
        sh.mainLine.Color = col;
        sh.mainLine.LineWidth = 2;
        sh.patch.FaceColor = col;
        sh.edge(1).Color= col;
        sh.edge(2).Color= col;
        title([ 'Trained on ' ExpOrder{1} ' ' traind ', decoding response to ' ExpOrder{2} ':' ])
        shLeg(iRESP)=sh.mainLine;
        ylim([.4 1])
        xlabel({'Time from response to 2nd stimulus [ms]'})
        ylabel('Az')
        hold on
        plot([0 0], ylim, ['k:']);
        plot([xlim], [.5 .5], ['k-'], 'linew', 2);
        
        
        
GFX_decoding(pcounter,iClass, iRESP, :) = mean(C_bp,2);


        
    end
        
        set(gca, 'fontsize', 15);
        legend([shLeg(1), shLeg(2)], {'correct', 'errors'})
icounter=icounter+1;
    
set(gca, 'fontsize', 25)
end
set(gcf, 'color', 'w');
%%

cd(basedir)
cd('Figures')
cd('Classifer ERN-Pe, tested on second-stimulus response-locked ERP')
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
         
             col=colsare{iRESP};
             
         dis = squeeze(GFX_decoding(1:pcounter-1,iClass, iRESP,:));
         stE = CousineauSEM(dis);
                  
         sh=shadedErrorBar(plotXtimes, mean(dis,1), stE,[],1); hold on;
         
         sh.mainLine.Color = col;
         sh.patch.FaceColor = col;
         sh.edge(1).Color= col;
         sh.edge(2).Color= col;
     end
         title([ traindON{iClass} ' trained, ...decoding '  RESPwas{iRESP} ])
         shLeg(iRESP)=sh.mainLine;
         ylim([.4 1])
         xlabel({['Time from final stimulus onset [ms]'];['(see again trials)']})
         hold on
         plot([0 0], ylim, ['k:']);
         plot([xlim], [.5 .5], ['k-'], 'linew', 2);
 
        
         icounter=icounter+1;
     
 end
 