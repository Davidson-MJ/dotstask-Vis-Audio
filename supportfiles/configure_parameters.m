
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

%% Stimulus variables

% stimulus variables
cfg.stim.duration           = 1.500;                                       % timeout for primary task
cfg.initialDotDifference    = 20;                                          % staircase initialization (VIS)
cfg.initialHzDifference     = 100;                                         % staircase initialization (AUD)

cfg.stim.durstim            = .150;                                         % time first order stimulus is shown on screen
cfg.stim.durstim2           = .3; %was .3                                   % time stimulus is shown on screen for second view (if vis), 
% % cfg.stim.durAdv             = 1.5;                                         % time advice is shown on screen

%interval timings:
%segmenting 400ms for preperation fixation cross:
cfg.stim.TW1               = 0;%.2; %,0.3;                                    % TW1= down-time before 'getready' indicated by large fix cross
cfg.stim.TW2               = .2; %0.4;                                        % TW2= 'get ready' indicator pre stim presentation.

%long wait between stim/response presentations.
cfg.stim.TW3               = .4;% 0.2;                                        % TW3= time after Stim before response/next presentation (small fix cross).

%NB; in expA, time between response and next stim= TW3+(TW1+TW2);

% feedback?
cfg.stim.beep               = sin(2*pi*[0:1/44100:.1]*1000);               % error tone
cfg.stim.beep2              = sin(pi*[0:1/44100:.1]*1000);                 % finish tone
cfg.stim.beeprate           = 22254;                                       % error tone rate
cfg.stim.beepvolume         = .5;                                          % error tone volume

%% configure audio masks for discrimination:
cfg.useAuditorymasks=0;                     % change to 1 for masking auditory tone in white noise. (different aud. task). Otherwise uses pitch discrimination



aud_samprate=44100;

if cfg.useAuditorymasks==1    % make noise maskers. cf. Zakrzewski et al., Brain & Cognition, 2019
                    % 2400ms white noise
maskerlength=2.4; %seconds
aud_samprate=44100;
wn= randn([1,maskerlength*aud_samprate]);

% 750ms on/off ramps: use Tukey window (rectangular)
R=1.5/2.4;% rampratio. Length of taper (2*.75) to total window.
tukey_win= tukeywin(maskerlength*aud_samprate, R)';
cfg.maskerTone = wn.*tukey_win;
end

%audio stim = 80ms sinusoid, 1000Hz or 2500 Hz, detection task is to choose
%higher pitch.

cfg.stimLow = sin(2*pi*1000*[0:1/aud_samprate:.08]);
cfg.stimHigh = sin(2*pi*2500*[0:1/aud_samprate:.08]);
    
     
%% Configure information seking types.

% advisor related variables
if cfg.useInfoSeeking_or_Advice==0
cfg.nadvisers                       = 6;                                    % 
cfg.advisor.accLevels               = linspace(.5,1, cfg.nadvisers);        % space accuracy levels by nadvisors,
cfg.advisor.trainAcc                = .8; 

%randomise the advisor parameters
cfg.advisor.pics                    = ones(1,6); % was [randperm(6)];       % single advisor pic.
cfg.advisor.acc                     = randperm(6);
end



% define the grid for the placement of the dots:
cfg.xymatrix = [repmat(linspace(-57,57,20),1,20);...
    sort(repmat(linspace(-57,57,20),1,20))]; 

% instructions on screen
cfg.instr.cjtext        = {'50%' '60%' '70%' '80%' '90%' '100%'};           % confidence judgement text
cfg.instr.instr = {'Left click with the mouse' '\n' 'Press spacebar to confirm response'}; % how to respond.


cfg.instr.finaldecision = {'What is your final decision?'};                 
cfg.instr.interval      = {'LEFT' 'RIGHT'};

cfg.instr.estimated_obsacc  = ...
    {'Your baseline accuracy (before any advice) was 71%' ...
    'What do you think this person''s accuracy was?' ...
    'In the next screen you will be prompted to enter a value.' ...
    'Press any button when you are ready.' ...
    'Enter a number (using the keyboard upper digits) between 0 and 100 and press Enter: '};
cfg.instr.groups        = [1 11 12 18 22];                                       % groupings of instruction slides

% save paths in cfg
cfg.my_path                 = basedir; %prev. my_path;
cfg.results_path            = savedir; %prev. results path
% cfg.stims_path              = stims_path;

