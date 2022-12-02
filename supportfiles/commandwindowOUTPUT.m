% commandwindowOUTPUT

%which exp type?

% calculate, and display running accuracy to confirm staircasing:
if t>1
allt=1:(t-1);
allresps = [alltrials(allt).cor];
running_acc = sum(allresps)/(t-1);

%also. give running block accuracy:
lastbreak = find([alltrials(1:(t-1)).break],1, 'last');
%define block trials.
blockt= lastbreak:(t-1);
%collect block resps.
blockresps= [alltrials(blockt).cor];
block_acc = sum(blockresps)/length(blockt);

trialpos_id = t- lastbreak;

end

%% what is the target accuracy for this part of the experiment?
targetP = (UD.stepSizeUp./(UD.stepSizeUp+UD.stepSizeDown)).^(1./UD.down);
%%
switch alltrials(t-1).stimtype
    case {'visual', 'VISUAL'}
        try  % display visual details for boxes
            disp(['trial ' num2str(trialpos_id) ' block ' num2str(alltrials(t-1).blockcount )]);
            disp(['trial n: ' num2str(t-1) '/' num2str(length(alltrials) )])
           dotsLeft = length(find(alltrials(t-1).wheredots(1,:)));
            dotsRight = length(find(alltrials(t-1).wheredots(2,:)));
            disp(['dotDiff: ' num2str(alltrials(t-1).stimdifference) '. ' num2str(dotsLeft) ' v ' num2str(dotsRight)])           
            disp(['accuracy: ' num2str(alltrials(t-1).cor) ',resp: ' num2str(alltrials(t-1).resp1_loc)])
            disp(['reaction time 1: ' num2str(alltrials(t-1).rt)])
                 disp('------------------------------------------');
                 disp(['block accuracy: ' sprintf('%.2f',block_acc*100)])
                 disp(['overall accuracy: ' sprintf('%.2f',running_acc*100) '%, intended ' sprintf('%.2f',targetP*100)])
           
            disp('------------------------------------------');
        catch
            disp('no previous trialinformation')
        end
    case {'audio', 'AUDIO'}
        try
            disp(['trial ' num2str(trialpos_id) ' block ' num2str(alltrials(t-1).blockcount )]);
            disp(['trial n: ' num2str(t-1) '/' num2str(length(alltrials) )])
            disp(['accuracy: ' num2str(alltrials(t-1).cor) ',resp: ' num2str(alltrials(t-1).resp1_loc)])
            disp(['reaction time: ' num2str(alltrials(t-1).rt)])
            %
            tone1= alltrials(t-1).firstHz;
            tone2= alltrials(t-1).secondHz;
            if alltrials(t-1).whereTrue==1 %first larget than second:
                hzdiff = tone1/tone2;
            else
                hzdiff = tone2/tone1;
            end
             disp(['stimdiff:'  num2str(alltrials(t-1).stimdifference)])
            disp(['HzDiff:' num2str(hzdiff) '. ' num2str(tone1) ' v ' num2str(tone2)])
            disp('------------------------------------------');   
             disp(['block accuracy: ' sprintf('%.2f',block_acc*100)])
            disp(['running accuracy: ' sprintf('%.2f',running_acc*100) '%, intended ' sprintf('%.2f',targetP*100)])
            disp('------------------------------------------');
        catch
            disp('no previous trial information')
            disp('------------------------------------------');
        end
end