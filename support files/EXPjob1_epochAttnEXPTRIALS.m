% epoch SSVEP trials
exppath = pathtoBehaviouraldata;
eegpath= '/Users/MattDavidson/Desktop/XM_Project/EEGData/MD_AttentionXmodal';


sanitycheckON=0;

nrealblock=1; %starting from where?

thresh67=.25; %specific multipliers per channel.
thresh68=.25;
threshmulti=3;

fontsize=10;
%
cd(eegpath)
allfoldersEEG = dir([pwd filesep 'ppant*']);
nppants= length(allfoldersEEG);

%%
dbstop if error
for     ippant = 28%1:nppants
    cd(eegpath)
    
    cd(allfoldersEEG(ippant).name)
    
    ppantdir = num2str(pwd);
    
    allfilesEEG = dir([pwd filesep '*vhdr']);
    
    cd(pathtoProcdatadir)
    
    initials=num2str(ppantdir(end-1:end));
    
    ppantcontinue= input(['Continue with ppant ' num2str(initials) '?'], 's');
    if strcmp(ppantcontinue, 'y')
        
        try cd(allfoldersEEG(ippant).name)
        catch
            mkdir(allfoldersEEG(ippant).name)
            cd(allfoldersEEG(ippant).name)
        end
        
        
        
        startrec = str2num(input(['Start at which EEG rec (5 = day2)?'], 's'));
        %%
        dayis=1;
        for iEEGrec = startrec:length(allfilesEEG) %(each block).
            cd(eegpath)
            cd(ppantdir)
            
            disp(['Processing file ' num2str(iEEGrec) ' of ' num2str(length(allfilesEEG))]);
            
            filename= num2str(allfilesEEG(iEEGrec).name);
            
            EEG= pop_loadbv(num2str(pwd), num2str(filename));
            
            %% locate blocks within eegrecording (6 per recording)
            count=1;
            Trialeventendlatency=[];
            Trialeventend=[];
            for iEvent= 1:length(EEG.event)
                switch  EEG.event(iEvent).type
                    case 'S 88' %block end
                        
                        Trialeventend(count) = iEvent;
                        Trialeventendlatency(count)= EEG.event(iEvent).latency;
                        count=count+1;
                        
                end
            end
            %%
            initials=filename(1:2);
            % find behavioural data
            if iEEGrec==5 %reset counter.
                dayis=2;
                nrealblock=1;
            elseif iEEGrec>4
                dayis=2;
            elseif iEEGrec==1
                nrealblock=1;
            end
            
            
            cd(num2str(exppath))
            
            %%
            ppantfol = dir([pwd filesep initials '_*' 'Day' num2str(dayis) '*']);
            
            %%
            
            cd(num2str(ppantfol.name))
            load('Seed_Data');
            
            ExpOrder(dayis,:,:)= Exps(3:26,:);
            %%
            for iblock = 1:length(Trialeventend) %6 blocks per recording
                cd(num2str(exppath))
                cd(num2str(ppantfol.name))
                clf
                
                
                %%
                %% load behavioural trigger info for timing,
                %     loadblock = ((iEEGrec-1)*6)+iblocktmp;
                filetoload = dir([pwd filesep 'Block' num2str(nrealblock) 'Exp*.mat']);
                load(num2str(filetoload.name));
                Trials = blockout.Trials;
                endtriggerlat = Trialeventendlatency(iblock);
                endstamp = endtriggerlat;
                startstamp=  endstamp - (175*EEG.srate);
                
                if startstamp<0
                    startstamp = 1;
                end
                
                %% load trial information that matches the EEG epoch
                %%%%% align first significant physical channel (tone
                %%%%% onset) with the trigger code for tone onset, and adjust the
                %%%%% lag
                %%
                
                %%
                
                blockdata = EEG.data(:, startstamp:endstamp);
                
                
                eegtime = (1:length(blockdata))/EEG.srate;    %srate
                %%
                dbstop if error
                
                %plot if working through by hand
                if sanitycheckON==1
                    figure(1)
                    clf
                    trialstime = (1:length(Trials))/blockout.scrRate;
                    %plot each exg channel.
                    starttrig = find(Trials>1,1, 'first');
                    for isub=1:2
                        subplot(2,1,isub)
                        
                        physchan = blockdata(66+isub,:);
                        cd_physchan = abs(physchan - mean(physchan));
                        sdevchan=threshmulti*std(cd_physchan);
                        plot(eegtime, cd_physchan, 'b')
                        hold on
                        plot(xlim, [1*std(cd_physchan) 1*std(cd_physchan)], 'r')
                        plot(xlim, [2*std(cd_physchan) 2*std(cd_physchan)], 'r')
                        plot(xlim, [3*std(cd_physchan) 3*std(cd_physchan)], 'r')
                        plot(xlim, [4*std(cd_physchan) 4*std(cd_physchan)], 'r')
                        plot([starttrig/blockout.scrRate starttrig/blockout.scrRate], ylim, 'r', 'linewidth', 3)
                        title(['block' num2str(nrealblock) ' , day ' num2str(dayis)])
                        xlim([0 starttrig/blockout.scrRate+.5])
                    end
                    
                    
                    %%
                    whichCHAN = upper(input('1, 2, or 0?', 's'));
                    threshmulti=input(['New threshmulti (prev ' num2str(threshmulti) ')=']);
                    
                    %%
                    switch whichCHAN
                        case '1'
                            physchan = blockdata(67,:);
                            cd_physchan = abs(physchan - mean(physchan));
                            sdevchan=threshmulti*std(cd_physchan);
                        case '2'
                            physchan = blockdata(68,:);
                            cd_physchan =abs( physchan - mean(physchan));
                            sdevchan=threshmulti*std(cd_physchan);
                        case '0'
                            BPlaginframes=input('Move BP how many frames earlier?');
                            
                    end
                    %% require input before moving on.
                    continueYN='n';
                    if ~strcmp(whichCHAN,'0')
                        %index first tone onset
                        disp('plotting again')
                        onset1= find(cd_physchan>sdevchan,1,'first');
                        % plot([onset1/1000 onset1/1000], ylim, ['k' '-'])
                        
                        %index trig onset
                        starttrig = find(Trials>1,1, 'first');
                        
                        %convert both to seconds.
                        timeBPstim1= starttrig/blockout.scrRate; %
                        timeEEGstim1=onset1/EEG.srate; %
                        
                        lagbetween = timeBPstim1-timeEEGstim1; %in seconds
                        
                        
                        
                        %move EEG onset to match Trial onset
                        lag = timeBPstim1-timeEEGstim1;
                        BPlaginframes = round(lag*blockout.scrRate);
                        
                        %adjust the length of the plotTrial
                        shiftframes =zeros(1,abs(BPlaginframes));
                        plotTrial=[];
                        if BPlaginframes > 0 %Trials are after EEG onset, so put Nan at end of Trials.
                            plotTrial=horzcat(Trials(1+length(shiftframes):end), shiftframes); %add NaN(s) at the beginning to maintain length
                            movement='sooner';
                        elseif BPlaginframes<0
                            %add nan at end, to delay the behavioural trace.
                            plotTrial=horzcat(shiftframes, Trials(1:(end-length(shiftframes))));
                            movement='later';
                        elseif BPlaginframes==0
                            plotTrial=Trials;
                            movement='(no change)';
                            
                        end
                        
                        %%plot to check if successful
                        figure(1)
                        %%
                        clf
                        eegtime = (1:length(cd_physchan))/EEG.srate;
                        for ipl=[1, 3]
                            subplot(4,1,ipl)
                            plot(eegtime, abs(cd_physchan))
                            hold on
                            plot(xlim, [sdevchan sdevchan], ['-' 'k'], 'linewidth', 2)
                            hold on
                            trialstime = (1:length(Trials))/blockout.scrRate;
                            %
                            plot([starttrig/blockout.scrRate starttrig/blockout.scrRate], ylim, 'r', 'linewidth', 3)
                            
                            plot(trialstime, Trials*2, 'r', 'linewidth', 1)
                            title(['Old alignment Block '  num2str(nrealblock) ' day ' num2str(dayis)], 'fontsize', fontsize*2)
                        end
                        subplot(4,1,3)
                        xlim([starttrig/blockout.scrRate-.1 starttrig/blockout.scrRate+.1])
                        title('Old, zoomed at first onset', 'fontsize', fontsize*2)
                        %%
                        newtrig=  find(Trials>1,1, 'first');
                        
                        
                        for ipl=[2,4]
                            subplot(4,1,ipl)
                            plot(eegtime, abs(physchan))
                            
                            hold on
                            plot(trialstime, plotTrial, 'r', 'linewidth', 1)
                            plot([newtrig/blockout.scrRate newtrig/blockout.scrRate], ylim, 'r', 'linewidth', 3)
                            
                            title(['new, saved as start BP ' num2str(abs(BPlaginframes)) 'frames ' num2str(movement)], 'fontsize' ,fontsize*2)
                        end
                        subplot(4,1,4)
                        title(['new, saved as start BP ' num2str(abs(BPlaginframes)) 'frames ' num2str(movement)], 'fontsize', fontsize*2)
                        xlim([starttrig/blockout.scrRate-.1 starttrig/blockout.scrRate+.1])
                        
                        
                        %%
                        
                    end
                    StD=sdevchan;
                    
                    continueYN='y';
                    
                    
                else %  no sanity check, just collect on raw best guess.
                    
                    
                    
                    %select channel with higher SD.
                    physchan = blockdata(67,:);
                    cd_physchan = abs(physchan - mean(physchan));
                    SD1 = std(cd_physchan);
                    max67=max(cd_physchan);
                    
                    physchan = blockdata(68,:);
                    cd_physchan = abs(physchan - mean(physchan));
                    SD2= std(cd_physchan);
                    max68=max(cd_physchan);
                    
                    if max68>max67 %whichever has more activity.
                        
                        whichchan='2';
                        threshmulti=thresh67;
                        physchan = blockdata(68,:);
                        cd_physchan = abs(physchan - mean(physchan));
                    else
                        whichchan='1';
                        threshmulti=thresh68;
                        physchan = blockdata(67,:);
                        cd_physchan = abs(physchan - mean(physchan));
                        
                        
                    end
                    
                    %calculate lag and adjust trial accordingly.
                    %index trig onset
                    StD= threshmulti*std(cd_physchan);
                    trialstime = (1:length(Trials))/blockout.scrRate;
                    onset1= find(cd_physchan>StD,1,'first');
                    starttrig = find(Trials>1,1, 'first');
                    
                    %convert both to seconds.
                    timeBPstim1= starttrig/blockout.scrRate; %
                    timeEEGstim1=onset1/EEG.srate; %
                    
                    %move EEG onset to match Trial onset
                    lag = timeBPstim1-timeEEGstim1;
                    BPlaginframes = round(lag*blockout.scrRate)
                    
                    %adjust the length of the plotTrial
                    shiftframes =zeros(1,abs(BPlaginframes));
                    plotTrial=[];
                    if BPlaginframes > 0 %Trials are after EEG onset, so put Nan at end of Trials.
                        plotTrial=horzcat(Trials(1+length(shiftframes):end), shiftframes); %add NaN(s) at the beginning to maintain length
                        movement='sooner';
                    elseif BPlaginframes<0
                        %add nan at end, to delay the behavioural trace.
                        plotTrial=horzcat(shiftframes, Trials(1:(end-length(shiftframes))));
                        movement='later';
                    elseif BPlaginframes==0
                        plotTrial=Trials;
                        movement='(no change)';
                        
                    end
                    
                    
                    continueYN='y';
                    
                    %also plot just in case we want to check the result
                    StD= threshmulti*std(cd_physchan);
                    eegtime = (1:length(cd_physchan))/EEG.srate;
                    
                end
                
                
                if sanitycheckON==1
                set(gcf, 'visible', 'on')
                
                subplot(3,1,1)
                plot(eegtime, cd_physchan)
                hold on
                plot(trialstime, Trials, 'r')
                hold on
                plot(xlim, [StD StD], 'r')
                plot([starttrig/blockout.scrRate starttrig/blockout.scrRate], ylim, 'r', 'linewidth', 3)
                
                xlim([starttrig/blockout.scrRate-.1 starttrig/blockout.scrRate+.1])
                title({['ppant ' num2str(ippant) ' ' num2str(initials) ];['Old alignment Block '  num2str(nrealblock) ' day ' num2str(dayis)]}, 'fontsize', fontsize*2)
                
                for ipl=[1,2]
                    subplot(3,1,1+ipl)
                    plot(eegtime, cd_physchan)
                    
                    hold on
                    plot(trialstime, plotTrial, 'r', 'linewidth', 1)
                    hold on
                    plot(xlim, [StD StD], 'r')
                    xlim([starttrig/blockout.scrRate-.1 starttrig/blockout.scrRate+.1])
                    
                end
                %find new onset ...
                starttrignew = find(plotTrial>1,1, 'first');
                subplot(3,1,2)
                title(['new, saved as start BP ' num2str(abs(BPlaginframes)) ' frames ' num2str(movement)], 'fontsize', fontsize*2)
                hold on
                plot([starttrignew/blockout.scrRate starttrignew/blockout.scrRate], ylim, 'r', 'linewidth', 3)
                
                xlim([starttrignew/blockout.scrRate-.5 starttrignew/blockout.scrRate+5])
                subplot(3,1,3)
                title(['new, saved as start BP ' num2str(abs(BPlaginframes)) ' frames ' num2str(movement)], 'fontsize', fontsize*2)
                xlim([starttrignew/blockout.scrRate-.1 starttrignew/blockout.scrRate+.1])
                hold on
                plot([starttrignew/blockout.scrRate starttrignew/blockout.scrRate], ylim, 'r', 'linewidth', 3)
                
                
                cd(pathtoProcdatadir)
                try cd(allfoldersEEG(ippant).name)
                catch
                    mkdir(allfoldersEEG(ippant).name)
                    cd(allfoldersEEG(ippant).name)
                end
        
                printfilename=['Day ' num2str(dayis) ', block ' num2str(nrealblock) ', adjust to ' num2str(abs(BPlaginframes))];
                print('-dpng', printfilename);
                
                end
                cd(num2str(exppath))
                cd(num2str(ppantfol.name))
                
                %           end % if debugging.
                
                % change to right directory
                cd(pathtoProcdatadir)
                try cd([allfoldersEEG(ippant).name])
                catch
                    mkdir([allfoldersEEG(ippant).name])
                    cd([allfoldersEEG(ippant).name])
                end
                savename=['Day(' num2str(dayis) '),Block(' num2str(nrealblock) ')'];
                save(savename, 'blockdata', 'BPlaginframes')
                
                nrealblock=nrealblock+1;
                
                
            end %end block
            disp(['fin ' num2str(iEEGrec) ' of '   num2str(length(allfilesEEG)) ' for ppant ' num2str(ippant) '_' num2str(initials)]);
            
            
        end %end EEG
    end
    %%
    disp('saving...')
    
    cd(eegpath)
    disp('next ppant')
end
%%
cd(pathtoProcdatadir)

