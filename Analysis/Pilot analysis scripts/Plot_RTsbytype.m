%plot bar data (visual vs auditory RTs).
clear all
% cd('/Users/mdavidson/Desktop/dotstask- Vis+Audio EXP/Exp_output/DotsandAudio_behaviour')
cd('/Users/mdavidson/Desktop/dotstask- Vis+Audio EXP/Exp_output/DotsandAudio_behaviour/ver1')
basedir=pwd;
figdir= '/Users/mdavidson/Desktop/dotstask- Vis+Audio EXP/Figures';
pfols= dir([pwd filesep '*' '_p0*']);

ReactionTimesALL = nan(length(pfols),2);
CorErrcountsALL = nan(length(pfols),2);
ExperimentOrder = nan(length(pfols),1);
%
%%
%plots individual participant level histograms of RT, as well as Bar


% AA_Adjust_behavioural_output_data;


%%
close all
for ippant = 1:length(pfols)
    
    cd(basedir);
    cd(pfols(ippant).name);
    
    
   try cd('behaviour')
    %simply load final file.
     lfile = dir([pwd filesep '*final' '*']);    
    load(lfile.name);    
   catch
       cd ../
       lfile = dir([pwd filesep '*final' '*']);    
    load(lfile.name);    
   end
       
%%
    try  usetrials = alltrials_final;
    catch
        usetrials = alltrials;
    end
  %%  
    %store the experiment order for later plots.
    if cfg.xmodBlockTypes(1)==3 % audio 'VISUAL'        
    ExperimentOrder(ippant,1) =2;
    orderi = 'aud,vis';
    else
    ExperimentOrder(ippant,1) =1; % visual then AUDIO.
    orderi = 'vis,aud';
    end
    
    
    %2x2 conds to plot:
    xmodtype = lower({usetrials.stimtype});
    CORRorNO = double([usetrials.cor]);
    trialID = double([usetrials.trialid]);
    icount =1;
    
    clf
    
    for ic=1:4
        switch ic
            case 1 % visual correct
                sub_index1=find(contains(xmodtype, 'visual'));
                sub_indextmp1 = find(CORRorNO ==1);                
                
                tis = 'vis correct';
                
            case 2 %visual incorrect
                sub_index1=find(contains(xmodtype, 'visual'));
                sub_indextmp1 = find(CORRorNO ==0);
                
                tis = 'vis incorrect';
            case 3 %auditory correct
                sub_index1=find(contains(xmodtype, 'audio'));
                sub_indextmp1 = find(CORRorNO  ==1);
                
                tis = 'aud correct';
            case 4 %auditory incorrect
                sub_index1=find(contains(xmodtype, 'audio'));
                sub_indextmp1 = find(CORRorNO  ==0);
                tis = 'aud incorrect';
        end
        %include search limiter for all:
        sub_indextmp2 = find(trialID>=1); % exclude practice trials.
        
        %restrict to relevant trials.
        sub_index2 = intersect(sub_indextmp1, sub_indextmp2);
        
        useindex = intersect(sub_index1, sub_index2);
        
        thisRT = [usetrials(useindex).rt];
        
        % note that the RTs need to be adjusted based on modality type.
        % They are recorded in matlab as time since the stimulus
        % presentation began. So the screen flip time for dot stimuli, yet
        % for auditory stimuli, there is a delay.
        % Stimuli were ON (100ms), OFF (500ms), ON(100ms). Hence adjust by
        % 600ms, as the earliest response for tone comparison was after 600ms.
        % also, the sound card as a 180ms delay. .:. +780
        
        if ic>2 && ippant<5
            thisRT = thisRT-0.78;
        elseif ic>2 && ippant>=5
            thisRT = thisRT-.6;
        end
            
        
        ReactionTimesALL(ic,ippant) = nanmean(thisRT);
        CorErrcountsALL(ic, ippant) = length(thisRT);
        figure(1);
        if ic==1
%             clf;
            set(gcf, 'units', 'normalized', 'position', [0 0 .5 .5], 'color', 'w')

        end
        hold on
        subplot(2,2,icount)
        %%
%         hist(thisRT, 1000);
histogram(thisRT, 100)
        title(['participant ' num2str(ippant) ' ' tis ' (' orderi ')']);
        xlabel('RT (sec)');
        xlim([0 10]);
        ylims= get(gca, 'ylim');
        text(4, .5*ylims(2) , ['Median = ' sprintf('%.2f', mean(thisRT)) 's, n = ' num2str(length(thisRT))], 'fontsize', 15);
        icount=icount+1;
        set(gca, 'fontsize', 15);
    end
    
    cd(figdir)
    cd('RTs per participant, by stim type')
    set(gcf, 'color', 'w')
    %print
%     print('-dpng', ['participant ' num2str(ippant) ' correct and error RT distributions'])

clear alltrials*

end
%% can also plot mean across participants.
figure(2); clf;
set(gcf, 'units', 'normalized', 'position', [0 0 .3 .5], 'color', 'w')

mBar=nanmean(ReactionTimesALL,2); % mean across ppants
countsBar = nanmean(CorErrcountsALL,2);

mBar = [mBar(1:2)';mBar(3:4)'];
%stack for comparison.
bh=bar(mBar); hold on
bh(1).FaceColor = [0 .7 .4];
bh(2).FaceColor = [.7 0 .4];
hold on

legend('correct', 'incorrect', 'AutoUpdate', 'off')
ylabel('Reaction Time (seconds)');
set(gca, 'xticklabels', {'Visual', 'Auditory'})
set(gca, 'fontsize', 15)
%
stE= CousineauSEM(ReactionTimesALL');
stE=[stE(1:2);stE(3:4)];
eH= errorbar_groupedfit(mBar,stE);
set(gca, 'fontsize', 25);
ylim([0 1.5])


text(.75, .1, sprintf('%.01f', countsBar(1)), 'color', 'w','fontsize', 20, 'fontweight', 'bold')
text(1.05, .1, sprintf('%.01f', countsBar(2)), 'color', 'w','fontsize', 20, 'fontweight', 'bold')

text(1.75, .1, sprintf('%.01f', countsBar(3)), 'color', 'w','fontsize', 20, 'fontweight', 'bold')
text(2.05, .1, sprintf('%.01f', countsBar(4)), 'color', 'w', 'fontsize', 20, 'fontweight', 'bold')
%%
print('-dpng', 'Barchart summary')

%%


