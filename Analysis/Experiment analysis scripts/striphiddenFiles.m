function pstruct = striphiddenFiles(inputStruct)

% strip the hidden files (starting with prefix '._' from our directory
% lists.
%Useful for creating participant lists.


removeIDX=[];
for ip= 1:length(inputStruct)
    if strcmp(inputStruct(ip).name(1), '.')
       removeIDX= [removeIDX, ip];
    end
end
inputStruct(removeIDX)=[];
pstruct = inputStruct;