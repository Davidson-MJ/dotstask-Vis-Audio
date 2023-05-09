basedir = '/Users/mdavidson/Desktop/dotstask- Vis+Audio EXP/Exp_output/DotsandAudio_behaviour';
cd(basedir)
pdirs= dir([basedir filesep '*_p*']);

CoM=zeros(length(pdirs),2);
%%
for ippant = 1:length(pdirs)
    cd(basedir)
    cd(pdirs(ippant).name);
    
    finfile =  dir([pwd filesep '*_final.mat']);
    load(finfile.name);
    
    %find changes of Mind.
    allJ1_acc = [alltrials_final(391:end).cor];
    
    
    allJ2_acc= [alltrials_final.confj_cor];
    
    %%
    
    for it=1:length(allJ1_acc)
        if allJ1_acc(it)>allJ2_acc(it)% right - wrong
            CoM(ippant,1) = CoM(ippant,1)+1;
        elseif allJ1_acc(it)<allJ2_acc(it) %wrong-right
            CoM(ippant,2) = CoM(ippant,2)+1;
        end
    end
end

%%

