% miniBlockTrace
removemixedperiods=0;
Chunks = blockout.Chunks;
rivTrackingData=blockout.rivTrackingData;
Trials= blockout.Trials;
scrRate=60;
Order=blockout.Order;
windowRect=params.windowRect;
%ignore switches that happen in first xstim_s after stimulust presentation

quick=0;
num= ['Block ' num2str(iblock)];

Xmodaltype=blockout.Casetype;
ExpType = Xmodaltype;

fontsize=10;

%
skswitch=0;
%specify values for figures etc

if Speed=='L'
    Lspeed = 'Low Speed';
    Rspeed = 'High Speed';
else
    Lspeed='High Speed';
    Rspeed='Low Speed';
end

%%

%Prepare the data into easy matrix
Timing = rivTrackingData(:,3);
Timesecs = 1:size(Timing,1)/scrRate;

%Total Exp is difference between button presses.
TotalExp = rivTrackingData(:,2) - rivTrackingData(:, 1);


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
if removemixedperiods==1%remove periods of mixed response
for i =2:length(TotalExp)-1
    if TotalExp(i)==0
        TotalExp(i) = TotalExp(i-1); %removes mixed periods
    end
end
end

%%
% % Puts the button response during stimulus presentation into a big matrix
% % note that there are 20 rows, 4 stim of each type per block
Data=zeros(length(Chunks)/2, params.Trialdurs.long*scrRate);

for i = 1:length(Chunks)/2
    tmp = TotalExp(Chunks(2*i - 1):Chunks(2*i))';

    Data(i, 1:length(tmp)) = tmp';
end
%%
% finds 'switch' time points in button press (when changing from left to
% right eye)
if removemixedperiods==0
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
    switchpoint=[];
switchtime=[];
switchFROM=[];


%%
for iframe = 2:length(Timing)-1 %switch point in frames
    
    if TotalExp(iframe)~= TotalExp(iframe-1) % ie if at two frames don't match perceptually (a switch)
        %coming out of mixed dominance (which we skip), or a clean switch (rare)
        switchpointtmp = iframe;
        %clean switch
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
close
set(0, 'DefaultFigurePosition', [0 0 800 400]);

if sanitycheckON==0
    set(gcf, 'visible', 'off');
end

% subplot(2,2,1:2)
plot(Timing, TotalExp, 'Color', 'k');
ylim([-2 2]);
xlim([0 length(TotalExp)/scrRate])


%% Calculate L/Right dominance
Left_tot = abs(sum(TotalExp(TotalExp==-1)));
Right_tot= sum(TotalExp(TotalExp==1));

L_pct=100*(Left_tot/length(TotalExp));
R_pct=100*(Right_tot/length(TotalExp));

%mean percept dur
m_dur = mean(diff(switchpoint))/scrRate;
% 
% 
% %mean Lefteyedur 
% xl = TotalExp==-1;
% leftdurs=findstr(xl',[0 0]);
% 
% zcnt= (leftdurs(diff([1 leftdurs])~=1))
% xld=diff(find(diff(xl))); %whenever there is a change from 0 to 1. 
% %%
% ldurs=[];
% if xl(1)==1, %then first 'change' was to a percept
%     for i=1:length(xld)
%         if mod(i,2)~=0
%             ldurs=[ldurs,xld(i)]
%         end
%     end
% else
%     for i=1:length(xld)
%         if mod(i,2)==0
%             ldurs=[ldurs,xld(i)]
%         end
%     end
% end
%%
L_pct=sprintf('%.2f', L_pct);
R_pct=sprintf('%.2f', R_pct);
M_dur=(sprintf('%.2f',m_dur)); %plotted in final image.
%%
set(gca, 'yTick', [ -1 1], 'yTickLabel',...
    {[num2str(Lspeed)];...
    [num2str(Rspeed)]},...
    'Fontsize', fontsize);
title([ 'Buttonpress Activity during ' num2str(num)  ]);
xlabel('Seconds');
%%

%


% check switchpoints correlate
hold on

text(130, -1.5, ['Total switches = ' num2str(length(switchpoint))], 'Fontsize', fontsize)


%% TrainingAccuracy

ChunkEndtimes=[];

for i = 1:length(Chunks)
    if mod(i,2)==0 %even numbers for end of chunk
        ChunkEndtimes = [ChunkEndtimes, Chunks(i)];
    end
end
%%
buttonpressatChunkEND=[];
for i = 1:length(ChunkEndtimes)
    prepresstime = ChunkEndtimes(i) - 1; %1/scrRate frames in seconds
        prebutton = TotalExp(prepresstime,1);
        buttonpressatChunkEND = [buttonpressatChunkEND, prebutton];
end
%%
congruentpresentation = [];
chcounter=1;
for ich = 1:length(Order)
    
    stimpresent = Order(ich);
    
    buttontmp = buttonpressatChunkEND(ich);
    switch stimpresent
        case 1
            congruentpresentation(1,chcounter) = 0;%fail
        case {82 83 84} %low
          if strcmp(Speed, 'L') %-1 is left eye and low hz. 
              if buttontmp ==-1
                  congruentpresentation(1,chcounter) = 1; %success
              else
                  congruentpresentation(1,chcounter) = 0;%fail
              end
          else % is actually high hz for left eye
              if buttontmp ==1
                  congruentpresentation(1,chcounter) = 1;%success
              else
                   congruentpresentation(1,chcounter) = 0;%fail
              end
          end
          
        case {92 93 94} %high hz
            if strcmp(Speed, 'H') %-1 is left eye and high hz. 
              if buttontmp ==-1
                  congruentpresentation(1,chcounter) = 1; %success
              else
                  congruentpresentation(1,chcounter) = 0;%fail
              end
          else %-1 is actually low hz
              if buttontmp ==1
                  congruentpresentation(1,chcounter) = 1;%fail
              else
                  congruentpresentation(1,chcounter) = 0;%success
              end
            end

    end
    chcounter=chcounter+1;
end
%%
% 
% Chunkstarttimes=[];
% 
% for i = 1:length(Chunks)
%     if mod(i,2)>0 %odd numbers
%         Chunkstarttimes = [Chunkstarttimes, Chunks(i)];
%     end
% end
% % 
% buttonpressatChunkstart=[];
% for i = 1:length(Chunkstarttimes)
%     prepresstime = Chunkstarttimes(i) - 1; %1/scrRate frames in seconds
%     prebutton = TotalExp(prepresstime,1);
%     buttonpressatChunkstart = [buttonpressatChunkstart, prebutton];
% end
% %%
% congruentpresentation = [];
% chcounter=1;
% for ich = 1:length(Order)
%     
%     stimpresent = Order(ich);
%     
%     
%     buttontmp = buttonpressatChunkstart(ich);
%     switch stimpresent
%         case 1
%             %just use for plotting, don't use for calculations.
%             congruentpresentation(1,chcounter) = 0;
%             
%         case 2 %low
%             if strcmp(Speed, 'L') %-1 is left eye and low hz.
%                 if buttontmp ==-1
%                     congruentpresentation(1,chcounter) = 1; %success
%                 else
%                     congruentpresentation(1,chcounter) = 0;%fail
%                 end
%             else %-1 is actually high hz
%                 if buttontmp ==-1
%                     congruentpresentation(1,chcounter) = 0;%fail
%                 else
%                     congruentpresentation(1,chcounter) = 1;%success
%                 end
%             end
%             
%         case 3 %high hz
%             if strcmp(Speed, 'H') %-1 is left eye and high hz.
%                 if buttontmp ==-1
%                     congruentpresentation(1,chcounter) = 1; %success
%                 else
%                     congruentpresentation(1,chcounter) = 0;%fail
%                 end
%             else %-1 is actually low hz
%                 if buttontmp ==-1
%                     congruentpresentation(1,chcounter) = 0;%fail
%                 else
%                     congruentpresentation(1,chcounter) = 1;%success
%                 end
%             end
%     end        
%             chcounter=chcounter+1;
%     
% end

%%
% observe if stimuli correlate to chunks (visually)
hold on
%
tcount=1;
for i= 1:(length(Chunks)/2)

trialwas=Trials(Chunks(2*i-1));
if trialwas>1   
switch trialwas
        
        %         case 1
        %
        %             scolour= [.75 .75 .75];
        
        case {82 83 84}
            
            scolour= [0 .75 1]; %bright blue
        case {92 93 94}
            
            scolour= [1 .49 .31]; %bright organge
            
    end
    
    x1= Timing(Chunks(2*i-1));
    x2= Timing(Chunks(2*i));
    xvec = x1:.1:x2;
    
    for i=1:length(xvec)
        tempx = xvec(i);
        plot([tempx,tempx], [-.5 .5],...
            '-', 'Color', scolour, 'MarkerFacecolor', scolour, 'MarkerSize', 14);
    end
    
    if congruentpresentation(1,tcount) %this was a trial which was presented to congruent percept
        %circle the trial?
        text(median(xvec)-2, 0, '*', 'color' ,'r', 'Fontsize', 28)
    end
end
    tcount=tcount+1;
end
%%

text(40, 1.55, '*', 'color',[0 .75 1] , 'FontSize', 28);
text(50, 1.60, 'Low speed tone', 'color','k', 'FontSize', fontsize);


text(120, 1.55, '*', 'color', [1 .49 .31], 'FontSize', 28);
text(130, 1.60, 'High speed tone', 'color','k', 'FontSize', fontsize);


text(40, -1.5, '*', 'color' ,'r', 'Fontsize', 28)
text(50, -1.5, 'Matched Example', 'color' ,'k', 'Fontsize', fontsize)



%%

if ~ProcessingUpstairs
F = getframe(gcf);
[X, Map] = frame2im(F);
% Open Screen
%%
screenPREPs
%
figtoshow=Screen('MakeTexture', params.windowPtr, X);
Screen('TextSize', params.windowPtr,40);
%
for drawLR=0:1
    
    
    % Select left-eye image buffer for drawing:
    Screen('SelectStereoDrawBuffer', params.windowPtr, drawLR);
    imCenter = params.windowRect/2;
    
    
    
    % Drawing the texture
    Screen('DrawTexture',params.windowPtr, figtoshow)
    
   %Draw Accuracy. 
        DrawFormattedText(params.windowPtr, ['You were ' num2str(sprintf('%.2f',BlockAttnAccuracy*100)) '% Accurate'], 'center',...
        [imCenter(4)*1.6],[],[],[],[],[],[]);

     DrawFormattedText(params.windowPtr, [Leftc ' ' L_pct '\n' Rightc ' ' R_pct '\n' M_dur], 'center',...
        [15],[],[],[],[],[],[]);

end
Screen('Flip', params.windowPtr);

%%
KbWait()
pause(2);
else 
    shg
end
printfilename= ['Block' num2str(iblock) ' Tracking'];
print('-dpng', printfilename);

