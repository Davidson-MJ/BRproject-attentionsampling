%%  Segment Localizer epochs from data trace. Place in databook by type.
 function job2_preprocessExperimentEpochsbyType(savebase, eegdataIN, pathtoOnsets, pathtobehaviouraldata, Epochlength)
dbstop if error

%note no Epoch rejection at this stage, just storage.

SSRfriendly = 1; %is changed to 1 in later analysis, to skip preprocessing stages that contaminate spectral domain.




%set up outpath
addpath(pathtoOnsets)

cd(savebase)

try cd('j2_AllchanEpoched')
    
catch
    mkdir('j2_AllchanEpoched')
    cd('j2_AllchanEpoched')
end
outPathAll = (pwd);

%%



%load channel locations for rereferncing
%%
cd(savebase)
cd ../../../Analysis
%%
elocs = readlocs('channellocs.loc','filetype', 'loc'); %load electrode position file


cd(eegdataIN)
allppants = dir([pwd filesep 'ppant*']);

%%

for ippant = 24:length(allppants)
    realblock=1;
    dayis=1;
    
    preprocdlow_short=[];
    preprocdlow_med=[];
    preprocdlow_long=[];
    preprocdhigh_short=[]; %concatenates for averaging. 
    preprocdhigh_med=[]; %concatenates for averaging. 
    preprocdhigh_long=[]; %concatenates for averaging. 
    
 
    
    ppantIN =allppants(ippant).name;
    disp(['processing ppant ' num2str(ppantIN) ', (' num2str(ippant) ' of ' num2str(length(allppants)) ')...'])
    cd(num2str(ppantIN))
datainPATH = num2str(pwd);    
    
    allfilesEEG = dir([pwd filesep '*.vhdr']);
    
    blockTYPES= zeros(2,24,2); %day, block, exp/cond
    
    for iEEG = 1:length(allfilesEEG)
        if iEEG==5 %reset realblock for second day.
            realblock=1;
            dayis=2;
        end
        %%
        dbstop if error
        filename= allfilesEEG(iEEG).name;
        
        if strcmp(filename(8), 'n')
            daycond='nonAttend';
            
        else
            daycond='Attend';
        end
        if iEEG<5
            day1cond=daycond;
        end



        cd(datainPATH)
        %load EEG data
        EEG= pop_loadbv(num2str(pwd), num2str(filename));
        
        
        
        %PREPROCESS continuous EEG
        procEEG = preprocesscontinuousEEG(EEG, elocs, SSRfriendly);
        
        
        %         %% sanity check to see if preprocess effects topo
        %         clf
        %         plotdata =cat(3, EEG.data(1:64,1000:1500), procEEG(1:64,1000:1500));
        %         plottopo(plotdata, 'chanlocs', elocs, 'colors', {'b' {'r'} });
        % % %         inspect to check if rereferencing does anything!
        %%
        %%
        cd([pathtoOnsets filesep num2str(ppantIN)]);
        numblocks = dir([pwd filesep 'AUTOTrial Onsets for rec(' num2str(iEEG) ')*' '.mat']);
        %collect onset time information
        for iblock = 1:length(numblocks)
            
            %low hz trialtypes.
            count82=1; %short
            count83=1;% medium
            count84=1;% long
            %high hz trial types
            count92=1; %stimulus trial type counters for concat.
            count93=1;
            count94=1; %trial types.
            
            cd(pathtoOnsets)
            cd(ppantIN)
            
            %         disp(['Processing file ' num2str(iblock) ' of ' num2str(length(allfilesEEG))]);
            
            load(['AUTOTrial Onsets for rec(' num2str(iEEG) '), block(' num2str(iblock) '), both stim channel, ' num2str(ppantIN) '.mat'])
            
            
            %% collect some behavioural/block data to save with EEG
            cd(pathtobehaviouraldata)
            initials=ppantIN(end-1:end);
            finddir= dir([pwd filesep initials '*Day' num2str(dayis) '*']);
            
            ppantBHLdata = finddir.name;
                            
            cd(ppantBHLdata);
            
            %load block data
            blockis = dir([pwd filesep 'Block' num2str(realblock) 'Exp*']);
            load(blockis.name)
            % xmod, phase, trial order.
            Casetype=blockout.Casetype;
            Phasetype=blockout.Phasetype;
            BlockOrder=blockout.Order;
            
            load('Seed_Data.mat', 'Exps')
            blockTYPES(dayis,:,:)=Exps(3:end,:);
            %Epoch entire recorded  block, for visualization

            
         
                filename = ['BLOCK(' num2str(realblock) ')_day' num2str(dayis) '_' num2str(daycond)];
         %%
            allchanseachblock = procEEG(:,istartTime:iendTime);
            %%include an ICA for later use.            
            % downsample 
            allchanseachblock_ds = downsample(allchanseachblock',4)';
%             clf
%             subplot(211)
%             pwelch(allchanseachblock(1,1:1000), [],[],[],1000);
%             subplot(212)
%             pwelch(allchanseachblock_ds(1,1:250),[],[],[],250);
%             %%
%             shg
           %% 
            
%             
%             %%save
%             cd(outPathAll)
%             try cd(ppantIN)
%             catch
%                 mkdir(ppantIN)
%                 cd(ppantIN)
%             end
%             ppantOUT = pwd;
            
                      save([num2str(filename)], 'allchanseachblock_ds', 'BlockOrder', 'onsetTrialTimes', 'Casetype', 'Phasetype');
            
            
            %% Epoch by type
            %remove vis only.
%             BlockOrder = BlockOrder(BlockOrder>1);
%             for iOnset = 1:length(BlockOrder);
%                 
%                 trialtype = BlockOrder(iOnset);
%                 
%                 
%                 startepoch = onsetTrialTimes(iOnset)-(abs(Epochlength(1)*EEG.srate)); % prestim and post
%                 endepoch = onsetTrialTimes(iOnset)+(abs(Epochlength(2)*EEG.srate)); % post
%                 
%                 try datatmp = procEEG(:, startepoch:endepoch);
%                 catch
%                     datatmp = procEEG(:, startepoch:size(procEEG,2));
%                 end
%                 for ichan = 1:64
%                     %detrend also
%                     tmp = squeeze(datatmp(ichan,:));
%                     
%                     etrial = detrend(tmp, 'constant');
%                     %
%                     %remove prestim baseline
%                     basetmp= etrial(1,1:abs(Epochlength(1)*EEG.srate));
%                     base= mean(basetmp);
%                     baset = repmat(base, 1, length(etrial));
%                     tmp2 = etrial - baset;
%                     
%                     %%%%
%                     %%%%
%                     %%%%
%                     %%%%
%                     %downsample before saving
%                     %%%%
%                     %%%%
%                     res_tmp=downsample(tmp2,4); % May effect time-frequency
%                     ds_datatmp(ichan,:) = res_tmp;
%                 end
% 
%                 
%                 %add to data book to save by type of stimulus
%                 try
%                     switch trialtype
%                     case 82 %lowhz short
%                         preprocdlow_short(dayis,realblock, count82, :,:) = ds_datatmp;
%                         count82=count82+1;
%                         
%                     case 83 %lowhz medium
%                         preprocdlow_med(dayis,realblock,count83,:,:) = ds_datatmp;
%                         count83=count83+1;
%                         
%                     case 84 %lowhz long
%                         preprocdlow_long(dayis,realblock,count84,:,:) = ds_datatmp;
%                         count84=count84+1;
%                         
%                      case 92 %high hz short
%                          preprocdhigh_short(dayis,realblock,count92,:,:) = ds_datatmp;
%                         count92=count92+1;
%                         
%                         case 93
%                             preprocdhigh_med(dayis,realblock,count93,:,:) = ds_datatmp;
%                         count93=count93+1;
%                         case 94
%                             preprocdhigh_long(dayis,realblock,count94,:,:) = ds_datatmp;
%                         count94=count94+1;
%                         
%                     end
%                 catch
%                     error(['size mismatch for block' num2str(realblock) ', trial(' num2str(iOnset) '), type(' (num2str(trialtype)) ')ppant' num2str(ppantIN)]);
%                     
%                 end
%             end
                     disp(['finished block' num2str(realblock)])
            realblock=realblock+1;
%             
%             cd(datainPATH)
        end
    end
%     cd(ppantOUT)
%     
%     save('downsampledprocd_EpochedbytypeLONG(day,block,trial,chans,samps)',...
%         'blockTYPES', ...
%         'day1cond',...
%         'preprocdhigh_long', ... 
%         'preprocdhigh_med', ...
%         'preprocdhigh_short', ...
%         'preprocdlow_long', ...
%         'preprocdlow_med',...
%         'preprocdlow_short');
%     
    
    cd(eegdataIN)
    disp(['Finished ppant ' num2str(ippant) ' of ' num2str(length(allppants)) '...'])
end
cd(outPathAll)
datapathOUT=outPathAll;
disp('Finished job 2 preprocessing')
end
