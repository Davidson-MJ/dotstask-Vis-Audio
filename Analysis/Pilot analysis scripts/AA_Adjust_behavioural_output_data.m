% ADJUST behavioural output tables, in case their was a crash.


clear all
cd('/Users/mdavidson/Desktop/dotstask- Vis+Audio EXP/Exp_output/DotsandAudio_behaviour')
basedir=pwd;
figdir= '/Users/mdavidson/Desktop/dotstask- Vis+Audio EXP/Figures';
pfols= dir([pwd filesep '*' '_p*']); 
%%
% 

for ippant =1:length(pfols)
cd(basedir);
    cd(pfols(ippant).name);
clf

%% check if quit key was pressed.

adjdata= dir([pwd filesep 'behaviour' filesep '*quit_on' '*.mat']);

if ~isempty(adjdata) && ippant ~=4
    % need to adjust table.
    cd('behaviour')
    load(adjdata.name, 'alltrials', 't');
    uptotrial = t;
    prevdata = alltrials(1:uptotrial);
    %load remaining data
    cd ../    
    lfile = dir([pwd filesep '*final' '*']);    
    load(lfile.name);
    %final data= 
    pf = alltrials(uptotrial+1:end); 
    %Now  we need to merge the tables.
    alltrials_final = [prevdata, pf];
    if length(alltrials_final)~= 780
        error('check trial adjustment');
    end
    %now save as appropriate.
    save(lfile.name, 'alltrials_final', '-append');
elseif ippant ~=4
    %simply load final file.
     lfile = dir([pwd filesep '*final' '*']);    
    load(lfile.name);    
     alltrials_final = alltrials;
     
     save(lfile.name, 'alltrials_final', '-append');
     
elseif ippant==4
    
    repair_Participant4_trials;
end

end

