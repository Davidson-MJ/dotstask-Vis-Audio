% tempSave_and_BreakInstructions

%% -- Save data every break 


thisblock = alltrials(t).blockcount;
cd(ppantsavedir)

save( [subject.fileName '_' num2str(floor(t/cfg.ntrials))],'alltrials', 'cfg', 'subject', 't', 'UD')

%-- break
% if strcmp(alltrials(t).ExpType, 'A')
%     allblocks = cfg.nblocks_partA;
% else
%     allblocks = cfg.nblocks_partB;
% end
allblocks = cfg.nblocks_partA+cfg.nblocks_partB;

      
%% display instructions or feedback, depending on trial position:

Screen('TextSize',window.Number,32);
if alltrials(t).trialid==.01 
% start of practice trials    
    if cfg.giveAudioFeedback==1
    showtext = [' Press any key to begin practice trials.'...
        '\n \n You will hear an error tone (beep), when incorrect'];
    else
        showtext = [' Press any key to begin practice block.'...
            '\n \n <b> Block: ' num2str(alltrials(t).blockcount*100) ' of ' num2str(cfg.nblocksprac) '<b>'];
    end
        
elseif alltrials(t).blockcount < 1
 
    showtext = ['Well done ! '...
        '\n \n Press any key to continue practice blocks...' ...
        '\n \n <b> Block: ' num2str(alltrials(t).blockcount*100) ' of ' num2str(cfg.nblocksprac) '<b>'];

        
  
    
elseif   alltrials(t).blockcount ==1
 % end of practice
    if cfg.giveAudioFeedback==1    
    showtext = [' End of practice. \n \n Press any key to begin experiment.'...
        '\n \n You will no longer hear error tones when incorrect' ...
        '\n \n Next block: ' num2str(alltrials(t).blockcount) ' of ' num2str(allblocks) ','...
        '\n \n ' num2str(cfg.ntrials) ' trials until next break'];    
    else
         showtext = [' End of practice. '...
             ' \n \n  <b> <color=.7,.7,1,> Now, for the real experiment,' ...
             '\n increase your speed and respond as fast',...
             '\n as you can. <b><color>'...
        '\n \n <b> Next block: ' num2str(alltrials(t).blockcount) ' of ' num2str(allblocks) ','...
        '\n \n ' num2str(cfg.ntrials) ' trials until next break <b>',...
        '\n <color=.7,.7,1,> Remember: <b>increase<b> your speed <color>',... 
   '\n  Press any key to begin.'];
    end
elseif    alltrials(t).blockcount >1 
    %if within experiment, calculate previous block accuracy, and give
    %appropriate level of feedback:
    
    prevblockindex = (t-(cfg.ntrials)): t-1;       
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
    showtext = [' Take a short break. ' ...
        'Last block, you were too slow on ' sprintf('%2.f', (nmissed/cfg.ntrials*100)) '% of trials, \n \n',...
        'and answered '  sprintf('%2.f', (blockAcc*100)) '% correctly'...            
        '\n \n Next block ' num2str(alltrials(t).blockcount) ' of ' num2str(allblocks) ','...
        '\n \n ' num2str(cfg.ntrials) ' trials until next break'...
        '\n \n press any key to continue experiment.'];
    
    else % give verbal feedback to increase speed or accuracy (without using those terms)
        

        if blockAcc >= .90   || mRT >2 % if making less than 10% errors, speed them up.
         %%
            showtext = [' \n \n <b> <color=1,.7,.7,> That block, you were too slow. '...
                '\n Try to respond as quickly as possible. <b><color>'...  
                '\n \n Take a short break.' ...
            '\n \n Next block ' num2str(alltrials(t).blockcount) ' of ' num2str(allblocks) ','...
        '\n \n ' num2str(cfg.ntrials) ' trials until next break'...
          '\n\n <color=.7,.7,1,> Remember: <b>increase<b> your speed <color>',... 
        '\n \n press any key to continue experiment.'];
        
        elseif blockAcc <= .70 % too many errors, slow down!  
        
            showtext = [' \n  \n <b> <color=1,.7,.7,> Try to respond more carefully.  <b><color>'...                
            '\n \n Take a short break.  ' ...
            '\n \n  Next block ' num2str(alltrials(t).blockcount) ' of ' num2str(allblocks) ','...
        '\n \n ' num2str(cfg.ntrials) ' trials until next break'...
        '\n \n press any key to continue experiment.'];
        else %good performance:
            
            showtext = ['\n \n <color=.7,.7,1,> That block, your speed was just right <color>'...
             '\n \n Take a short break. \n'...     
            '\n \n Next block ' num2str(alltrials(t).blockcount) ' of ' num2str(allblocks) ','...
        '\n \n ' num2str(cfg.ntrials) ' trials until next break,'...
        '\n \n press any key to continue experiment.'];
        end
    end
    
    %display key results to experimenter:
    disp(['End of block ' num2str(alltrials(t).blockcount) ' of  ' num2str(allblocks)])
    disp(['Block Accuracy: ' num2str(blockAcc) ', block RT: ' num2str(mRT)])
   disp('------------------------------------------');

end

%% DrawFormattedText(window.Number, showtext ,'center', 'center', [255 255 255]);
DrawFormattedText2(showtext, 'win', window.Number , ...
    'xlayout', 'center', ...
    'sy', 'center', 'yalign', 'center', 'sx', 'center', 'xalign', 'center', 'baseColor', [255 255 255]);

Screen('Flip', window.Number);
%%
pause(1);
%make sure all Keys are released, before continuing, after key press.
KbWait([],[],GetSecs()+2);
collect_response(cfg.response, inf);
% keyd = NaN;


