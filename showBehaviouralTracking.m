clear all
scrRate=60;
window = (7 * scrRate); %6 seconds at screen Rate
dbstop if error
ParticipantBehaviouralTracking=nan(3,2,3, 4, window+1); %4 reps per block.
%[xmod,phase, hz, blocks, samps] = size(ParticipantBehaviouralTracking)
realblockcount=1;
usesmooth=0; %for smoothing output
useSherrbar=1; %plot single trace of trace with error bars?
%%
try cd('/Users/MattDavidson/Desktop/XM_Project/DATA_newhope/');
catch
    cd('/Users/MatthewDavidson/Desktop/XMODAL/DATA_newhope/');
end

savedatadir=pwd;
allppantfols=dir([pwd filesep '*Day*']);
%%

sanitycheckON=0;
fontsize=15;

for ippant=1:length(allppantfols) %%%%% %% %% %% %
    %% % %% %%
    ParticipantBehaviouralTracking=nan(3,2,3, 4, window+1); %4 reps per block.
    Participant_IndivTrialleveldata=nan(3,2,3, 24, window+1); %24 trials per type
    Participant_IndivTrialleveldata_Vis=nan(3,2,3, 12, window+1); %12 trials per type
    cd(savedatadir)
    namedir=allppantfols(ippant).name;
    cd(namedir)
    for i =1:24 %always 24 blocks.
        %%
        load('Seed_Data')
        filet = dir([pwd filesep 'Block' num2str(i)  'Exp*']);
        
            filename = filet.name;
            load(num2str(filename), 'blockout')
            %%
            rivTrackingData=blockout.rivTrackingData;
            TotalExp = rivTrackingData(:,2)  - rivTrackingData(:,1); %-1 left eye, +1 right eye.
            TotalExp=TotalExp';
            Data= [];
            Chunks=blockout.Chunks;
            
            if ippant==41 && i == 22
                Chunks(30) = length(blockout.Trials);
            end
            
            if params.AttendEXP==1
                attendcond='Attend';
            else
                attendcond='non-Attend';
            end
            %% extend chunk window beyond stimulus offset.
            for ich=1:length(Chunks)/2
                onsett=Chunks(2*ich-1);
                try tmp=TotalExp(1,onsett:onsett+window);
                catch
                    tmp=TotalExp(1,onsett:length(TotalExp));
                    epochfull= length(Data);
                    plusme = epochfull - length(tmp);
                    tmp2= zeros(1,plusme);
                    tmp = [tmp,tmp2];
                end
                
                Data(ich,:) =tmp;
            end
            %%
            Speed=[];
            %convert to congruent
            try Speed = blockout.LeftEyeSpeed;
            catch
                if length(filename)==20;
                    tmp= str2num(filename(16));
                else
                    tmp= str2num(filename(17));
                end
                
                switch tmp
                    case {1, 3}
                        Speed='L';
                    case {2, 4}
                        Speed='H';
                end
            end
            %%
            Tracking_by_type=[];
            
            congrData=Data;
            for itrial = 1:length(blockout.Order)
                trialwas= blockout.Order(itrial);
                trialtrace=congrData(itrial,:);
                switch trialwas
                    case 1
                        
%                         congrData(itrial,:)=0;
                                %use first BP as congruent (index switching)
                                fBP=trialtrace(1);
                                trialtrace(trialtrace~=1)=0; %left eye low hz congruent
                                congrData(itrial,:)=abs(trialtrace);
                                %store for later.
                                try Tracking_by_type.Visonly= [Tracking_by_type.Visonly; abs(trialtrace)];
                                catch
                                    Tracking_by_type.Visonly= abs(trialtrace);
                                end
                    case {82, 83, 84}; %low Hz trial
                        if strcmp(Speed, 'L')
                            trialtrace(trialtrace~=-1)=0; %left eye low hz congruent
                            congrData(itrial,:)=abs(trialtrace);
                        else %left eye was high hz
                            trialtrace(trialtrace~=1)=0; %Right eye low hz congruent
                            congrData(itrial,:)=abs(trialtrace);
                        end
                        
                        %store for later.
                        try Tracking_by_type.LowHz = [Tracking_by_type.LowHz; abs(trialtrace)];
                        catch
                            Tracking_by_type.LowHz = abs(trialtrace);
                        end
                    case {92, 93, 94}; %high Hz trial,
                        if strcmp(Speed, 'L')          %then +1 was to the High hz image
                            trialtrace(trialtrace~=1)=0; %left eye high hz congruent
                            congrData(itrial,:)=abs(trialtrace);
                        else %left eye was high hz
                            trialtrace(trialtrace~=-1)=0; %Right eye high hz congruent
                            congrData(itrial,:)=abs(trialtrace);
                        end
                        
                        try Tracking_by_type.HighHz = [Tracking_by_type.HighHz; abs(trialtrace)];
                        catch
                            Tracking_by_type.HighHz = abs(trialtrace);
                        end
                end
            end
            
            
            if sanitycheckON==1
                %%
                figure(1)
                colormap('jet')
                imagesc(Data);
                title(['Left eye was ' num2str(Speed) '  hz']);
                yt=get(gca,'ytick');
                yt=1:20;
                set(gca,'ytick', 1:20, 'yticklabel', blockout.Order)
                colorbar
                
                figure(2)
                colormap('hot')
                colormap(flipud(colormap))
                imagesc(congrData);
                title(['Left eye was ' num2str(Speed) '  hz']);
                yt=get(gca,'ytick');
                yt=1:20;
                colorbar
                set(gca,'ytick', 1:20, 'yticklabel', blockout.Order)
                %        continueYN=input('y/n:');
                
                figure(3)
                colormap('hot')
                colormap(flipud(colormap))
                subplot(2,1,1)
                imagesc(Tracking_by_type.LowHz)
                title('Low Congr trials');
                subplot(2,1,2)
                imagesc(Tracking_by_type.HighHz)
                title('High Congr trials');
                colorbar
                
                %%
            end
            blockout.trackingData= Data;
            blockout.congrtrackingData=congrData;
            blockout.window_framespostoffset=window;
            blockout.Tracking_by_type=Tracking_by_type; %all trials this block.
            save(filename, 'blockout', '-append')
        
    end
    
    
    for iblocktype=1:6
        trialcount=1; % for each block type.
        outdata=[];
        switch iblocktype
            case {1, 2}
                needxmod= 'Auditory and Tactile';
                xmod=1;
            case {3, 4}
                needxmod = 'Auditory';
                xmod=2;
            case {5, 6}
                needxmod = 'Tactile';
                xmod=3;
        end
        if mod(iblocktype,2)~=0 %odd numbers in phase
            needphase='In';
            phs=1;
            
        else
            needphase='Out';
            phs=2;
        end
        %cycle through for block types
        for i=1:24
            filet = dir([pwd filesep 'Block' num2str(i) 'Exp*']);
            %  load this blocks data. (6 trials per hz type, 3 x vis). 
            load(filet.name, 'blockout')
             %
                if strcmp(blockout.Casetype, needxmod)==1
                    if strcmp(blockout.Phasetype, needphase)==1
                        % then store
                        %should be (each day), 6 blocks per xmodx phase
                        %combo.
                        trialsin=[1:6] + 6*(trialcount-1); 
                        trialsin_vis=[1:3] + 3*(trialcount-1); 
% %                         
%                         ParticipantBehaviouralTracking(xmod, phs, 1, trialsin(1):trialsin(6),:)=blockout.Tracking_by_type.LowHz;
%                         ParticipantBehaviouralTracking(xmod, phs, 2, trialsin(1):trialsin(6),:)=blockout.Tracking_by_type.HighHz;
% %                         %
%                         ParticipantBehaviouralTracking(xmod, phs, 3, trialsin(1):trialsin(3),:)=blockout.Tracking_by_type.Visonly;
%                         trialcount=trialcount+1;

                        %take mean, per freq, per block.

                        ParticipantBehaviouralTracking(xmod, phs, 1, trialcount,:)=nanmean(blockout.Tracking_by_type.LowHz,1);
                        ParticipantBehaviouralTracking(xmod, phs, 2, trialcount,:)=nanmean(blockout.Tracking_by_type.HighHz,1);                        
                        ParticipantBehaviouralTracking(xmod, phs, 3, trialcount,:)=nanmean(blockout.Tracking_by_type.Visonly,1);
                        
                        
                        
                        %also trial level data.
                        
                        Participant_IndivTrialleveldata(xmod, phs, 1, trialsin(1):trialsin(6),:)=blockout.Tracking_by_type.LowHz;
                        Participant_IndivTrialleveldata(xmod, phs, 2, trialsin(1):trialsin(6),:)=blockout.Tracking_by_type.HighHz;
                        
                        Participant_IndivTrialleveldata_Vis(xmod, phs, 1, trialsin_vis(1):trialsin_vis(3),:)=blockout.Tracking_by_type.Visonly;
                        
                        
                        trialcount=trialcount+1;
                        
                        
                        
                        
                        
                        
                    end
                end
                clear blockout
            
        end
    end
    save('PpanttrackingbyType(xmod,phase,hz,trials,samps)', 'ParticipantBehaviouralTracking',...
        'Participant_IndivTrialleveldata','Participant_IndivTrialleveldata_Vis');
    
    
    
    clf
    %%
    % separate in phase and out of phase
    plotcount=1;
    
    
    
    pl=[];
    %
    for xmod=1:3
        
%         for iphase=1:2
            % for iplot=1:2
            %
            
            %in phase first
            %
%             switch iphase
%                 case 1
%                     titlep = {[num2str(attendcond) ', Day ' params.Day1_2 ','];[' In phase, participant ' params.Initials ' ']};
%                 case 2
%                     titlep = {[num2str(attendcond) ', Day ' params.Day1_2 ', '];['Out of phase, participant ' params.Initials ' ']};
%     end
            
            
            switch xmod
                case 1
                    marker='-.';
                    stimmod='AnT';
                case 2
                    marker = '-';
                    stimmod='AUD';
                case 3
                    marker = ':';
                    stimmod='TAC';
            end
            subplot(3,1,plotcount)
            for ihz = 1:3
                switch ihz
                    case 1
                        colorin = 'b'; %low hz
                    case 2
                        colorin = 'r'; %high hz
                        case 3
                        colorin = 'k'; %vis hz
                end
                if ihz<3
%                 tmp=squeeze(ParticipantBehaviouralTracking(xmod,iphase,ihz,:,:));                
tmp=squeeze(nanmean(ParticipantBehaviouralTracking(xmod,:,ihz,:,:),2)); %takes mean over phase.
                else
                    %                 tmp=squeeze(ParticipantBehaviouralTracking(xmod,iphase,ihz,:,:));                
                    tmp=squeeze(nanmean(ParticipantBehaviouralTracking(xmod,:,ihz,:,:),2));
                end
                stErr = std(tmp)/sqrt(size(tmp,1));
                plotme= nanmean(tmp,1);
                if usesmooth==1
                    plotme = smooth(plotme,15);
                    stErr=smooth(stErr,15);
                end
                timing = [1:length(tmp)]/scrRate;
                if useSherrbar==1
                    p=shadedErrorBar(timing, plotme, stErr, [colorin marker],1);
                    pl(ihz).mainLine=p.mainLine;
                else
                    pl(ihz)=plot(timing, plotme, [colorin marker], 'linewidth', 3);
                end
                hold on
                
                ylim([.1 1])
                xlim([0 timing(end)])
                
            end
%             title(titlep,'fontsize', fontsize)
            xlabel('Time (secs)', 'fontsize', fontsize)
            ylabel('Prob', 'fontsize', fontsize)
            plot(xlim, [0.5 0.5], ['k' '-'])
            
            plotcount=plotcount+1;
            if useSherrbar==1
                lg=legend([pl(1).mainLine, pl(2).mainLine pl(3).mainLine], {[stimmod ' Low'] , [stimmod ' High'], ['Visonly']});
            else
                lg=legend([pl(1), pl(2)], {stimmod 'Low' , stimmod ' High'});
            end
            set(lg, 'fontsize', fontsize)
            
%         end
    end
    
    %%
    cd(savedatadir)
%     cd('figs')
%     cd('Behavioural Tracking by Individual')
%     printfilename=['Behavioural Tracking for ' num2str(params.Initials) ', Day ' num2str(params.Day1_2) ', (' num2str(attendcond) ')'];
% %     if usesmooth==1        
% %         print('-dpng', [printfilename ' smoothed']) 
%     else
%         print('-dpng', printfilename)
%     end
%      cd(savedatadir)
%     namedir=allppantfols(ippant).name;
%     cd(namedir)
%     
%     if usesmooth==1        
%         print('-dpng', [printfilename ' smoothed']) 
%     else
%         print('-dpng', printfilename)
%     ends
%     
    %%
end
