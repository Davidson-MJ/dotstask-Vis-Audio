%DrawDotsOnScreen


%
%Run staircase for medium difficulty (Changes dot density difference).
if t > 2
    if alltrials(t).difficulty == 2
        alltrials(t).dotdifference = ...
            staircase([currentDotCor(2) currentDotCor(1)], ...
            [currentDotDiff(2) currentDotDiff(1)]);
        currentDotDiff(2) = currentDotDiff(1);
        currentDotDiff(1) = alltrials(t).dotdifference;
        %Set dotdifference for
    elseif alltrials(t).difficulty == 1
        alltrials(t).dotdifference = currentDotDiff(1)*3;
    elseif alltrials(t).difficulty == 3
        alltrials(t).dotdifference = round(currentDotDiff(1)/3);
    end
end


% using staircased dots difference.
larger = 200 + alltrials(t).dotdifference;
smaller = 200 - alltrials(t).dotdifference;

% vectors are created that contain logical values to tell where
% dots have to be set in the squares (randomized)

alltrials(t).wheredots(alltrials(t).wherelarger,randsample(400,larger)) = 1;
alltrials(t).wheredots(3-alltrials(t).wherelarger,randsample(400,smaller)) = 1;
alltrials(t).wheredots = logical(alltrials(t).wheredots);

%% stimulus presentation
Screen('DrawLines',window.Number,innerrect1out,3,255);
Screen('DrawLines',window.Number,innerrect2out,3,255);

%Left
Screen('DrawDots', window.Number, ...
    cfg.xymatrix(:,squeeze(alltrials(t).wheredots(1,:))), ...
    2, 255, center1, 2);
%Right
Screen('DrawDots', window.Number, ...
    cfg.xymatrix(:,squeeze(alltrials(t).wheredots(2,:))), ...
    2, 255, center2, 2);
