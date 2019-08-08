%% Build all trials ( practice and experimental blocks).
% 
% NB: Stimulus timings (durations, ISI, etc), are defined in:
% 'configure_parameters.m'
%% initialise variables

% number of trials definition
cfg.allblockTypes              = [1,2,3,4];  %1 = Vis(noIS), Aud(IS), Aud(noUS), VIS(w/IS);



%type of Experiment we are running:
if strcmp(cfg.df_order,'vA')
    cfg.stimTypes={['visual'],['AUDIO']};
    cfg.xmodBlockTypes=[1,2];
else
    cfg.stimTypes={['audio'], ['VISUAL']};
    cfg.xmodBlockTypes=[3,4];
end

% practice blocks cfgs
cfg.ntrialsprac             = 10;
cfg.nblocksprac             = 3;

% experimental blocks cfg
cfg.ntrials                 = 60 ; % per block;
cfg.nblocks_partA           = 5; 
cfg.nblocks_partB           = 7; 
cfg.SeeAgain_proportion     =.7; % on how many trials should the 'see-again' response be available for partB?
cfg.ntotalblocks            = cfg.nblocksprac*2 + cfg.nblocks_partA + cfg.nblocks_partB;

N_alltrials = cfg.ntrialsprac*cfg.nblocksprac*2 + ... %prac blocks
                    cfg.ntrials*cfg.nblocks_partA + ... % part A (no InfoSeeking)
                    cfg.ntrials*cfg.nblocks_partB ; % part B (w InfoSeeking)
                
%% -  - Begin Experiment build.
%% Build  practice trials first.


% Part A and Part B. Note Part B requires the 'see again' option on
% proportion of trials:

% we'll randomize in a vector,
%See again:
seeQ= ones(1,ceil(cfg.ntrialsprac*cfg.SeeAgain_proportion));
% respond right away:
rQ= zeros(1,(cfg.ntrialsprac-length(seeQ)));

% combine as vector, before we will shuffle per block
pracBtrials= [rQ, seeQ]; 

%also create vector for 'where true', correct responses per trial.
wheretrue_vec = [ones(1, cfg.ntrialsprac*.5), ones(1, cfg.ntrialsprac*.5)+1];
%1 = left side / first tone, 2 = right side/second tone.

%% build both series of practice blocks
for iEXP=1:2 % for first then second type. (partA vs partB).
    %begin counter;
    trialid= 1;
    
    % store/concatenate, at end.
    practiceblocks=[]; 
    
    % for each block in practice
    for iblock = 1: cfg.nblocksprac 
        
        %clear vector for each individual block, concatenated at end.
        block_trialsPRAC = []; 
        
        % shuffle per block (only using in part B)
        pracBtrials=shuffle(pracBtrials); 
    
        
        wheretrue_vec = shuffle(wheretrue_vec);
        for itrial = 1: cfg.ntrialsprac %for each trial per prac block
            
            %preallocate each trial in prac block            
            block_trialsPRAC(itrial).isprac               = 1; 
            block_trialsPRAC(itrial).trialid              = trialid*.01; %['prac ' num2str(trialid)];            
            block_trialsPRAC(itrial).stimtype             = cfg.stimTypes{iEXP}; % Vis or Audio.
            block_trialsPRAC(itrial).xmodtype             = cfg.xmodBlockTypes(iEXP);
            block_trialsPRAC(itrial).blockcount           =  iblock*.01;
            block_trialsPRAC(itrial).whereTrue            = wheretrue_vec(itrial);
  
            if itrial==1 
                block_trialsPRAC(itrial).break                = true; %break after last trial of each block. 
            else
                block_trialsPRAC(itrial).break                = false; %continue otherwise
            end

            % exp A vs B specific fields:
            if iEXP==1
                block_trialsPRAC(itrial).InfoOption           = NaN;
                block_trialsPRAC(itrial).ExpType              = 'A';
                block_trialsPRAC(itrial).SeeAgainOpt          = 'n';
            else
                block_trialsPRAC(itrial).ExpType              = 'B';
                block_trialsPRAC(itrial).InfoOption           = pracBtrials(itrial);
                if pracBtrials(itrial)==0 %resp now.
                block_trialsPRAC(itrial).SeeAgainOpt          = 'n';
                else
                block_trialsPRAC(itrial).SeeAgainOpt          = 'y';
                end
            end
            trialid=trialid+1;
        end
        
        %concatenate blocks in a series.
       practiceblocks=[practiceblocks, block_trialsPRAC];
        
    end
    
    %rename as appropriate.
    switch iEXP
        case 1
            practiceblocks_A    = practiceblocks;
        case 2
            practiceblocks_B    = practiceblocks;
    end
    
end

% now we have the practice trials for first and second half of exp.

%% BUILD experimental trials
 % as above, in EXP B we'll randomize See/Resp trials (40% of trials as resp now).
 
%See again:
seeQ= ones(1,ceil(cfg.ntrials*cfg.SeeAgain_proportion));
% respond right away:
rQ= zeros(1,(cfg.ntrials-length(seeQ)));
expBtrials= [seeQ, rQ];

% also create vector for 'where true', correct responses per trial.
%for part A, allocate across all trials in block.
wheretrue_vecA = [ones(1, cfg.ntrials*.5), ones(1, cfg.ntrials*.5)+1]; 


% for part B to keep even numbers of each, define separately for the each case.
ntrialsSeeagain= length(seeQ);
%need to distribute for both see again, AND respond now types.
wheretrue_vecSeeagain = [ones(1, ntrialsSeeagain*.5), ones(1, ntrialsSeeagain*.5)+1]; 
wheretrue_vecRespnow = [ones(1, (cfg.ntrials-ntrialsSeeagain)*.5), ones(1, (cfg.ntrials-ntrialsSeeagain)*.5)+1]; 

%now we can pull from correct vector to ensure equal distribution of 'true'
%response locations.

%1 = left side / first tone, 2 = right side/second tone.
%%

trialid=1;

for iEXP=1:2 % for first then second type.
  
    experimentalblocks=[];
    
    switch iEXP %use correct number of blocks.
        case 1
            nblocks = cfg.nblocks_partA;
        case 2
            nblocks = cfg.nblocks_partB;
    end
    
    for iblock =  1 : nblocks
        
        %keep track of block count:
        blockcounter= iblock + (iEXP-1)*cfg.nblocks_partA; 
        
        
        
        block_trialsEXP = []; %clear vector for each individual block, concatenated at end.
        
      %  (only using in part B)
        expBtrials=shuffle(expBtrials); 
      
        % shuffle per block
        wheretrue_tmpA= shuffle(wheretrue_vecA);
        wheretrue_tmpSee= shuffle(wheretrue_vecSeeagain);
        wheretrue_tmpResp= shuffle(wheretrue_vecRespnow);
               
        %reset proportionate trial counts per block
        trialid_seeag=1;
        trialid_respnow=1;
        
        
        for itrial = 1: cfg.ntrials %for each trial
            
            %preallocate each trial in prac block
             block_trialsEXP(itrial).isprac               = 0; 
            block_trialsEXP(itrial).trialid              = trialid;
            block_trialsEXP(itrial).blockcount           = blockcounter;           
            block_trialsEXP(itrial).stimtype             = cfg.stimTypes{iEXP}; % Vis or Audio.
            block_trialsEXP(itrial).xmodtype             = cfg.xmodBlockTypes(iEXP);
            
            if itrial==1 
                block_trialsEXP(itrial).break                = true; %break at last trial of each block. 
            else
                block_trialsEXP(itrial).break                = false; %continue otherwise
            end
            
            if iEXP==1
                block_trialsEXP(itrial).InfoOption           = NaN;
                block_trialsEXP(itrial).ExpType              = 'A';
                block_trialsEXP(itrial).whereTrue            = wheretrue_tmpA(itrial);
                block_trialsEXP(itrial).SeeAgainOpt          = 'n';
            
            else % determine whether InfoSeeking is displayed as option               
                
                block_trialsEXP(itrial).InfoOption           = expBtrials(itrial);
                block_trialsEXP(itrial).ExpType              = 'B';
                
                if expBtrials(itrial)== 0 %not see again!
                    block_trialsEXP(itrial).whereTrue            = wheretrue_tmpResp(trialid_respnow);
                    block_trialsEXP(itrial).SeeAgainOpt         = 'n';
                    trialid_respnow=trialid_respnow+1;
                else % see again trials, where resp=true?
                    block_trialsEXP(itrial).whereTrue            = wheretrue_tmpSee(trialid_seeag);
                      block_trialsEXP(itrial).SeeAgainOpt          = 'y';
                    trialid_seeag=trialid_seeag+1;
                end
            end
            
            trialid=trialid+1;
        end
        
        experimentalblocks=[experimentalblocks,block_trialsEXP];
        
    end
    
    switch iEXP
        case 1
            experimentalblocks_A    = experimentalblocks;
        case 2
            experimentalblocks_B   = experimentalblocks;
    end
    
end


% combine all practice and experimental blocks.

alltrials = [practiceblocks_A, experimentalblocks_A, practiceblocks_B, experimentalblocks_B];
%sanity checks:
if length(alltrials)~=N_alltrials
    error('check code: ntrial count incorrect')
end



%% check the design manually
%create image of experimental parameters:    
%  print in ppant folder.    
    imgExpOutline(alltrials, {'xmodtype',  'isprac', 'InfoOption', 'whereTrue', 'break'})
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
    starttrial = itrial;
    cfg.restarted = 1;
else
    starttrial=1;
end

