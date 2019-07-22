%% Build all trials ( practice and experimental blocks).
% code largely unchanged from Naomi's handover.

trialid = 0;
index=1;

[alltrials, block_trialsPRAC,block_trialsEXP] =deal([]);   %initialize as empty vectors


%% Build  practice trials

%Create difficulty condition matrix 
% 2 difficulty levels for practice.
prac3Dif        = repmat(cfg.trialDif,1,cfg.ntrialsprac(3)/length(cfg.trialDif));

for b = 1: cfg.nblocksprac % for each block in practice
    
    block_trialsPRAC = []; %clear vector for each individual block, concatenated at end.
   
    if b == cfg.nblocksprac % for last block % if last practice block (of 6 practice trials)
        % Only last block contains easy trials
        AdviceAcc    = [ones(1, round(cfg.ntrialsprac(b) *cfg.advisor.trainAcc)) zeros(1, round(cfg.ntrialsprac(b) *(1-cfg.advisor.trainAcc)))];
    end
    
    for t = 1: (cfg.ntrialsprac(b)) %for each trial per prac block
        
        %preallocate
       trialid                                 = trialid+1;
        block_trialsPRAC(end+1).trialid            = trialid;
        block_trialsPRAC(end).questionnaireAns     = [];
        block_trialsPRAC(end).adviceLocation       =  NaN;
        block_trialsPRAC(end).advCor               = NaN; 
        
        if b == cfg.nblocksprac % for last block
            block_trialsPRAC(end).pic              = 7;
            block_trialsPRAC(end).advAccLevel      = cfg.advisor.trainAcc;
            block_trialsPRAC(end).difficulty       = prac3Dif(t);
            block_trialsPRAC(end).adviceLocation   = 1; %Update
            block_trialsPRAC(end).advCor           = AdviceAcc(t);
            
        else % for all other practice blocks 
            block_trialsPRAC(end).pic              = NaN;
            block_trialsPRAC(end).advAccLevel      = NaN;
            block_trialsPRAC(end).advCor           = NaN;
            block_trialsPRAC(end).difficulty       = 2;
            
        end
    end
    
    block_trialsPRAC    = block_trialsPRAC(randperm(length(block_trialsPRAC)));         % randomize trials within block
    alltrials           = cat(2,alltrials,block_trialsPRAC);                            % concatenate practice blocks
end

%we now have practice trials, with associated difficulty levels.
%% experimental trials
expDif  = repmat(cfg.trialDif,1,cfg.ntrials/length(cfg.trialDif)); 
%trial difficulty [1 2 3] creates a matrix the size of a block with equal numbers of trials for each dif
expAdviceLoc          = repmat([1 2], 1, cfg.nblocks/2); %Block advice location [1=up 2=down]: Matrix size of the number of blocks with same number of the 2 locations
expAdviceLoc          = expAdviceLoc(randperm(length(expAdviceLoc))); %randomise the advice location

for b =  1 : cfg.nblocks
    
    %create a matrix the size of block trial number with 0 and 1s to match
    %advisor accuracy (0 = incorrect advice, 1=correct advice)
    AdviceAcc       = [ones(1, round(cfg.ntrials *cfg.advisor.accLevels(cfg.advisor.acc(b)))) zeros(1, round(cfg.ntrials *(1-cfg.advisor.accLevels(cfg.advisor.acc(b)))))];  
    
        for i = 1 : cfg.ntrials
            % for each trial in this block, allocate parameters:
            trialid                              = trialid+1;
            block_trialsEXP(end+1).trialid         = trialid;
            block_trialsEXP(end).questionnaireAns  = [];
            block_trialsEXP(end).advAccLevel       =cfg.advisor.accLevels(cfg.advisor.acc(b));
            block_trialsEXP(end).advCor            = AdviceAcc(i);
            block_trialsEXP(end).pic               = cfg.advisor.pics(b);
            block_trialsEXP(end).adviceLocation    =  expAdviceLoc(b);
            block_trialsEXP(end).difficulty        = expDif(i);
            
        end
    
     %randomize trials within block
        block_trialsEXP   = block_trialsEXP(randperm(length(block_trialsEXP)));  % randomize trials within two blocks
        alltrials          = cat(2,alltrials,block_trialsEXP);                     % concatenate experimental block
        block_trialsEXP   = [];
end
clear  block_trial*;

%% add block number
t=0;
for b = 1 : cfg.nblocksprac
    for p = 1: cfg.ntrialsprac(b)
        t=t+1;
        alltrials(t).block = b;
    end
end
for b = (cfg.nblocksprac + 1) : cfg.ntotalblocks
    for p = 1 : cfg.ntrials
        t=t+1;
        alltrials(t).block = b;
    end
end
clear part b  t

%% check fields: none should be empty
fields = fieldnames(alltrials);
for f= 1:length(fields)
    if eval(['length({alltrials.' fields{f} '})']) ~= length(alltrials)
        disp(['Empty fields in ' fields{f} '!']);
    end
end
clear f

%% add wherelarger (which side has more dots)
wl0 = repmat([1 2],1,sum(cfg.ntrialsprac)/2);
wl1 = repmat([1 2],1,cfg.ntrials/2 * cfg.nblocks);
wl0 = wl0(randperm(length(wl0)));
wl1 = wl1(randperm(length(wl1)));
wl  = cat(2,wl0,wl1);
%%


for t = 1 : length(alltrials)
    % add where larger
    alltrials(t).wherelarger   = wl(t);
    
    % add where dots field
    alltrials(t).wheredots     = zeros(2,400);
    
    %-- add breaks and feedback
    if t == 1
        alltrials(t).break         = false;
        alltrials(t).feedback      = false;
        alltrials(t).instr         = true;
        alltrials(t).questionnaire = false;
        
    %-- add breaks between blocks.
    elseif alltrials(t-1).block ~= alltrials(t).block 
        alltrials(t).break         = true;
        alltrials(t).feedback      = true;
        if alltrials(t).block <= 4
            alltrials(t).instr     = true;
        else
            alltrials(t).instr     = false;
        end
        %only for odd experimental blocks
        if mod(alltrials(t).block,2) && alltrials(t).block > 2 
            alltrials(t).questionnaire     = true;
        else
            alltrials(t).questionnaire     = false;
        end
    else
        alltrials(t).break         = false;
        alltrials(t).feedback      = false;
        alltrials(t).instr         = false;
        alltrials(t).questionnaire = false;
    end
end
clear wl* t

% {
%% check the design manually
%create image of experimental parameters:    
% 
%reorder:
    figure();
    [~, index] = sort([alltrials.trialid]);
    img_dsg(alltrials(index),{'pic','block','break','feedback','wherelarger','questionnaire'})
    
    %print output.
    comeback=pwd;
    cd(ppantsavedir)
    print('-dpng', 'Exp overview');
    close all
    cd(comeback);


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% in case experiment was restarted after crash
if (subject.restart)
    [filename, pathname] = uigetfile('*.mat', 'Pick last saved file ');
    load([pathname filename]);
    starttrial = t;
    cfg.restarted = 1;
else
    starttrial=1;
end

