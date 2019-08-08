%% define stimulus boxes
% define box width and location on screen by degrees of visual angle,
% rather than hardcoded pixels.
% ideally to allow reproducibility across experimental set-ups, if approx viewing distance
% from screen is known

% M Davidson. July 2019.


%required dva:
boxwidthDVA= 8;% width of square boxes containing dots.
boxecc = boxwidthDVA/2+4; % the box eccentricity from screen centre (centre edge of box ).
framewidth = .1;  % width of the frame around boxes.

display.dist=60; %cm approxviewDist
display.resolution = window.Width; % in pixels

%need width in cm.
Res = get(0, 'ScreenPixelsPerInch');
%1 inch = 2.54 cm:
display.width = (window.Width/Res)*2.54; % now in cm.

%feed these values to convert required angle, into pixels for boxes.

%%
 pix_fromcentre = angle2pix(display,boxecc );
 pix_boxwidth = angle2pix(display,boxwidthDVA);
 pix_framewidth = angle2pix(display,framewidth);
%%
% define distance of left and right from centre


center1x = window.Center(1) - pix_fromcentre;
center1y = window.Center(2);
center1 = [center1x, center1y];

%define left rectangle:
% rect1 = [(center1x - pix_boxwidth/2-5*pix_framewidth), (center1y - pix_boxwidth/2 - 5*pix_framewidth),...
%     (center1x + pix_boxwidth/2+5*pix_framewidth), (center1y + pix_boxwidth/2 + 5*pix_framewidth)];

rect1 = [(center1x - pix_boxwidth/2-5*pix_framewidth), (center1y - pix_boxwidth/2 - 5*pix_framewidth),...
    (center1x + pix_boxwidth/2+5*pix_framewidth), (center1y + pix_boxwidth/2 + 5*pix_framewidth)];

center2x = window.Center(1) + pix_fromcentre; % adding pixels pushes to right of screen.
center2 = [center2x, center1y]; % same y pos as left side.

%define right rectangle:
rect2 = [(center2x - pix_boxwidth/2-5*pix_framewidth), (center1y - pix_boxwidth/2 - 5*pix_framewidth),...
    (center2x + pix_boxwidth/2+5*pix_framewidth), (center1y + pix_boxwidth/2 + 5*pix_framewidth)];


% define the grid for the placement of the dots:
% basically a cartesian grid:
border1 = -pix_boxwidth/2;
border2 = pix_boxwidth/2;

% this is the grid size, n x n . 
%Dots will fill half of these elements (+- dot difference between left and
%right).
n_elements = 20; % n X n grid.

% this is a grid for the dots placement, relative to the centre 
cfg.xymatrix = [repmat(linspace(border1,border2,n_elements),1,n_elements);...
    sort(repmat(linspace(border1,border2,n_elements),1,n_elements))]; 


