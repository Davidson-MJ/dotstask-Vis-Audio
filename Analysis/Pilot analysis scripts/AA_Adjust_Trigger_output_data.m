
clear variables
close all
basedir= '/Users/mdavidson/Desktop/dotstask- Vis+Audio EXP';
addpath([basedir filesep 'Analysis'])
cd(basedir);
cd('EEG');
pfol=dir([pwd filesep 'p_*']);
  
    
    
    for ippant=1:length(pfol)

        cd(basedir)
        cd('EEG')
        cd(pfol(ippant).name);

load('Epoch information.mat', 'allTriggerEvents', 'alltrials_final');
% define how many trials of each type we SHOULD have, according to
% behavioural output that has been saved.
allexptypes = {(alltrials_final.ExpType)};

lengthpartA = length(find(contains(allexptypes, 'A')));
lengthpartB = length(find(contains(allexptypes, 'B')));


%check for misalignment: 

%critically, we need to assign an actual trial index to all these epochs, for later matching with behavioural data.
        %so go through and find all the indices for either 2,3, or 102,103, as
        %these indicate first stimulus onset in trial.
        %all epochs partA
        sub1= find(allTriggerEvents.type==3); %auditory
        sub2= find(allTriggerEvents.type==2); %visual
        Aonset_index = [sub1;sub2]; %covers all epochs regardless of exp type.
        %all epochs partB
        sub1= find(allTriggerEvents.type==103); %auditory
        sub2= find(allTriggerEvents.type==102); %visual
        
        Bonset_index = [sub1,sub2]; %covers all epochs regardless of exp type.
        
        %% Now create a table entry, for the real epochs, as they will be defined in
        %the behavioural output.
        % NB nEpochs= length(onset_index)
        for irow = 1:lengthpartA-1
            %each epoch should be added to table.
            
            startE=Aonset_index(irow);
              endE = Aonset_index(irow+1)-1;
            
            %append real epoch information to this table.
            if irow<=lengthpartA               
            allTriggerEvents(startE:endE, 6)= table(irow);
            else
                allTriggerEvents(startE:endE, 6)= table(nan);
            end
%             allTriggerEvents(startE,6) = table(irow); %append adjusted epoch count.
            
%              if irow==(length(Aonset_index)-1)                
%                 startE=Aonset_index(irow+1);
%                 endE = Bonset_index(1)-1;
%                 %i.e. first epoch in second half of experiment, signifies end
%                 %of first half.
%                 allTriggerEvents(startE:endE, 6)= table(irow+1);
%              end            
        end
        
        %% Now for part B, easier to start at the end.
        trialID = lengthpartA+1:(lengthpartB+lengthpartA);
        
        trialID_rev = fliplr(trialID);
        % now reverse the order:
        Bonset_rev = fliplr(Bonset_index');
        %%
        for irow = 2:length(trialID)
            
            
            startE =Bonset_rev(irow);
            endE =Bonset_rev(irow-1)-1;
            allTriggerEvents(startE:endE, 6) = table(trialID_rev(irow));
        end
        
        % complete table.        
        allTriggerEvents(Bonset_index(end):end,6)= table(max(trialID));
        %replace zero entries with NaNs for stability.
        temp = table2array([allTriggerEvents(:,6)]);
        nanrep =find(temp==0);
        
        allTriggerEvents(nanrep,6)=table(nan);
        
        %
%         %% now for part B, find the first onset, AFTER the last part A trial.
%         % There can be some overlap if restarting around the A to B
%         % transition.
% %       
%         firstrealB = find(Bonset_index>lastA, 1,'first');
%        Bonsetnow = Bonset_index(firstrealB:end);
%        
%        
%             counter=1;
%             %%
%         for itrial = 1:length(Bonsetnow)-1
%         
%             %start at adjusted point:    
%             startE= Bonsetnow(itrial);
%             
%             endE = Bonsetnow(itrial+1)-1;
%               
%             adjustedval = lengthpartA+counter;
%             %append real epoch information to this table.
%             if adjustedval<=lengthpartB+lengthpartA
%                 
%                 allTriggerEvents(startE:endE, 6)= table(adjustedval);
%             else
%                 allTriggerEvents(startE:endE, 6)= table(nan);
%             end
%             counter=counter+1;
%             
%             if itrial==(length(Bonsetnow)-1)                
%                 startE=Bonsetnow(itrial+1);
%                 endE = size(allTriggerEvents,1);
%                 %i.e. first epoch in second half of experiment, signifies end
%                 %of first half.
%                 allTriggerEvents(startE:endE, 6)= table(adjustedval+1);
%              end  
%             
%         end         %
 %%           
        %rename this column
        allTriggerEvents.Properties.VariableNames{6} = 'epoch_in_exp_adjusted';
        
        %now adjust for the '1'/101 case, for robustness. These are actual
        %trial beginning marks, caught in the baseline of our ERPs , 
        %which are time locked to stimulus onset. So adjust
        %to the following index, so the '1/101' shows the correct trial
        all1s = find(allTriggerEvents.type ==1);
        all101s = find(allTriggerEvents.type ==101);
        alltoadjust = [all1s; all101s];
        %%
        allTriggerEvents(alltoadjust,6) = allTriggerEvents(alltoadjust+1,6);
        %save this important per participant info.
        save('Epoch information', 'allTriggerEvents', '-append')
    end
    
    %%
%     repair_participant4_EEG
%        cd(basedir)
%         cd('EEG')
%         cd(pfol(4).name);
%         %load trigger information
%         load('Epoch information.mat', 'allTriggerEvents');
%         %%
%         cd(basedir)
%         cd(['Exp_output' filesep 'DotsandAudio_behaviour'])
%         cd('73781348327_p04');
        % can go through slowly.
%         
%        for iblock = 1:26 % 25 plus final.
%            %%
% %            load me 
% loadbl = num2str(iblock);
% blockis = dir([pwd filesep '*_' loadbl '.mat']);
%         load(blockis.name, 'alltrials','t');
%         
%         trialsupto = t;
%         % check that all the blocks are correct.
%         datasaved = [alltrials(1:trialsupto).rt];
%         % check whether all the data has been contained.
%         if length(find(datasaved)) == trialsipto-1
%             % then we can safely label these trials in the dataset.
%             
%             
%             
%         
%         
%         
%        end
    