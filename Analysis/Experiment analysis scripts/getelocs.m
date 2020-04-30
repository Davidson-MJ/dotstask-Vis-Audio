% getelocs
basedir=pwd;
try cd('/Users/MattDavidson/Desktop/XM_Project/EEGData/Analysis')
catch
    cd('/Users/mdavidson/DOCUMENTS/matlab/matlab toolboxes/MD misc')
end
%%    
elocs= readlocs('channellocs.loc');
elocs32=readlocs('JMac-32.locs');
biosemi64 = readlocs('BioSemi64.loc'); 
%%
cd(basedir);

electrodeAXIS=[];
for ieloc = 1:64

    electrodeAXIS= [electrodeAXIS, {num2str(elocs(ieloc).labels)}];

end

getelocs_neighbs;

occChans = [29:31,62];
poChansLeft =[23,56,24,60];
poChansRight =[26,59,27,64]; 


%% used in JMAC data:
chanorder = [{'FP1'},{'FPZ'},{'FP2'},{'F7'},{'F3'},{'FZ'},{'F4'},...
    {'F8'},{'FT7'},{'FC3'},{'FCZ'},{'FC4'},{'FT8'},{'T7'},{'C3'},...
    {'CZ'},{'C4'},{'T8'},{'TP7'},{'CP3'},{'CPZ'},{'CP4'},{'TP8'},{'P7'},...
    {'P3'},{'PZ'},{'P4'},{'P8'},{'POZ'},{'O1'},{'OZ'},{'O2'}];

%% note the need to correct to upper case for biosemi electrodes,
% for use in fieldtrip.
for i=1:64
    biosemi64(i).labels = upper(biosemi64(i).labels);
end
