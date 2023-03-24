 %update length of stair case if first trial in A or B.
        
 
 
 lengthA = length(practiceblocks_A) + length(experimentalblocks_A);
 
 if t==1
             
        stoprule = length(practiceblocks_A); 
        
        UD = PAL_AMUD_setupUD(UD, 'stopcriterion', 'trials', 'stoprule', stoprule);
    
 elseif t==lengthA+1 % first trial in part B
        
        %Save previous staircase
        
        UpDownStruct_partA = UD;
        
     
        %reset staircase UD params:
        %staircase to end, so remove stop rule.
               
        stoprule = length(practiceblocks_B);
        stopcriterion = 'trials';
        
        %also new criterion: we want to use a slightly harder version, so
        %switch from  Up-Down schedule in partA, to: 
        
        down = cfg.stepDown_partB;
        % prep Palamedes structure
       % prep Palamedes structure
       UD = PAL_AMUD_setupUD('up',up,'down',down);
       UD = PAL_AMUD_setupUD(UD,'StepSizeDown',StepSizeDown,'StepSizeUp', ...
           StepSizeUp,'stopcriterion',stopcriterion,'stoprule',stoprule, ...
           'startvalue',startvalue,'xMax', xmax, 'xMin', xmin);
        %%
        
        
%display target accuracy level:

        %         targetP = (StepSizeUp./(StepSizeUp+StepSizeDown)).^(1./down);
        %         message = sprintf('\rTargeted proportion correct: %6.4f',targetP);
        
 end
    