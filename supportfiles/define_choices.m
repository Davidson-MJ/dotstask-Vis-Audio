%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%12/10/17 Nomi Carlebach
%This script defines the information type choices and location of the boxes in which they will be presented
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%[Sc.window, Sc.rect] = Screen('OpenWindow',2)

%Set base rect size for the choice boxes
cfg.infoType.BaseRect = [0 0 200 250];

%Get rect coordinates centered around the wanted location 
cfg.infoType.rects(:,1) =  CenterRectOnPointd(cfg.infoType.BaseRect , Sc.rect(3)/2, Sc.rect(4)*(3/8)-15);
cfg.infoType.rects(:,2) =  CenterRectOnPointd(cfg.infoType.BaseRect , Sc.rect(3)/2, Sc.rect(4)*(5/8)+15);


%Read in the images for advisers 
for i=1:cfg.nadvisers+2
    %Load pictures with different advisors
    cfg.advisor.image{i} = imread([stims_path '/observer' num2str(i) '.jpg']);
end

%read in image for view option
cfg.infoType.viewIm = imread([stims_path '/View.jpg']);




