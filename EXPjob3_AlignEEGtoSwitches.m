%% job 3: align ERPimage to button press 'switches'
% clear all

dbstop if error
allEEGblockdatadir= '/Users/MattDavidson/Desktop/XM_Project/EEGData/DATA/Processed/EEG_from_Attention_XmodalEXP/jSW_1_blockEpoched';
allBPdatadir= '/Users/MattDavidson/Desktop/XM_Project/DATA_newhope';

%%


getelocs; %get channel info
dataINdir = allBPdatadir;


%% for plotting and calcs
fontsize=10;
refreshrate=60;
basesubtract = 0;%s from start of epoch. e.g. 1 = first 1 second of 10s epoch (switch at 5)
% single channel at a time, since large structures (many switch events).
checkchan= 64; 
%POz, Oz, PO8 done for 0sec brem, 
%POz done for 2sec brem.

srate=250;
epochlength = [-5 5];%window to plot, same as epoched data 


%% Hz index to find
f1= 4.5; %hz
two_f1= 2*f1; %hz
three_f1= 3*f1;

f2= 20; %hz
twof2=2*f2;



%% parameters used for mtspecgram
    params.tapers= [1, 1];
    params.fpass = [1, 60]; %above 50 to check kernel width at 50Hz.
    params.Fs = 250;
    params.pad= 1; %helps with kernel
    movingwin = [1.5, .2];

    % for kernel construction
noisebinwidth =2;
checkshape = 0;

sanitycheckON=0;
%%
cd(allEEGblockdatadir)
%%
allppants = dir(['ppant*']);
nppants=length(allppants);
%%

    for ppantIN=1:nppants
        cd(allEEGblockdatadir)
       ppantfol=allppants(ppantIN).name;
       initials=ppantfol(end-1:end);
        
       cd(allEEGblockdatadir)
       %find ppant
       ppantfol=dir(['ppant*' '_' num2str(initials)]);
       cd(ppantfol.name)
       %%
       savedir = num2str(pwd);
       
       
       for iday=1:2
        %uses mtspecgramc         
       Collect_SwitchEEGperPpantperBlock
             
       end
        
        %%
        
        disp(['fin ppant ' num2str(ppantIN) ' ' num2str(initials)])
    end

