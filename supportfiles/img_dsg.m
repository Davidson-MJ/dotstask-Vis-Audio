function img_dsg(struct,fields,t);

% plot an image of the experimental outline, for sanity checks.

%field names
if nargin<2
    fields = fieldnames(struct);
end
%all trials
if nargin<3
    t = 1:length(struct);
end
x = [];
s = @(x) nansum(cat(2,x(:),-isnan(x(:))),2)';
n = @(x) (s(x)-min(s(x))) ./ (max(s(x))-min(s(x)));

    for ii = 1:length(fields)
        eval(['x = cat(1,x,n(s([struct.' fields{ii} '])));']);
    end

imagesc(t,[],x);
set(gca,'ytick',1:length(fields),'yticklabel',fields);