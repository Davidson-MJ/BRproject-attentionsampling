% function job3A_prepbytype_Visonly(savebase, eegdataIN, pathtoOnsets, pathtobehaviouraldata, Epochlength)
%Add hoc function combining job 2-3-4 previously to exctract across all
%data for visual only trials .

%from job2

dbstop if error

%note no Epoch rejection at this stage, just storage.

SSRfriendly = 0; %is changed to 1 in later analysis, to skip preprocessing stages that contaminate spectral domain.

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


job.preprocIndividualVisonly=1;
job.sortbyblocktype=1;
%load channel locations for rereferncing
%%
if job.preprocIndividualVisonly==1
cd(savebase)
cd ../../../Analysis
%%
elocs = readlocs('channellocs.loc','filetype', 'loc'); %load electrode position file


cd(eegdataIN)
allppants = dir([pwd filesep 'ppant*']);

%%
%23 was KS. skip.
for ippant = [32,8]%length(allppants)
    realblock=1;
    dayis=1;
    %
    visualonlytrials=zeros(2,24,3,64,2501);
    
 
    
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
            
            
            countVis=1; %visual only
            
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
         
            allchanseachblock = procEEG(:,istartTime:iendTime);
            %%include an ICA for later use.
            
            
            
            %%save
%             cd(outPathAll)
%              diris = dir([pwd filesep '*_' num2str(initials)]);
%     cd(diris.name)
%                       save([num2str(filename)], 'allchanseachblock', 'BlockOrder', 'onsetTrialTimes', 'Casetype', 'Phasetype');
            
            
            %% Epoch by type use vis only
            %find index for visual only trials
            Visindex = find(blockout.Order<2); 
            if length(Visindex)<3
                error('checkme')
            end
            %Start times 
            starttimes=[];
            for i=1:length(Visindex)
               tmp=blockout.Chunks(2*(Visindex(i))-1);
                starttimes=[starttimes, tmp];
            end
            %convert to ms
            onsetTrialTimes= round((starttimes/60) * 1000);
            %%
            
            for iOnset = 1:length(onsetTrialTimes)
                
                trialtype = 1;
                
                
                startepoch = onsetTrialTimes(iOnset)-(abs(Epochlength(1)*EEG.srate)); % prestim and post
                endepoch = onsetTrialTimes(iOnset)+(abs(Epochlength(2)*EEG.srate)); % post
                
                try datatmp = procEEG(:, startepoch:endepoch);
                catch
                    datatmp = procEEG(:, startepoch:size(procEEG,2));
                end
                for ichan = 1:64
                    %detrend also
                    tmp = squeeze(datatmp(ichan,:));
                    
                    etrial = detrend(tmp, 'constant');
                    %
                    %remove prestim baseline
                    basetmp= etrial(1,1:abs(Epochlength(1)*EEG.srate));
                    base= mean(basetmp);
                    baset = repmat(base, 1, length(etrial));
                    tmp2 = etrial - baset;
                    
                    %%%%
                    %%%%
                    %%%%
                    %%%%
                    %downsample before saving
                    %%%%
                    %%%%
                    res_tmp=downsample(tmp2,4); % May effect time-frequency
                    ds_datatmp(ichan,:) = res_tmp;
                end

                
                %add to data book to save by type of stimulus
                
                        visualonlytrials(dayis,realblock, countVis, :,:) = ds_datatmp;
                        countVis=countVis+1;
                   
            end
                     disp(['finished block' num2str(realblock)])
            realblock=realblock+1;
            
            cd(datainPATH)
        end
    end
    cd(outPathAll)
    diris = dir([pwd filesep '*_' num2str(initials)]);
    cd(diris.name)
    save('downsampledprocd_EpochedbytypeLONG(day,block,trial,chans,samps)',...
        'visualonlytrials', '-append');
    
    
    cd(eegdataIN)
    disp(['Finished ppant ' num2str(ippant) ' of ' num2str(length(allppants)) '...'])
end
cd(outPathAll)
datapathOUT=outPathAll;
disp('Finished job 2 preprocessing vis only')
%  end

end


if job.sortbyblocktype==1
% 
% 
% %From job 3.
cd(outPathAll)

allppants = dir(['ppant*']);
%%
for ippant = 1%:length(allppants)
    cd(allppants(ippant).name)
    load('downsampledprocd_EpochedbytypeLONG(day,block,trial,chans,samps).mat')
    
    allVIS=[];
%     absEpochdur=size(preprocdhigh_long,ndims(preprocdhigh_long));
    
    %new Exp has 24 blocks, types 1:6.
    %odd numbers are in phase, even are out of phase.
    %1,2 = AnT. 3,4=Aud, 5,6=Tac. Each repeated 4 times (=24)
    %each block has 3 length of stim, short(x3), med(x2) and long(x1).
    for idayis=1:2
        
        %for robustness to only save those we have
        if idayis==1
            contfn = 'Y'; %continue function. 
        else %if day 2, only want to continue if the data has been collected!
            if size(preprocdlow_short,1)<2
                contfn='N';
            end
        end
        if strcmp(contfn,'Y')
            for imod = 1:6 %AnT, Aud, Tac.
                %new data book per freqxphase
                
                %[nblocks, ntrials, nchans, nsamps]
                dataALL_Vis=[];
                
                %
                
                countblocks = 1; %1:4 per modality (6*4 = 24)
                
                targetblocks = find(blockTYPES(idayis,:,1)==imod);
                
                if length(targetblocks)~=4 %numblocks.
                    error('count off for saved types of xmodal experiment type')
                end
                
                for iblock = 1:length(targetblocks)
                    getblock = targetblocks(iblock);
                    
                    
                    tmpVis = squeeze(visualonlytrials(idayis,getblock,:,:,:));
                    
                    
                    
                    dataALL_Vis.Block(countblocks).data=tmpVis;
                    
                    
                    countblocks = countblocks+1;
                end
                
                %save appropriately
                switch imod
                    case 1
                        allVIS.day(idayis).AnT.Inphase = dataALL_Vis;
                        
                    case 2
                        allVIS.day(idayis).AnT.Outofphase = dataALL_Vis;
                        
                    case 3
                        allVIS.day(idayis).AUD.Inphase = dataALL_Vis;
                    case 4
                        allVIS.day(idayis).AUD.Outofphase = dataALL_Vis;
                    case 5
                        allVIS.day(idayis).TAC.Inphase = dataALL_Vis;
                    case 6
                        allVIS.day(idayis).TAC.Outofphase = dataALL_Vis;
                        
                end
                
            end
        end
    end
    
    save('GroupedEpochsStructure', 'allVIS', '-append')
    
    disp(['finished for ppant' num2str(ippant) ', ' num2str(allppants(ippant).name)]);
    cd(outPathAll)
    
end
end

% disp('Finished Job 3 prep');
