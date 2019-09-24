
     
showtext = ['Escape key-pressed, please call the experimenter'];
     
disp('---------------------------');
disp('---------------------------');
disp('-----ESCAPE PRESSED--------');
disp(['% % restart trial on t= ' num2str(t-1)]);
disp('---------------------------');
disp('---------------------------');


%save current file.
save([ppantsavedir '/behaviour/' subject.fileName '_quit_on_trial' num2str(t)],'alltrials', 'cfg', 'subject', 't', 'UD')

%% display instructions


Screen('TextSize',window.Number,32);
DrawFormattedText(window.Number, showtext ,'center', 'center', [255 255 255]);
Screen('Flip', window.Number);

ShowCursor
