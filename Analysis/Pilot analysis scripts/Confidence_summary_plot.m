%called from Plot_Confidencedistributons

% simply ourtsourcing a quick plot routine.
dbstop if error

%store the experiment order for later plots.
ExpOrder = lower(cfg.stimTypes);
if strcmp(ExpOrder{1}, 'visual')
    ExperimentOrder(ippant) = 1;
    xmodd = 'auditory'; % the modality conf jdgmnts were provided in
else
    ExperimentOrder(ippant) = 2;
    xmodd = 'visual'; % the modality conf jdgmnts were provided in
end



% gather some useful experimental data information
ConfData=[];
ConfData.modality = xmodd;
ConfData.stimdiff=UpDownStruct_partB.xCurrent;

%find the index of part B trials
npractr = cfg.ntrialsprac * cfg.nblocksprac;
% startA= npractr+1;
endA= (npractr+ cfg.nblocks_partA*cfg.ntrials);
startB= endA+npractr+1;
endB = startB+cfg.nblocks_partB*cfg.ntrials -1;

ConfData.cor1= [alltrials(startB:endB).cor];
% ConfData.cor2= [alltrials(startB:endB).confj_cor];
ConfData.confj= [alltrials(startB:endB).confj];

%also store subset (by errors vs correct).
CORid = find(ConfData.cor1);
ERRid = find(ConfData.cor1==0);

ConfData.INDEX_Correct= CORid;
ConfData.INDEX_Error= ERRid;

%% now plot! 
figure(1); clf;
set(gcf, 'units', 'normalized', 'position', [0 0 .5 .6])
%%
%set colour
if strcmpi((cfg.stimTypes{2}),'visual')
    colnow = viscolour; else colnow = audcolour;
end
%show  confidence by correct and error.
dataX=[];
if Expver==2
dataX{1} = (ConfData.confj(ConfData.INDEX_Correct));%+45;
dataX{2} = (ConfData.confj(ConfData.INDEX_Error));%+45;
elseif Expver==1
    dataX{1} = abs(ConfData.confj(ConfData.INDEX_Correct))+45;
    dataX{2} = abs(ConfData.confj(ConfData.INDEX_Error))+45;
end


h=rm_raincloud(dataX', colnow, 1, 'ks',2);
xlabel('Confidence judgement')
ylabel('Response')
%%
if Expver==2
set(gca, 'yticklabels',...
    {['Err,\it n\rm =' num2str(length(ERRid))...
    '\it, m\rm =' sprintf('%1.1f',mean(dataX{2}))],...
    ['Corr,\it n\rm =' num2str(length(CORid))...
    '\it, m\rm =' sprintf('%1.1f',mean(dataX{1}))]},...
    'xtick',[-55:10:55], 'xticklabels', {'100% sure wrong', [],[],[],[],'        50%',[], [], [],[],[],'100% sure correct' }, 'fontsize', 16)
 xlim([-60 60]) 
elseif  Expver==1
    set(gca, 'yticklabels',...
    {['Err,\it n\rm =' num2str(length(ERRid))...
    '\it, m\rm =' sprintf('%1.1f',mean(dataX{2}))],...
    ['Corr,\it n\rm =' num2str(length(CORid))...
    '\it, m\rm =' sprintf('%1.1f',mean(dataX{1}))]},...
    'fontsize', 16)
     xlim([40 110]) 
end
%%

title(['Participant ' num2str(ippant) ' ' pname ' Confidence in partB ' ExpOrder{2} ' trials '], 'Interpreter', 'none');
hold on;
set(gcf, 'color', 'w')

% %% print output.
cd(figdir)
cd('Confidence plots')
print('-dpng', ['Participant ' num2str(ippant) ' ' pname ', confidence in partB ' ExpOrder{2} ]) 

%