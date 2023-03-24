% Call_classifier_VIS_AUDIO_robustver
% wrapper script to train a decoder on corrects vs errors,

% compared to the Call_classifier_VIS_AUDIO which only trains on a single,
% matched set-size of data, this version iterates multiple times to
% redue the variance of the classifier output.


%%
%for all participants, specify output

GFX_decoding= zeros(length(pfols), 2, 2,281);

[nppants, trainedon, correctErr, npnts]= size(GFX_decoding);


my_SVM_ECOC_ERP_Decoding_crossmodal(pfols, eegdatadir);  


