%% load data and Behavioural data, matching switch points, direction,
% and then averaging around switch.

%job1 locate behavioural data that correlates with EEG
clearvars -except pathtoBehaviouraldata pathtoEEGdata pathtoEpocheddataEXP
refreshrate = 60;
fontsize = 15;
% excl_switchs=0; %minimum seconds required for switch /percept to count.

%%
epochlength = [-5 5]; %seconds note that this and the next (EEG) epochs need to be consistent for plotting and to retain the order.

%%
dbstop if error

%%
allEEGblockdatadir= '/Users/MattDavidson/Desktop/XM_Project/EEGData/DATA/Processed/EEG_from_Attention_XmodalEXP/jSW_1_blockEpoched';
allBPdatadir= '/Users/MattDavidson/Desktop/XM_Project/DATA_newhope';
%%
cd(allEEGblockdatadir)
%%
allppants = (dir([pwd filesep 'ppant*']));
nppants=length(allppants);
%%

for ppantIN =28%1:nppants
    cd(allEEGblockdatadir)
    ppantfol= allppants(ppantIN).name;
    %which ppant?
    initials = num2str(ppantfol(end-1:end));
    %how many days completed?
    cd(ppantfol)
    
    
    excl_switchs=0; %ignore switches of a short duration.
    
    
    
    for iday = 1:2
        
        TotalBPdata=[];
        J2_blockout=[];
        cd(allBPdatadir)
        tmp= dir([num2str(initials) '*Day' num2str(iday) '*' ]);
        cd(tmp.name)
        load('Seed_Data.mat')
        ExpOrder= Exps(3:26,:);
        for iblock=1:24
            
            filetoload=dir(['Block' num2str(iblock) 'Exp*']);
            load(filetoload.name);
            Timing=blockout.rivTrackingData;
            TotalExp=Timing(:,2)-Timing(:,1);
            
            if TotalExp(1)==0 %correct for lazy start.
                firstvalue=find(TotalExp, 1, 'first'); %finds first nonzero
                for i=1:firstvalue
                    TotalExp(i,1)=TotalExp(firstvalue);
                end
            end
            
            %% finds 'switch' time points - middle of 0's for some
            switchpoint=[];
            switchtime=[];
            switchFROM=[];
            mixed_durationALL=[];
            
            mixedperceptsindx = (find(TotalExp==0));
            
            mixedperceptsindx(end+1) = mixedperceptsindx(end)+2; % allows for last if mixed percept not held till end of trial
            %
            mixedperceptsdur= diff(mixedperceptsindx);
            endmixedperceptsindx = find(mixedperceptsdur>1);
            
            endmixedcounter=1;
            %
            dbstop if error
            %%
            for iframe = 2:length(Timing)-1 %switch point in frames
                
                if TotalExp(iframe)~= TotalExp(iframe-1) %switch point
                    
                    
                    if TotalExp(iframe)==0 %coming to mixed dominance, so find middle point of zeros
                        
                        startmixedindx = iframe;
                        
                        endindxtmp = endmixedperceptsindx(endmixedcounter);
                        endindx = mixedperceptsindx(endindxtmp);
                        mixed_duration = endindx - startmixedindx;
                        
                        switchpointtmp= startmixedindx + round(mixed_duration/2);
                        
                        
                        
                        
                        endmixedcounter=endmixedcounter+1;
                        
                        switchFROMp = TotalExp(iframe-1);
                        
                        try switchTOp = TotalExp(endindx+1);
                        catch
                            switchTOp= TotalExp(end);
                        end
                        
                        if switchFROMp ~=switchTOp %actual swich around zeros not false switch [-1 0 0 0 -1] etc
                            switchFROM = [switchFROM, switchFROMp];
                            switchpoint = [switchpoint switchpointtmp]; %aligns to middle of mixed dom period
                            mixed_durationALL=[ mixed_durationALL, mixed_duration];
                        end
                        
                    end
                    
                    
                    if TotalExp(iframe) ~=0 && TotalExp(iframe-1)~=0
                        switchpoint=[switchpoint, iframe];
                        switchFROM = [switchFROM, TotalExp(iframe-1)];
                        mixed_duration=0;
                        mixed_durationALL=[ mixed_durationALL, mixed_duration];
                    end
                    
                    
                    
                    
                end
            end
            
            %collect time stamps for these switchpoints (currently in frames).
            
            for i=1:length(switchpoint) %switch point in ms
                switchtime= [switchtime blockout.rivTrackingData(switchpoint(i),3)];
            end
            %% Remove switches which we label as 'false' based on short duration.
            dominance_dur = diff(switchtime);
            remswitch=  [];
            
            
            for i = 1:length(dominance_dur)
                if dominance_dur(i) < excl_switchs %%%%%%%%%%%%%  !
                    remswitch = [remswitch, i];
                end
            end
            
            %Now remove 'false' switches from button press trace,
            for i=1:length(remswitch)
                
                tempidx = remswitch(i);
                falseswitchstart=switchpoint(tempidx);
                falseswitchend = switchpoint(tempidx +1);
                
                pertmp = TotalExp(falseswitchstart-1);
                
                TotalExp(falseswitchstart:falseswitchend)= pertmp;
            end
            
            %
            %%Finally
            % find if a switch happens during one of our stimulus chunks,
            % and remove that from further analysis.
            
            forgetswitch=[];
            restswitch=[];
            stimswChunk_idx=[];
            stimswitchFROM = [];
            Chunks=blockout.Chunks;
            xstim=0;
            %%
            for i=1:length(switchpoint)
                %locate if timepoint is within a chunk
                value = switchpoint(i);
                
                %find closest value in Chunks
                tmp= abs(Chunks-value);
                
                [idx idx] = min(tmp); %gives index in Chunks of closest start/finish
                
                pos = min(tmp);
                %% find out if between start and end of a stimulus, or between end and start
                %%of next...
                
                if mod(idx,2)==0  %number is even (closest chunk point is an end of stim)
                    
                    if value < Chunks(idx) % switchpoint is before the 'end' of a stim.
                        forgetswitch = [forgetswitch, i];
                    end
                    
                else %number is odd, and closest chunkpoint corresponds to start of stim
                    
                    if value > Chunks(idx)
                        forgetswitch=[forgetswitch,i];
                    else
                        
                    end
                    
                end
                
            end
            
            %remove those stimulus driven switches from our outgoing switch
            %matrices.
            
            %remove from switchpoints
            switchpoint(forgetswitch)=[];
            %remove from times
            switchtime(forgetswitch)=[];
            %remove from percept tracking
            switchFROM(forgetswitch)=[];
            mixed_durationALL(forgetswitch)=[];
            
            %%save for later
            TotalBPdata(iblock,1:length(TotalExp)) = TotalExp;
            J2_blockout(iblock).switchpoint=switchpoint;
            J2_blockout(iblock).switchtime=switchtime;
            J2_blockout(iblock).switchFROM=switchFROM;
            J2_blockout(iblock).mixed_duration=mixed_durationALL;
            J2_blockout(iblock).Speed=blockout.LeftEyeSpeed;
            %
            
        end
        save('J2_realignResults', 'TotalBPdata', 'J2_blockout')
        
        
        
        %%
        
        % Align percept duration around switchpoints.
        %how big are our epochs?
        halflength = abs((epochlength(1)*refreshrate));
        
        
        ppantSWITCHtracestH = [];
        ppantSWITCHtracestL=[];
        
        switchorderBLOCK=[];
        switchorderALL=[];
        
        %%
        %%
        cd(allBPdatadir)
        tmp= dir([num2str(initials) '*Day' num2str(iday) '*' ]);
        cd(tmp.name)
        load('J2_realignResults.mat')
        %%
        for iblock = 1:24
            %%
            blockdata = squeeze(TotalBPdata(iblock,:));
            switchpoints = J2_blockout(iblock).switchpoint;
            switchtimes = J2_blockout(iblock).switchtime;
            lefteyecond = J2_blockout(iblock).Speed;
            switch_from = J2_blockout(iblock).switchFROM;
            all_toHighswitchdata = [];
            all_toLowswitchdata=[];
            
            
            %%
            for iswitch = 1:length(switchpoints)
                
                INswitchpoint = switchpoints(iswitch);
                
                if INswitchpoint>halflength % %ie if it occurs after first epochlength(1) seconds of the block
                    
                    if INswitchpoint<size(blockdata,2)-halflength %happens before the end of the block.
                        
                        BPdata = blockdata(1,INswitchpoint-halflength:INswitchpoint+halflength);
                        
                        switch switch_from(iswitch)
                            
                            case -1 %percept changed TO right eye,
                                
                                if lefteyecond=='L' %lowhzin left eye
                                    
                                    toHIGHswitchdatatmp = BPdata; %we want lowhzblue in plot
                                    storage='tH';
                                    %                             switchcountHL = switchcountHL+1;
                                    
                                else % left eye was Highhz,so changed to TO right eye low hz
                                    toLOWswitchdatatmp  = BPdata*-1; %switch colour
                                    storage='tL';
                                    %                             switchcountLH = switchcountLH+1;
                                end
                                
                            case 1 %percept changed TO left eye
                                
                                if lefteyecond=='L' %lowhzin left eye
                                    toLOWswitchdatatmp = BPdata; %switches colour
                                    storage='tL';
                                    %                             switchcountLH = switchcountLH+1;
                                else %highhz in left eye
                                    toHIGHswitchdatatmp  = BPdata*-1;
                                    storage='tH';
                                    %                             switchcountHL = switchcountHL+1;
                                end
                        end
                        switchorderBLOCK = [switchorderBLOCK; storage];
                        
                        switch storage
                            case 'tH'
                                all_toHighswitchdata = [all_toHighswitchdata; toHIGHswitchdatatmp];
                                
                            case 'tL'
                                all_toLowswitchdata= [all_toLowswitchdata; toLOWswitchdatatmp];
                                
                        end
                        
                    end
                    
                end
            end
            %%
            ppantSWITCHtracestH = [ppantSWITCHtracestH; all_toHighswitchdata]; %concatenate vertically
            ppantSWITCHtracestL=[ppantSWITCHtracestL; all_toLowswitchdata];
        end
        
        
        
        %%
        BA_durationsoftoLOWswitch= zeros(size(ppantSWITCHtracestL,1), 2); %empty matrix to record before/after length of percept durations
        BA_durationsoftoHIGHswitch= zeros(size(ppantSWITCHtracestH,1), 2);
        
        mixed_durationtL = zeros(size(ppantSWITCHtracestL,1), 1);
        mixed_durationtH = zeros(size(ppantSWITCHtracestH,1), 1);
        %%
        %% Calculate  the length of the percept after a switch has occured (and before)
        for toPercept = 1:2
            
            switch toPercept
                case 1
                    data = ppantSWITCHtracestL;
                case 2
                    data= ppantSWITCHtracestH;
            end
            
            for iswitch = 1:size(data,1)
                %%
                
                etrial = squeeze(data(iswitch,:));
                if sum(etrial)>0
                    midpoint= round(length(etrial)/2);
                    
                    %from switchpoint
                    etrialA = etrial(1,midpoint:end);
                    
                    
                    dursindx = find(diff(etrialA));
                    dur_frames= diff(dursindx);
                    %%
                    if etrialA(1,1)==0
                        try tmp_durofTOpercept = dur_frames(1);
                        catch
                            tmp_durofTOpercept = midpoint; % no change, so use whole interval
                        end
                        
                        gapafter=  dursindx(1);
                        
                    else %clean switch
                        try tmp_durofTOpercept = dursindx(1);
                        catch
                            tmp_durofTOpercept = midpoint; % no change, so use whole interval
                        end
                        
                        gapafter=0;
                        
                    end
                    %%
                    % before switch percept duration
                    etrialB = etrial(1,1:midpoint);
                    
                    
                    dursindx = find(diff(etrialB));
                    dur_frames= diff(dursindx);
                    
                    %
                    if etrialB(1,end)==0
                        try tmp_durofFROMpercept = dur_frames(end);
                        catch
                            tmp_durofFROMpercept = midpoint; %entire preswitch interval
                        end
                        if isnan(mean(dursindx))
                            gapbefore = midpoint;
                        else
                            gapbefore= midpoint-dursindx(end);
                        end
                    else %clean switch
                        try tmp_durofFROMpercept = dur_frames(end);
                        catch
                            tmp_durofFROMpercept = midpoint; %entire preswitch interval
                        end
                        
                        gapbefore = 0;
                    end
                    %%
                    mixed_durTEMP = gapbefore+gapafter;
                    %
                    
                    switch toPercept
                        case 1
                            BA_durationsoftoLOWswitch(iswitch,1) = tmp_durofFROMpercept;
                            BA_durationsoftoLOWswitch(iswitch,2) = tmp_durofTOpercept;
                            mixed_durationtL(iswitch)= mixed_durTEMP;
                        case 2
                            BA_durationsoftoHIGHswitch(iswitch,1) = tmp_durofFROMpercept;
                            BA_durationsoftoHIGHswitch(iswitch,2) = tmp_durofTOpercept;
                            mixed_durationtH(iswitch)= mixed_durTEMP;
                    end
                end
            end
        end
        
        %%
        save('J2_realignResults', 'ppantSWITCHtracestH', 'ppantSWITCHtracestL', 'BA_durationsoftoLOWswitch', 'BA_durationsoftoHIGHswitch','mixed_durationtH', 'mixed_durationtL', '-append');
        
        
        %%
        %sort order
        
        clf;
        
        printfilename = ['J2_Ppant ' num2str(initials) ', Day ' num2str(iday) ' ranked BPress activity during experiment'];
        set(gcf, 'Name', printfilename, 'color', 'w', 'visible', 'off')
        %%
        for sorttype=1:3
            switch sorttype
                case 1
                    sortVARL = BA_durationsoftoLOWswitch(:,1); % preswitch (highhz) percept duration
                    sortVARH = BA_durationsoftoHIGHswitch(:,1); % preswitch (lowhz) percept duration
                    printsort = 'pre-switch percept length';
                    places = [1, 4];
                    
                case 2
                    sortVARL = mixed_durationtL;
                    sortVARH = mixed_durationtH;
                    printsort = 'mixed percept duration';
                    places = [2, 5];
                    
                case 3
                    sortVARL = BA_durationsoftoLOWswitch(:,2); % preswitch (highhz) percept duration
                    sortVARH = BA_durationsoftoHIGHswitch(:,2); % preswitch (lowhz) percept duration
                    printsort = 'post-switch percept length';
                    places = [3, 6];
            end
            
            [sortedL, sorted_indxL] = sort(sortVARL,1, 'descend');
            [sortedH, sorted_indxH] = sort(sortVARH,1, 'descend');
            
            %% reshape according to sorted
            plotdataL=zeros(size(ppantSWITCHtracestL,1), size(ppantSWITCHtracestL,2));
            plotdataH=zeros(size(ppantSWITCHtracestH,1), size(ppantSWITCHtracestH,2));
            %
            for i = 1:size(ppantSWITCHtracestH,1)
                intrial = sorted_indxH(i);
                plotdataH(i,:) = ppantSWITCHtracestH(intrial,:);
            end
            
            for i = 1:size(ppantSWITCHtracestL,1)
                intrial = sorted_indxL(i);
                plotdataL(i,:) = ppantSWITCHtracestL(intrial,:);
            end
            %% plotting
            %
            timing = (1:length(BPdata)) - halflength;
            timingsecs = timing/refreshrate;
            %
            trialsL = 1:size(ppantSWITCHtracestL,1);
            trialsH = 1:size(ppantSWITCHtracestH,1);
            
            
            subplot(2,3,places(1))
            
            imagesc(timingsecs, 1:size(sortVARL,1), plotdataL(:,:))
            title({['High flicker to Low flicker,'];[' ranked by ' num2str(printsort)]}, 'fontsize', fontsize)
            ylabel('Switch count throughout experiment', 'fontsize', fontsize)
            xlabel('Seconds', 'fontsize', fontsize)
            xt= get(gca, 'Xtick');
            
            set(gca, 'Xtick',xt, 'fontsize', fontsize)
            
            subplot(2,3,places(2))
            
            imagesc(timingsecs, 1:size(sortVARL,1), plotdataH(:,:))
            title({['Low flicker to High flicker,'];[' ranked by ' num2str(printsort)]}, 'fontsize', fontsize)
            ylabel('Switch count throughout experiment', 'fontsize', fontsize)
            xlabel('Seconds', 'fontsize', fontsize)
            xt= get(gca, 'Xtick');
            
            set(gca, 'Xtick',xt, 'fontsize', fontsize)
        end
        
        print(gcf, '-dpng', num2str(printfilename))
        %      screen2jpeg(printfilename)
        %         close all
        %%
        % jheapcl
        clf;
        
        printfilename = ['J2_Ppant ' num2str(initials) ', Day ' num2str(iday) ' unranked BPress activity during experiment'];
        set(gcf, 'Name', printfilename,  'color', 'w', 'visible', 'off')
        
        subplot(2,1,1)
        imagesc(timingsecs, 1:size(sortVARL,1), ppantSWITCHtracestL(:,:));
        title('Sequence of switches to Low Hz Percept', 'fontsize', fontsize);
        ylabel('Switch #', 'fontsize', fontsize)
        xlabel('Seconds', 'fontsize', fontsize)
        
        subplot(2,1,2)
        imagesc(timingsecs, 1:size(sortVARL,1), ppantSWITCHtracestH(:,:));
        title('Sequence of switches to High Hz Percept', 'fontsize', fontsize);
        ylabel('Switch #', 'fontsize', fontsize)
        xlabel('Seconds', 'fontsize', fontsize)
        %     jheapcl
        %%
        print(gcf, '-dpng', num2str(printfilename))
        %          screen2jpeg(printfilename)
        cd(allBPdatadir)
    end
end
