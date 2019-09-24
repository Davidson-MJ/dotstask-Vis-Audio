% tempSave_and_BreakInstructions

%% -- Save data every break 


thisblock = sum([alltrials(1:t).break])-1;
save([ppantsavedir '/behaviour/' subject.fileName '_' num2str(round(t/cfg.ntrials))],'alltrials', 'cfg', 'subject', 't', 'UD')

%-- break

%% display instructions or feedback, depending on trial position:

Screen('TextSize',window.Number,32);
if alltrials(t).trialid==.01 
% start of practice trials    
    if cfg.giveAudioFeedback==1
    showtext = [' Press any button to begin practice trials.'...
        '\n \n You will hear an error tone (beep), when incorrect'];
    else
        showtext = [' Press any button to begin practice trials.'];
    end
        
elseif alltrials(t).blockcount < 1
 % continue practice trials:
    showtext = [' Press any button to continue practice trials'];
    
elseif   alltrials(t).blockcount ==1
 % end of practice
    if cfg.giveAudioFeedback==1    
    showtext = [' End of practice. \n \n Press any button to begin experiment.'...
        '\n \n You will no longer hear error tones when incorrect' ...
        '\n \n Next block: ' num2str(alltrials(t).blockcount) ' of ' num2str(max([alltrials(:).blockcount])) ','...
        '\n \n ' num2str(cfg.ntrials) ' trials until next break'];    
    else
         showtext = [' End of practice. \n \n Press any button to begin experiment.'...      
        '\n \n Next block: ' num2str(alltrials(t).blockcount) ' of ' num2str(max([alltrials(:).blockcount])) ','...
        '\n \n ' num2str(cfg.ntrials) ' trials until next break'];
    end
    
elseif    alltrials(t).blockcount >1
    %if within experiment, calculate previous block accuracy, and give
    %appropriate level of feedback:
    
    prevblockindex = (t-(cfg.ntrials+1)): t-1;       
    % N missed (too slow)
    didrespond_tmp = [alltrials(prevblockindex).didrespond];
    nmissed = length(find(didrespond_tmp==0));
    %Block accuracy    
    blockAcc = sum([alltrials(prevblockindex).cor])/cfg.ntrials;
    
    %mean RT
    mRT = sum([alltrials(prevblockindex).rt])/cfg.ntrials;
    
      
    %display previous accuracy (?)
    
    if cfg.dispFeedback_stats==1
    %experimental blocks.
    showtext = [' Take a short break.' ...
        'Last block, you were too slow on ' sprintf('%2.f', (nmissed/cfg.ntrials*100)) '% of trials, \n \n',...
        'and answered '  sprintf('%2.f', (blockAcc*100)) '% correctly'...            
        '\n \n Next block ' num2str(alltrials(t).blockcount) ' of ' num2str(max([alltrials(:).blockcount])) ','...
        '\n \n ' num2str(cfg.ntrials) ' trials until next break'...
        '\n \n press any button to continue experiment.'];
    
    else % give verbal feedback to increase speed or accuracy (without using those terms)
        
        proportionmissed =length(prevblockindex)/nmissed;
        
        %tailor feedback if responding slowly or inaccurately:
        
        if proportionmissed <.05 % doing well, no performance based feedback                 
        showtext = [' Take a short break.' ...
            '\n \n Next block ' num2str(alltrials(t).blockcount) ' of ' num2str(max([alltrials(:).blockcount])) ','...
        '\n \n ' num2str(cfg.ntrials) ' trials until next break'...
        '\n \n press any button to continue experiment.'];
       
        
    %else if too slow or too innacurate:
        elseif proportionmissed >.05 
            showtext = [' Take a short break.' ...
                '\n Remember to respond as quickly as possible, while doing your best.'...                
            '\n \n Next block ' num2str(alltrials(t).blockcount) ' of ' num2str(max([alltrials(:).blockcount])) ','...
        '\n \n ' num2str(cfg.ntrials) ' trials until next break'...
        '\n \n press any button to continue experiment.'];

        elseif (targetP-blockAcc) > .10   % if >10% disparity between block accuracy and desired:
            
            showtext = [' Take a short break.' ...
                '\n Remember to respond as quickly as possible, while doing your best.'...                
            '\n \n Next block ' num2str(alltrials(t).blockcount) ' of ' num2str(max([alltrials(:).blockcount])) ','...
        '\n \n ' num2str(cfg.ntrials) ' trials until next break'...
        '\n \n press any button to continue experiment.'];
        end
        
    end
    
    %display key results to experimenter:
    disp(['End of block ' num2str(alltrials(t).blockcount) ' of  ' num2str(max([alltrials(:).blockcount]))])
    disp(['Block Accuracy: ' num2str(blockAcc) ', block RT: ' num2atr(mRT)])
   disp('------------------------------------------');

end

DrawFormattedText(window.Number, showtext ,'center', 'center', [255 255 255]);
Screen('Flip', window.Number);

%make sure all Keys are released, before continuing, after key press.
KbWait([],[],GetSecs()+2);
collect_response(cfg.response, inf);
% keyd = NaN;


