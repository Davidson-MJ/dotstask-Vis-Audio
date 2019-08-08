% plot_debugAccuracy
% quick script to plot the accuracy / staircase calibration for the
% previous trials.

%collect information:

ntrials = t-1;
responses = [alltrials(1:ntrials).cor];
trialID= 1:ntrials;

if alltrials(t).stimtype(1)
accuracyTIME = cumsum(responses)./trialID;

%% plotting:
subplot(211)

plot(trialID, accuracyTIME);
shg
