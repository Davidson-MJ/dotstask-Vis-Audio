
% Reseed the random-number generator for each expt.
cfg.resetrn                 = rng('shuffle');
cfg.computer                = computer;

%-- Configure Input keys for current device
cfg.response.until_release  = 1;
cfg.response.escape         = KbName('ESCAPE');
cfg.response.pause          = KbName('p');

%% default
if ~isfield(cfg,'port'),            cfg.port = 'keyboard';end
if ~isfield(cfg,'experimenter'),    cfg.experimenter = 'space';end
if ~isfield(cfg,'escape'),          cfg.escape = 'ESCAPE';end
if ~isfield(cfg,'pause'),           cfg.pause = 'P';end
if ~isfield(cfg,'until_release'),   cfg.until_release = true;end
if ~isfield(cfg,'restarted'),       cfg.restarted = false;end

%% Stimulus variables

cfg.useInfoSeeking_or_Advice=1;             % change to 1 to include 'see again' as the option, 2 for advice from an agent (2 unfinished).

% stimulus variables
cfg.stim.durstim                = .3;                                       % presentation time of sensory stimuli.
cfg.stim.respduration           = 1 ;                                    % timeout for primary task (only first half of exp.)

%interval timings:
%segmenting 400ms for preperation fixation cross:
cfg.stim.TW1               = .4;                                    % TW1= down-time before 'getready' indicated by large fix cross
% cfg.stim.TW2               = .2;
% % TW2= 'get ready' indicator pre stim presentation. not in use

%long wait between stim/response presentations, for decoding.
cfg.stim.TW3               = .8;% 0.2;                                        % TW3= time after Stim before response/next presentation (small fix cross).



%% feedback?
cfg.dispFeedback_stats      =0;  % change to 1 to give audio feedback, and hard feedback (stats between blocks)
cfg.giveAudioFeedback       =0;  %1 will provide trial level feedback during practice.

cfg.auddur                  =0.1; 
cfg.tonegap                 = 0.1; %seconds, gap between tones to be discriminated
cfg.audrate                 = 44100;
cfg.stim.beepvolume         = 1;                                          % error tone volume



%% configure STAIRCASE parameters (using Palamedes toolbox).
cfg.stepDown_partA             = 4; % 4 incorrect before stim change = 84% accuracy 
cfg.stepDown_partB            = 2; %harder difficulty ~71%, encourage see-again choices.
%Set up up/down procedure:
up      = 1;                       % increase difficulty after 'up' correct
down    = cfg.stepDown_partA;      % decrease after incorrect.

%Note that this just initializes (70% accuracy)
% the 'down' value above will be updated based on experiment type, as
%different accuracy levels are requested.

StepSizeDown = 2;        % 
StepSizeUp =   2;          %  step size (ndots), Hzratio(85%, 90% increment etc).
stopcriterion = 'trials';   %
stoprule = NaN;             % Updated based on ntrials per experiment, see 'updateStaircase_trialstart.m'
startvalue = 50;           % difference between dot boxes/ Hz, start easy.
xmax= 100;                 % difference bound
xmin=1; 

% prep Palamedes structure
UD = PAL_AMUD_setupUD('up',up,'down',down);
UD = PAL_AMUD_setupUD(UD,'StepSizeDown',StepSizeDown,'StepSizeUp', ...
    StepSizeUp,'stopcriterion',stopcriterion,'stoprule',stoprule, ...
    'startvalue',startvalue,'xMax', xmax, 'xMin', xmin);
% 
% %Determine and display targetd proportion correct based on above params:
targetP = (StepSizeUp./(StepSizeUp+StepSizeDown)).^(1./down);
message = sprintf('\rTargeted proportion correct: %6.4f',targetP);
disp(message);

%%
%note that to start experiment, we need to convert this log unit diff into
%dots difference (or Hz).
%natural log units can be converted to percentage change using the formula:
% e.g. if initial dot difference is 175 vs 225
% percntDiff = log(225)-log(175);



cfg.initialstimDifference    = startvalue; % staircase initialization (both!)


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




% instructions on screen
cfg.instr.cjtext        = {'50%' '60%' '70%' '80%' '90%' '100%'};           % confidence judgement text
cfg.instr.instr = {'Left click with the mouse' '\n' 'Press spacebar to confirm response'}; % how to respond.


cfg.instr.finaldecision = {'What is your final decision?'};                 
cfg.instr.interval      = {'LEFT' 'RIGHT'};


% %% not in use
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

