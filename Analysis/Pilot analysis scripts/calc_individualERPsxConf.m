% calc_individualERPsxConf

% for part B data, stratifies ERP responses by confidence. Then
% concatenates across subjects.


% called from Plot_dataforERPs_EEGtrigbased

for ippant=1:length(pfol)
    cd(basedir)
    cd('EEG')
    
    cd(pfol(ippant).name);    
    load('participant TRIG extracted ERPs');
       
    % for each participant, we also require the behavioural data, should
    % already be stored, if not see Plot_PFX_Classifier results, job1.
    %%
    load('Epoch information');
    % for ease of indexing, remove unnecessary fields, and convert to
    % table:
    
    ExpOrder = {alltrials_final(1).stimtype, alltrials_final(end).stimtype};
    
    %%
    if ~exist('alltrials_table', 'var')
    temptab = alltrials_final;
    trimmedtab= rmfield(temptab, {'trialid', 'break', 'blockcount', 'xmodtype', 'InfoOption',...
        'SeeAgainOpt', 'VBLtime_starttrial', 'time_starttrial', ...
        'flip_accuracy_starttrial', 'wheredots', 'VBLtime_stim1pres',...
        'time_stim1pres', 'flip_accuracy_stim1pres', 'VBLtime_stim1offset',...
        'time_stim1offset', 'flip_accuracy_stim1offset', 'resp1_time',...
        'VBLtime_Opt_onset', 'time_Opt_onset', 'flip_accuracy_Opt_onset',...
        'respInfoSeek_time', 'respInfoSeek_loc', 'didrespond_IS',...
        'ISeek', 'ISeek_rt', 'VBLtime_starttrial2', 'time_starttrial2',...
        'flip_accuracy_starttrial2', 'VBLtime_stim2pres','time_stim2pres',...
        'flip_accuracy_stim2pres','flip_accuracy_stim2offset', 'time_stim2offset', 'VBLtime_stim2offset',...
        'VBLtime_confj_onset','time_confj_onset','flip_accuracy_confj_onset'});
    %%
    alltrials_table = struct2table(trimmedtab);
    
    
    ExpOrder = {alltrials_final(1).stimtype, alltrials_final(end).stimtype};
    
    
    save('Epoch information', 'alltrials_table', 'ExpOrder', '-append');
    
    end
    %%
    
    %so we have both stimlocked and resplocked. just need to use the
    %correct indexing, based on the alltrials_table information.
    
    % for resp in part B, split by confidence.        
        %pre allocate data (response locked and stim locked)                          
        [conf_x_slEEG ,conf_x_rlEEG] = deal(zeros(size(resplockedEEG,1), size(resplockedEEG,2), 3));                            
        
        % now gather EEG, based on second half, non-practice trials.        
        partA = strcmp(alltrials_table.ExpType, 'A');
        partB = strcmp(alltrials_table.ExpType, 'B');
        notprac = alltrials_table.isprac ==0;
        
        %merge these lists.
        usetrials = and(partB, notprac);
                
        %now for our analysis, we will only focus on the correct, and
        %non-practice trials. create a vector for trials to 'keep'.
        %fill first half of table for easier indexing.
        alltrials_table.confj(partA) = {nan};
        alltrials_table.confj_time(partA) = {nan};
        alltrials_table.confj_loc(partA) = {nan};
        alltrials_table.confj_cor(partA) = {nan};
        
        confj_tmp = cell2mat(alltrials_table.confj);
        
        %we need to split CJ by sure correct, maybe corr, and sure wrong.
        % sure wrong is only when the confj is opposite in sign to the
        % initial response.
        
        %simplest thing is just to take the absolute of all confj (assuming
        %people stick to their first decision). Then identify the limitied
        %number of Change of mind cases, and reverse the sign (to
        %negative).
        confj_abs = abs(confj_tmp);
        
        % find CoM. left is 1, right is 2. therefore -2 from both .
        initialj = alltrials_table.resp1_loc;            
        secondj = cell2mat(alltrials_table.confj_loc); % sign should match
        
        %so which were a change of mind?
        CoM = find(initialj - secondj); % search for nonzeros
        
        %now for these trials, change the sign of the confj.
        confj_abs(CoM) = confj_abs(CoM)*-1;
        
        %% now we can reduce the size of our beh and EEG, to only relevant trials, and sort
        %by terciles
        
        conf_now = confj_abs(usetrials);       
        respEEGd = resplockedEEG(:,:,usetrials);
        stimEEGd = stimlockedEEG(:,:,usetrials);
        
        
        %now take terciles, based on conf judgements:        
        quants = quantile(conf_now, 2);
        
        %now we have all the data, and confidence rows per quartile:
        %split EEEG into terciles:
        %lowest
        t1 = find(conf_now<=quants(1));
        %middle
        t2a = find(conf_now>quants(1));
        t2b = find(conf_now<quants(2));
        t2= intersect(t2a, t2b); 
        %highest
        t3 = find(conf_now>quants(2));
        
        %store for easy access.
        terclists(1).list = t1;
        terclists(2).list = t2;
        terclists(3).list = t3;
        
        %now for each tercile, take the mean EEG      
%%
        for iterc=1:3            
           
        
        %take mean corr ERP for this tercile:
        tempERP = squeeze(nanmean(respEEGd(:,:,terclists(iterc).list),3));              
        %% now store:
        conf_x_rlEEG(:,:,iterc) = tempERP;
        
        %now take mean for stimulus locked equivalent.
        tempERP = squeeze(nanmean(stimEEGd(:,:,terclists(iterc).list),3));                              
        conf_x_slEEG(:,:,iterc) =tempERP;
        end
      
%     %%
% % sanity check    
% plot(plotXtimes_2, squeeze(conf_x_slEEG(31,:,:))); 
%     
%%
    save('participant B ERPs by confidence', ...
        'conf_x_rlEEG', 'terclists',...
        'conf_x_slEEG', 'plotXtimes_2', 'ExpOrder');
%     
end

%now concatenate and save across participants.
    %%
[GFX_conf_x_rlEEG,GFX_conf_x_slEEG] =  deal(nan(length(pfol), 64, 281,3));
%%
for ippant=1:length(pfol) % 1,3,4
    cd(basedir)
    cd('EEG')
    cd(pfol(ippant).name);
    load('participant B ERPs by confidence');
      
    %store the rest:
    GFX_conf_x_rlEEG(ippant,:,:,:)= conf_x_rlEEG;    
    GFX_conf_x_slEEG(ippant,:,:,:) = conf_x_slEEG;
end

%% % save Group FX
cd(basedir)
  cd('EEG')
cd('GFX')
%%
    save('GFX_averageERPsxConf',...
        'GFX_conf_x_slEEG', 'GFX_conf_x_rlEEG', 'plotXtimes_2');
 %%
 
