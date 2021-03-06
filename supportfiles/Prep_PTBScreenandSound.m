% Prep_PTBScreenandSound
% script to set up basic screen background for running dots task in PTB
% prep screen in PTB:
close all


%% Stimulus (Screen) variables

cfg.backgroundColour = [123,123,123];           % grey
cfg.fontsize=32;


%% INITIALIZE PsychToolBox
% select offscreen window if we can
if cfg.offscreen==1
    scrnwin=max(Screen('Screens'));
else
    scrnwin=min(Screen('Screens'));
end

%note because we are on a MAC, need to skip synctests, PTB drivers are not
%well supported for new releases.
if strcmp(cfg.computer, 'MACI64')
     Screen('Preference', 'SkipSyncTests', 1);
end

%open screen:
AssertOpenGL;
[window.Number, window.Rect]=Screen('OpenWindow', scrnwin, cfg.backgroundColour);

% window = SetScreen('BGColor',cfg.backgroundColour,'FontSize',24,'OpenGL',1, 'Window', scrnwin);

%define params for easy reference
window.Width        = RectWidth(window.Rect);
window.Height       = RectHeight(window.Rect);
window.Center       = [window.Width/2 window.Height/2];
window.AspectRatio  = window.Rect(4)/window.Rect(3);       % Get the aspect ratio of the screen:
window.RefreshRate  = Screen('NominalFramerate', window.Number);
cfg.fps             = Screen('GetFlipInterval', window.Number);
cfg.frame           = Screen('Flip', window.Number);

%update to max priority.
Priority(MaxPriority(window.Number));

if (window.RefreshRate == 0) %% correct refreshrate for LCD screens
    window.LCD = 1;
    window.RefreshRate = 60;
end

windowIN=window.Number;

%%  Set font parameters
Screen('TextFont', window.Number ,'Helvetica');
Screen('TextSize', window.Number , 20);                  % fontsize
Screen('TextColor', window.Number , [255 255 255]);      % fontcolour


% Screen('BlendFunction', window.Number, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
%% define stimulus boxes
define_boxes;

%% define & create informtion type choices boxes and images
% define_choices;


%% define confidence scale (second half of exp).
define_scale;

%% define simple response boxes (Left/Right click)
% used for first half of each experiment:
define_mouseboxes;

%% Set priority for script execution to realtime priority:
priorityLevel=MaxPriority(window.Number);
Priority(priorityLevel);
cfg.startexp = GetSecs;


%% -- prep AUDIO

InitializePsychSound

%%

if subject.id~=999 
    ListenChar(2);
    HideCursor();
end

KbName('UnifyKeyNames');

