%super datafile creation for easy storage and view of data types per ppant
%conditions.


clear all
close all
%set up directories
try cd('/Users/MattDavidson/Desktop/XM_Project')
catch
    cd('/Users/MatthewDavidson/Desktop/XMODAL')
    addpath('/Users/matthewdavidson/Documents/GitHub/Crossmodal_BinocularRivalry-Supportfiles-master')
    
end
basedir = pwd;
cd('DATA_newhope')
Behaviouraldatadir = pwd;
try cd('/Users/MattDavidson/Desktop/XM_Project/EEGData/DATA/Processed/EEG_from_Attention_XmodalEXP')
catch
%     cd('/Users/MatthewDavidson/Desktop/XMODAL/')
end
EEGdatadir = pwd;

%%
checkshape=0; %change to 1 to inspect SNR kernel.
%only collect attended day Data %changed to both days
epochlength = [-5 5]; %seconds note that this and the next (EEG) epochs need to be consistent for plotting and to retain the order.
%% just collecting BEH data for now.
% paramsMT.tapers= [1, 1];
% paramsMT.fpass = [1, 60]; %above 50 to check kernel width at 50Hz.
% paramsMT.Fs = 250;
% paramsMT.pad= 1; %helps with kernel
% movingwin = [1.5, .2];

% for kernel construction
% noisebinwidth =2;
%%

cd(basedir)
cd(Behaviouraldatadir)
% Type is
%%

cd(basedir)
cd(Behaviouraldatadir)
allppants = dir([pwd filesep  '*' '_Attn' '*']);
allppantInitials =  cell(1,length(allppants));
for i=1:length(allppants)
    
    allppantInitials(i)= {num2str(allppants(i).name(1:2))};
end

allppantsInitials = unique(allppantInitials); %avoid doing the cycle twice!

%%
tic
for ippant=1:length(allppantsInitials) %now 2 entries per ppant, so Nallppants = 68!
    
    cd(basedir)
    cd(Behaviouraldatadir)
    initialstocheck = allppantsInitials{ippant};
    
    ppantfols= dir([pwd filesep  initialstocheck '*' '_Attn' '*']);
    
    
    % for ippant = allppants
    %% CATEGORIES OF DATA FILE (COLUMNS)
    
    categories = {'Participantref',...
        'Initials',...
        'DayofTesting',...
        'Date',...
        'AttentionCond',...
        'BlockthisDay',...
        'XMOD',...
        'LeftEyeHz',...
        'LeftEyeCol',...
        'SwitchNumber',...
        'SwitchDirection',...
        'PreviousPerceptDuration',...
        'ThisPerceptDuration',...
        'DuringChunkedPeriod',... %yes/no
        'TrialTypeDuringSwitch',...
        'Hz',...
        'Phase',...
        'Duration',...
        'TimeSinceStimOnset',...%Time since previous onset *should be identical to above if During ==yes
        'TimeSinceStimOffset',...
        'TimeUntilnextStimOnset',...
        'TimeUntilnextStimOffset',...
        'PrevTrialTypetoSwitch',...};
        'NextTrialTypetoSwitch',...};       
        'Timesteps'};
    
    % create column headings
    datafile = cell(1);
    datafile(1,1:length(categories)) = categories;
    %fill for first participant
    %% Behavioural data first.
    
    %%%%%%% change here based on TYPE we are interested in.
    for ixmod=1:2
        
        
        
        switch ixmod
            case 1
                % just looking at AnT Attend.
                ddir='Across Exp Auditory and Tactile, In phase';
                XMOD='AnT';
            case 2
                ddir='Across Exp Auditory and Tactile, Anti phase';
                XMOD='AnT';
            case 3
                ddir='Across Exp Auditory, In phase';
                XMOD='AUD';
            case 4
                ddir='Across Exp Auditory, Anti phase';
                XMOD='AUD';
            case 5
                ddir='Across Exp Tactile, In phase';
                XMOD='TAC';
            case 6
                ddir='Across Exp Tactile, Anti phase';
                XMOD='TAC';
        end
        
        
        
        %phase type of these stimuli:
        if mod(ixmod,2)~=0
            Phase = 'In';
        else
            Phase = 'Outof';
        end
        
        
        
        
        initialsare = initialstocheck;
        
        cd(Behaviouraldatadir)
        cd(ddir);
        
        
        %%
        
        
        for iday = 1:2
            cd(Behaviouraldatadir)
            cd(ddir)
            
            load(ppantfols(iday).name) %this loads experimental conditions
            
            for iblock = 1:4 %there are four repetitions of each Phase x XMODcombo per day.
                
                %% blockindex
                realblockindex=params.ExpOrder(3:26,:);
                blockexp=find(realblockindex(:,1)==ixmod,iblock); %find the appropriate index, for this block type, out of 24
                blockstore=blockexp(iblock);
                %eye condition.
                cond = realblockindex(blockstore,2);
                
                %now switch order/info
                cd(Behaviouraldatadir)
                pfol = dir([pwd filesep initialsare '*' 'Attn' '*']);
                cd(pfol(iday).name)
                
                load(['Block' num2str(blockstore) 'Exp' num2str(ixmod) '_Cond' num2str(cond) '.mat'])
                if params.AttendEXP==1
                    load('CountedTones.mat')
                end
                
                %CalculateSwitchdata (based on other scripts).
                [switchpoint, stimswitchNOW, stimswitchINDX, switchFROM, mixed_durationALL]=calcswitchDataforCREATEfile2(blockout);
                outsidestimswitches = find(ismember([1:length(switchpoint)], stimswitchNOW)==0);
                
                %how many rows (ie switches) for this block?
                allswitches = switchpoint;
                
                %correct for previous entries
                if size(datafile,1)==1
                    rowindex = 2:length(allswitches)+1;
                else
                    rowindex = (size(datafile,1)+1):((size(datafile,1)) + length(allswitches));
                end
                
                
                
                %fill block data:trials
                datafile(rowindex,1) = {ippant};
                %% initials are
                datafile(rowindex,2) = {params.Initials};
                %% Dayis
                datafile(rowindex,3) = {params.Day1_2};
                %% Date is
                dateis=params.namedir(7:10);
                datafile(rowindex,4) = {dateis};
                %% condition is
                
                if params.AttendEXP==1
                    Ais='On';
                else
                    Ais='Off';
                end
                datafile(rowindex,5) = {Ais};
                
                
                datafile(rowindex,6) = {blockstore};
                
                %% XMOD
                datafile(rowindex,7) = {XMOD};
                %% Left eye params
                
                switch cond
                    case 1
                        Speed = 'L';Colour = 'G';
                    case 2
                        Speed = 'H';Colour = 'G';
                    case 3
                        Speed = 'L';Colour = 'R';
                    case 4
                        Speed = 'H';Colour = 'R';
                end
                datafile(rowindex,8) = {Speed};
                datafile(rowindex,9) = {Colour};
                %% Trial num
                
                datafile(rowindex,10) = num2cell((1:length(allswitches))');
                
                %switch direction, calculated by BP vs Eye cond (from
                %output above)
                %change to string
                
                if strcmp(Speed,'H') %left eye high speed
                    %change switch direction so negative is always
                    %LowHz
                    switchFROM = switchFROM*-1;
                end
                %replace with category labels
                tmp=[];
                for i=1:length(switchFROM)
                    if switchFROM(i)<1
                        diris='pf1_pf2';
                    else
                        diris = 'pf2_pf1';
                    end
                    %store direction
                    datafile(rowindex(i),11) = {diris};
                end
                
                %Previous percept duration (prior to start of mixed
                %or switch)
                durations = diff([1 switchpoint 10500]); %accounting for block fin
                preperceptdurations = durations(1:(end-1)); %shifted
                postperceptdurations = durations(2:end); %shifted
                
                %store
                datafile(rowindex,12) = num2cell(round(preperceptdurations/60,1)');
                datafile(rowindex,13) = num2cell(round(postperceptdurations/60,1)');
                
                %% indicate which switches were during cross modal
                for ist = 1:length(stimswitchNOW)
                    %this is the number of the switch, this block
                    trialindex = stimswitchNOW(ist);
                    
                    tmp = stimswitchINDX(ist);
                    stimis=checkme.OrderIN(tmp);
                    
                    switch stimis
                        case 1 %vis only
                            tnow = 'VisX';
                            dnow = '2.6';
                        case 82
                            tnow = 'Low';
                            dnow = '2';
                        case 83
                            tnow = 'Low';
                            dnow = '3.1';
                        case 84
                            tnow = 'Low';
                            dnow = '4';
                            
                        case 92
                            tnow = 'High';
                            dnow = '2';
                        case 93
                            tnow = 'High';
                            dnow = '3.1';
                        case 94
                            tnow = 'High';
                            dnow = '4';
                    end
                    datafile(rowindex(trialindex),14)= {'Yes'};
                    datafile(rowindex(trialindex),15)= {stimis};
                    datafile(rowindex(trialindex),16) = {tnow};
                    datafile(rowindex(trialindex),17) = {Phase};
                    
                    datafile(rowindex(trialindex),18) = {dnow};
                end
                
                %complete data for vis only outside chunks.
                datafile(rowindex(outsidestimswitches),14) = {'No'};
                
                %
                %% Now find time since previous tone onset for all
                %Onsets are odd numbers in Chunks, offsets are even.
                allch = blockout.Chunks;
                Onsets =allch([1:2:length(allch)]);
                Offsets =allch([2:2:length(allch)]);
                for isw = 1:length(switchpoint)
                    %for onsets
                    for onoff=19:20
                        switch onoff
                            case 19
                                uset=Onsets;
                            case 20
                                uset=Offsets;
                        end
                        [~,ind]= min(abs(uset-switchpoint(isw)));
                        eventtime= uset(ind) ;
                        Diffis = switchpoint(isw) - eventtime;
                        if Diffis <0 %diff is time to next event.
                            
                            datafile(rowindex(isw),onoff+2) = {round(abs(Diffis)/60,1)};
                            %also previous event
                            if ind>1
                                prevevent = switchpoint(isw) - uset(ind-1);
                                prevtype = checkme.OrderIN(ind-1);
                                
                                datafile(rowindex(isw),onoff) = {round(abs(prevevent)/60,1)};
                                datafile(rowindex(isw),onoff) = {round(abs(prevevent)/60,1)};
                                
                                
                                
                            else
                                datafile(rowindex(isw),onoff) = {'NaN'};
                                
                                
                            end
                            
                            %save the previous stim type
                            
                            
                        else %Diffis time from previous event
                            datafile(rowindex(isw),onoff) = {round(abs(Diffis)/60,1)};
                            
                            %also timeto next event
                            if ind<15
                                prevevent = switchpoint(isw) - uset(ind+1);
                                datafile(rowindex(isw),onoff+2) = {round(abs(prevevent)/60,1)};
                                
                                
                                
                            else
                                %timing
                                datafile(rowindex(isw),onoff+2) = {'NaN'};
                                
                                
                                
                                
                            end
                            
                        end
                    end
                    
                    
                    %%
                    nextonset = find(Onsets>switchpoint(isw), 1);
                    prevoffset=find(Offsets<switchpoint(isw), 1);
                    if prevoffset
                        datafile(rowindex(isw), 23) = {checkme.OrderIN(prevoffset)};
                    else
                        datafile(rowindex(isw), 23) = {'NaN'};
                    end
                    if nextonset
                        datafile(rowindex(isw), 24) = {checkme.OrderIN(nextonset)};
                    else
                        datafile(rowindex(isw), 24) = {'NaN'};
                    end
                    %%
                end
                %% Now collect EEG
%                 cd(EEGdatadir)
%                 cd('jSW_1_blockEpoched')
%                 pfol = dir([pwd filesep 'ppant' '*' initialsare]);
%                 cd(pfol.name)
%                 %%
%                 load(['Day(' num2str(iday) '),Block(' num2str(blockstore) ').mat']);
%                 % Note that this includes an adjustment that needs to be
%                 % made in frames to the EEG trace.
%                 
%                 %switchpoints to time EEG by
%                 switchEEGtimes = switchpoint-BPlaginframes;
%                 
%                 %For each switch, Epoch around and store the mtspectrogram.
%                 % mtspectrogram whole block, then chop up (it's faster).
%                 %%
%                 
%                 dsdata=downsample(blockdata',4); % May effect time-frequency
%                 chandata=squeeze(dsdata(:,1:64))';
%                 timingEEG = (1:length(chandata) )/ 250;
%                 
%                 %for each switch, epoch and save
%                 for isw=1:length(switchEEGtimes)
%                     tswitch = switchEEGtimes(isw)/60;
%                     if tswitch>6 && tswitch< 168 % ignore start of blocks.
%                         %
%                         %epoch
%                         [~,tstart]= min(abs(timingEEG - (tswitch-5))) ;
%                         [~,tend]= min(abs(timingEEG - (tswitch+5))) ;
%                         usedata = chandata(:,tstart:tend);
%                         
%                         % preprocess
%                         for ichan = 1:64
%                         tmp = usedata(ichan,:);
%                         a1= tmp-mean(tmp); %demean
%                         usedata(ichan,:) = detrend(a1, 'linear');
%                         end
%                         
%                         [spec, timespec, freqspec]=mtspecgramc(usedata', movingwin, paramsMT);
%                         
%                         ls=10*log10(spec.^2);
%                         
%                         
%                         %calc SNR using kernel.
%                         if ~exist('kernel')
%                             tapers=1;
%                             timewin=movingwin(1);
%                             
%                             etrial=squeeze(ls(1,:,32)); %single timepoint, single chan, all freqs
%                             [kernel,~]=buildconvSNRkernel(tapers, timewin, freqspec, noisebinwidth, 1, etrial);
%                         end
%                         
%                         %perform SNR convolution over all chans, then store
%                         %times of interest:
%                         SNRdata=zeros(size(ls));
%                         
%                         %SNR via convolution, %comparing to surrounding freqs.
%                         
%                         for ichan=1:size(ls,3)
%                             for itime=1:size(ls,1)
%                                 tspec=squeeze(ls(itime,:,ichan));
%                                 snrtmp= conv(tspec,kernel, 'same');
%                                 SNRdata(itime,:,ichan)=snrtmp;
%                             end
%                         end
%                         
%                         [~, f1] = min(abs(freqspec - 4.5));
%                         [~, f2] = min(abs(freqspec - 20));
%                         [~, fnegimF] = min(abs(freqspec - 15.5));
%                         [~, fposimF] = min(abs(freqspec - 24.5));
%                         [~, twof1] = min(abs(freqspec - 9));
%                         [~, threef1] = min(abs(freqspec - 13.5));
%                         [~, twof2] = min(abs(freqspec - 40));
%                         
%                          
%                         %epoch here.
%                         
%                         %low TF
%                         datafile(rowindex(isw), 25) = {squeeze(SNRdata(:,f1,:))};
%                         %high tf
%                         datafile(rowindex(isw), 26) = {squeeze(SNRdata(:,f2,:))};
%                         %intermods
%                         datafile(rowindex(isw), 27) = {squeeze(SNRdata(:,fnegimF,:))};                        
%                         datafile(rowindex(isw), 28) = {squeeze(SNRdata(:,fposimF,:))};
%                         %harms
%                         datafile(rowindex(isw), 29) = {squeeze(SNRdata(:,twof1,:))};
%                         datafile(rowindex(isw), 30) = {squeeze(SNRdata(:,threef1,:))};
%                         datafile(rowindex(isw), 31) = {squeeze(SNRdata(:,twof2,:))};
%                         
%                     end
%                 end
                
                % epoch increments after spectrogram:
%                 
%                 %%
%                 if length(timing)~=51
%                     error('checkme')
%                 end
%                 datafile(rowindex, 27) = {timing};
            end
            
            
        end %trialtype for EEG analysis
        %increase row index after each block
        
        
    end
    %id / files (day 1 vs 2)
    
    %%
    
    % end %xmod Inphase/Out
    %
    cd(basedir)
    cd('ANOVAdata_allppants')
    %%
    participant= initialstocheck;
    %%
    cd(XMOD);
    %%
%     timing = timespec-5;
timing=[]; timespec=[]; freqspec=[];
    save([XMOD 'datafile_BPaligned_' num2str(participant) '.mat'], 'datafile', 'freqspec', 'participant', 'timespec', 'timing');
    disp(['Fin ' num2str( ippant)])
end
toc