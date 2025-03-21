  %check for sig      
            checkcluster=1;
            shuffType=1;
            sigs=find(pvals<.05);
            %
            %             %perform cluster based correction.
            if length(sigs)>2 &&checkcluster==1
                
                % find biggest cluster:
                %finds adjacent time points
                sigs = find(pvals<.05);
                
                vect1 = diff(sigs);
                v1 = (vect1(:)==1);
                d = diff(v1);
                clusterSTandEND= [find([v1(1);d]==1) find([d;-v1(end)]==-1)];
                [~,maxClust] = max(clusterSTandEND(:,2)-clusterSTandEND(:,1));
                
                %
                for icl=maxClust% 1:size(clusterSTandEND,1)
                    
                    %start and end are now:
                    % change icl to maxClust if we only want the largest
                    % cluster.
                    STC=sigs(clusterSTandEND(icl,1));
                    ENDC=sigs(clusterSTandEND(icl,2)+1);
                    checktimes =STC:ENDC;
                    observedCV = sum(tvals(checktimes)); % (pos or neg)
                    % now shuffle condition labels to see if this cluster is
                    % sig (compared to chance).
                    
                    
                    
                    
                    nshuff=1000;
                    
                    sumTestStatsShuff = zeros(1,nshuff);
                    sumTestStatsShuff_full = zeros(1,nshuff);
                    %create a pseudo data set (0) for statistical
                    %comparison. 
                    nulltest = ones(size(ttestdata)).* compareTo;
                    for irand = 1:nshuff
                        
                        if shuffType==1 %null is that no condition differences.
                            
                            
                            shD=zeros(2,size(ttestdata,1),size(ttestdata,2));
                            %since this is a within subjects design, we permute
                            %the subjet specific averages within each subject
                            %(as per Maris & Oostenveld (2007).
                            
                            % for each subject, randomly permute the averages.
                            %(Dsub1cond1,Datasub1cond2)
                            for ippant = 1:size(ttestdata,1)
                                
                                if mod(randi(100),2)==0 %if random even number
                                    % shD(1,ippant,:) = shuffle(ttestdata(ippant,:)); % all time points.
                                    % shD(2,ippant,:) = shuffle(nulltest(ippant,:)); % all time points.

                                    shD(1,ippant,:) = ttestdata(ippant,:); % all time points.
                                    shD(2,ippant,:) = nulltest(ippant,:); % all time points.
                                else
                                    % shD(1,ippant,:) = shuffle(nulltest(ippant,:)); % all time points.
                                    % shD(2,ippant,:) = shuffle(ttestdata(ippant,:)); % all time points.
                                    
                                    shD(1,ippant,:) = nulltest(ippant,:); % all time points.
                                    shD(2,ippant,:) = ttestdata(ippant,:); % all time points.
                                end
                                
                                %                             shD(ipartition,ippant,:) = pdata;
                            end
                            
                        else %null is that there are no temporal coincident sig values.
                            for ipartition = 1:2
                                for ippant = 1:size(ttestdata,1)
                                    for itime=1:length(checktimes)
                                        
                                        %take random timepoint.
                                        pdata = ttestdata(ippant, randi(size(ttestdata,2)));
                                        
                                        
                                        shD(ipartition,itime,ippant) = pdata;
                                    end
                                end
                            end
                        end
                        
                        %                     tvalspertimepoint = zeros(1,length(checktimes));
                        %%
                        % figure(3); clf; plot(squeeze(mean(shD(1,:,:),2))); hold on
                        %                     plot(squeeze(mean(shD(2,:,:),2))); ylim([2.4 3])
                        %%
                        testdata = squeeze(shD(1,:,:)) - squeeze(shD(2,:,:));
                        p=[];
                        tvalspertimepoint=[];
                        for itest = 1:length(checktimes)
                            
                            [~, p(itest), ~,stat]= ttest(testdata(:,checktimes(itest)));
                            
                            tvalspertimepoint(1,itest) = stat.tstat;
                        end
                        
                        % the null hypothesis is that these prob distributions
                        % are exchangeable, so retain this permutation cluster-
                        % level stat.
                        % sumTestStatsShuff(1,irand) = sum(abs(tvalspertimepoint));%(checktimes)));
                        
                        sumTestStatsShuff(1,irand) = sum(tvalspertimepoint);%(checktimes)));
                        
                        % max cluster in this shuffle:
                        %  sigsS=find(p<.05);
                        %  if length(sigsS)>2
                        %   % find biggest cluster:
                        %   %finds adjacent time points
                        %   vect1 = diff(sigsS);
                        %   v1 = (vect1(:)==1);
                        %   d = diff(v1);
                        %   clusterSTandEND= [find([v1(1);d]==1) find([d;-v1(end)]==-1)];
                        %   if ~isempty(clusterSTandEND)
                        %       allclust=[];
                        %       for ishCluster = 1:size(clusterSTandEND,1)
                        %           %grab largest
                        %           % find biggest cluster:
                        % 
                        %           STC=sigsS(clusterSTandEND(ishCluster,1));
                        %           ENDC=sigsS(clusterSTandEND(ishCluster,2)+1);
                        %           checktimes =STC:ENDC;
                        %           shuffCV= sum((tvalspertimepoint(checktimes)));
                        %           allclust(ishCluster)= shuffCV;
                        %       end
                        %       % retain max per shuffle:
                        %       sumTestStatsShuff_full(1,irand) = max(allclust);
                        %   else
                        %       sumTestStatsShuff_full(1,irand) = 0;
                        %   end
                        %   %%
                        % 
                        %  else 
                        % sumTestStatsShuff_full(1,irand) = 0;
                        %  end
                    end %repeat nshuff times
                    
                    
                    %is the observed greater than CV?
                    % plot histogram:
                    %%
                    figure(2);
                    
                    clf
                    
                    subplot(121)
                    H=histogram((sort(sumTestStatsShuff)));
                    title(['sum tvals = ' num2str(observedCV)]);
                    % fit CDF
                    cdf= cumsum(abs(H.Data))/ sum(abs(H.Data));
                    %the X values (actual CV) corresponding to .01
                    [~,cv95uncorr] = (min(abs(cdf-.95)));
                    [~,cv05uncorr] = (min(abs(cdf-.05)));
                    [~,cv99uncorr] = (min(abs(cdf-.99)));
                    [~,cv01uncorr] = (min(abs(cdf-.01)));
                    [~,cv999uncorr] = (min(abs(cdf-.999)));
                    [~,cv001uncorr] = (min(abs(cdf-.001)));
                    hold on
                    pCV=plot([observedCV observedCV], ylim, ['r-']);                   
                    p95=plot([H.Data(cv95uncorr) H.Data(cv95uncorr)], ylim, ['k:']);
                    p05=plot([H.Data(cv05uncorr) H.Data(cv05uncorr)], ylim, ['k:']);
                    plot([H.Data(cv99uncorr) H.Data(cv99uncorr)], ylim, ['k:']);
                    plot([H.Data(cv01uncorr) H.Data(cv01uncorr)], ylim, ['k:']);
                    plot([H.Data(cv999uncorr) H.Data(cv999uncorr)], ylim, ['k:']);
                    plot([H.Data(cv001uncorr) H.Data(cv001uncorr)], ylim, ['k:']);
                    legend([pCV p05], {['observed'] ['95%'] })
                 
                    %compare to full cluster? 
                    % subplot(122);
                    %  H=histogram((sort(sumTestStatsShuff_full)));
                    % % fit CDF
                    % cdf= cumsum(abs(H.Data))/ sum(abs(H.Data));
                    % %the X values (actual CV) corresponding to .01
                    % [~,cv05uncorr] = (min(abs(cdf-.95)));
                    % hold on
                    % pCV=plot([observedCV observedCV], ylim, ['r-']);                   
                    % p05=plot([H.Data(cv05uncorr) H.Data(cv05uncorr)], ylim, ['k:']);
                    % legend([pCV p05], {['observed'] ['95%'] })
                    %%
                    
                    figure(1);
                    if observedCV>H.Data(cv95uncorr) || observedCV<H.Data(cv05uncorr)
                        
figure(1)
                        yl=get(gca, 'ylim');
                        xl=get(gca, 'xlim');
                        sigplace = yl(1) + usesigmod*(diff(yl)); % place at bottom for catch
                        
%%
                        
                       %%
                       for itime=checktimes

                           hold on
                           plot(xvec(itime), sigplace, ['*' ],'markersize', 10, 'linewidth', 3, 'color', sigcol)
                           
                       end
                        
                       disp([' plotting significnt cluster:' num2str(xvec(checktimes(1))) ' - ' num2str(xvec(checktimes(end))) ]);
                       txtplace =  xl(2) - .1*(diff(xl)); % place at bottom for catch
                       % text(txtplace, sigplace, '\itp\rm_(_c_l_u_s_t_e_r_) < .05', 'HorizontalAlignment','center', 'FontSize', 12);
                    end
                    
                    %
                end
            end
            
          
            