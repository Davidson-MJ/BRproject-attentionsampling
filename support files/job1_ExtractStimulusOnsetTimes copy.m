% Check Localizer conditions for SSAEP and SSSEP, visualize trials and
% save stimulus onset times for epoching.
function [ dataOUT] = job1_ExtractStimulusOnsetTimes(savebase, dataIN, sanitycheckON)

dataOUT= num2str([savebase filesep 'j1_Onsets']);

dbstop if error

disp('Do you want to save to ...')
if sanitycheckON==1
    saveYN = (input([num2str(dataOUT) '?'], 's'));
else saveYN='y';
end


threshmulti=2;


blockduration = 180000; %ms approx

failedcount=1;

if saveYN == 'y'
    addpath(dataOUT);
    
    cd(num2str(dataIN));
    
    eegpath= num2str(pwd);
    
    allppants = dir([num2str(pwd) filesep 'ppant*']);
    
    %%
    
    
    for ippant =28%1:length(allppants)
        continueYN=input(['locate onsets for ppant ' num2str(allppants(ippant).name) ' Y/N:'], 's');
        if strcmp(continueYN,'y')
            disp(['Starting ppant' num2str(ippant) ' of ' num2str(length(allppants))])
            ppantIN = allppants(ippant).name;
            
            cd(num2str(ppantIN))
            datainPATH = num2str(pwd);
            
            allfilesEEG = dir([num2str(pwd) filesep '*.vhdr']);
            
            
            
            
            %%
            for i =1:length(allfilesEEG) % for each file in ppant fold
                cd(datainPATH);
                disp(['Processing file ' num2str(i) ' of ' num2str(length(allfilesEEG))]);
                
                filename= allfilesEEG(i).name;
                
                %                 try
                EEG= pop_loadbv(num2str(pwd), num2str(filename));
                
                %                     Trigger codes: 'S [1,2,3,4,5]' = stim on (vis, lowin, highin, lowout,
                %                     highout)
                %
                %                                   'S 55' = stim off
                %                                   'S
                %                                   'S
                %                                   'S
                
                %locate start of Blocks, trigger
                block_end=[];
                %                     blockstart=[];
                
                for iEvent = 1:length(EEG.event)
                    switch EEG.event(iEvent).type
                        
                        case 'S 88'
                            block_end = [block_end, EEG.event(iEvent).latency];
                            
                    end
                    
                end
                block_start=[];
                %             if length(block_end)<6 %missing final trigger
                %                 block_end = [block_end, length(EEG.data(1,:))];
                %             end
                for iblock = 1:length(block_end)
                    block_starttmp = block_end(iblock) - blockduration;
                    if block_starttmp<0; %prerecording, so realign to 1
                        block_starttmp = 1;
                    end
                    block_start = [block_start, block_starttmp];
                end
                
                
                Timesecs = (1:size(EEG.data,2))/EEG.srate;
                
                
                
                %for each block collect the responses in both
                %channels.
                %Locate onset based on physical stimuli for tone channels
                for ieachblock = 1:length(block_start)
                    istartTime = block_start(ieachblock);
                    iendTime = block_end(ieachblock);
                    plotspot=1;
                    
                    for icheckchan = 1:2 %
                        
                        switch icheckchan
                            case 1
                                iChan=67;
                                %                                     type=
                                %                                     'tactile'
                            case 2
                                iChan=68;
                                %                                     type = 'audio' (whitenoise);
                        end
                        
                        chanInput = EEG.data(iChan,istartTime:iendTime);
                        %                     chanInput = EEG.data(iChan,:);
                        bc_chanInput= chanInput - mean(chanInput); %rmvbaseline
                        sqbc_chanInput= bc_chanInput.^2; %square for power
                        
                        %filter high freq noise.
                        %                     filtrlength = 100; %points for filt Order.
                        %                     srate=1000;
                        %     fHighcutoff= 25; %may want
                        %     flowcutoff = 1;
                        %     Wn = (2/srate)*fHighcutoff; %hz cutoff normalized.
                        %     Wnl= (2/srate)*flowcutoff;
                        %
                        %     fir_coeffbandp = fir1(filtrlength,[Wnl Wn]);
                        %
                        %
                        %         sqbc_chanInput = filter(fir_coeffbandp, 1, sqbc_chanInput);
                        
                        %set threshold to search for stimulus beginning
                        threshold(1,icheckchan)=threshmulti*std(sqbc_chanInput);
                        
                        
                        
                        printfilename= ['AUTOTrial Onsets for rec(' num2str(i) '), block(' num2str(ieachblock) '), both stim channel, ' num2str(ppantIN) ];
                        set(0, 'DefaultFigurePosition', [0 2000 2000 2000]);
                        if sanitycheckON==1; %user decides which channel;
                            
                            set(gcf, 'Name', num2str(printfilename), 'NumberTitle', 'off', 'visible', 'on');
                            
                            
                            
                            subplot(2,1,plotspot)
                            plot(Timesecs(istartTime:iendTime), sqbc_chanInput)
                            title([num2str(iChan) num2str(threshold(plotspot))])
                            plotspot=plotspot+1;
                            
                            
                        else
                            set(gcf, 'Name', num2str(printfilename), 'NumberTitle', 'off', 'visible', 'off');
                        end
                    end
                    if sanitycheckON==1
                        whichchan = str2num(input('Which Channel for collecting onsets? [1/2]', 's'));
                        
                        if whichchan==1
                            iChan=67;
                            exptype='TAC';
                            
                        elseif whichchan==2
                            iChan=68;
                            exptype='AUD';
                            
                        elseif whichchan==3
                            exptype='AnT';
                            iChan=68;
                        end
                    else
                        
                        %go with the channel with the larger threshold
                        if threshold(1)>threshold(2)
                            iChan=67;
                            %                         exptype='TAC';
                        else
                            iChan=68;
                            %                     exptype='AUD';
                        end
                        
                    end
                    
                    
                    
                    chanInput = EEG.data(iChan,istartTime:iendTime);
                    bc_chanInput= chanInput - mean(chanInput); %rmvbaseline
                    sqbc_chanInput= bc_chanInput.^2; %square for power
                    
                    %set threshold to search for stimulus beginning
                    threshold=threshmulti*std(sqbc_chanInput);
                    
                    %%  find the onset of each audio/tactile trial
                    
                    iTrial = 0;
                    
                    nTrial=12;
                    
                    
                    skipDur = 7;  % duration to be skipped in sec (trial onset length) before looking for the next trial
                    n_skipDur = skipDur * EEG.srate; % # of points to be skipped
                    onsetTrialTimes = nan*ones(1,nTrial);
                    iTime=0;
                    saveTrials=1:12;
                    
                    while 1
                        
                        iTime = iTime+1;
                        
                        if iTime<length(sqbc_chanInput)
                            if sqbc_chanInput(iTime) > threshold;
                                iTrial = iTrial + 1;
                                onsetTrialTimes(1,iTrial) = iTime ;
                                iTime = iTime+ n_skipDur;
                            end
                        else
                            %missed a trial (iTime ran out).
                            %reset
                            iTime=0;
                            iTrial=0;
                            disp(['block length expired, reset threshold'])
                            threshmulti= input(['Set new threshold multi prev= ' num2str(threshmulti) ': '] ,'s');
                            threshmulti=str2num(threshmulti);
                            clf
                            plot(Timesecs(istartTime:iendTime), sqbc_chanInput)
                            hold on
                            plot(Timesecs(istartTime)*[1 1],ylim,'k')
                            threshold=threshmulti*std(sqbc_chanInput);
                            plot(xlim,threshold*[1 1],'g');
                            nTrial=input(['Collect how many trials before trimming?'],'s');
                            nTrial=str2num(nTrial);
                            saveTrials=  input(['Which indexed trials to save (A:B)='] ,'s');
                            saveTrials=str2num(saveTrials);
                        end
                        if iTrial == nTrial
                            break
                        end
                        
                    end
                    % add to compensate for the start of the block
                    
                    onsetTrialTimes = onsetTrialTimes+istartTime;
                    onsetTrialTimes=onsetTrialTimes(saveTrials);
                    
                    %%
                    % sanity check for tone onset...
                    clf
                    plot(Timesecs(istartTime:iendTime), sqbc_chanInput)
                    hold on
                    plot(Timesecs(istartTime)*[1 1],ylim,'k')
                    plot(xlim,threshold*[1 1],'g')
                    
                    for iTrial = 1:length(onsetTrialTimes)
                        plot(Timesecs(onsetTrialTimes(iTrial)) *[1 1],ylim,'r')
                    end
                    
                    title(['Save Onsets for ppant' num2str(ippant) 'recording' num2str(i) ', block' num2str(ieachblock) ' as below ?'], 'fontsize', 20)
                    
                    
                    if iChan==67; %only check audio channels to save time.
                        shg
                        goodonsetsYN= input('Do you want to save these onset times? (see figure) y/n:' ,'s');
                        
                        if sanitycheckON==1 %save individual block types, slowly...
                            if strcmp(goodonsetsYN,'n')
                                %collect new search parameters.
                                threshmulti= input(['Set new threshold multi prev= ' num2str(threshmulti) ': '] ,'s');
                                threshmulti=str2num(threshmulti);
                                 nTrial=input(['Collect how many trials before trimming?'],'s');
                                    nTrial=str2num(nTrial);
                                    saveTrials=  input(['Which indexed trials to save (A:B)='] ,'s');
                                    saveTrials=str2num(saveTrials);
                                
                            end
                            %if sanity check ON, keep trying until right threhsolds
                            %are found
                            iTime=0;
                            iTrial=0;
                            while strcmp(goodonsetsYN,'n')     %recollect onsets with new threshold
                                iTime = iTime+1;
                                if iTime==1
                                    clf
                                    %replot data
                                    plot(Timesecs(istartTime:iendTime), sqbc_chanInput)
                                    hold on
                                    plot(Timesecs(istartTime)*[1 1],ylim,'k')
                                    threshold=threshmulti*std(sqbc_chanInput);
                                    plot(xlim,threshold*[1 1],'g');
                                    hold on
                                end
                                if iTime<length(sqbc_chanInput)
                                    if sqbc_chanInput(iTime) > threshold;
                                        iTrial = iTrial + 1;
                                        onsetTrialTimes(1,iTrial) = iTime ;
                                        iTime = iTime+ n_skipDur;
                                    end
                                else
                                    %missed a trial (iTime ran out).
                                    %reset
                                    iTime=0; %reset counters
                                    iTrial=0;
                                    disp(['block length expired, reset threshold'])
                                    threshmulti= input(['Set new threshold multi prev= ' num2str(threshmulti) ': '] ,'s');
                                    threshmulti=str2num(threshmulti);
                                    nTrial=input(['Collect how many trials before trimming?'],'s');
                                    nTrial=str2num(nTrial);
                                    saveTrials=  input(['Which indexed trials to save (A:B)='] ,'s');
                                    saveTrials=str2num(saveTrials);
                                    
                                end
                                if iTrial == nTrial
                                    clf
                                    plot(Timesecs(istartTime:iendTime), sqbc_chanInput)
                                    hold on
                                    plot(xlim,threshold*[1 1],'g');
                                    hold on
                                    title(['Save Onsets for ppant' num2str(ippant) 'recording' num2str(i) ', block' num2str(ieachblock) ' as below?'], 'fontsize', 20)
                                    %plot captured 12 onsets.
                                    onsetTrialTimes=onsetTrialTimes+istartTime;
                                    for iTrial = saveTrials
                                        plot(Timesecs(onsetTrialTimes(iTrial)) *[1 1],ylim,'r')
                                    end
                                    shg
                                    goodonsetsYN= input('Do you want to save these onset times? (see figure) y/n:' ,'s');
                                    if strcmp(goodonsetsYN,'n')
                                        threshmulti= input(['Set new threshold multi prev= ' num2str(threshmulti) ': '] ,'s');
                                        threshmulti=str2num(threshmulti);
                                        nTrial=input(['Collect how many trials before trimming?'],'s');
                                        nTrial=str2num(nTrial);
                                        saveTrials=  input(['Which indexed trials to save (A:B)='] ,'s');
                                        saveTrials=str2num(saveTrials);
                                        iTime=0; iTrial=0;
                                        onsetTrialTimes=nan(1,nTrial) ;
                                    else
                                        
                                        onsetTrialTimes=onsetTrialTimes(saveTrials);
                                        
                                    end
                                end
                                
                            end
                            
                            
                            
                            
                        else %if not checking individual trials.
                            if strcmp(goodonsetsYN,'n')
                                failedOnsets(failedcount).all=['ppant' num2str(ippant) 'recording' num2str(i) ', block' num2str(ieachblock)];
                                failedcount=failedcount+1;
                            end
                        end
                    else
                        goodonsetsYN='y';
                    end
                    %%
                    if goodonsetsYN=='y' %only save if good
                        cd(num2str(dataOUT));
                        
                        try cd(ppantIN)
                            % save at ppant level
                        catch
                            mkdir(num2str(ppantIN))
                            cd(ppantIN)
                            
                        end
                        savedir = num2str(pwd);
                        
                        disp('printing...saving..');
                        %                     if sanitycheckON==1
                        print('-dpng',printfilename);
                        clf
                        %                         sca
                        %                     end
                        save(num2str(printfilename), 'onsetTrialTimes', 'istartTime', 'iendTime');
                        
                        cd(eegpath)
                    else
                        disp(['failed onsets for ' num2str(ppantIN) ', rec ' (i) ','  num2str(filename)])
                    end
                    
                    
                end
                %             clearvars -except threshmulti savebase ippant dataOUT filecountYN savedir eegpath allppants allfilesEEG missedEEGLocOnsets ppantIN missedcount misseddetails dataIN datainPATH sanitycheckON blockduration
                cd(ppantIN)
            end
            cd(num2str(savedir))
            
            
            cd(num2str(dataIN))
        end
        disp(['Finished ppant' num2str(ippant) ' of ' num2str(length(allppants))])
    end
else
    disp('Rerun after changing savebase')
end

try disp(failedOnsets(:).all)
catch
end

end

