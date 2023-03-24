%DrawDotsOnScreen


%
%Run staircase  (Changes dot density difference).

Run_staircase;


%determine dot difference based on PAL output.
% dDiff = UD.xCurrent*200;
%convert to nDots
% using staircased dots difference.
larger = (n_elements^2) /2+ ceil(alltrials(t).stimdifference/2);
smaller = (n_elements^2)/2 - ceil(alltrials(t).stimdifference/2);

% vectors are created that contain logical values to tell where
% dots have to be set in the squares (randomized)

% alltrials(t).wheredots(alltrials(t).whereTrue,randsample(400,larger)) = 1;
% alltrials(t).wheredots(3-alltrials(t).whereTrue,randsample(400,smaller)) = 1;
alltrials(t).wheredots = zeros(2, n_elements^2);
%fill larger dot matrix  first:
largerLoc = alltrials(t).whereTrue;
if largerLoc==1 %left side larger
alltrials(t).wheredots(1, randsample(n_elements^2,larger)) = 1;
alltrials(t).wheredots(2, randsample(n_elements^2,smaller)) = 1;
else %right side larger
alltrials(t).wheredots(2, randsample(n_elements^2,larger)) = 1;
alltrials(t).wheredots(1, randsample(n_elements^2,smaller)) = 1;
end
%convert to logical.
alltrials(t).wheredots = logical(alltrials(t).wheredots);



%% stimulus presentation
% Screen('DrawLines',window.Number,innerrect1out,3,255);
% Screen('DrawLines',window.Number,innerrect2out,3,255);

% defined in 'define_boxes.m' 
Screen('FrameRect', window.Number,[255 255 255], rect1, pix_framewidth);
Screen('FrameRect', window.Number,[255 255 255], rect2, pix_framewidth);

% dotsize = ceil(pix_boxwidth/100);
%set dot size, to approx 1/2 of an element.
el_size = ceil(pix_boxwidth/n_elements);
dotsize=ceil(el_size/2);

%Left
Screen('DrawDots', window.Number, ...
    cfg.xymatrix(:,squeeze(alltrials(t).wheredots(1,:))), ...
    dotsize, 255, center1, 2);
%Right
Screen('DrawDots', window.Number, ...
    cfg.xymatrix(:,squeeze(alltrials(t).wheredots(2,:))), ...
    dotsize, 255, center2, 2);


% debug: drawy dot at centre:
% Screen('DrawDots', window.Number,[0,0], 5, 255, center1,2)% 
%  %dotsize? as rule of thumb, want at least 20 dots across a row
%  Screen('Flip', window.Number) 
