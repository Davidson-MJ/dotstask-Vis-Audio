% calc_ERPSxRTs

% for part A and B data, stratifies ERP responses by RT . Then
% concatenates across subjects.


% called from JOBS_ERPsortandaverage;


%%
for ippant=1:length(pfols)
    cd(eegdatadir)
    
    cd(pfols(ippant).name);    

    load('participant EEG preprocessed.mat');

    
    %
    % for each participant, we also require the behavioural data, should
    % already be stored, if not see Plot_PFX_Classifier results, job1.
    %% load index information
    load('Epoch information'); % contains BEH_matched

    plotXtimesPLOT = plotXtimes(1:size(stimlockedEEG,2)); % adjust according to preprocessing window.

    %so we have both stimlocked and resplocked. just need to use the
    %correct indexing, based on the BEH_Matched information.
    
    % for all trials split by rts.        
        %pre allocate data (response locked and stim locked)                          
        [rt_x_rlEEG] = deal(zeros(size(resplockedEEG,1), size(resplockedEEG,2), 4,2));      
        [rt_x_slEEG]  = deal(zeros(size(stimlockedEEG,1), size(stimlockedEEG,2), 4,2));      
        
        %changed to corrects only:
        for ipart = 1:2

            if ipart==1
                useindx = corAindx;
            else
                useindx= corBindx;
            end
       
       reactiontimes = BEH_matched.rt(useindx);
       

        % take zscore to compare across participants.
        z_rts= zscore(reactiontimes); %% not abs(conjmnts)
        
      
        %% now we can reduce the size of our beh and EEG, to only relevant trials, and sort
        %by terciles
        
        
        respEEGd = resplockedEEG(:,:,useindx);
        stimEEGd = stimlockedEEG(:,:,useindx);
        
        %%
        %now take terciles, based on conf judgements:        
        quants = quantile(z_rts, [3]); %quartiles
%          t1 = find(zconfj<quants(1));
%          t2 = find(zconfj>=quants(1));
         
        if diff(quants)==0 % can't separate into terciles.
            %instead,  save as high/low after median split.
              quants = quantile(z_rts, [.5]);
               t1 = nan;
               t2 = find(z_rts<quants(1));
               t3= find(z_rts>=quants(1));
               
               t4 = nan;
            disp(['Warning: using median split for ppant ' num2str(ippant)]);   
        else
            
        %now we have all the data, and confidence rows per quartile:
        %split EEEG into terciles:
        %lowest
        t1 = find(z_rts<quants(1));
        %middle
        t2a = find(z_rts>=quants(1));
        t2b = find(z_rts<quants(2));
        t2= intersect(t2a, t2b); 
        %next
        t3a = find(z_rts>=quants(2));
        t3b = find(z_rts<quants(3));
        t3= intersect(t3a, t3b); 
        
        %highest
        t4 = find(z_rts>=quants(3));
        end

        %store for easy access.
        terclists(1).list = t1;
        terclists(2).list = t2;
        terclists(3).list = t3;
        terclists(4).list = t4;
        
        %now for each tercile, take the mean EEG      
%%
        for iterc=1:4
           
            try
                %take mean corr ERP for this tercile:
                tempERP = squeeze(nanmean(respEEGd(:,:,terclists(iterc).list),3));
                % now store:
                rt_x_rlEEG(:,:,iterc, ipart) =tempERP;
                
                %now take mean for stimulus locked equivalent.
                tempERP = squeeze(nanmean(stimEEGd(:,:,terclists(iterc).list),3));
                rt_x_slEEG(:,:,iterc, ipart) =tempERP;
            catch
                rt_x_rlEEG(:,:,iterc, ipart) =nan;
                rt_x_slEEG(:,:,iterc,ipart) =nan;
            end
        end
      
% %%     %%
% % % sanity check    
% clf;
% plot(plotXtimesPLOT, squeeze(conf_x_rlEEG(31,:,:))); title(['participant ' num2str(ippant)]);
% set(gca, 'ydir' , 'reverse')%     
% legend({['q1'], ['q2'], ['q3'], ['q4']})

if ipart ==1
    terclists_partA = terclists;
else
    terclists_partB = terclists;
end
end % ipart
%%
disp(['saving rt  x ERP for ppant ' pfols(ippant).name]);

    save('part A and B ERPs by reaction time', ...
        'rt_x_rlEEG', 'terclists_partA','terclists_partB',...
        'rt_x_slEEG', 'plotXtimes', 'ExpOrder');
%     
end

%now concatenate and save across participants.
    %%
    disp('concatenating GFX ERPs x rt ');
[GFX_rt_x_rlEEG] =  deal(nan(length(pfols), 64, length(plotXtimesPLOT),4,2));
[GFX_rt_x_slEEG] =  deal(nan(length(pfols), 64, size(stimlockedEEG,2),4,2));

for ippant=1:length(pfols) % 1,3,4
    cd(eegdatadir)    
    cd(pfols(ippant).name);
    load('part A and B ERPs by reaction time');
      
    %store the rest:
    GFX_rt_x_rlEEG(ippant,:,:,:,:)= rt_x_rlEEG;    
    GFX_rt_x_slEEG(ippant,:,:,:,:) = rt_x_slEEG;
end

%% % save Group FX
cd(eegdatadir)  
cd('GFX')
%%
    save('GFX_averageERPsxRT',...
        'GFX_rt_x_rlEEG', 'GFX_rt_x_slEEG', 'plotXtimes');
 %%
 
