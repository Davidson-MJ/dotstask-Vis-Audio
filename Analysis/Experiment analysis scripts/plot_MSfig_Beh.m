% plot_MSfig_Beh

%called from JOBS_BehaviouralAnalysis.
%plots raincloud distributions of accuracy, RT and conf, ready for paper.


job.concatData=1; %acc, rts, and conf.
job.plot_MSFig_Beh =1; % combined/tiled in one.


if job.concatData
% preallocate some variables
% Accuracy data

ExperimentOrder = zeros(length(pfols),1); % auditory or visual first
[Accuracy_byAorB, nErrors_byAorB, GFX_allConfD] = deal(zeros(length(pfols),2)); % Acc and Conf

RTs_byAorB = nan(4, length(pfols)); % A_correct, A_error, B_correct, B_error


    for ippant = 1:length(pfols)
        
        cd(behdatadir);
        cd(pfols(ippant).name);
        
        lfile = dir([pwd filesep '*final.mat']);
        lfile= striphiddenFiles(lfile);

        load(lfile.name);
        %% region (modality):
         
        %store the experiment order for later plots.
        ExpOrder = lower(cfg.stimTypes);
        %sort next into modality.
        if strcmp(ExpOrder{1}, 'visual')
            ExperimentOrder(ippant) =1;
            xmodd= 'auditory'; % the modality conf judgements were provided on
        else
            ExperimentOrder(ippant) =2;
            xmodd= 'visual'; % the modality conf judgements were provided on
        end
        
        %end region modality
        
        %% region (accuracy)
      
        %use file name for debugging plots
        pname = ['p_' subject.id];
        pnames{ippant} = pname;
        
        %we need to restrct the trials to only NON practice trials.
        usetrials=alltrials;
        isprac = find([alltrials.isprac]);
        usetrials(isprac)=[];
       
        
        %participant:
        startA = 1;
        endA = cfg.ntrials* cfg.nblocks_partA;
        startB=endA+1;
        endB = length(usetrials);
        
        alltrialsA= [usetrials(startA:endA).cor];
        alltrialsB= [usetrials(startB:endB).cor];
        %
        Aacc= sum(alltrialsA)./length(alltrialsA);
        Bacc= sum(alltrialsB)./length(alltrialsB);
        
        errorsA = length(alltrialsA) - sum(alltrialsA);
        errorsB = length(alltrialsB) - sum(alltrialsB);
        
        % store  Accuracy for  across participant averaging:
        Accuracy_byAorB(ippant, :) = [Aacc,Bacc];
        nErrors_byAorB(ippant,:) = [errorsA, errorsB];
       
         %end region accuracy
        
        %% region (RT)
         %2x2 conds to plot:
        xmodtype = lower({usetrials.stimtype});
        ordertype = {usetrials.ExpType};
        CORRorNO = double([usetrials.cor]);
        
        
        %cycle through part A cor, err, then part B cor, err.
        for ic=1:4
            switch ic
                case 1 % part A correct
                    
                    sub_index1= find(ismember(ordertype, 'A'));
                    sub_indextmp1 = find(CORRorNO ==1);
                    
                    currentx = ExpOrder{1};
                case 2 %part A incorrect
                    sub_index1= find(ismember(ordertype, 'A'));
                    sub_indextmp1 = find(CORRorNO ==0);
                    
                case 3 %partB correct
                    sub_index1= find(ismember(ordertype, 'B'));
                    sub_indextmp1 = find(CORRorNO  ==1);
                    currentx = ExpOrder{2};
                    
                case 4 %partB incorrect
                    sub_index1= find(ismember(ordertype, 'B'));
                    sub_indextmp1 = find(CORRorNO  ==0);                    
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
                
            else
                thisRT= thisRT-.2;
            end
            
            
            ReactionTimesALL(ic,ippant).mean = nanmean(thisRT);
%             ReactionTimesALL(ic,ippant).all = [thisRT];
%             CorErrcountsALL(ic, ippant) = length(thisRT);
%             
            RTs_byAorB(ic,ippant) = nanmean(thisRT);
          
        end        
        
        %end region RT
          
        %% region (Conf)
        
        
        %gather some useful experimental data information
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
        
        %     Confidence_summary_plot; %xmodd,pname used w/in.
        
        
        %now that we have the Conf data per participant, take z score and prep
        %for GFX.
        ppantz =zscore(ConfData.confj,1);
        
        GFX_allConfD(ippant,1) = nanmean(ppantz(ConfData.INDEX_Correct));
        GFX_allConfD(ippant,2) = nanmean(ppantz(ConfData.INDEX_Error));
        
        
        
        disp(['fin concat ppant ' num2str(ippant)]);
        %end region conf
    end

%% Now wrangle GFX per plot type        
%% Accuracy
        vis_first = find(ExperimentOrder==1);
        aud_first = find(ExperimentOrder==2); % have removed.
        
        partAAcc = Accuracy_byAorB(:,1);
        partBAcc = Accuracy_byAorB(:,2);
        
        partA_vis = partAAcc(vis_first,:);
        partA_aud = partAAcc(aud_first,:);
        
        partB_vis = partBAcc(aud_first,:);
        partB_aud = partBAcc(vis_first,:);
        
         Xdata_Acc=[partA_vis,partB_aud];
         
         expo = {'visual','auditory'};
   
%RTs:
         
Xdata_RTsA = [RTs_byAorB(1,vis_first)',RTs_byAorB(2,vis_first)'];
   Xdata_RTsB=[RTs_byAorB(3,vis_first)',RTs_byAorB(4,vis_first)'];

%Conf:
Xdata_Conf = GFX_allConfD;
end

%%
%%

   clf;
set(gcf, 'units', 'normalized', 'position', [0 0 1 .5], 'color', 'w')
set(gcf, 'units', 'normalized', 'position', [0 0 .5 1], 'color', 'w')

fontsizeX= 20;
%separate into Aud and Visual.
cmap = cbrewer('qual', 'Paired',10);
colormap(cmap)
viscolour = cmap(3,:);
audcolour=cmap(9,:);
%positions of subplot panels:
subSpots = [2,2,1; ...
    2,2,2; ...
    2,2,3; ...
    2,2,4];

plotData={Xdata_Acc,Xdata_RTsA,Xdata_RTsB, Xdata_Conf};%, Xdata_Conf};
titlesare ={'Accuracy', 'Visual RT', 'Auditory RT', 'Auditory Confidence'};
ylabels ={'proportion correct', 'seconds', 'seconds', 'z-scored confidence'};
ylimsare=[.4,1.1 ; .1 .45; .5 1.9; -3.5 3.5];
xtickdetails ={{'\bfVisual', '\bfAuditory'},...
    {'Correct', 'Error'},...
    {'Correct', 'Error'},...
    {'Correct', 'Error'}};


% plot_MSFig_Beh
%Acc, RTs, Conf 

for idtype=1:4
    subplot(subSpots(idtype,1),subSpots(idtype,2),subSpots(idtype,3));
    expo = xtickdetails{idtype};
   plotXdata=plotData{idtype};
   
    
    [a,b]=CousineauSEM(plotXdata);
    
    dataX{1} = b(:,1);
    dataX{2} = b(:,2);
    bh =rm_raincloud(dataX', [cmap(2,:)]);
   if idtype>1
    % change colours if RTs:
    % change colours
        %patches:
        bh.p{1}.FaceColor = cmap(4,:); % green
        bh.p{2}.FaceColor = cmap(6,:); % redish
        %scatter:
        bh.s{1}.MarkerFaceColor = cmap(4,:); % green
        bh.s{2}.MarkerFaceColor = cmap(6,:); % redish
   
       
   end
    %add plot specs
    xlabel(ylabels{idtype});
    set(gca, 'yticklabel', {[expo{2}], [ expo{1}]})    
    xlim(ylimsare(idtype,:)); % flipped!     
    
        
    ytsare = get(gca, 'ytick');
    title(titlesare{idtype})
%     text(.45, ytsare(1), ['\it M=\rm' sprintf('%.2f',mean(Xdata(:,2)))], 'fontsize', fontsizeX)
%     text(.45, ytsare(2), ['\it M=\rm' sprintf('%.2f',mean(Xdata(:,1)))], 'fontsize', fontsizeX)
    set(gcf, 'color', 'w');
    set(gca, 'fontsize', fontsizeX)
    set(gcf, 'color', 'w');
    set(gca, 'fontsize', fontsizeX)
    
    
if idtype==1
    hold on; plot([.5 .5], ylim, 'k:', 'linew', 3)
end
if idtype==3 % hide yticks
%     set(gca,'xtick', []);
%     axis off
%     xlabel('');
end


%add sig
        [~, p1] = ttest(plotXdata(:,1), plotXdata(:,2));
        
        if p1<.001
            psig= '***';
            textsz=40;
            textalgn='middle';
        elseif p1<.01
            psig= '**';
            textsz=40;
            textalgn='middle';
        elseif p1<.05
            psig ='*';
            textsz=40;
            textalgn='middle';
        else
            psig= 'ns';
            textsz=20;
            textalgn='bottom';
        end
        
        %rain clouds have weird axes:
        yl= get(gca, 'ylim');
        mY= (mean(ytsare));
        %place at base + 90% diff
        sigheight = ylimsare(idtype,1) + ...
            (ylimsare(idtype,2) - ylimsare(idtype,1)) *.9;
        
        ts=text(sigheight, mY, psig, 'fontsize', textsz);
        ts.VerticalAlignment= textalgn;
        ts.HorizontalAlignment= 'center';
        hold on;
        %     plot(xlim, [yl(1), yl(2)], ['k:' ]);
        plot([sigheight, sigheight], [ytsare(1), ytsare(2)], ['k-' ], 'linew', 1);
        
        disp(get(gca, 'ylim'))

end


  