% commandwindowOUTPUT

%which exp type?

switch alltrials(t-1).stimtype   
    case {'visual', 'VISUAL'}
        % display visual details for boxes
        disp(['trial n: ' num2str(t-1) '/' num2str(length(alltrials) )])
        disp(['accuracy: ' num2str(alltrials(t-1).cor) ',resp: ' num2str(alltrials(t-1).resp1_loc)]) 
        disp(['reaction time: ' num2str(alltrials(t-1).rt)])
        dotsLeft = length(find(alltrials(t-1).wheredots(1,:)));
        dotsRight = length(find(alltrials(t-1).wheredots(2,:)));
        disp(['dotDiff:' num2str(alltrials(t-1).dotdifference) '. ' num2str(dotsLeft) ' v ' num2str(dotsRight)])
        
%         disp(['confidence1: ' num2str(alltrials(t-1).cj1)])
%         if strcmp(alltrials,'cor2')
%             disp(['accuracy2: ' num2str(alltrials(t-1).cor2)])
%             disp(['confidence2: ' num2str(alltrials(t-1).cj2)])
%         end
%         disp(['obs acc: ' num2str(alltrials(t-1).obsacc)]);
        disp('------------------------------------------');
    
    
    case {'audio', 'AUDIO'}
        
        disp(['trial n: ' num2str(t-1) '/' num2str(length(alltrials) )])
        disp(['accuracy: ' num2str(alltrials(t-1).cor) ',resp: ' num2str(alltrials(t-1).resp1_loc)]) 
        disp(['reaction time: ' num2str(alltrials(t-1).rt)])
        %
        tone1= alltrials(t-1).firstHz;
        tone2= alltrials(t-1).secondHz;
        
        disp(['HzDiff:' num2str(tone1-tone2) '. ' num2str(tone1) ' v ' num2str(tone2)])                
        disp('------------------------------------------');
        
end