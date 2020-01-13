% pilot_analysis_Trialexplore
% This is the first script post eeglab gui. 
% looking to compare subtle trial differences which are too difficult to do
% in eeglab.
clear all
close all

%select which jobs to perform
job.restrictBehdata                       =1;  % according to epoch rejection.
job.plotERN_byEXPorder                    =1;  % plot ppant level ERN for exp halves. 

job.plotBeh_data                          =1;





%%change to EEG directory.
ppant=1;

cd('/Users/mdavidson/Desktop/dotstask- Vis+Audio EXP');
basedir=pwd;
%% find ppant EEG file.
pfile = dir([pwd filesep 'p' num2str(ppant) '_preproc_final.set']);

%load that participants EEG file.
EEG=pop_loadset(pfile(1).name, pwd);


if job.restrictBehdata                      ==1  % according to epoch rejection.
%we need to create a table with the relevant participant information, after
%accounting for the trials which were rejected based on EEG preprocessing.

%% we can load the EEG history as a text file. Scan it for the pop_rejepoch
%command, then extract the trials.
EEGh= EEG.history;
%
findme ='pop_rejepoch( EEG, [';
rejl = strfind(EEGh, findme);
%numbers start at the end of this index.
% find the next closed bracket.
EEGh2 = EEGh(rejl:end);
rejEp_end = strfind(EEGh2, ']'); 
%now we can extract the string of rejected epoch indices.
rejind = EEGh(1,rejl:rejEp_end+rejl);
%extract only numbers:
rejected_trials= string(regexp(rejind, '\d*', 'match'));

%% reorient to behavioural data directory
cd(basedir);
cd ('Exp_output');
cd('DotsandAudio_behaviour');
%% find participant behaviour dir.
p_behfile = dir([pwd filesep '*_' num2str(ppant) ]);
cd(p_behfile(1).name);
cd('behaviour');
%% load the final behaviour:
loadme = dir([pwd filesep '*_final.mat']);
load(loadme(1).name);

%restrict data to only those retained trials, with data.
availabletrials = length([alltrials(:).VBLtime_starttrial]);
allpos = 1:availabletrials-1;
%%
allpos(str2double(rejected_trials)) =[]; % remove rejected trials
alltrials_EEG = alltrials(allpos);
%%
%convert to table for easy processing.
%need to remove some columns 
alltrials_EEG = rmfield(alltrials_EEG, 'break');
alltrials_EEGtab = struct2table(alltrials_EEG);

%%
save(loadme(1).name, 'alltrials_EEGtab', 'rejected_trials', '-append');

end

%% plotting ERP by BEH / Exp type.
if job.plotERN_byEXPorder ==1   
   % 
   searchparts = {'A', 'B'};
   for ipart = 1:2
       
       %search parameters separately.       
   parttrials = find(strcmp(alltrials_EEGtab.ExpType, searchparts{ipart}));
   
   errortrials = find(alltrials_EEGtab.cor== 0);
   correcttrials = find(alltrials_EEGtab.cor== 1);
   
   partCorrect = intersect(parttrials, correcttrials);
   partIncorrect = intersect(parttrials, errortrials);
   
   
   switch ipart
       case 1
           partA_Cor = partCorrect;
           partA_Incor = partIncorrect;
       case 2
           partB_Cor = partCorrect;
           partB_Incor = partIncorrect;
   end
    
   end
   
   %% prepare datatypes for plotting results
   mpA_Cor = squeeze(nanmean(EEG.data(:,:,partA_Cor),3));
   mpB_Cor = squeeze(nanmean(EEG.data(:,:,partB_Cor),3));
   mpA_InCor = squeeze(nanmean(EEG.data(:,:,partA_Incor),3));
   mpB_InCor = squeeze(nanmean(EEG.data(:,:,partB_Incor),3));
   mA_diff = mpA_InCor-mpA_Cor;
   mB_diff = mpB_InCor-mpB_Cor;
   
   %%
   
   for ipart = 1:2
       switch ipart
           case 1
               d1=mpA_Cor;
               d2=mpA_InCor;
               d3=mA_diff;
           case 2
               d1=mpB_Cor;
               d2=mpB_InCor;
               d3=mB_diff;
       end
       
       %filter each and then concatenate for plotting.
       filtd1 = ft_preproc_lowpassfilter(d1, EEG.srate, 10);
       filtd2 = ft_preproc_lowpassfilter(d2, EEG.srate, 10);
       filtd3 = ft_preproc_lowpassfilter(d3, EEG.srate, 10);
       
       
       plotdata = cat(3, filtd1, filtd2, filtd3);
       
       %%
       figure(ipart); clf;
       set(gcf, 'units', 'normalized', 'position', [0 .5 .5 1])
       
       plottopo(plotdata, 'chanlocs', EEG.chanlocs,...
           'colors', {'b', 'r', 'k'});
       
   end
   %%
   barA = [mean([alltrials_EEG(partA_Cor).rt]), mean([alltrials_EEG(partA_Incor).rt])];
   barB = [mean([alltrials_EEG(partB_Cor).rt]), mean([alltrials_EEG(partB_Incor).rt])];
   
   figure(3); 
   subplot(121);
   bar(barA);
   set(gca, 'xtick', {'correct', 'incorrect'})
   subplot(122);
   bar(barB);
   
end