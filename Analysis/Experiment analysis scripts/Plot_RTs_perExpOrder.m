%Plot_RTs_perExpOrder

%called from JOBS_BehaviouralAnalysis.
%plots summary distributions of RTs.
% Plots:
%    PFX. 2x2 histograms (part A/B, Correct/Error).    
%    Grand total (partA Corr and Err, partB Corr and Err)
%    Split by order (V-A: CandE, A-V: CandE). 


ReactionTimesALL = [];
CorErrcountsALL = nan(2,length(pfols));
ExperimentOrder = nan(length(pfols),1);
%%

cd(behdatadir)


fontsizeX=25;
%separate into Aud and Visual.
cmap = cbrewer('qual', 'Paired',10);
colormap(cmap)
viscolour = cmap(3,:);
audcolour=cmap(9,:);
% correct=cmap(4,:); %greenish
% error =cmap(6,:); %reddish

%%
close all
figure(1);
clf;
set(gcf, 'units', 'normalized', 'position', [0 0 .75 .75], 'color', 'w')
        
for ippant = 1:length(pfols)
    
    cd(behdatadir);
    cd(pfols(ippant).name);
    
    
    
    lfile = dir([pwd filesep '*final' '*']);
    
    load(lfile.name);
    %use file name for debugging plots
    pname = ['p_' subject.id];
    
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
    
    st=suptitle(['Participant ' pname ]);
    st.Interpreter = 'none';
    st.FontSize= 18;
    st.FontWeight= 'bold';
        
    %cycle through part A cor, err, then part B cor, err.    
    for ic=1:4
        switch ic
            case 1 % part A correct
                
                sub_index1= find(ismember(ordertype, 'A'));
                sub_indextmp1 = find(CORRorNO ==1);                
                
                tis = ['part A correct (' ExpOrder{1} ')'];
                currentx = ExpOrder{1};
                
            case 2 %part A incorrect
                sub_index1= find(ismember(ordertype, 'A'));     
                sub_indextmp1 = find(CORRorNO ==0);
                
                tis = ['error (' ExpOrder{1} ')'];
            case 3 %partB correct
                sub_index1= find(ismember(ordertype, 'B'));
                sub_indextmp1 = find(CORRorNO  ==1);
                
                tis = ['part B correct (' ExpOrder{2} ')'];
                currentx = ExpOrder{2};
            case 4 %partB incorrect
                sub_index1= find(ismember(ordertype, 'B'));
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
        
        
        % note that the RTs need to be adjusted based on modality type.
        % They are recorded in matlab as time since the stimulus
        % presentation began. So the screen flip time for dot stimuli, 
        % but mouse click collection doesn't begin for cfg.durstim.
        % 
        % For auditory stimuli, there is also a delay.
        % AUDIO Stimuli were ON (100ms), OFF (500ms), ON(100ms). Hence adjust by
        % 600ms, as the earliest response for tone comparison was after 600ms.
        % also, the sound card as a 180ms delay. .:. +780 (?)
        
        %remove RTs > 5s.        
        thisRT = thisRT(thisRT<5);
        
        %adjust auditory RTs
        if strcmp(currentx, 'audio')        
            %remove implausible values, RTs recorded before second tone begins.
            thisRT = thisRT(thisRT>.6);
            
            %now adjust to start RT after second tone ONSET.
            thisRT = thisRT-.6;

        end
            
        
        ReactionTimesALL(ic,ippant).mean = nanmean(thisRT);
        ReactionTimesALL(ic,ippant).all = [thisRT];
        CorErrcountsALL(ic, ippant) = length(thisRT);
        
        
        
        hold on
        subplot(2,2,icount)
     
        histogram(thisRT, 100)
        
        title({[tis]; ['Median = ' sprintf('%.2f', mean(thisRT)) 's, n = ' num2str(length(thisRT))]})
        xlabel('RT (sec)');
        ylims= get(gca, 'ylim');
        
        
        icount=icount+1;
        set(gca, 'fontsize', 12);
    end
    %%
    cd(figdir)
    cd('RTs per participant, by stim type')
    set(gcf, 'color', 'w')
    %print
    print('-dpng', ['participant ' num2str(ippant) ' ' pname ' correct and error RT distributions'])

clear usetrials*

end
%% can also plot mean across participants.

%%
clf;
set(gcf, 'units', 'normalized', 'position', [0 0 .75 .75], 'color', 'w')

%use indexing which matches the order of ppant processing above:
vis_first = find(ExperimentOrder==1);
aud_first = find(ExperimentOrder==2);

% vis_first= [13:18]; % this is the RT fixed subset.


% partA_vis = partA(vis_first,:);
% partA_aud = partA(aud_first,:);
% 
% partB_vis = partB(aud_first,:);
% partB_aud = partB(vis_first,:);

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
legend('correct', 'incorrect')
ylabel('RT (sec.)');
set(gca, 'xticklabels', {[expo{1}], [ expo{2}]})

%
title(['Order: ' expo{1} '-' expo{2} ', n' num2str(size(barDD,2))]);

stE=[stE(1:2);stE(3:4)];
eH= errorbar_groupedfit(mBar,stE);
set(gca, 'fontsize', 15);
ylim([0 max(max(mBar))+.4])

% ttests
[~, p1] = ttest(barDD(1,:), barDD(2,:));
[~, p2] = ttest(barDD(3,:), barDD(4,:));

%%
if p1<.001
    psig= '***';
elseif p1<.01
    psig= '**';
elseif p1<.05
    psig ='*';
else 
    psig= 'ns';
end
    
    text(1, (max(mBar(1,:)) +.1), psig, 'fontsize', 25)
%%
if p2<.001
    psig= '***';
elseif p2<.01
    psig= '**';
elseif p2<.05
    psig ='*';
end
%place
text(2, (max(mBar(2,:)) +.1), psig, 'fontsize', 25)


%also distributions per.   
   %%
   subplot(4,2,2)
   hdata = ([ReactionTimesALL(1,vis_first).all]);   
   hd=histogram(hdata,100);
   hd.FaceColor = [0 .7 .4];
   xlim([0 5])

   title('A correct')
   subplot(4,2,4)
   hdata = ([ReactionTimesALL(2,vis_first).all]);   
   hd=histogram(hdata,100);
   hd.FaceColor = [.7 0 .4];
    xlim([0 1.5])
   title('A error')
   xlim([0 5])
   
   subplot(4,2,6)
   hdata = ([ReactionTimesALL(3,vis_first).all]);   
   hd=histogram(hdata,100);
   title('B correct')
   hd.FaceColor = [0 .7 .4];
   xlim([0 5])

   subplot(4,2,8)
   hdata = ([ReactionTimesALL(4,vis_first).all]);   
   hd=histogram(hdata,100);
   hd.FaceColor = [.7 0 .4];
    xlim([0 5]) 
   title('B error')
end
   %
print('-dpng', ['summary RTs, Order ' expo{1} '-' expo{2} ', n' num2str(length(barDD))])

shg


%% raincloud option:

clf;
set(gcf, 'units', 'normalized', 'position', [0 0 .8 .8], 'color', 'w')

for ipart= 1:2;
    if ipart==1 % part A
        Xdata=[[ReactionTimesALL(1,vis_first).mean]',[ReactionTimesALL(2,vis_first).mean]'];
        expo = {'correct', 'error'};
        tis = 'Part A: Visual';
        xlimsr= [0 1];
    else
        Xdata=[[ReactionTimesALL(3,vis_first).mean]',[ReactionTimesALL(4,vis_first).mean]'];
        expo = {'correct','error'};
        tis = 'Part B: auditory';
        xlimsr= [0 2];
        
    end
    
    subplot(1,2, ipart)
    
    [a,b]=CousineauSEM(Xdata);
    
    dataX{1} = b(:,1);
    dataX{2} = b(:,2);
    bh =rm_raincloud(dataX', [cmap(2,:)]);
    % change colours
    %patches:
    bh.p{1}.FaceColor = cmap(4,:); % green
    bh.p{2}.FaceColor = cmap(6,:); % redish
    %scatter:
    bh.s{1}.MarkerFaceColor = cmap(4,:); % green
    bh.s{2}.MarkerFaceColor = cmap(6,:); % redish
    
    
    %add plot specs
    set(gca, 'yticklabel', {[expo{2}], [ expo{1}]})
    title([tis])
%     axis tight
    xlim([xlimsr])
    
    
    %
    
    ytsare = get(gca, 'ytick');
    
    text(0.1, ytsare(1), ['\it M=\rm' sprintf('%.2f',mean(Xdata(:,2)))], 'fontsize', fontsizeX)
    text(0.1, ytsare(2), ['\it M=\rm' sprintf('%.2f',mean(Xdata(:,1)))], 'fontsize', fontsizeX)
    set(gcf, 'color', 'w');
    set(gca, 'fontsize', fontsizeX)
    set(gcf, 'color', 'w');
    set(gca, 'fontsize', fontsizeX)
    
    xlabel('RT (sec)')
    
%
% ttests
[~, p1] = ttest(Xdata(:,1), Xdata(:,2));

if p1<.001
    psig= '***';
elseif p1<.01
    psig= '**';
elseif p1<.05
    psig ='*';
else 
    psig= 'ns';
end
    
%rain clouds have weird axes:
yl= get(gca, 'ylim');
mY= (mean(ytsare));
sigheight= mean(Xdata(:)) +.4;
sigheight = xlimsr(2)*.9;

    ts=text(sigheight, mY, psig, 'fontsize', 45);
    ts.VerticalAlignment= 'middle';
    ts.HorizontalAlignment= 'center';
    hold on;
%     plot(xlim, [yl(1), yl(2)], ['k:' ]);
    plot([sigheight-.05, sigheight-.05], [ytsare(1), ytsare(2)], ['k-' ], 'linew', 2);

end