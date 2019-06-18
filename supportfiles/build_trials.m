%% Build trials
trials = [];
trialid = 0;
index=1;

[block_trials0 block_trials1] =deal([]); %initialize as empty vectors


%% practice trials
%Create difficulty condition matrix 
prac3Dif        = repmat(cfg.trialDif,1,cfg.ntrialsprac(3)/length(cfg.trialDif));
%%

for b = 1: cfg.nblocksprac % for each block in practice
    block_trials0 = []; %clear vector
    
    for t = 1: (cfg.ntrialsprac(b)) %for each trial per prac block
        
        %preallocate
        trialid                                 = trialid+1;
        block_trials0(end+1).trialid            = trialid;
        block_trials0(end).questionnaireAns     = [];
        block_trials0(end).adviceLocation       =  NaN;
        block_trials0(end).advCor               = NaN;
        
        %if final practice block
        if b == cfg.nblocksprac
%             block_trials0(end).pic              = 7;
%             block_trials0(end).advAccLevel      = cfg.advisor.trainAcc;
            block_trials0(end).difficulty       = prac3Dif(t);
            block_trials0(end).adviceLocation   = 1; %Update
%             block_trials0(end).advCor           = AdviceAcc(t);
            
        
        else
            block_trials0(end).pic              = NaN;
            block_trials0(end).advAccLevel      = NaN; 
            block_trials0(end).advCor           = NaN;
             block_trials0(end).difficulty       = 1; % set to easy difficulty in practice.
           
        end
    end
    
    block_trials0    = block_trials0(randperm(length(block_trials0)));         % randomize trials within block
    trials           = cat(2,trials,block_trials0);                            % concatenate practice block
end

%% experimental trials
expDif                = repmat(cfg.trialDif,1,cfg.ntrials/length(cfg.trialDif)); %trial difficulty [1 2 3] creates a matrix the size of a block with equal numbers of trials for each dif
expAdviceLoc          = repmat([1 2], 1, cfg.nblocks/2); %Block advice location [1=up 2=down]: Matrix size of the number of blocks with same number of the 2 locations
expAdviceLoc          = expAdviceLoc(randperm(length(expAdviceLoc))); %randomise the advice location


for b =  1 : cfg.nblocks
    
    %create a matrix the size of block trial number with 0 and 1s to match
    %advisor accuracy (0 = incorrect advice, 1=correct advice)
    AdviceAcc       = [repmat(1, 1, round(cfg.ntrials *cfg.advisor.accLevels(cfg.advisor.acc(b)))) repmat(0, 1, round(cfg.ntrials *(1-cfg.advisor.accLevels(cfg.advisor.acc(b)))))];  
    
        for i = 1 : cfg.ntrials
            trialid                              = trialid+1;
            block_trials1(end+1).trialid         = trialid;
            block_trials1(end).questionnaireAns  = [];
            block_trials1(end).advAccLevel       =cfg.advisor.accLevels(cfg.advisor.acc(b));
            block_trials1(end).advCor            = AdviceAcc(i);
            block_trials1(end).pic               = cfg.advisor.pics(b);
            block_trials1(end).adviceLocation    =  expAdviceLoc(b);
            block_trials1(end).difficulty        = expDif(i);
            
        end
    
     %randomize trials within block
        block_trials1   = block_trials1(randperm(length(block_trials1)));  % randomize trials within two blocks
        trials          = cat(2,trials,block_trials1);                     % concatenate experimental block
        block_trials1   = [];
end
%clear  block_trial*;

%% add block number
t=0;
for b = 1 : cfg.nblocksprac
    for p = 1: cfg.ntrialsprac(b)
        t=t+1;
        trials(t).block = b;
    end
end
for b = (cfg.nblocksprac + 1) : cfg.ntotalblocks
    for p = 1 : cfg.ntrials
        t=t+1;
        trials(t).block = b;
    end
end
clear part b  t

%% check fields: none should be empty
fields = fieldnames(trials);
for f= 1:length(fields)
    if eval(['length({trials.' fields{f} '})']) ~= length(trials)
        disp(['Empty fields in ' fields{f} '!']);
    end
end
clear f

%% add wherelarger
wl0 = repmat([1 2],1,sum(cfg.ntrialsprac)/2);
wl1 = repmat([1 2],1,cfg.ntrials/2 * cfg.nblocks);
wl0 = wl0(randperm(length(wl0)));
wl1 = wl1(randperm(length(wl1)));
wl  = cat(2,wl0,wl1);
for t = 1 : length(trials)
    % add where larger
    trials(t).wherelarger   = wl(t);
    
    % add where dots field
    trials(t).wheredots     = zeros(2,400);
    
    %-- add breaks and feedback
    if t == 1
        trials(t).break         = false;
        trials(t).feedback      = false;
        trials(t).instr         = true;
        trials(t).questionnaire = false;
    elseif trials(t-1).block ~= trials(t).block 
        trials(t).break         = true;
        trials(t).feedback      = true;
        if trials(t).block <= 4
            trials(t).instr     = true;
        else
            trials(t).instr     = false;
        end
        %only for odd experimental blocks
        if mod(trials(t).block,2) && trials(t).block > 2 
            trials(t).questionnaire     = true;
        else
            trials(t).questionnaire     = false;
        end
    else
        trials(t).break         = false;
        trials(t).feedback      = false;
        trials(t).instr         = false;
        trials(t).questionnaire = false;
    end
end
clear wl* t
%{
% check the design manually
if 0
    % after randomization
    img_dsg(trials,{'pic','obstype','block','break','feedback','wherelarger','questionnaire'})
    figure(gcf+1);
    [z index] = sort([trials.trialid]);clear z;
    img_dsg(trials(index),{'pic','obstype','block','break','feedback','wherelarger','questionnaire'})
end

%}
