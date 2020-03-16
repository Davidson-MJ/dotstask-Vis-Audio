figure(1); 
clf
dbstop if error
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
set(gcf, 'units', 'normalized', 'position', [0 2 .4 .25])
%%

if strcmpi((cfg.stimTypes{2}),'visual')
    colnow = viscolour; else; colnow = audcolour;
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

title(['Participant ' num2str(ippant) ' Confidence in ' cfg.stimTypes{2} ' trials ']);
hold on;
set(gcf, 'color', 'w')

%% can also plot the results of Info seeking behaviour, if it occurred.
% 
% %trials where no choice was given:
% ForcedOpt = find([alltrials(startB:endB).InfoOption] ==0); 
% Choiceavail = find([alltrials(startB:endB).InfoOption] ==1); 
% 
% %choice on all trials:
% ChoiceOpt= [alltrials(startB:endB).ISeek];
% 
% ReviewOpt = find(ChoiceOpt ==1);
% 
% %we need the unique characters choose 0 and no option, to give us the
% %'chosen respond now' option.
% RespondOpt = find(ChoiceOpt ==0);
% 
% %We already have the forced choice, so now find choosing to respond.
% ChosenRespOpt = intersect(Choiceavail, RespondOpt);
% 
% % Choose review, choose respond, forced respond)
% ConfData.INDEX_Correct= CORid;
% ConfData.INDEX_Error= ERRid;
% ConfData.INDEX_ReviewbyChoice = ReviewOpt;
% ConfData.distrib_ReviewbyChoice = ConfData.confj(ReviewOpt);
% 
% ConfData.INDEX_RespondbyChoice = ChosenRespOpt;
% ConfData.distrib_RespondbyChoice = ConfData.confj(ChosenRespOpt);
% 
% ConfData.INDEX_ForcedChoice =ForcedOpt;
% ConfData.distrib_ForcedChoice = ConfData.confj(ForcedOpt);
% 
% 
% 
% 
% % also show by choice:
% 
% subplot(2,1,2)
% dataX=[];
% dataX{1} = abs(ConfData.confj(ConfData.INDEX_RespondbyChoice))+45;
% dataX{2} = abs(ConfData.confj(ConfData.INDEX_ReviewbyChoice))+45;
% dataX{3} = abs(ConfData.confj(ConfData.INDEX_ForcedChoice))+45;
% 
% 
% 
% h=rm_raincloud(dataX', cmap([18],:), 1, 'ks', 2);
% xlabel('Confidence judgement')
% ylabel('Response')
% set(gca, 'yticklabels', {['Forced response'] , ['Review by choice'], ['Respond by choice']}, 'fontsize', 16)
% %  xlim([0 100]) 
% title(['Confidence in ' cfg.stimTypes{2} ' trials ']);
% hold on;
% set(gcf, 'color', 'w')
% shg
% % save('Confidence output summary', 'ConfData');

% %% print output.
cd(homedir)
cd('Figures')
cd('Confidence plots')
print('-dpng', ['Participant ' num2str(ippant) ', confidence in ' cfg.stimTypes{2} ', ver ' num2str(Expver)]) 
% %%
% %% store for  across participant averaging:
% Confidence_byChoice(ippant, 1) = squeeze(mean(dataX{1}));
% Confidence_byChoice(ippant, 2) = squeeze(mean(dataX{2}));
% Confidence_byChoice(ippant, 3) = squeeze(mean(dataX{3}));
