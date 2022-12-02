
     
showtext = ['Escape key-pressed, please call the experimenter'];
     


%when was the previous break, that is when we should restart from, to
%recover an entire block.

lastbreak = find([alltrials(1:(t-1)).break],1, 'last');
%define block trials.
blockt= lastbreak:(t-1);

disp('---------------------------');
disp('---------------------------');
disp('-----ESCAPE PRESSED--------');

disp(['---  Quit on trial ' num2str(length(blockt)) ', in block  ' num2str(floor(lastbreak/cfg.ntrials))]) 
% disp(['% % restart trial on t= ' num2str(t-1)]);

disp(['% % restart trial on t= ' num2str(lastbreak)]);
disp('---------------------------');
disp('---------------------------');
%%

%save current file.
save([ppantsavedir '/behaviour/' subject.fileName '_quit_on_trial' num2str(t)  ', in block  ' num2str(floor(lastbreak/cfg.ntrials))],'alltrials', 'cfg', 'subject', 't', 'UD')

%% display instructions


Screen('TextSize',window.Number,32);
DrawFormattedText(window.Number, showtext ,'center', 'center', [255 255 255]);
Screen('Flip', window.Number);
pause(1);
ShowCursor
