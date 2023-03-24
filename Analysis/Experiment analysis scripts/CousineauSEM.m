function [wSE, NEWdata] = CousineauSEM(Xdata)

% function for delivering the Standard error of the mean, adjusted
% for within-subject comparisons (cf., Cousineau, 2005).


%dimensions for input data structure = nppants, samples 
if nargin<1
    error('need data')
end

disp(['Calc wSEM for N = ' num2str(size(Xdata,1)) ' participants']);

%adjust standard error as per COusineau(2005)
            %confidence interval for within subj designs.
            % y = x - mXsub + mXGroup,
            x = Xdata;
            
            mXsub =squeeze( nanmean(x,2)); %mean across conditions we are comparing (within ppant ie. time points).
            mXgroup = nanmean(nanmean(mXsub)); %mean overall (remove b/w sub differences)
            
            %for each observation, subjtract the subj average, add
            %the group average.
            NEWdata = x - repmat(mXsub, 1, size(x,2)) + repmat(mXgroup, size(x,1),size(x,2));
            
            %generate output
            %Sterr adjusted for w/in subj comparisons:
            wSE= nanstd(NEWdata)./sqrt(size(NEWdata,1));