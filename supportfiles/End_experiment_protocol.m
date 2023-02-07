%% collect last questionnaire
%questionnaire


cd(ppantsavedir)
%save final file.
if t>partBstart
    UpDownStruct_partB=UD;
    
    save([subject.fileName '_final'],'alltrials',...
    'cfg', 'subject', 't', 'UpDownStruct_partB', 'UpDownStruct_partA')
else
    if ~exist('UpDownStruct_partA', 'var')
        UpDownStruct_partA = UD;
    end
    
save([ subject.fileName '_final'],'alltrials',...
    'cfg', 'subject', 't', 'UpDownStruct_partA')
    
end

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

