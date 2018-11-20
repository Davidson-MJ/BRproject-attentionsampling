% function newBlockByBlock_BatchAnalysis(pathtoBehaviouraldata, sanitycheckON)
%some data preparations for easier analysis.

% pathtoBehaviouraldata='/Users/MattDavidson/Desktop/XM_Project/DATA_newhope';
%%%% some analysis parameters we can change
% LRcriteria = 0; %>alpha for difference in LR eye dominance permissable. (e.g. 0.5 means blocks with LR dom diff <.05 are rejected)

%avoid switches which happen within this window of onset, as they are too fast to be induced by cross modal?
xstim_s = 0; %secs, e.g. ignore switches in first .1 second

%ignore switches that happen within skswitch_s (seconds) of each other,
%assumed to be a false switch, or button press error.
skipswitch_s = 0; %seconds

%move the window of interest
% shiftwin=[1.25 2.5]; %seconds post stim onset to start  'chunks', and the length of chunk window for catching events.
shiftwin = []; %seconds


%remove mixed periods (convert behavioural trace to binary), or keep
%within.
remove_mixedperiods = 0; %1 to remove all mixed periods changing zeros to the prev.percept.
fontsize=15;

% if sanitycheckON==0 %speed up process by not printing block by block analysis.
set(gcf, 'visible', 'off')
% end
dbstop if error

cd(pathtoBehaviouraldata)

try addpath('/Users/MattDavidson/Desktop/Crossmodal_BinocularRivalry-Supportfiles-master')
catch
    addpath('/Users/MatthewDavidson/Documents/Github/Crossmodal_BinocularRivalry-Supportfiles-master')    
end

%ignore switches that happen in first xstim_s after stimulust presentation
allppantsfols= dir(['*_On*']);
nppantfols=length(allppantsfols);

sanitycheckON=0; %to output block by block plots,

useANYlengthstim=0;
job.runanew=0;
job.justplot=1;



if job.runanew==1;
for ifol = 1:nppantfols
    cd(pathtoBehaviouraldata)
    cd(allppantsfols(ifol).name)
    load('Seed_Data')
    
    xstim = 60*(xstim_s); %buffer in frames
    skswitch= 60*(skipswitch_s); %in frames.
    
    Exps = Exps(3:26,:); %remove practice blocks.
   
    
    SWprobs= zeros(3,24);
    MNTprobs= zeros(3,24);
    for num = 1:24
        cd(pathtoBehaviouraldata)
        cd(allppantsfols(ifol).name)
        blockis = dir(['Block' num2str(num) 'Exp*']);
        load(blockis.name)
        ExpType = blockout.Casetype;
        EyeCond = blockout.LeftEyeSpeed;
        Speed=EyeCond;
        
        EyecondC = Exps(num,2);
        
        if EyecondC>2
            Leftc='G';
            Rightc='R';
        else
            Leftc='R';
            Rightc='G';
        end
        if mod(Exps(num,1),2)>0 %not an even number
            phaseis= 'In phase';
        else
            phaseis= 'Anti phase';
        end
        
        
        %% establish variables
        rivTrackingData = blockout.rivTrackingData;
        Chunks=blockout.Chunks;
        
        %Prepare the data into easy matrix
        Timing = rivTrackingData(:,3);
        Trials=blockout.Trials;
        Order=blockout.Order;
        % Timesecs = 1:size(Timing,1)/60;
        
        
        
        if isnan(Timing(1)) %start off with nans, find when the timing kicked in
            firstframe = length(find(isnan(Timing)));
            
            timestep = mean(diff(Timing(firstframe+2:end)));
            
            for ifix = 1:firstframe
                rivTrackingData(ifix, 1:2) = 0; %fill start of trial with zeros,
                rivTrackingData(ifix, 3) = ifix*timestep; % fill timing
            end
        end
        
        
        
        %Total Exp is difference between button presses.
        TotalExp = rivTrackingData(:,2) - rivTrackingData(:, 1); %makes -1 left eye
        
        
        %remove zeros at start of trial. if button press was late.
        if TotalExp(1)==0
            firstvalue=find(TotalExp, 1, 'first'); %finds first nonzero
            for i=1:firstvalue
                TotalExp(i,1)=TotalExp(firstvalue);
            end
        end
        
        %remove single frame 'mixed' reponses, as they mess up the calculations
        for i = 2:length(TotalExp)-1
            if TotalExp(i)==0
                if TotalExp(i+1)~=0 && TotalExp(i-1)~=0
                    TotalExp(i) = TotalExp(i-1);
                end
            end
        end
        
        
        if remove_mixedperiods ==1 %remove ALL mixed periods for calculations.
            for i=2:length(TotalExp)
                if TotalExp(i)==0
                    TotalExp(i) = TotalExp(i-1);
                end
            end
        end
        
        
        Data=blockout.trackingData; %performed in earlier job.
        
        % finds 'switch' time points in button press (when changing from left to
        % right eye)
        if remove_mixedperiods==0 %then we have to account for the mixed periods,
            %finding the halfway point in the period of mixed dominance
            switchpoint=[];
            switchtime=[];
            switchFROM=[];
            mixed_durationALL=[];
            
            mixedperceptsindx = (find(TotalExp==0)); %whenever both or no buttons pressed
            mixedperceptsindx(end+1) = mixedperceptsindx(end)+2; % allows for last if mixed percept not held till end of trial
            mixedperceptsdur= diff(mixedperceptsindx); %of all those indexed, how long? (to find middle point of mixed periods)
            %
            endmixedcounter=1; %start counter
            %
            endmixedperceptsindx = find(mixedperceptsdur>1);
            
            %%
            for iframe = 2:length(Timing)-1 %switch point in frames
                
                if TotalExp(iframe)~= TotalExp(iframe-1) % ie if at two frames don't match perceptually (a switch)
                    if TotalExp(iframe)==0 %coming to mixed dominance, so find middle point of zeros
                        
                        %find the details of this period of mixed dominance.
                        startmixedindx = iframe;
                        endindxtmp = endmixedperceptsindx(endmixedcounter);
                        endindx = mixedperceptsindx(endindxtmp);
                        
                        mixed_duration = endindx - startmixedindx;
                        switchpointtmp= startmixedindx + round(mixed_duration/2);
                        endmixedcounter=endmixedcounter+1;
                        
                        switchFROMp = TotalExp(iframe-1);%= what the person was seeing before they switched
                        
                        try switchTOp = TotalExp(endindx+1);
                        catch
                            switchTOp= TotalExp(end);
                        end
                        
                        if switchFROMp ~=switchTOp; %actual swich around zeros not false switch [-1 0 0 0 -1] etc
                            
                            %should also be a switch which resulted in a long enough
                            %change (not quick switch then switch back)
                            %thus:
                            
                            if ~isempty(switchpoint)
                                if (switchpointtmp - (switchpoint(end))) > skswitch; %ie if (newswitch point - the previous) is longer than minimum required.
                                    
                                    switchFROM = [switchFROM, switchFROMp];
                                    switchpoint = [switchpoint switchpointtmp]; %aligns to middle of mixed dom period
                                    mixed_durationALL=[ mixed_durationALL, mixed_duration];
                                else
                                    %                         switchpoint(end)=[]; %and if not then remove the previous switchpoitn, since we've captured a 'false'
                                    %                         switchFROM(end) =[];
                                end
                            else %its the first switchpoint
                                switchFROM = [switchFROM, switchFROMp];
                                switchpoint = [switchpoint switchpointtmp]; %aligns to middle of mixed dom period
                                mixed_durationALL=[ mixed_durationALL, mixed_duration];
                            end
                        end
                    else %coming out of mixed dominance (which we skip), or a clean switch (rare)
                        switchpointtmp = iframe;
                        %clean switch
                        if TotalExp(iframe) ~=0 && TotalExp(iframe-1)~=0
                            if length(switchpoint)>0
                                if(switchpointtmp-(switchpoint(end))) > skswitch
                                    switchpoint=[switchpoint, iframe];
                                    switchFROM = [switchFROM, TotalExp(iframe-1)];
                                    mixed_duration=0;
                                    mixed_durationALL=[ mixed_durationALL, mixed_duration];
                                else
                                    switchpoint(end)=[];
                                    switchFROM(end)=[];
                                end
                            else %first switch  (length(switchpoint)=0)
                                switchpoint=[switchpoint, iframe];
                                switchFROM = [switchFROM, TotalExp(iframe-1)];
                                mixed_duration=0;
                                mixed_durationALL=[ mixed_durationALL, mixed_duration];
                            end
                        end
                    end
                    
                end
            end
            
            if length(switchpoint) ~=length(switchFROM)
                error('count off between switchpoint and switchFROM')
            end
        else
            % keep the mixed periods in the trace.
            switchpoint=[];
            switchtime=[];
            switchFROM=[];
            
            
            %%
            for iframe = 2:length(Timing)-1 %switch point in frames
                
                if TotalExp(iframe)~= TotalExp(iframe-1) % ie if at two frames don't match perceptually (a switch)
                    
                    switchpointtmp = iframe;
                    % is it a clean switch (rare)?
                    if TotalExp(iframe) ~=0 && TotalExp(iframe-1)~=0
                        if length(switchpoint)>0
                            if(switchpointtmp-(switchpoint(end))) > skswitch
                                switchpoint=[switchpoint, iframe];
                                switchFROM = [switchFROM, TotalExp(iframe-1)];
                                
                                
                            else
                                switchpoint(end)=[];
                                switchFROM(end)=[];
                            end
                        else %first switch  (length(switchpoint)=0)
                            switchpoint=[switchpoint, iframe];
                            switchFROM = [switchFROM, TotalExp(iframe-1)];
                            
                            
                        end
                    end
                    
                    
                end
            end
            
            if length(switchpoint) ~=length(switchFROM)
                error('count off between switchpoint and switchFROM')
            end
        end
        %%
        % sanity check of switch data(zero's removed)
        %set a decent size figure
        
        
     
        
        if sanitycheckON==1
            %             set(gcf, 'Visible', 'off');
            %%
               clf
            subplot(2,2,1:2)
            plot(Timing, TotalExp, 'Color', 'k');
            ylim([-2 2]);
            xlim([0 Timing(end)])
            
            
            set(gca, 'yTick', [-1 1], 'yTickLabel', {['lefteye ' num2str(EyeCond)]; 'righteye'}, 'Fontsize', fontsize);
            title(['Block ' num2str(num) ', Buttonpress activity for ' num2str(ExpType)  ' ' num2str(phaseis)], 'fontsize', fontsize);
            xlabel('Seconds');
            
            
            %% %
            % check switchpoints correlate
            hold on
            %first collect the time in Seconds of each switch point.
            
            
            for i=1:length(switchpoint)
                switchtime= [switchtime rivTrackingData(switchpoint(i),3)];
            end
            % %% for plotting very short switches, in case they havent been removed.
            % switchlengths = diff(switchpoint);
            %
            % for idiff = 1:length(switchlengths)
            %     tempdiff= switchlengths(idiff);
            %
            %     if tempdiff<skswitch %if time between switches is too short
            %
            %           plot([switchtime(idiff+1) switchtime(idiff+1)], ylim, ['-', 'r'], 'linewidth', 1);
            %
            %
            %     else %need to remove those switches from further analysis...
            %
            %
            %
            %
            %     end
            % end
            
            
            % plot the individual switch points to check they correlate.
%             for i = 1:length(switchtime)
%                 plot([switchtime(i) switchtime(i)], ylim, [':', 'r'], 'linewidth', .5);
%             end
            
            text(100, -1.5, ['Nswitches = ' num2str(length(switchpoint))], 'Fontsize', fontsize)
            
            % observe if stimuli correlate to chunks (visually)
            
            for i= 1:(length(Chunks)/2)
                
                switch Order(i)
                    
                    case 1
                        stype= 'No Crossmodal';
                        scolour= [.75 .75 .75];
                        
                    case {92, 93, 94}
                        stype = 'High Hz';
                        scolour= [1 .49 .31]; %bright organge
                    case {82, 83, 84}
                        stype = 'Low Hz';
                        
                        scolour= [0 .75 1]; %bright blue
                end
                
                x1= Timing(Chunks(2*i-1));
                x2= Timing(Chunks(2*i));
                xvec = x1:.1:x2;
                for i=1:length(xvec)
                    tempx = xvec(i);
                    plot([tempx,tempx], [-.5 .5],...
                        '-', 'Color', scolour, 'MarkerFacecolor', scolour, 'MarkerSize', 14);
                end
                
                
            end
            
            text(60, 1.75, '*', 'color',[.75 .75 .75] , 'FontSize', fontsize*3);
            text(63, 1.80, 'Visual only (no trial)', 'color','k', 'FontSize', fontsize);
            
            text(100, 1.75, '*', 'color',[0 .75 1] , 'FontSize', fontsize*3);
            text(103, 1.80, 'Low Hz ', 'color','k', 'FontSize', fontsize);
            
            
            text(140, 1.75, '*', 'color', [1 .49 .31], 'FontSize', fontsize*3);
            text(143, 1.80, 'High Hz ', 'color','k', 'FontSize', fontsize);
        end
        %%
        % find if a switch happens during one of our stimulus chunks
        
        stimswitch=[];
        restswitch=[];
        stimswChunk_idx=[];
        stimswitchFROM = [];
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
                
                if value < Chunks(idx) % switchpoint is before the 'end'.
                    stimswChunk_idx=[stimswChunk_idx idx-1];
                    stimswitch = [stimswitch value]; %add the timepoint matrix
                    stimswitchFROM = [stimswitchFROM, switchFROM(i)]; %adds the previous percept to our data (we need to know what the switch was from)
                else %value >chunks(idx), and before the start of next stim
                    restswitch = [restswitch value];
                    
                end
                
            else %number is odd, and closest chunkpoint corresponds to start of stim
                
                %include something here, to skip switches that happen
                %'accidentally' at stim onset
                
                
                if value > Chunks(idx)
                    if (value - Chunks(idx))>xstim    %added to ignore acidental switches too fast to be induced.
                        
                        stimswChunk_idx =[stimswChunk_idx idx];
                        stimswitch= [stimswitch value];
                        stimswitchFROM = [stimswitchFROM, switchFROM(i)];
                    end
                else
                    restswitch=[restswitch value]; %switch occured outside of stim
                end
                
            end
            
        end
        %%
        
        %% %%%%% %%%% %%%% %%% %%%% % %% %%%%% %%%% %%%% %%% %%%% % %% %%%%% %%%% %%%% %%% %%%% %
        % Now remove switches that occured more than once
        doublesw = find(diff(stimswChunk_idx)==0); %% %%%%% %%%% %%%% %%% %%%% %
        
        double_swChunks=[];
        for idb = 1:length(doublesw)            %% %%%%% %%%% %%%% %%% %%%% %
            tmp = doublesw(idb);                %% %%%%% %%%% %%%% %%% %%%% %
            
            
            %also record order number of these double switches to remove from analysis
            idxtmp = stimswChunk_idx(tmp);
            
            if mod(idxtmp,2)>0 %then start of chunk,
                realchnk = (idxtmp+1)/2;
            else
                realchnk = (idxtmp)/2;
            end
            double_swChunks = [double_swChunks, realchnk];
        end
        
        double_swChunks = unique(double_swChunks); % in case >2 switches per xmodal stim.
        double_swChunksTYPE = Order(double_swChunks);
        
        
        
        
        for idb = 1:length(doublesw)
            tmp = doublesw(idb);                %% %%%%% %%%% %%%% %%% %%%% %
            %now revalue for removal
            stimswitchFROM(tmp)=88;         %temp revalue, then remove next step (to preserve index order)
            stimswitch(tmp)=88;                   %% %%%%% %%%% %%%% %%% %%%% %
            stimswChunk_idx(tmp)=88;
            
            
            stimswitchFROM(tmp+1)=88;
            stimswitch(tmp+1)=88;                   %% %%%%% %%%% %%%% %%% %%%% %
            stimswChunk_idx(tmp+1)=88;
            
            
            
        end
        %% %%%%% %%%% %%%% %%% %%%% %
        %% remove from further analysis
        stimswitchFROM(stimswitchFROM==88)=[];
        stimswitch(stimswitch==88)=[];
        stimswChunk_idx(stimswChunk_idx==88)=[];
        
        %now for the above vectors, we have a record of only those xmodal stimuli
        %which invoked ONLY a single switch event. Note that the stimuli which
        %invoked more than one are indexed by
        
        
        %%
        stimswTYPE=[];
        % %
        for i = 1:length(stimswitch) %for all instances a switch happened during stimulus presentation
            %
            temp = Trials(stimswitch(i)); %find the index of what stim type it was
            %
            if temp==0; %since switch window has been moved
                tmptrack = Trials(1,stimswitch(i)-200:stimswitch(i));
                typestmp = unique(tmptrack);
                temp = typestmp(2); %takes stim value.
                
            end
            stimswTYPE= [stimswTYPE temp];
            
        end
        
        
        
        
        
        
        %%
        %sanitycheck that we captured stimswitches - plot them onto the button
        %press trace
        % counter=1;
        if sanitycheckON==1
            for i = 1:length(stimswitch)
                
               
                plot([stimswitch(i)/60 stimswitch(i)/60], 0, ['*' 'k'], 'markersize', fontsize*1.5, 'linewidth', 4)
               
            end
        end
        %%
        % stimswitchFROM=switchFROMtmp; %work with new order, now visual has been removed
        % stimswitch = stimswitchtmp;
        % stimswChunk_idx=stimswOrdertmp;
        %
        %remove visual only from type
        % try Rem= phand(1,:)==1;
        %
        %     phand(Rem)=[];
        % catch
        % end
        
        
        % if sanitycheckON==1
        %     disp(['stimswitchtype = ' num2str(phand)])
        %
        % continueYN = input('Happy with trace so far, switches and omits?Y/N...', 's');
        % else
        
        %      shg
        % end
        
        %% %%%
        
        % Left/right graph
        %Calculates amount of time viewing left /right or neither stim in case there is a bias
        
        % Finds the total chance of having left or right
        %taking sum of button presses over the average of all button presses
        LeftPress = length(find(TotalExp == -1));
        RightPress = length(find(TotalExp == 1));
        MixedPress = length(find(TotalExp==0));
        
        LeftChance = round(100*(LeftPress/length(TotalExp)));
        RightChance= round(100*(RightPress/length(TotalExp)));
        MixedChance = round(100*(MixedPress/length(TotalExp)));
        blocklength= 100; % '%' of the time
        %observed
        x1 = [repmat('a', blocklength,1); repmat('b', blocklength,1)];
        x2= [ones(LeftChance,1); repmat(2, blocklength-LeftChance,1); ones(RightChance,1); repmat(2,blocklength-RightChance,1)];
        
        %         [tbl, chi2stat, pval] = crosstab(x1,x2); %calculates pval of L vs R.
        
        if sanitycheckON==1
            %
            subplot(2, 2, 3);
            % Bar graph, changing y axes to between 0 and 1
            bar([LeftChance, 0,0], 'FaceColor', num2str(Leftc), 'BarWidth', 0.6 );
            hold on
            bar([0, RightChance,0], 'FaceColor', num2str(Rightc), 'BarWidth', 0.6);
            bar([0, 0, MixedChance], 'FaceColor', 'y', 'BarWidth', 0.6);
            ylim([0 100]);
            text(1, 90, [num2str(LeftChance) '%'], 'FontSize', 18);
            text(2,90, [num2str(RightChance) '%'], 'FontSize', 18);
            text(3,90, [num2str(MixedChance) '%'], 'FontSize', 18);
            
            
            
            
            %             if pval<.001 %then not approximately equal left/right dominance for block
            %                 xlabel(['warning!! significant diff b/w LR dom p<.001'])
            %             end
            
            set(gca, 'XTickLabel', {['Left'] ['Right'] ['Mixed']}, 'fontSize', fontsize)
            title('Left/Right dominance of button press', 'fontsize', fontsize); ylabel('Dominance (%)', 'fontsize', fontsize);
            
        end
        %
        %% Ifswitch occured, how likely was it to be during stimulation?
        vistrialswitch = length(find(stimswTYPE==1));
        
        Stimcount = length(stimswTYPE) - vistrialswitch;
        
        % Totalsw = length(switchpoint);
        % Totalsw = length(Stimcount) + length(;
        Stimpct = round(100*(Stimcount/12)); %16 stimuli presented, how many did we switch on?
        Restpct = round(100*(vistrialswitch/3));
        if sanitycheckON==1
            subplot(2, 2, 4);
            % Bar graph, changing y axes to between 0 and 1
            bar([Stimpct, 0], 'FaceColor', 'y', 'BarWidth', 0.6 );
            hold on
            bar([0, Restpct], 'FaceColor', 'k', 'BarWidth', 0.6);
            % bar([0, Restpct], 'FaceColor', 'k', 'BarWidth', 0.6);
            ylim([0 100]);
            text(1, 90, [num2str(Stimpct) '%'], 'FontSize', 18);
            text(2,90, [num2str(Restpct) '%'], 'FontSize', 18);
            
            set(gca, 'XTickLabel', {['During '  num2str(ExpType) ' stimulation '] 'During Vis only chunks'}, 'fontSize', fontsize)
            title('Likelihood of switch '); ylabel('Percent likelihood');
            %%
        end
        % cd ../
        % cd(basedir)
        %%
        % KbWait
        
        %% Now for frequency and phase analysis %%
        FROMpercepts=[];
        
        fromLOWtoHIGH_stimtype=[];
        fromHIGHtoLOW_stimtype=[];
        fromLOWtoHIGH_timestamp=[];% for eeg later.
        fromHIGHtoLOW_timestamp=[];%
        fromLOWtoHIGH_order=[];
        fromHIGHtoLOW_order=[];
        
        for i=1:length(stimswTYPE) %number of switches occuring during stim
            %
            perceptt = stimswitchFROM(i); % find percept at start of chunk
            FROMpercepts(i) =  perceptt;
            stimswTYPE;
        end
        
        
        stimswOrder_idx= (stimswChunk_idx+1)/2;
        %%
        % %-1 is always lefteye
        for i=1:length(FROMpercepts) %determine direction of switch
            
            perceptt = FROMpercepts(i);
            
            switch perceptt
                case -1; %if trial started with left eye dominance
                    
                    if EyeCond == 'L'; % and left eye is low Hz;
                        
                        fromLOWtoHIGH_stimtype = [fromLOWtoHIGH_stimtype, stimswTYPE(i)];
                        fromLOWtoHIGH_timestamp = [fromLOWtoHIGH_timestamp, stimswitch(i)];
                        fromLOWtoHIGH_order = [fromLOWtoHIGH_order, stimswOrder_idx(i)]   ;
                        
                    else %Speed='H', left eye is high hz, while percept is left eye
                        fromHIGHtoLOW_stimtype = [fromHIGHtoLOW_stimtype, stimswTYPE(i)];
                        fromHIGHtoLOW_timestamp = [fromHIGHtoLOW_timestamp, stimswitch(i)];
                        fromHIGHtoLOW_order = [fromHIGHtoLOW_order, stimswOrder_idx(i)]   ;
                    end
                    
                case 1 %trial started with right eye dominance (+1)
                    if EyeCond=='L' %Right eye High Hz
                        fromHIGHtoLOW_stimtype=[ fromHIGHtoLOW_stimtype, stimswTYPE(i)];
                        fromHIGHtoLOW_timestamp = [ fromHIGHtoLOW_timestamp, stimswitch(i)];
                        fromHIGHtoLOW_order = [fromHIGHtoLOW_order, stimswOrder_idx(i)]   ;
                    else %Lspeed is 'H' right eye low Hz
                        fromLOWtoHIGH_stimtype=[fromLOWtoHIGH_stimtype, stimswTYPE(i)];
                        fromLOWtoHIGH_timestamp= [fromLOWtoHIGH_timestamp,stimswitch(i)];
                        fromLOWtoHIGH_order = [fromLOWtoHIGH_order, stimswOrder_idx(i)]   ;
                    end
                    
            end
        end
        
        
        %% Now find button press when stim was presented, but no switch occured, for
        % maintenance calculations
        
        stimtemp=1:1:length(Order);
        removestim = [stimswOrder_idx, double_swChunks];
        removestim = sort(removestim);
        
        stimtemp(removestim)=[]; %remove those stim which have already been processed, leaving maintenance only.
        %%
        
        %
        
        maintOrder=stimtemp; %index of stim which didnt switch
        mainttype=[];
        for i=1:length(maintOrder)
            idx=maintOrder(i);
            
            tmp=Trials(Chunks((2*idx)-1));
            
            mainttype(i)= tmp;
        end
        
        % %% remove vis only
        % Rem = find(mainttype(1,:)==1);
        % mainttype(Rem)=[];
        % maintOrder(Rem)=[];
        
        %% freq/phase analysis
        maintpercepts=[];
        % maint_congruent=[];
        % maint_incongruent=[];
        maintainedduringHIGH=[];
        maintainedduringLOW=[];
        maintdurLorder=[];
        maintdurHorder=[];
        maintainedduringMIXED=[];
        
        for i=1:length(maintOrder) %number of maintenance epochs
            endchunk_idx = 2*maintOrder(i);
            perceptt = TotalExp(Chunks(endchunk_idx)); % find percept maintained at end of  chunk
            maintpercepts(i) =  perceptt;
        end
        
        %%
        % %-1 is always lefteye
        for i=1:length(maintpercepts)
            
            perceptt = maintpercepts(i);
            
            switch perceptt
                case -1; %if trial started with left eye dominance
                    
                    if Speed == 'L'; % and left eye is low Hz;
                        maintainedduringLOW = [maintainedduringLOW mainttype(i)];
                        maintdurLorder = [maintdurLorder maintOrder(i)];
                    else %Speed='H', left eye is high hz, while percept is left eye
                        maintainedduringHIGH = [maintainedduringHIGH mainttype(i)];
                        maintdurHorder = [maintdurHorder maintOrder(i)];
                    end
                    
                case 1 %trial started with right eye dominance (+1)
                    if Speed=='L' %Right eye High Hz
                        maintainedduringHIGH = [maintainedduringHIGH mainttype(i)];
                        maintdurHorder = [maintdurHorder maintOrder(i)];
                    else %speed is 'H' .:. right eye low Hz;
                        maintainedduringLOW = [maintainedduringLOW mainttype(i)];
                        maintdurLorder = [maintdurLorder maintOrder(i)];
                    end
                case 0
                    maintainedduringMIXED= [maintainedduringMIXED mainttype(i)];
            end
        end
        
        %last but not least, count the times when a stimulus was presented, but a
        % 'failed switch' occured, where switch >1 times during stim.
        failedSwitchFROM= [];
        for idbl = 1:length(double_swChunks)
            failchnk = double_swChunks(idbl);
            
            percept_pre = TotalExp(Chunks(failchnk) - 1); %finds the button press one frame before stim onset.
            
            failedSwitchFROM = [failedSwitchFROM, percept_pre];
        end
        % %-1 is always lefteye
        
        failed_swLOWtoHIGH=[];
        failed_swLOWtoHIGHorder=[];
        failed_swHIGHtoLOW=[];
        failed_swHIGHtoLOWorder=[];
        
        for i=1:length(failedSwitchFROM)
            
            perceptt = failedSwitchFROM(i);
            
            switch perceptt
                case -1; %if trial started with left eye dominance
                    
                    if Speed == 'L'; % and left eye is low Hz;
                        failed_swLOWtoHIGH = [failed_swLOWtoHIGH, double_swChunksTYPE(i)];
                        failed_swLOWtoHIGHorder = [failed_swLOWtoHIGHorder, double_swChunks(i)];
                    else %Speed='H', left eye is high hz, while percept is left eye
                        failed_swHIGHtoLOW = [failed_swHIGHtoLOW, double_swChunksTYPE(i)];
                        failed_swHIGHtoLOWorder=[failed_swHIGHtoLOWorder, double_swChunks(i)];
                    end
                    
                case 1 %trial started with right eye dominance (+1)
                    if Speed=='L' %Right eye High Hz
                        failed_swHIGHtoLOW = [failed_swHIGHtoLOW, double_swChunksTYPE(i)];
                        failed_swHIGHtoLOWorder=[failed_swHIGHtoLOWorder, double_swChunks(i)];
                    else %speed is 'H' .:. right eye low Hz;
                        failed_swLOWtoHIGH = [failed_swLOWtoHIGH, double_swChunksTYPE(i)];
                        failed_swLOWtoHIGHorder = [failed_swLOWtoHIGHorder, double_swChunks(i)];
                    end
                    
            end
        end
        %%
        
        
        checkme.CaseType = ExpType;
        checkme.block = num;
        checkme.OrderIN = Order;
        checkme.stimswOrder= stimswOrder_idx;
        checkme.stimswitchtypes = stimswTYPE;
        checkme.switchpoint = switchpoint;
        checkme.switchtime = switchtime;
        
        checkme.fromHIGHtoLOWidx = fromHIGHtoLOW_order;
        checkme.fromHIGHtoLOW_type = fromHIGHtoLOW_stimtype;
        checkme.fromHIGHtoLOW_timestamp = fromHIGHtoLOW_timestamp;
        
        checkme.fromLOWtoHIGHidx = fromLOWtoHIGH_order;
        checkme.fromLOWtoHIGH_type= fromLOWtoHIGH_stimtype;
        checkme.fromLOWtoHIGH_timestamp = fromLOWtoHIGH_timestamp;
        
        checkme.double_swChunksOrder= double_swChunks;
        checkme.double_swChunksTYPE=double_swChunksTYPE;
        
        checkme.dblswHIGHtoLOW= failed_swHIGHtoLOW;
        checkme.dblswHIGHtoLOWorder= failed_swHIGHtoLOWorder;
        checkme.dblswLOWtoHIGH=failed_swLOWtoHIGH;
        checkme.dblswLOWtoHIGHorder=failed_swLOWtoHIGHorder;
        
        checkme.maintOrder = maintOrder;
        checkme.maintType = mainttype;
        checkme.maintHightype = maintainedduringHIGH;
        checkme.mHorder = maintdurHorder;
        checkme.maintLowtype = maintainedduringLOW;
        checkme.mLorder = maintdurLorder;
        checkme.maintMix = maintainedduringMIXED;
        checkme.chunkeddata=Data;
        
        
        
        
        if sanitycheckON==1
            
            
%              checkme
%              continueSWvsM = input('Print/Continue with switch vs maintenance analysis? y/n...', 's');
            continueSWvsM='y';

        else
            continueSWvsM='y';
        end
        if continueSWvsM=='y'
            %%
            if sanitycheckON==1
            % cd(num2str(namedir));
            print(gcf, '-dpng', ['Block' num2str(num) ' Tracking with likelihood']);
            end
            %%
            % clf
            % cd ../
            %% plot and calculate congruent vs incongruent switchrates
            namedir=allppantsfols(ifol).name;
            
            dataout= switch_maintaincountAttnExp(fromHIGHtoLOW_stimtype, fromLOWtoHIGH_stimtype, maintainedduringHIGH, maintainedduringLOW, ...
                failed_swHIGHtoLOW, failed_swLOWtoHIGH, ExpType, phaseis, num, sanitycheckON);
            %% %save in ppant data folder
            
%            saveProcessAcrossppants(mainttype,maintainedduringHIGH, maintainedduringLOW, fromHIGHtoLOW_stimtype,fromHIGHtoLOW_timestamp, fromLOWtoHIGH_stimtype,fromLOWtoHIGH_timestamp,...
%                switchpoint, switchtime, stimswOrder_idx, maintOrder, failed_swHIGHtoLOW, failed_swLOWtoHIGH, Data, ExpType, phaseis, namedir, pathtoBehaviouraldata, Order, checkme, params);
            
            
            
%             checkme.LRdom_pval=pval;
            checkme.LefteyePCT = LeftChance;
            checkme.RighteyePCT=RightChance;
            checkme.MixedPCT=MixedChance;
            
            if Leftc =='R'
                checkme.RedPCT = LeftChance;
                checkme.GreenPCT = RightChance;
            else
                checkme.RedPCT = RightChance;
                checkme.GreenPCT = LeftChance;
            end
            if Speed=='L'
                checkme.LowhzPCT = LeftChance;
                checkme.HighhzPCT = RightChance;
            else
                checkme.LowhzPCT = RightChance;
                checkme.HighhzPCT = LeftChance;
            end
            
            
        else
            error(['discrepent for block' num2str(num) ', ' num2str(Casetype)]);
            
        end
        
%         checkme
        blockprobs=dataout;
        
%         blockdata = dataout;
        cd(pathtoBehaviouraldata)
        cd(allppantsfols(ifol).name)
        save(blockis.name, 'checkme', 'blockprobs', '-append')
        
        % store for easy plots.
        if useANYlengthstim==1
        SWprobs(1,num) = blockprobs.prob_swXMtype_anyLowhz;
        SWprobs(2,num)= blockprobs.prob_swXMtype_anyHighhz;
        SWprobs(3,num)= blockprobs.prob_switchVISonly;
        
        MNTprobs(1,num)= blockprobs.prob_maintXMtype_anyLowHz;
        MNTprobs(2,num)= blockprobs.prob_maintXMtype_anyHighHz;
        MNTprobs(3,num) = blockprobs.prob_maintVISonly;
        else
            SWprobs(1,num) = nanmean([blockprobs.prob_swXMtype_Lowhz_short,blockprobs.prob_swXMtype_Lowhz_medium, blockprobs.prob_swXMtype_Lowhz_long]);
        SWprobs(2,num)= nanmean([blockprobs.prob_swXMtype_Highhz_short, blockprobs.prob_swXMtype_Highhz_medium, blockprobs.prob_swXMtype_Highhz_long]);
        SWprobs(3,num)= blockprobs.prob_switchVISonly;
        
        MNTprobs(1,num)= nanmean([blockprobs.prob_maintXMtype_Lowhz_short, blockprobs.prob_maintXMtype_Lowhz_medium, blockprobs.prob_maintXMtype_Lowhz_long]);
        MNTprobs(2,num)=  nanmean([blockprobs.prob_maintXMtype_Highhz_short, blockprobs.prob_maintXMtype_Highhz_medium, blockprobs.prob_maintXMtype_Highhz_long]);
        MNTprobs(3,num) = blockprobs.prob_maintVISonly;
            
        end
            if any(squeeze(SWprobs(:,num)))>1 || any(squeeze(MNTprobs(:,num)))>1 ;
                error('check probs')
            end
    end
    
    % now in each ppant folder. store the probabilities for combined
    % crossmodal, 3 x hz
    % Hz.
    
    save('CombinedProbs(hz,block)', 'SWprobs', 'MNTprobs')
    
end


% now that it's done. Concat across ppants by attnd or not, then plot
%%
cd(pathtoBehaviouraldata)

AcrossallProbsSW=zeros(34,2,3);
AcrossallProbsMNT=zeros(34,2,3);
for iattn=1:2
    cd(pathtoBehaviouraldata);
    switch iattn
        case 1
            gotofols = dir([pwd filesep '*Attn_On']);
        case 2
            gotofols = dir([pwd filesep '*Attn_Off']);
    end
    
    for ip = 1:length(gotofols)
        cd(pathtoBehaviouraldata);
        cd(gotofols(ip).name);
        load('CombinedProbs(hz,block)')
        
        AcrossallProbsMNT(ip,iattn,:)=squeeze(nanmean(MNTprobs,2));
        AcrossallProbsSW(ip,iattn,:)=squeeze(nanmean(SWprobs,2));
    end
end
cd(pathtoBehaviouraldata)

save('CombinedProbs(ppants,attend,hz)', 'AcrossallProbsSW', 'AcrossallProbsMNT');
end
if job.justplot==1
cd(pathtoBehaviouraldata)
    load('CombinedProbs(ppants,attend,hz).mat');

    %% plotting:
colLow= [.5 .7 .5];%dark green

colHigh= [.7 .5 .5];%[. %dark red
fontsize=15;
colV=[.7 .7 .7];

combineVis = 1; % 1 = set horizontal line as per Lunghi et al (2014).
%%
clf
plotcount=1;
for plotme = 1:2 %switches then maintenance.
    
    switch plotme
        case 1
            databook = AcrossallProbsSW;
            typeis = 'Switching to congruent percept';
            yvec=[.4 .7];
            col=[0, 0, 1];
        case 2
            databook = AcrossallProbsMNT;
            typeis = 'Maintenance of congruent percept';
            yvec=[.1 .5];
            col=[1,0,0];
    end
       
    %     [nppants,ntypes,nattnd,nfreqs]= size(databook);
    %%
    for iattndcond = 3% 1:2
%         subplot(2,2,plotcount)
        switch iattndcond
            case 1
                condwas='while Attending to cross-modal stimulation';
            case 2
                condwas='while ignoring cross-modal stimulation';
            case 3
                condwas = 'during crossmodal tones';
        end
       if iattndcond~=3
           %dims are= ppant, blocktype, attn, freq
           data_COMB= squeeze(databook(:,iattndcond,:));
     % take mean over crossmodal and phase.
           
    
       else
%            placepl = [1:2]+(2*(plotcount-1));
%            subplot(2,2, placepl )
           subplot(1,2,plotme)
           bar_COMB= databook; % mean over phase
           %note we have separate att and natt for plots.
           %reorder so that we have attn (3x hz) vs natt (3xhz)
           
           
           bar_COMBre=[];
           icc=1;
           for it=1:2
               for ih=1:3
                   bar_COMBre(:,icc) = bar_COMB(:,it, ih);
                   icc=icc+1;
               end
           end
           
       end
    
   

if iattndcond~=3
    bhandle(1)=bar(squeeze(nanmean(bar_COMB,1)), .5);
    bhandle(1).FaceColor = colLow;
    hold on; %append for different colours
    bartmp= bar_COMB;
    bartmp(:,1)=nan;
    bhandle(2)=bar(squeeze(nanmean(bartmp,1)), .5);
    bhandle(2).FaceColor=colHigh;
    bartmp(:,2)=nan;
    bhandle(3)=bar(squeeze(nanmean(bartmp,1)), .5);
    bhandle(3).FaceColor = colV;
    
    bhandle(1).BarWidth = .9;
    bhandle(2).BarWidth = .9;
    bhandle(3).BarWidth = .9;
    bar_COMBe=bar_COMB;
else
    %%
    if combineVis~=1
    bh=bar(squeeze(nanmean(bar_COMB,1)), .5);
   
    else 
        bh=bar(squeeze(nanmean(bar_COMB(:,:,1:2),1)), .5);    
        
        hold on
        
        %place horiz bar. 
            bvis=squeeze(mean(mean(bar_COMB(:,:,3),2),1));
visVal= plot(xlim, [bvis bvis], 'k-');

% place combined bar.
% visVal=bar(3, mean(mean(bar_COMB(:,:,3),2),1));
                        
    bh(1).FaceColor = colLow;
    bh(2).FaceColor = colHigh;
     bh(1).BarWidth = .9;
    bh(2).BarWidth = .9;
    
    try visVal.FaceColor = colV;
    visVal.BarWidth = .4;
    catch
        visVal.Color = colV;
        visVal.LineWidth=8;
    end
    end
    end
   
    
    bar_COMBe=bar_COMBre;
end
%
    %adjust error bars for w/in subj:
    mXp = nanmean(bar_COMBe,2);
    mA = nanmean(mXp);
    
    %adjust:
    Xnew = bar_COMBe - repmat(mXp, [1,size(bar_COMBe,2)]) + repmat(mA, [size(bar_COMBe,1) size(bar_COMBe,2)]);
    
%    err_bar= nanstd(Xnew) / sqrt(34);
   err_bar = nanstd(bar_COMBe)/sqrt(34);
    %%
   hold on
   if iattndcond~=3
       %place normally.

        errorbar(nanmean(bar_COMB,1), err_bar, 'k', 'linestyle', 'none');
   else %adjust for wonky placement.
       %arrange to 2x3
       err_bar = [err_bar(:,1),err_bar(:,2),err_bar(:,3);...
           err_bar(:,4),err_bar(:,5),err_bar(:,6)];
       m_bar=squeeze(nanmean(bar_COMB,1));
       
       if combineVis~=1
       numgroups = 2;
    numbars = 3; %per group
       else
           numgroups = 2;
    numbars = 2; %per group
    
    m_bar=m_bar(:,1:2);
    err_bar=err_bar(:,1:2);
       end
           
           
    groupwidth = min(0.8, numbars/(numbars+1.5));
    allxt = []; %save xlocations
    for i = 1:numbars
        % Based on barweb.m by Bolu Ajiboye from MATLAB File Exchange
        x = (1:numgroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*numbars);  % Aligning error bar with individual bar
        errorbar(x, m_bar(:,i), err_bar(:,i), 'k', 'linestyle', 'none');
        allxt = [allxt, x];
    end
       
    %also place vis only erro bar
    if combineVis==1
        err_bar = nanstd(bar_COMBe)/sqrt(34);
        errVis= (err_bar(3) + err_bar(6))/2;
         try %only if we used a bar chart.
        errorbar(3, visVal.YData, errVis, 'k', 'linestyle', 'none')
         catch
         end
    end
    
   
   %%
   
    
   
    %label 
%     set(gca,'xticklabel', {'Auditory', 'Tactile', 'Auditory and Tactile'}, 'fontsize', fontsize)
if iattndcond~=3    
set(gca,'xticklabel', {'Low', 'High', 'Visonly'}, 'fontsize', fontsize)
else
    set(gca,'xtick', 1:3, 'xticklabel', {'Attending cues', 'Ignoring cues', 'Visual only'}, 'fontsize', fontsize)
    legend([bh(1) bh(2) visVal], {'Low Hz', 'High Hz', 'Visual only'})
end
    set(gca, 'fontsize', fontsize)
%     set(lg, 'location', 'northeast')
%     ylim([yvec])
ylim([ 0 .9])
%     ylabel({['Proportion of trials'];[condwas]}, 'fontsize', fontsize)
    ylabel({['Proportion of trials']}, 'fontsize', fontsize)
    %%
    title({[ num2str(typeis) ];[condwas]}, 'fontsize', fontsize)
% title({['Proportion for ' num2str(typeis)];['over trial types']}, 'fontsize', fontsize)
    xlabel('Cross-modal Stimulation type', 'fontsize', fontsize)
    cd('figs')
   cd('A_ProbabilityBargraphs')
   shg
set(gca, 'fontsize', fontsize)

   %%
%     print('-dpng', ['Probability of ' typeis ' ' condwas   ' combining all to compare to Lunghi'])
    
%     shg
    cd(pathtoBehaviouraldata)
    plotcount=plotcount+1;
    
    end
    %%
    if plotme==1
        ylim([.45 .8])
    else
        ylim([.1 .7])
    end
%     xlim([.2 .7])
end
end
%%
set(gcf, 'color', 'w')
shg
shg
cd ../../
print('-dpng', ['barswitchvsmaint'])
