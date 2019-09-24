%% collect last questionnaire
%questionnaire


%save final file.
save([ppantsavedir '/behaviour/' subject.fileName '_final'],'alltrials', 'cfg', 'subject', 't', 'UD')

%% display instructions


Screen('TextSize',window.Number,32);

showtext = ' All done! \n \n Thank you for participating :) ';

DrawFormattedText(window.Number, showtext ,'center', 'center', [255 255 255]);
Screen('Flip', window.Number);

% wait till release of all keys, then a single stroke.
KbWait([],2)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Thanks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% close PTB
Screen('CloseAll');
ListenChar(0);
DisableKeysForKbCheck([]);
ShowCursor()
Priority(0);

