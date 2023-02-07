%Plot_RTs_perExpOrder

%called from JOBS_BehaviouralAnalysis.
%plots summary distributions of RTs.
% Plots:
%    PFX. 2x2 histograms (part A/B, Correct/Error).
%    Grand total (partA Corr and Err, partB Corr and Err)
%    Split by order (V-A: CandE, A-V: CandE).


jobs=[];

jobs.concat_RT=1; %prepare for plots.

jobs.plotPFX_RT =0; % per ppant

jobs.plotGFX_RT =1 ; %tidy (raincloud) GFX

%%

cd(behdatadir)

%fig specifics:
fontsizeX=25;
%separate into Aud and Visual.
cmap = cbrewer('qual', 'Paired',10);
colormap(cmap)
viscolour = cmap(3,:);
audcolour=cmap(9,:);
% correct=cmap(4,:); %greenish
% error =cmap(6,:); %reddish

%%

if jobs.concat_RT
    
    
    %preallocate some variables.
    ReactionTimesALL = [];
    CorErrcountsALL = nan(2,length(pfols));
    ExperimentOrder = nan(length(pfols),1);
    pnames = cell(length(pfols),1);
    
    
    for ippant = 1:length(pfols)
        
        cd(behdatadir);
        cd(pfols(ippant).name);
        
        
        
        lfile = dir([pwd filesep '*final' '*']);
        lfile= striphiddenFiles(lfile);
        load(lfile.name);
        %use file name for debugging plots
        pname = ['p_' subject.id];
        pnames{ippant}= pname;
        
        %we need to restrct the trials to only NON practice trials.
        usetrials=alltrials;
        isprac = find([alltrials.isprac]);
        usetrials(isprac)=[];
        
        %store the experiment order for later plots.
        ExpOrder = lower(cfg.stimTypes);
        
        if strcmp(ExpOrder{1}, 'visual')
            ExperimentOrder(ippant) = 1;
        else
            ExperimentOrder(ippant) = 2;
        end
        
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
                
            else % if visual, the trigger was 0.2 sec early. 
                % i.e. trigger, 0.2s delay, stim on screen for 0.3s, then
                % response collected.
                thisRT = thisRT-0.2;
            end
            
            
            ReactionTimesALL(ic,ippant).mean = nanmean(thisRT);
            ReactionTimesALL(ic,ippant).all = [thisRT];
            CorErrcountsALL(ic, ippant) = length(thisRT);
            
            
        end
        clear usetrials*
    end
    
    
    
end
%%

%%

if jobs.plotPFX_RT
    close all
    figure(1);
    clf;
    set(gcf, 'units', 'normalized', 'position', [0 0 .75 .75], 'color', 'w')
    titlesare={' part A correct (visual)', 'error (vis)', 'part B correct (aud.)' , 'error (aud.)'};
    for ippant=1:length(pfols)
        pname = pnames{ippant};
        icount=1;
        %%
        clf;
        for ic=1:4
            
            hold on
            plotRTs = ReactionTimesALL(ic,ippant).all;
            
            subplot(2,2,icount)
            histogram(plotRTs, 100)
            
            title({[titlesare{ic}]; ['Median = ' sprintf('%.2f', mean(plotRTs)) 's, n = ' num2str(length(plotRTs))]})
            xlabel('RT (sec)');
            ylims= get(gca, 'ylim');
            
            
            set(gca, 'fontsize', 12);
            
            icount=icount+1;
        end
        
        cd(figdir)
        cd('RTs per participant, by stim type')
        set(gcf, 'color', 'w')
        %print
        print('-dpng', ['participant ' num2str(ippant) ' ' pname ' correct and error RT distributions'])
    end
    
    
end


%% can also plot mean across participants.
% raincloud option:

if jobs.plotGFX_RT  %tidy (raincloud) GFX
    %%
    %use indexing which matches the order of ppant processing above:
    vis_first = find(ExperimentOrder==1);
    aud_first = find(ExperimentOrder==2);
    
    
    clf;
    set(gcf, 'units', 'normalized', 'position', [0 0 .8 .8], 'color', 'w')
    
    for ipart= 1:2;
        if ipart==1 % part A
            Xdata=[[ReactionTimesALL(1,vis_first).mean]',[ReactionTimesALL(2,vis_first).mean]'];
            expo = {'correct', 'error'};
            tis = 'Part A: Visual';
            xlimsr= [0 2];
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
end