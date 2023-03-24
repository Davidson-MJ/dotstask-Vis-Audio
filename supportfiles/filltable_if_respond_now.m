% filltable_if_respond_now;

% Simple script filling the appropriate columns in our output table with
% NaNs. Since no second stimulus presentation is required.

%% Order of recorded stimulus timings:

%response to info options
alltrials(t).respInfoSeek_time              = NaN;
alltrials(t).respInfoSeek_loc               = NaN;
alltrials(t).ISeek                          = NaN;
alltrials(t).ISeek_rt                       = NaN;
alltrials(t).didrespond_IS                  = NaN;

%start of next trial sequence
alltrials(t).VBLtime_starttrial2            =NaN;
alltrials(t).time_starttrial2               =NaN;
alltrials(t).flip_accuracy_starttrial2      =NaN;

%presentation of large fix cross.
alltrials(t).VBLtime_largeFix2                  =NaN; 
alltrials(t).time_largeFix2                     =NaN;
alltrials(t).flip_accuracy_largeFix2            =NaN;

%second stimulus presentation
alltrials(t).VBLtime_stim2pres           = NaN;
alltrials(t).time_stim2pres              = NaN;
alltrials(t).flip_accuracy_stim2pres     = NaN;

%second stimulus presentation offset
alltrials(t).VBLtime_stim2offset             = NaN;
alltrials(t).time_stim2offset                = NaN;
alltrials(t).flip_accuracy_stim2offset       = NaN;

%%
