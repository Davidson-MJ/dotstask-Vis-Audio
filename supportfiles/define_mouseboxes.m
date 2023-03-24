% define_mouseboxes

%define simple boxes which will be filled-in, by clicks in first half of
%exp.

% size of each response box. 
cfg.MouseRect = [0, 0 , 200,100]; 

% define location, to be drawn adjacent to one another (centred on X).
cfg.MouseRect_pos1= CenterRectOnPoint(cfg.MouseRect, window.Center(1)-cfg.MouseRect(3)/2, window.Rect(4)*cfg.bar.positiony); 
cfg.MouseRect_pos2= CenterRectOnPoint(cfg.MouseRect, window.Center(1)+cfg.MouseRect(3)/2, window.Rect(4)*cfg.bar.positiony); 
%centred
cfg.MouseRect_pos3= CenterRectOnPoint(cfg.MouseRect, window.Center(1), window.Rect(4)*cfg.bar.positiony); 
