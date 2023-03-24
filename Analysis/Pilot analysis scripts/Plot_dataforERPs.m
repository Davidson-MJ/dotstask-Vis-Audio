%plot data for ERPs:
clear variables
close all
basedir= '/Users/mdavidson/Desktop/dotstask- Vis+Audio EXP';
addpath([basedir filesep 'Analysis'])
cd(basedir);
cd('EEG');
pfol=dir([pwd filesep 'p_*']);

%%

job.calc_individualERPs = 1; % stimulus and response locked.

job.plot_individualERPs=1;

job.concat_allGFXERPs = 0;


job.plot_GFXERPs =0;
%%
if job.calc_individualERPs ==1
for ippant=1%:length(pfol)
    
cd(basedir)
cd('EEG')

cd(pfol(ippant).name);

    %real ppant number:
    lis = pfol(ippant).name;
    ppantnum = str2num(cell2mat(regexp(lis, '\d*', 'Match')));
    
    dload = dir([ pwd filesep '*pruned with ICA.set']);
    EEGuse= pop_loadset(dload(1).name);
    %%
    
    
    %filter for plotting (below 10 Hz). for some plotting.
%     EEG = pop_eegfiltnew(EEGuse, 10, 0.1, 8448, 0, [], 1);

% detrend data:
EEGtmp = zeros(size(EEGuse.data));
for ichan=1:64
    
    %detrend each matrix
    alld = squeeze(EEGuse.data(ichan,:,:));
    %detrend works across columns (2nd dim)    
    
    EEGtmp(ichan,:,:) = (alld);
%     EEGtmp(ichan,:,:) = detrend(alld);
end

   
    %%
    %make table for relevant data.
    EEGtrigs = table();
    for iev = 1:size(EEGtmp,3)
               
        
      EEGtrigs(iev,1) =  table(iev);
      
      %make sure we are using trigger at time = 0;     
      EEGtrigstime = [EEGuse.epoch(iev).eventlatency{:}];
      usetrig= find(EEGtrigstime==0, 1 );
      
      EEGtrigs(iev,2) =  table(EEGuse.epoch(iev).eventtype{usetrig});
    end
    
                
    
    %% adjust column names in table
    EEGtrigs.Properties.VariableNames{1} = 'EEGindex';
    EEGtrigs.Properties.VariableNames{2} = 'EEGtrigger';
       
    
     % establish experiment order
                 %if trigger 2 exists, then visual-audio
                 %if trigger 3 exists, then audio-visual               
                 if any(EEGtrigs.EEGtrigger ==2)
                     ExpOrder = {'visual', 'auditory'};
                 else
                     ExpOrder = {'auditory', 'visual'};
                 end
                     
    %%
    % find all errors(A/B),corrects (A/B),  vis and audio.
    
    for trigsearch= 1:6
        switch trigsearch
            case 1
                trigsnow = [10,20];
            case 2
                trigsnow = [110,120];
            case 3
                trigsnow = [11,21];
            case 4
                trigsnow = [111,121];
            case 5
                trigsnow = [2,102]; % will grab visual in first or second half.
            case 6
                trigsnow = [3,103]; % will grab audio in first or second half.
        end
                
      sub_index1= find(EEGtrigs.EEGtrigger==trigsnow(1)); % errorleft
         sub_index2 = find(EEGtrigs.EEGtrigger==trigsnow(2)); % error right         
%          sub_index = intersect(sub_index1, sub_index2);
                  
        sub_index = sort([sub_index1; sub_index2]);
        
         EEG_tmpsub = EEGtmp(1:64,:,sub_index);
         
         switch trigsearch
             case 1
                 EEG_err_A = EEG_tmpsub;
             case 2
                 EEG_err_B = EEG_tmpsub;
             case 3
                 EEG_cor_A = EEG_tmpsub;
             case 4
                 EEG_cor_B = EEG_tmpsub;
             case 5
                 EEG_visstim = EEG_tmpsub;
                 
             case 6
                 EEG_audstim= EEG_tmpsub;
         end
    end
    %%
    plotXtimes = EEGuse.times;
    save('participant extracted ERPs', ...
        'EEG_err_B',...
         'EEG_err_A',...
         'EEG_cor_A',...
         'EEG_cor_B',...
         'EEG_visstim',...
         'EEG_audstim', 'ExpOrder', 'plotXtimes');
     
  
    
end
end

if job.plot_individualERPs   %% PLOT each type:
    basedir= '/Users/mdavidson/Desktop/dotstask- Vis+Audio EXP';
     %this script prints Stimulus locked and response locked ERPs per
     %pariticopant, in this same folder.
     for ippant=1:length(pfol)
         cd(basedir)
         cd('EEG')
         
         cd(pfol(ippant).name);
         
         %real ppant number:
         lis = pfol(ippant).name;
         ppantnum = str2num(cell2mat(regexp(lis, '\d*', 'Match')));
         
         Plot_PFX_ERPs; % stimulus locked and response locked.
     end
end










%% concat across groups

if job.concat_allGFXERPs ==1
    %%
[GFX_visstimERP, GFX_audstimERP, GFX_visrespCOR, GFX_audrespCOR,...
    GFX_visrespERR, GFX_audrespERR] = deal(zeros(length(pfol), 64, 307));
%%
for ippant=1:length(pfol)
    cd(basedir)
    cd('EEG')
    cd(pfol(ippant).name);
    load('participant extracted ERPs');
    
    
    %sort by modality.
    if strcmp(ExpOrder{1}, 'visual')
        
        corr_Vis  = EEG_cor_A;
        err_Vis  = EEG_err_A;
        
        corr_Aud = EEG_cor_B;
        err_Aud  = EEG_err_B;
        
    else
        
        corr_Vis  = EEG_cor_B;
        err_Vis  = EEG_err_B;
        corr_Aud = EEG_cor_A;
        err_Aud  = EEG_err_A;
    end
    
    %store
    GFX_visstimERP(ippant,:,:)= squeeze(nanmean(EEG_visstim,3));
    GFX_audstimERP(ippant,:,:)= squeeze(nanmean(EEG_audstim,3));
    
    GFX_visrespCOR(ippant,:,:) = squeeze(nanmean(corr_Vis,3));
    GFX_visrespERR(ippant,:,:) = squeeze(nanmean(err_Vis,3));
    
    GFX_audrespCOR(ippant,:,:) = squeeze(nanmean(corr_Aud,3));
    GFX_audrespERR(ippant,:,:) = squeeze(nanmean(err_Aud,3));
    
end

%% % save Group FX
cd(basedir)
  cd('EEG')
cd('GFX')
%%
    save('GFX_averageERPs', 'GFX_audrespCOR', 'GFX_audrespERR', ...
        'GFX_audstimERP', 'GFX_visrespCOR', 'GFX_visrespERR', 'GFX_visstimERP', 'plotXtimes');
end


%%
% if job.plot_GFXERPs == 1
    basedir= '/Users/mdavidson/Desktop/dotstask- Vis+Audio EXP';    
    cd(basedir)
    cd('EEG')
    cd('GFX')
    load('GFX_averageERPs.mat')
    
    %plot stimulus and response locked ERPs.
    Plot_GFX_ERPs;
    
    