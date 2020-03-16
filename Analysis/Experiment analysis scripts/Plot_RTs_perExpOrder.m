%plot bar data (visual vs auditory RTs).
%called from JOBS_BehaviouralAnalysis
ReactionTimesALL = [];%nan(4,length(pfols));
CorErrcountsALL = nan(2,length(pfols));
ExperimentOrder = nan(length(pfols),1);
%%

cd(behdatadir)

%preallocate some variables
% ExperimentOrder = zeros(length(pfols),1); % auditory or visual first
% Accuracy_byAorB = zeros(length(pfols),2); % first and second half


fontsizeX=25;
%separate into Aud and Visual.
cmap = cbrewer('qual', 'Paired',10);
colormap(cmap)
viscolour = cmap(3,:);
audcolour=cmap(9,:);
%%
%plots individual participant level histograms of RT, as well as Bar


% AA_Adjust_behavioural_output_data;


%%
close all
for ippant = 1:length(pfols)
    
    cd(behdatadir);
    cd(pfols(ippant).name);
    lfile = dir([pwd filesep '*final' '*']);
    
    load(lfile.name);
    
    clf;
    %we need to restrct the trials to only NON practice trials.
    usetrials=alltrials;
    isprac = find([alltrials.isprac]);
    usetrials(isprac)=[];
    
    %store the experiment order for later plots.
    ExpOrder = lower(cfg.stimTypes);
    
    %2x2 conds to plot:
    xmodtype = lower({usetrials.stimtype});
    ordertype = {usetrials.ExpType};
    CORRorNO = double([usetrials.cor]);
    trialID = double([usetrials.trialid]);
    icount =1;
    
    clf
    %cycle through part A cor, err, then part B cor, err.    
    for ic=1:4
        switch ic
            case 1 % part A correct
                
                sub_index1=find(contains(ordertype, 'A'));
                sub_indextmp1 = find(CORRorNO ==1);                
                
                tis = {['Participant ' num2str(ippant) ];['part A correct (' ExpOrder{1} ')']};
                currentx = ExpOrder{1};
                
            case 2 %part A incorrect
                sub_index1=find(contains(ordertype, 'A'));
                sub_indextmp1 = find(CORRorNO ==0);
                
                tis = ['error (' ExpOrder{1} ')'];
            case 3 %auditory correct
                sub_index1=find(contains(ordertype, 'B'));
                sub_indextmp1 = find(CORRorNO  ==1);
                
                tis = ['part B correct (' ExpOrder{2} ')'];
                currentx = ExpOrder{2};
            case 4 %auditory incorrect
                sub_index1=find(contains(ordertype, 'B'));
                sub_indextmp1 = find(CORRorNO  ==0);
                tis = ['error (' ExpOrder{2} ')'];
        end
        
        if strcmp(ExpOrder{1}, 'visual')
            ExperimentOrder(ippant) = 1;
        else
            ExperimentOrder(ippant) = 2;
        end
%%
        %restrict to relevant trials.        
        useindex = intersect(sub_index1, sub_indextmp1);
        
        thisRT = [usetrials(useindex).rt];
        
        %remove implausible values
        thisRT = thisRT(thisRT<2);
        
        % note that the RTs need to be adjusted based on modality type.
        % They are recorded in matlab as time since the stimulus
        % presentation began. So the screen flip time for dot stimuli, 
        % but mouse click collection doesn't begin for cfg.durstim
        % for auditory stimuli, there is also a delay.
        % AUDIO Stimuli were ON (100ms), OFF (500ms), ON(100ms). Hence adjust by
        % 600ms, as the earliest response for tone comparison was after 600ms.
        % also, the sound card as a 180ms delay. .:. +780
%         
        if strcmp(currentx, 'visual')            
            
%             thisRT = thisRT;            
            
        elseif strcmp(currentx, 'audio')        
            
            thisRT = thisRT-.78;
        end
            
        
        ReactionTimesALL(ic,ippant).mean = nanmean(thisRT);
        ReactionTimesALL(ic,ippant).all = [thisRT];
        CorErrcountsALL(ic, ippant) = length(thisRT);
        figure(1);
        if ic==1
%             clf;
            set(gcf, 'units', 'normalized', 'position', [0 0 .5 .5], 'color', 'w')

        end
        hold on
        subplot(2,2,icount)
     
            histogram(thisRT, 100)
        title(tis );
        xlabel('RT (sec)');
        xlim([0 2]);
        ylims= get(gca, 'ylim');
        text(1, .5*ylims(2) , ['Median = ' sprintf('%.2f', mean(thisRT)) 's, n = ' num2str(length(thisRT))], 'fontsize', 15);
        icount=icount+1;
        set(gca, 'fontsize', 15);
    end
    %%
    cd(figdir)
    cd('RTs per participant, by stim type')
    set(gcf, 'color', 'w')
    %print
    print('-dpng', ['participant ' num2str(ippant) ' correct and error RT distributions'])

clear usetrials*

end
%% can also plot mean across participants.
figure(2); clf;
set(gcf, 'units', 'normalized', 'position', [0 0 .3 .5], 'color', 'w')
tmp= [ReactionTimesALL.mean];
tmpM= reshape(tmp, [4, length(pfols)]);
mBar=nanmean([tmpM],2); % mean across ppants
countsBar = nanmean(CorErrcountsALL,2);

%show all A vs B.
mBar = [mBar(1:2)';mBar(3:4)'];

%stack for comparison.
bh=bar(mBar); hold on
bh(1).FaceColor = [0 .7 .4];
bh(2).FaceColor = [.7 0 .4];
hold on
%%
legend('correct', 'incorrect', 'AutoUpdate', 'off')
ylabel('Reaction Time (seconds)');
set(gca, 'xticklabels', {'Part A', 'Part B'})
set(gca, 'fontsize', 15)
%
stE= CousineauSEM(ReactionTimesALL');
stE=[stE(1:2);stE(3:4)];
eH= errorbar_groupedfit(mBar,stE);
set(gca, 'fontsize', 25);
ylim([0 1])


text(.75, .1, sprintf('%.01f', countsBar(1)), 'color', 'w','fontsize', 20, 'fontweight', 'bold')
text(1.05, .1, sprintf('%.01f', countsBar(2)), 'color', 'w','fontsize', 20, 'fontweight', 'bold')

text(1.75, .1, sprintf('%.01f', countsBar(3)), 'color', 'w','fontsize', 20, 'fontweight', 'bold')
text(2.05, .1, sprintf('%.01f', countsBar(4)), 'color', 'w', 'fontsize', 20, 'fontweight', 'bold');

title('Grand average reaction times')
%%
print('-dpng', 'Barchart summary, grand average RTs')

%% now separate by modality:

%% now separate by order

%%
clf;
set(gcf, 'units', 'normalized', 'position', [0 0 .6 .5], 'color', 'w')

for iorder = 1%:2
    
 if iorder==1
     barDD = tmpM(:,vis_first);
     stE= CousineauSEM(tmpM(:,vis_first)');
     expo = {'visual','auditory'};
 else
     barDD = tmpM(:,aud_first);
     stE= CousineauSEM(tmpM(:,aud_first)');
     expo = {'auditory','visual'};
 end
mBar= nanmean(barDD,2);

%plot A vs B this order subset
%show all A vs B.
mBar = [mBar(1:2)';mBar(3:4)'];

subplot(1,2,iorder);
%stack for comparison.
bh=bar(mBar); hold on
bh(1).FaceColor = [0 .7 .4];
bh(2).FaceColor = [.7 0 .4];
hold on
%
legend('correct', 'incorrect', 'AutoUpdate', 'off')
ylabel('RT (sec.)');
set(gca, 'xticklabels', {['Part A ' expo{1}], ['Part B ' expo{2}]})
set(gca, 'fontsize', 15)
%
title([expo{1} '-' expo{2} ', \itn= \rm' num2str(size(barDD,2))]);

stE=[stE(1:2);stE(3:4)];
eH= errorbar_groupedfit(mBar,stE);
set(gca, 'fontsize', 25);
ylim([0 1])

%% ttests
[~, p1] = ttest(barDD(1,:), barDD(2,:));
[~, p2] = ttest(barDD(3,:), barDD(4,:));

if p1<.05
    text(1, (mean(mBar(1,:)) +.1), 'o', 'fontsize', 25)
end
   if p2<.05 
    text(2, (mean(mBar(2,:)) +.1), 'o', 'fontsize', 25)
   end
%also distributions per.   
   %%
   subplot(4,2,2)
   hdata = ([ReactionTimesALL(1,vis_first).all]);   
   hd=histogram(hdata,100);
   hd.FaceColor = [0 .7 .4];
   xlim([0 1.5])
   title('A correct')
   subplot(4,2,4)
   hdata = ([ReactionTimesALL(2,vis_first).all]);   
   hd=histogram(hdata,100);
   hd.FaceColor = [.7 0 .4];
   xlim([0 1.5])
   title('A error')
   
   subplot(4,2,6)
   hdata = ([ReactionTimesALL(3,vis_first).all]);   
   hd=histogram(hdata,100);
   title('B correct')
   hd.FaceColor = [0 .7 .4];
   xlim([0 1.5])
   subplot(4,2,8)
   hdata = ([ReactionTimesALL(4,vis_first).all]);   
   hd=histogram(hdata,100);
   hd.FaceColor = [.7 0 .4];
   xlim([0 1.5])
   title('B error')
end
   %%
print('-dpng', 'Barchart summary, grand average RTs split by order')
