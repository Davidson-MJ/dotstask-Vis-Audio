 %update length of stair case if first trial in A or B.
    if t==1
        
        lengthA = length(practiceblocks_A) + length(experimentalblocks_A);
        UD = PAL_AMUD_setupUD(UD, 'stopcriterion', 'trials', 'stoprule', lengthA);
    
    elseif t== lengthA+1 %first trial in B
        
        lengthB = length(practiceblocks_B) + length(experimentalblocks_B);        
        
        %also new criterion: we want to use a slightly harder version, so
        %switch from  3Up 2Down (partA) to 
        
        down = cfg.stepDown_partB;
        
        UD = PAL_AMUD_setupUD(UD, 'stopcriterion', 'trials', 'stoprule', lengthB, 'down', down);
        
%display target accuracy level:

        %         targetP = (StepSizeUp./(StepSizeUp+StepSizeDown)).^(1./down);
        %         message = sprintf('\rTargeted proportion correct: %6.4f',targetP);
        
    end
    