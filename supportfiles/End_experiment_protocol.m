%% collect last questionnaire
%questionnaire

%% save temporary final file
save([results_path subject.dir '/behaviour/' subject.fileName '_' num2str(round(t/20))],'trials', 'cfg', 't');

%% collect estimated observers accuracy
%trials(t).estim_obsacc = estimated_obsacc(Sc,cfg);

%% save final file
save([results_path subject.dir '/behaviour/' subject.fileName '_final'],'subject','cfg','trials');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Thanks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

insimdata = imread(char('instructions/instr22.jpg'));
texins = Screen('MakeTexture', Sc.window, insimdata);
Screen('DrawTexture', Sc.window, texins);
Screen('Flip',Sc.window);

% end of the experiment tone
Beeper(261.63,.4,1);
WaitSecs(.500);
KbWait;

%% close PTB
Screen('CloseAll');
ListenChar(0);
DisableKeysForKbCheck([]);
ShowCursor()
Priority(0);
toc
