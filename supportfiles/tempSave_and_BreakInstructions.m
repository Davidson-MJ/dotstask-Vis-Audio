% tempSave_and_BreakInstructions

%-- Save data every 20th trials
%         savepath= [savedir
save([ppantsavedir '/behaviour/' subject.fileName '_' num2str(round(t/20))],'alltrials', 'cfg', 'subject', 't')
%-- break

%display instructions

Screen('TextSize',window.Number,32);
if alltrials(t).trialid==.01 % start practice trials
    showtext = [' Press any button to begin practice trials.'...
        '\n \n You will hear an error tone (beep), when incorrect'];
elseif alltrials(t).blockcount < 1
    showtext = [' Press any button to continue practice trials'];
elseif   alltrials(t).blockcount ==1
    showtext = [' End of practice. \n \n press any button to begin experiment.'...
        '\n \n You will no longer hear error tones when incorrect' ...
        '\n \n Next block ' num2str(alltrials(t).blockcount) ' of ' num2str(max([alltrials(:).blockcount])) ','...
        '\n \n ' num2str(cfg.ntrials) ' trials until next break'];
    
elseif    alltrials(t).blockcount >1
    showtext = [' Take a short break. \n \n press any button to continue experiment.'...];
        '\n \n Next block ' num2str(alltrials(t).blockcount) ' of ' num2str(max([alltrials(:).blockcount])) ','...
        '\n \n ' num2str(cfg.ntrials) ' trials until next break'];
end

DrawFormattedText(window.Number, showtext ,'center', 'center', [255 255 255]);
Screen('Flip', window.Number);
collect_response(cfg.response, inf);

