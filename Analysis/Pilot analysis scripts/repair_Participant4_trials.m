
load('73781348327_25_12.mat', 'alltrials')
p1_360 = alltrials;

%28 trials (one block) is missing.
load('73781348327_25_13.mat')
p388_390 = alltrials;

% 30 trials per block, so keep blocks 


% add together first half trials.
pA = [p1_360(1:387)];

load('73781348327_25_final.mat')
p388_780 = alltrials;

%% add missing field names to pA.
pAfnames = fieldnames(pA);
pBfnames = fieldnames(p388_780);


for ifieldfinal = 1:size(pBfnames,1)
    %if missing, add to table.
    if ~isfield(pA, pBfnames{ifieldfinal})
        
        %we can add only a single element, matlab populates the remaining
        %column (above).
        pA(360).(pBfnames{ifieldfinal}) =[];
        
    end
end

%% now that the fieldnames match, we can combine structures:
alltrials_final = [pA, p388_780([size(pA,2)+1]:end)];

%save as final:
save('73781348327_25_final.mat', 'alltrials_final', '-append')

