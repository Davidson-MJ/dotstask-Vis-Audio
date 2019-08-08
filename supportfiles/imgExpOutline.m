function imgExpOutline(alltrials, fieldsare, ntrials)


% M Davidson  July 2019
% create matrix for all output, then visualize for sanity checks.

if nargin<2
fieldsare= fieldnames(alltrials);
end
if nargin<3
ntrials = 1:length(alltrials);
end
%%
%for each field, get the vector of all responses.
X=nan(length(ntrials), length(fieldsare));
for iff = 1:length(fieldsare)
  
    
    content= eval(['alltrials(1).' fieldsare{iff} ]);
    %determine if characters.
    if ischar(content)
    
        reps = eval( ['[str2mat(alltrials(:).' fieldsare{iff} ')]']);
        %convert to unique numbers
        
        
        
    else
        reps = eval( ['[alltrials(:).' fieldsare{iff} ']']);
    end
    
    X(:, iff)=reps;
end
%%
figure(100);clf;  set(gcf, 'Units','normalized', 'position', [.65 .55 .27 .4]);% nice semi-rect.
imagesc(ntrials, [], X');
set(gca,'ytick',1:length(fieldsare),'yticklabel',fieldsare, 'fontsize', 20);
title('Experiment outline')
xlabel('trial number')


end