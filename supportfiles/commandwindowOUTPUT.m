% commandwindowOUTPUT

%which exp type?

% calculate, and display running accuracy to confirm staircasing:
if t>1
allt=1:(t-1);
allresps = [alltrials(1:t).cor];
running_acc = sum(allresps)/(t-1);

end
%%
switch alltrials(t-1).stimtype
    case {'visual', 'VISUAL'}
        try  % display visual details for boxes
            disp(['trial n: ' num2str(t-1) '/' num2str(length(alltrials) )])
           dotsLeft = length(find(alltrials(t-1).wheredots(1,:)));
            dotsRight = length(find(alltrials(t-1).wheredots(2,:)));
            disp(['dotDiff: ' num2str(alltrials(t-1).stimdifference) '. ' num2str(dotsLeft) ' v ' num2str(dotsRight)])           
            disp(['accuracy: ' num2str(alltrials(t-1).cor) ',resp: ' num2str(alltrials(t-1).resp1_loc)])
            disp(['reaction time 1: ' num2str(alltrials(t-1).rt)])
                 disp('------------------------------------------');
                 disp(['running accuracy: ' sprintf('%.2f',running_acc*100) '%, intended ' sprintf('%.2f',targetP*100)])
            %         disp(['confidence1: ' num2str(alltrials(t-1).cj1)])
            %         if strcmp(alltrials,'cor2')
            %             disp(['accuracy2: ' num2str(alltrials(t-1).cor2)])
            %             disp(['confidence2: ' num2str(alltrials(t-1).cj2)])
            %         end
            %         disp(['obs acc: ' num2str(alltrials(t-1).obsacc)]);
            disp('------------------------------------------');
        catch
            disp('no previous trialinformation')
        end
    case {'audio', 'AUDIO'}
        try
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
            disp(['HzDiff:' num2str(hzdiff) '. ' num2str(tone1) ' v ' num2str(tone2)])
            disp('------------------------------------------');            
            disp(['running accuracy: ' sprintf('%.2f',running_acc*100) '%, intended ' sprintf('%.2f',targetP*100)])
            disp('------------------------------------------');
        catch
            disp('no previous trial information')
            disp('------------------------------------------');
        end
end