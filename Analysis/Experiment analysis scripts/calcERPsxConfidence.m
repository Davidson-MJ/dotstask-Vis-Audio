% calc_individualERPsxConf

% for part B data, stratifies ERP responses by confidence. Then
% concatenates across subjects.


% called from Plot_dataforERPs_EEGtrigbased
normON=0;

%%
for ippant=1:length(pfols)
    cd(eegdatadir)
    
    cd(pfols(ippant).name);    
    
    load('participant TRIG extracted ERPs', ...
        'resplockedEEG', 'stimlockedEEG', 'resplockedEEG_stimbaserem', ...
        'plotXtimes', 'ExpOrder', 'BEH_matched');
       
    % for each participant, we also require the behavioural data, should
    % already be stored, if not see Plot_PFX_Classifier results, job1.
    %% load index information
    load('Epoch information');
    
    
    %so we have both stimlocked and resplocked. just need to use the
    %correct indexing, based on the BEH_Matched information.
    
    % for resp in part B, split by confidence.        
        %pre allocate data (response locked and stim locked)                          
        [conf_x_slEEG ,conf_x_rlEEG] = deal(zeros(size(resplockedEEG,1), size(resplockedEEG,2), 3));                            
        
        %changed to corrects only:
        partBindx = corBindx;
                
        %Using  correct  trials, collect confj
       confjmnts = ([BEH_matched(partBindx).confj]); 
        
        % take zscore to compare across participants.
        zconfj = zscore((confjmnts)); %% not abs(conjmnts)
        
        %avoid trials in which there was a change of mind (negative
        %confidence value).
        % ?       
        %% now we can reduce the size of our beh and EEG, to only relevant trials, and sort
        %by terciles
        
        
        respEEGd = resplockedEEG(:,:,partBindx);
        stimEEGd = stimlockedEEG(:,:,partBindx);
        
        %%
        %now take terciles, based on conf judgements:        
        quants = quantile(zconfj, [.5]);
         t1 = find(zconfj<quants(1));
         t2 = find(zconfj>=quants(1));
         
%         if diff(quants)==0 % can't separate into terciles.
%             %instead,  save as high/low.
%               quants = quantile(zconfj, [.5]);
%                t1 = find(zconfj<quants(1));
%                t2 = nan;
%                t3 = find(zconfj>=quants(1));
%                
%         else
%             
%         %now we have all the data, and confidence rows per quartile:
%         %split EEEG into terciles:
%         %lowest
%         t1 = find(zconfj<quants(1));
%         %middle
%         t2a = find(zconfj>=quants(1));
%         t2b = find(zconfj<quants(2));
%         t2= intersect(t2a, t2b); 
%         %highest
%         t3 = find(zconfj>=quants(2));
%         end

        %store for easy access.
        terclists(1).list = t1;
        terclists(2).list = t2;
%         terclists(3).list = t3;
        
        %now for each tercile, take the mean EEG      
%%
        for iterc=1:2%3            
           
%             try
                %take mean corr ERP for this tercile:
                tempERP = squeeze(nanmean(respEEGd(:,:,terclists(iterc).list),3));
                %% now store:
                conf_x_rlEEG(:,:,iterc) =tempERP;
                
                %now take mean for stimulus locked equivalent.
                tempERP = squeeze(nanmean(stimEEGd(:,:,terclists(iterc).list),3));
                conf_x_slEEG(:,:,iterc) =tempERP;
%             catch
%                 conf_x_rlEEG(:,:,iterc) =nan;
%                 conf_x_slEEG(:,:,iterc) =nan;
%             end
        end
      
%%     %%
% % sanity check    
% plot(plotXtimes, squeeze(conf_x_rlEEG(31,:,:))); 
% set(gca, 'ydir' , 'reverse')%     
%%
disp(['saving conf x ERP for ppant ' pfols(ippant).name]);

    save('part B ERPs by confidence', ...
        'conf_x_rlEEG', 'terclists',...
        'conf_x_slEEG', 'plotXtimes', 'ExpOrder');
%     
end

%now concatenate and save across participants.
    %%
[GFX_conf_x_rlEEG,GFX_conf_x_slEEG] =  deal(nan(length(pfols), 64, length(plotXtimes),3));
%%
for ippant=1:length(pfols) % 1,3,4
    cd(eegdatadir)    
    cd(pfols(ippant).name);
    load('part B ERPs by confidence');
      
    %store the rest:
    GFX_conf_x_rlEEG(ippant,:,:,:)= conf_x_rlEEG;    
    GFX_conf_x_slEEG(ippant,:,:,:) = conf_x_slEEG;
end

%% % save Group FX
cd(eegdatadir)  
cd('GFX')
%%
    save('GFX_averageERPsxConf',...
        'GFX_conf_x_slEEG', 'GFX_conf_x_rlEEG', 'plotXtimes');
 %%
 
