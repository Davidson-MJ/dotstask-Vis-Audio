cfg                         = [];
% Reseed the random-number generator for each expt.
cfg.resetrn                 = rng('shuffle');
cfg.computer                = computer;
% cfg.scripts                 = getscripts(); % save scripts in cfg;
%-- Input device
cfg.response.until_release  = 1;
cfg.response.escape         = 'ESCAPE';
cfg.response.pause          = 'p';

%% default
if ~isfield(cfg,'port'),            cfg.port = 'keyboard';end
if ~isfield(cfg,'experimenter'),    cfg.experimenter = 'space';end
if ~isfield(cfg,'escape'),          cfg.escape = 'ESCAPE';end
if ~isfield(cfg,'pause'),           cfg.pause = 'P';end
if ~isfield(cfg,'until_release'),   cfg.until_release = true;end
if ~isfield(cfg,'restarted'),       cfg.restarted = false;end

%% initialise variables
% number of trials definition
cfg.ntrials         = 60 ; % per block
cfg.nblocks         = 6; % total exp.
cfg.nblocksprac     = 3;
cfg.ntrialsprac     = repmat(6, 1, cfg.nblocksprac);    %practice trials per prac block. 
cfg.ntotalblocks    = cfg.nblocks + cfg.nblocksprac;    % there are 3 prac blocks in total:

cfg.ntrialsall      = [cfg.ntrialsprac repmat(cfg.ntrials, 1, cfg.nblocks)]; %outputs array containing number of trials in each block

%%
 
% Trial condition definitions
cfg.trialDif                = [1 2];                                       % 1=easy, 2=hard
cfg.blockTypes              = [1,2,3,4];                                    %1 = Aud(InfoSeeking), 2= VIS(InfoSeeking), 3,4 = no info seeking.
% stimulus variables
cfg.stim.duration           = 1.500;                                       % timeout for primary task
cfg.initialDotDifference    = 20;                                          % staircase initialization
cfg.stim.durstim            = .15;                                         % time first order stimulus is shown on screen
cfg.stim.durstim2           = .3;                                          % time stimulus is shown on screen for second view
cfg.stim.durAdv             = 1.5;                                         % time advice is shown on screen
cfg.stim.RSI1               = 0.3;                                         % time between information choice and advisor presentation
cfg.stim.RSI2               = 0.8;                                         % time between confidence decision and next-t first-order stimulus presentation
cfg.stim.RSI3               = 0.4;                                         % time after fixation that preparation fixation appears 
cfg.stim.RSI4               = 0.1;                                         % time bold preparation fixation is presented for 
cfg.stim.beep               = sin(2*pi*[0:1/44100:.1]*1000);               % error tone
cfg.stim.beep2              = sin(pi*[0:1/44100:.1]*1000);                 % finish tone
cfg.stim.beeprate           = 22254;                                       % error tone rate
cfg.stim.beepvolume         = .5;                                          % error tone volume

%% configure audio masks for discrimination:
% make noise maskers. cf. Zakrzewski et al., Brain & Cognition, 2019

% 2400ms white noise
maskerlength=2.4; %seconds
aud_samprate=44100;
wn= randn([1,maskerlength*aud_samprate]);

% 750ms on/off ramps: use Tukey window (rectangular)
R=1.5/2.4;% rampratio. Length of taper (2*.75) to total window.
tukey_win= tukeywin(maskerlength*aud_samprate, R)';
cfg.maskerTone = wn.*tukey_win;

%audio stim = 80ms sinusoid, 1000Hz or 2500 Hz
cfg.stimLow = sin(2*pi*1000*[0:1/aud_samprate:.08]);
cfg.stimHigh = sin(2*pi*2500*[0:1/aud_samprate:.08]);
%%
InitializePsychSound 
%%
%%
% advisor related variables
% cfg.nadvisers                            = 6;
% cfg.advisor.accLevels               = [.5 .6 .7 .8 .9 1];                        %Accuracy levels
% cfg.advisor.trainAcc                = .8;

%randomise the advisor parameters
% cfg.advisor.pics                    = [randperm(6)];
% cfg.advisor.acc                     = [randperm(6)];

% define the grid for the placement of the dots:
cfg.xymatrix = [repmat(linspace(-57,57,20),1,20);...
    sort(repmat(linspace(-57,57,20),1,20))]; 

% instructions on screen
cfg.instr.cjtext        = {'50%' '60%' '70%' '80%' '90%' '100%'};
cfg.instr.finaldecision = {'What is your final decision?'};
cfg.instr.interval      = {'LEFT' 'RIGHT'};
% cfg.instr.estimated_obsacc  = ...
%     {'Your baseline accuracy (before any advice) was 71%' ...
%     'What do you think this person''s accuracy was?' ...
%     'In the next screen you will be prompted to enter a value.' ...
%     'Press any button when you are ready.' ...
%     'Enter a number (using the keyboard upper digits) between 0 and 100 and press Enter: '};
% cfg.instr.groups        = [1 11 12 18 22];                                       % groupings of instruction slides

% save paths in cfg
cfg.my_path                 = basedir; %prev. my_path;
cfg.results_path            = savedir; %prev. results path
% cfg.stims_path              = stims_path;

