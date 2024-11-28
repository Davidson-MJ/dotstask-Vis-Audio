
%PLOT GFX, stim and response locked ERPs, combined for manuscript
% In this version (2), we will focus only on the response locked data, with
% topos inset.

cd(eegdatadir)
cd('GFX')
load('GFX_averageERPs TRIG based.mat')
smoothON=1;
hidetopos=0;
fntsize= 16;
%
figure(1);  clf;
set(gcf, 'units', 'normalized', 'position', [0.05 0.05 .8 .8], 'color', 'w');
figure(4);  clf; % for topos:
set(gcf, 'units', 'normalized', 'position', [0.05 0.05 .8 .8], 'color', 'w');


exppart = {'1st half', '2nd half'};

% meanoverChans = [11,12,19,47,46,48,49,32,56,20,31,57]; % resp
meanoverChans_RESP = [4,38,39,11,12,19,47,46,48,49,32,56,20,31,57];
meanoverChans_VIS = [20:31, 57:64];
meanoverChans_AUD = [4:15,39:52];

meanoverChans_POCC = [20:31, 57:64];

%same colours as beh data?
%separate into Aud and Visual.
cmap = cbrewer('qual', 'Paired',10);
% colormap(cmap)
% viscolour = cmap(3,:);
% audcolour=cmap(9,:);
grCol=cmap(4,:); %greenish
redCol =cmap(6,:); %reddish
elocs = readlocs('BioSemi64.loc'); %%
%
clf
usetopospot=1; % increments on figure 4 showing topos.

%%%% first plot the stimulus locked data, then the response locked:
avRTs= [0.4662, 0.4322;... % C, E (vis)
    0.98, 1.27]; % C E  (Aud) - > copied from behavioural analysis.

%stim, resp, or resp with prestim baseline?
for idata = 2%1:2
    if idata==1 % stimulus locked.
        subspots = [1,5];
        %         tspots = [1, 9];
        corrA = GFX_visstimCOR;
        errA = GFX_visstimERR;
        corrB = GFX_audstimCOR;
        errB = GFX_audstimERR;
        
        xlabis= 'stimulus';
    elseif idata==2
        %         subspots = [3, 7]; % subplot spots (for ERPs)
        %         tspots = [5, 13]; % spots for topos
        %
        corrA = GFX_visrespCOR;
        errA = GFX_visrespERR;
        corrB = GFX_audrespCOR;
        errB = GFX_audrespERR;
        
        xlabis= 'response';
        
    elseif idata==3
        %         subspots = [3, 7]; % subplot spots (for ERPs)
        %         tspots = [5, 13]; % spots for topos
        %
        corrA = GFX_visrespCOR_stimbase;
        errA = GFX_visrespERR_stimbase;
        corrB = GFX_audrespCOR_stimbase;
        errB = GFX_audrespERR_stimbase;
        
        xlabis= 'response (w/prestim)';
        
        
        
    end
    %%
    for ixmod = 1:2 % vis - aud
        
        switch ixmod
            case 1
                %             datac= GFX_visstimERP(vis_first, :,:);
                datac= corrA;
                datae= errA;
                %             titleis=  ['Visual ' xlabis ];
                if idata>1
                titleis=  ['Visual decision'];
                else
                    titleis ='Visual stimulus';
                end
                meanoverChans_tmp= meanoverChans_VIS;
                stimbar = [0 300];
                
                % topo times to patch: (stim locked)
                showt1 = [100,200]; %ms;
                showt2=[250,400]; % ms
                
                % when looking at difference ERP:                
                difft1 = [100,200];
                difft2 = [300, 500]; % ?
                
            case 2
                
                datac= corrB;
                datae= errB;
                
                % topo times to patch: (stim locked)
                
                % topo times to patch: (stim locked)
                showt1 = [100,200]; %ms;
                showt2=[250,400]; % ms
                % when looking at difference ERP:
                
                if idata>1
                titleis=  ['Auditory decision'];
                else
                    titleis ='Auditory stimulus';
                end
                meanoverChans_tmp= meanoverChans_AUD;
                stimbar = [0 100]; %!Check!
                %             use_xvec = plotXtimes;
        end
        
        
        % note that if response locked data, use ERN ,Pe windows:
        if idata==2 || idata==3
            if ixmod==1
            showt1 = [-50,150]; %ms;
            showt2=[250,450];
            else
                showt1=[-400 -200];
                showt2 = [400 700];
            end
%             meanoverChans_tmp = meanoverChans_POCC;           
%                     meanoverChans_tmp = meanoverChans_RESP;

        meanoverChans_tmp =unique([meanoverChans_POCC,meanoverChans_RESP]);
        end
        
        
        use_xvec = plotXtimes(1:size(datac,3));
        
        
        %apply smoothing to dataset:
        %50 ms window.
        if smoothON==1
            printname = ['GFX univariate ERP summary smoothed'];
            winsizet = dsearchn(use_xvec', [0 100]'); % 100ms smooth window.
            winsize = diff(winsizet);
            [tmpoutc, tmpoute] = deal(zeros(size(datac)));
            for ippant=1:size(datac,1)
                for ichan= 1:size(datac,2)
                    
                    tmpoutc(ippant,ichan,:) = smooth(squeeze(datac(ippant,ichan,:)), winsize);
                    tmpoute(ippant,ichan,:) = smooth(squeeze(datae(ippant,ichan,:)), winsize);
                end
            end
            datac=tmpoutc;
            datae=tmpoute;
        else
            printname=['GFX univariate ERP summary'];
        end
        
        
        %
        %%
        
        %%
        %
        %
        %   PREPARE ERP PLOTS  (Correct and Error)
        plotD= {datac, datae, datae-datac};
        colsAre= {grCol, redCol, 'k'};
        legh=[];
        lgc=1; % counter for legend entries (resets at 3)
        for iplotd= 1:3
            if iplotd<3 % cirrect, error ,diff
                figure(1);
                subplot(2,2,ixmod);
                %set y limits:
                
                if idata==1 %stimlocked                    
                ylim([-2.5 4])
                
                elseif idata==2 %resplocked
                    ylim([-2.5 3.5]);
                elseif idata==3
                    ylim([-2.5 5]);
                end
                
                xlim([- 500 1000]);
                title([titleis])
                
            else % difference waveform: update info for next plot:
                legh=[];
                subplot(2,2,ixmod+2);
                ylim([-2 3])
                xlim([- 500 1000])
                title('difference waveform')
                lgc=1;
               
            end
            
            %place patches first (as background)
            %place patches (as background) first:
            ytx= get(gca, 'ylim');
            hold on
            if iplotd==3 % show on difference
                %plot topo patches.
                if idata~=1 %skip first patch for vis stim locked.
                ph=patch([showt1(1) showt1(1) showt1(2) showt1(2)], [ytx(1) ytx(2) ytx(2) ytx(1) ],  [.9 .9 .9]);
                % ph.FaceAlpha=.4;
                ph.LineStyle= 'none';
                end
                ph=patch([showt2(1) showt2(1) showt2(2) showt2(2)], [ytx(1) ytx(2) ytx(2) ytx(1) ],  [.9 .9 .9]);
                % ph.FaceAlpha=.4;
                ph.LineStyle= 'none';
                
            end
            
            % %% now add the RT.
            if iplotd<3 && idata==1
%             showRT = avRTs(ixmod, iplotd);
%             plot([showRT*1000, showRT*1000], [-1 0], '-o', 'color', colsAre{iplotd})
               %plot stim bar to aid interp of ERP waveforms
        
             xvs= [stimbar(1) stimbar(1) stimbar(2) stimbar(2)];
             yvs= [-2.4 -2.1 -2.1 -2.4];
             pch=patch(xvs, yvs, ['k']);
             pch.FaceColor= [.8 .8 .8];
             
            end
            hold on
            % mean over relevant channels:
            tmp_plotData = squeeze(mean(plotD{iplotd}(:, meanoverChans_tmp,:),2));
            plotMean = squeeze(mean(tmp_plotData,1));
            stE1 = CousineauSEM(tmp_plotData );
            %Corrects, errors, difference:
            
            sh=shadedErrorBar(use_xvec, plotMean, stE1,{'color',colsAre{iplotd}, 'linew', 2},1);
            p1= sh.mainLine;
            legh(lgc) = sh.mainLine;
            plot([0 0], ylim, ['k-'])
            plot(xlim, [0 0], ['k-'])
            
            set(gca, 'ydir', 'normal', 'fontsize', fntsize)
            
            xlabel(['Time from ' xlabis ' onset [ms]'])
            ylabel(['\muV']);
            hold on;
            % add topo inset to show locations.
            gax = get(gca);
            xS= gax.Position(1);
            yS= gax.Position(2);
            wdth = gax.Position(3);
            hght = gax.Position(4);
            % place new pos within bounds of subplot.
            % newpos = [gax.Position(1)+wdth/3 ,gax.Position(2)+hght/3, wdth/3 hght/3];
            %%
            % ax= subplot('Position', newpos)
            
            
            %% add sig for id==3?
           if iplotd==3
              pvals =[];
              for itime= 1:length(use_xvec)
                  
                 [h,pvals(itime),ci,stat] = ttest(tmp_plotData(:,itime),0); 
                  
                 if pvals(itime)<.05
                     text(use_xvec(itime), -1.5, '*','fontsize',25, 'HorizontalAlignment', 'center');
                 end
              end
               
               
               
           end
            
            
            
            
            if iplotd==2 && ixmod==1
             lg=   legend([legh(1) legh(2)], {'Correct', 'Error'}, 'autoupdate', 'off', 'Orientation','Horizontal');
                
            elseif iplotd==3 && ixmod==1
                legend([legh(1)], {'Err-Corr'}, 'autoupdate', 'off');
            end
            
            lgc= lgc+1;
            
            %% we can also show the relevant topos in the next figure:
            %times for topography
            if ~hidetopos &&(  iplotd==1 || iplotd==3) % corrects and diff.
                figure(4); hold on;%
                if iplotd<3
                    
                    compwas = 'corr';
                else
                    
                    compwas = 'diff';
                end
                
                topoX1=dsearchn(use_xvec', showt1');
                topoX2=dsearchn(use_xvec', showt2');
                
                % plot average activity in both temporal windows:
                for plotts=1:2
                    if plotts ==1
                        topot = topoX1;
                        realt = showt1;
                        
                    else
                        topot = topoX2;
                        realt = showt2;
                        
                    end
                    subplot(2,4, usetopospot);
                    
                    gfx= squeeze(mean(plotD{iplotd},1)); % mean over participants.
                    % optionally plot an empty topo (showing chan locs)
                    if iplotd~=3
                        %%
                        topoData= ones(1,length(elocs));
                        topoplot(topoData, elocs, 'emarker2', {[meanoverChans_tmp], '.' 'm'}, 'whitebk', 'on' ,'conv', 'on','numcontour',1);
                        cmap=[.9 .9 .9];
                        colormap(cmap);
                        shg
                    else
                        topoData =mean(gfx(:,[topot(1):topot(2)]),2) ;% mean within time points:
                        topoplot(topoData, elocs, 'emarker2', {[meanoverChans_tmp], '.' 'w'} );
                    end
                    c=colorbar;
                    %              title({[xlabis];[num2str(realt(1)) '-' num2str(realt(2)) 'ms (' compwas ')']})
                    set(gca, 'fontsize', fntsize/2)
                    %              ylabel(c, '\muV')
                    caxis([-1 1]);
                    c=    colorbar;
                    usetopospot=usetopospot+1;
                    set(gca,'fontsize', 16);
                    ylabel(c, '\muV')
                end
                figure(1);
                hold on;
                
            end
            
            
            
            
            
        end % after all 3
        % tidy axes:
        
     
        %      xlim([])
        %      legend([p1, p2, sh.mainLine, pch], {'cor', 'err', 'diff','stimulus'}, 'location', 'NorthEast')
        %      legend([p1, p2, pch], {'cor', 'err', 'stimulus'}, 'location', 'NorthEast')
        
        
        
        
        
        
        
        
    end
end
%% stim and response locked
colormap('inferno')
cd(figdir)
% cd('Stimulus locked ERPs')
set(gcf, 'color', [.9 .9 .9]); %same colour as patch to align on figure




