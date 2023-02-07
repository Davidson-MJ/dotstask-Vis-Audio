function eH=errorbar_groupedfit(mData,ErrData)
dbstop if error
%model_series = data to plot
% m x n matrix, m= ngroups, n=nbars
%eH is errorbar handle
hold on;
% Finding the number of groups and the number of bars in each group
ngroups = size(mData, 1);
nbars = size(mData, 2);
% Calculating the width for each bar group
groupwidth = min(0.8, nbars/(nbars + 1.5));
% Set the position of each error bar in the centre of the main bar
% Based on barweb.m by Bolu Ajiboye from MATLAB File Exchange
for i = 1:nbars
    % Calculate center of each bar
    x = (1:ngroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*nbars);
    eH=errorbar(x, mData(:,i), ErrData(:,i), 'LineStyle', 'none','color', 'k', 'LineWidth',2);
end