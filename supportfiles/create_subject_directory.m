% prompt dubject info
prompt = {'Subject Number:','Gender(m/f):','Age:',...
    'hand(r/l): ', ...
    'Experiment restarted? Yes=1 or No=0: '};

answer = inputdlg(prompt);


subject.id          = answer{1};
subject.gender      = answer{2};
subject.age         = str2num(answer{3});
subject.hand        = answer{4};
subject.restart     = str2num(answer{5});
subject.date        = date;
subject.start_time  = clock;
subject.name        = num2str(subject.id);  
subject.screen      = 0;



% testing mode
if isempty(subject.id) 
    warning('TESTING MODE');
    subject.male            = NaN;
    subject.age             = NaN;
    subject.right_handed    = NaN;
    subject.screen          = 0; % small size screen:1
    subject.name            = 'test';
    subject.id              = 999;
            
end
if isempty(subject.name)
    subject.name = 'test';
end


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% in case experiment was restarted after crash
if (subject.restart)
    [filename, pathname] = uigetfile('*.mat', 'Pick last saved file, *_final ');
    load([pathname filename]);
    % prompt dubject info
    %%
    allstarts=find([alltrials.break]);
    
    prompt = {['Start at the beginning of a block.  Choose from: ' num2str(allstarts)]};
    starttrial_r=0;
    ppantsavedir=pathname;%
    cfg.restarted = 1;
    
    %restart only at block begging, for ease of analysis later
    while ~ismember(starttrial_r,allstarts)
        starttrial_rc = inputdlg(prompt);
        %% will only break once the correct trial is selected.
        
        starttrial_r = str2double(cell2mat(starttrial_rc));
        
        starttrial=starttrial_r;
    
    end
else %not restarted, so start at the beginning.
    starttrial=1;
      cfg.restarted = 0;

%% saving directory
% Unique filename depending on computer clock (avoids overwriting)
subject.fileName = [num2str(round(datenum(subject.start_time)*100000)) '_' num2str(subject.id)];
%% create directory if does not already exist
if ~exist([savedir  filesep 'DotsandAudio_behaviour'], 'dir')        
    mkdir([savedir filesep 'DotsandAudio_behaviour']);
end
%make participants outpath.
mkdir([[savedir filesep 'DotsandAudio_behaviour' filesep subject.fileName filesep 'behaviour']]);

ppantsavedir=[savedir filesep 'DotsandAudio_behaviour' filesep subject.fileName ];
 end
%% note that the experiment order (V-A or A-V) is predetermined.
% 
% try to load a previously generated experiment order:
expfile = dir([pwd filesep  'ExperimentOrder*']);
try load(expfile(1).name, 'randExpOrder')
    %continued below if successful.
    
catch
    %      set experiment type:
    if str2double(subject.id) < 999 % i.e. if not debugging.
        %     first ppant. so generate block design
        while ~exist('randExpOrder', 'var')
            %         randomize participant trial types
            %         1= V-A; 2= A-V
            randExpOrdertmp=randi(2,1,32);
            
            %         break when even numbers
            if length(find(randExpOrdertmp==1))==16
                dt=date;
                randExpOrder=randExpOrdertmp;
                save(['ExperimentOrder set ' date], 'randExpOrder')
                break
            end
        end
    end
end

if str2double(subject.id)<999 && ~isfield('cfg', 'df_order')
%now define experiment based on subject number
switch randExpOrder(str2double(subject.id))
    case 1
        cfg.df_order='vA'; % visual - then audio
        
    case 2
        cfg.df_order='aV' ;% audio- then visual discrimination
end
end
    

    