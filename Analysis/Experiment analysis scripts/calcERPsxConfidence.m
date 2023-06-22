% calc_individualERPsxConf

% for part B data, stratifies ERP responses by confidence. Then
% concatenates across subjects.


% called from Plot_dataforERPs_EEGtrigbased

%%
for ippant=1:length(pfols)
    cd(eegdatadir)
    
    cd(pfols(ippant).name);    

    load('participant EEG preprocessed.mat'); % this is after first job (sort and average).

    
    %
    % for each participant, we also require the behavioural data, should
    % already be stored, if not see Plot_PFX_Classifier results, job1.
    %% load index information
    load('Epoch information'); % contains BEH_matched
    


    plotXtimesPLOT = plotXtimes(1:size(stimlockedEEG,2)); % adjust according to preprocessing window.

    %so we have both stimlocked and resplocked. just need to use the
    %correct indexing, based on the BEH_Matched information.
    
        for itype=1:2
            
    % for resp in part B, split by confidence.        
        %pre allocate data (response locked and stim locked)                          
        [tmpconf_x_rlEEG] = [];%deal(zeros(size(resplockedEEG,1), size(resplockedEEG,2), 4));      
        [tmpconf_x_slEEG]  = [];%deal(zeros(size(stimlockedEEG,1), size(stimlockedEEG,2), 4));      
        
            %changed to corrects only:
            if itype==1
                partBindx = corBindx;
            else % subjectively correct only!
                % this will use either only objectively correct
                % trials, objectively incorrect trials, or all
                % trials.
                % AND
                % restrict focus to only subjectively correct confidence judgements
                % (avoids error detection complications).
                
                % use all trials
                sublist = sort([corBindx;errBindx]);
                allBEH= [BEH_matched.confj{sublist}];
                subjCorr=  find(allBEH>0); % only subjectively correct responses:
                partBindx= sublist(subjCorr);
            end
        %Using  correct  trials, collect confj
%        confjmnts = ([BEH_matched(partBindx).confj]); 
       
       confjmnts = BEH_matched.confj(partBindx);
       confjmnts = cell2mat(confjmnts);
       
       % note that confidence went from sure wrong -- to sure right
       % (-100        100)
        % take zscore to compare across participants.
        zconfj = zscore(confjmnts); %% not abs(conjmnts)
        
        %avoid trials in which there was a change of mind (negative
        %confidence value).
        % ?       
        %% now we can reduce the size of our beh and EEG, to only relevant trials, and sort
        %by terciles
        
        
        respEEGd = resplockedEEG(:,:,partBindx);
        stimEEGd = stimlockedEEG(:,:,partBindx);
        
        %%
        %now take terciles, based on conf judgements:        
%         quants = quantile(zconfj, [3]); %quartiles
        quants = quantile (zconfj, [.5]); %median split,



        terclists=[];
        if length(quants)>1 % more than a median split

        if diff(quants)==0 % can't separate into terciles.
            %instead,  save as high/low after median split.
            %just skip
%             continue
              quants = quantile(zconfj, [.5]);
               t1 = nan;
               t2 = find(zconfj<quants(1));
               t3= find(zconfj>=quants(1));
               t4 = nan;
            disp(['Warning: using median split for ppant ' num2str(ippant)]);   
        else
            
        %now we have all the data, and confidence rows per quartile:
        %split EEEG into terciles:
        %lowest
        t1 = find(zconfj<quants(1));
        %middle
        t2a = find(zconfj>=quants(1));
        t2b = find(zconfj<quants(2));
        t2= intersect(t2a, t2b); 
        %next
        t3a = find(zconfj>=quants(2));
        t3b = find(zconfj<quants(3));
        t3= intersect(t3a, t3b); 
        
        %highest
        t4 = find(zconfj>=quants(3));
        end

        %store for easy access.
        terclists(1).list = t1;
        terclists(2).list = t2;
        terclists(3).list = t3;
        terclists(4).list = t4;
        else

%             if quants==max(zconfj) % asymmetric distribution,
%              t1 = find(zconfj<quants(1));
%             t2 = find(zconfj>=quants(1));
%             else

         t1 = find(zconfj<quants(1));
         t2 = find(zconfj>=quants(1)); % note the split, using > 
                                    % median produces nan for 
                                    % some ppants (all confj together).
            
%             end
           terclists(1).list = t1;
        terclists(2).list = t2;
%         terclists(3).list = t3;s
%         terclists(4).list = t4;
        end
        %now for each tercile, take the mean EEG      
%%
        for iterc=1:length(terclists)
           
            try
                %take mean corr ERP for this tercile:
                tempERP = squeeze(nanmean(respEEGd(:,:,terclists(iterc).list),3));
                % now store:
                tmpconf_x_rlEEG(:,:,iterc) =tempERP;
                if any(isnan(tempERP(:)))
                    error('check code')
                end
                
                %now take mean for stimulus locked equivalent.
                tempERP = squeeze(nanmean(stimEEGd(:,:,terclists(iterc).list),3));
                tmpconf_x_slEEG(:,:,iterc) =tempERP;
            catch
                tmpconf_x_rlEEG(:,:,iterc)= repmat(nan, [64,length(plotERPtimes)]);
                tmpconf_x_slEEG(:,:,iterc) = repmat(nan, [64,length(plotERPtimes)]);
            end
        end
      
        
        
        
        if itype==1 % rename
            conf_x_rlEEG= tmpconf_x_rlEEG;
            conf_x_slEEG= tmpconf_x_slEEG;
        elseif itype==2
            
            
            conf_x_rlEEG_subjCorr= tmpconf_x_rlEEG;
            conf_x_slEEG_subjCorr= tmpconf_x_slEEG;
        end
        
        end
        
        
        
% %%     %%
% % % sanity check    
% clf;
% plot(plotXtimesPLOT, squeeze(conf_x_rlEEG(31,:,:))); title(['participant ' num2str(ippant)]);
% set(gca, 'ydir' , 'reverse')%     
% legend({['q1'], ['q2'], ['q3'], ['q4']})
%%
disp(['saving conf x ERP for ppant ' pfols(ippant).name]);

    save('part B ERPs by confidence', ...
        'conf_x_rlEEG','conf_x_rlEEG_subjCorr', 'terclists',...
        'conf_x_slEEG','conf_x_slEEG_subjCorr', 'plotXtimes', 'ExpOrder');
%     
end % ippant

% now concatenate and save across participants.
    %%
    disp('Concatenating GFX conf x erp');
[GFX_conf_x_rlEEG,GFX_conf_x_slEEG,...
    GFX_conf_x_rlEEG_subjCorr,GFX_conf_x_slEEG_subjCorr] =  deal(nan(length(pfols), 64, length(plotXtimesPLOT),length(terclists)));

for ippant=1:length(pfols) %
    cd(eegdatadir)    
    cd(pfols(ippant).name);
    load('part B ERPs by confidence');
      
    %store the rest:
    GFX_conf_x_rlEEG(ippant,:,:,:)= conf_x_rlEEG;    
    GFX_conf_x_slEEG(ippant,:,:,:) = conf_x_slEEG;
    GFX_conf_x_rlEEG_subjCorr(ippant,:,:,:)= conf_x_rlEEG_subjCorr;    
    GFX_conf_x_slEEG_subjCorr(ippant,:,:,:) = conf_x_slEEG_subjCorr;
    disp(['concat ppant ' num2str(ippant)])
end

% % save Group FX
cd(eegdatadir)  
cd('GFX')
%
    save('GFX_averageERPsxConf',...
        'GFX_conf_x_slEEG', 'GFX_conf_x_rlEEG', ...
        'GFX_conf_x_slEEG_subjCorr','GFX_conf_x_rlEEG_subjCorr',...
        'plotXtimes');
 %%
 
