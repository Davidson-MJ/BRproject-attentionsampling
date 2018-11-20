%plot across participant button press traces.
clear all
scrRate=60;
window = (7 * scrRate); %6 seconds at screen Rate
dbstop if error
realblockcount=1;
usesmooth=0; %for smoothing output
useSherrbar=1; %plot single trace of trace with error bars?
%
try cd('/Users/MattDavidson/Desktop/XM_Project/DATA_newhope');
catch
    cd('/Users/MatthewDavidson/Desktop/XMODAL/DATA_newhope');
end
    savedatadir=pwd;
    
    %%
ppantdirs = dir(['*_On*']);
%
icount=1;
group_A_d1list=[];
group_nA_d1list=[];
group_A_d2list=[];
group_nA_d2list=[];
% remove non ppant directories.
for i=1:length(ppantdirs)
    %
    tmp=length(ppantdirs(icount).name);
    if tmp<10 %remove shadow folders
        ppantdirs(icount)=[];
        
    else
        cd(ppantdirs(icount).name);
        load('Seed_Data.mat', 'params')
        
        switch params.Day1_2
            case '1' %first day
                switch params.AttendEXP
                    case 1 %Attend first day
                        
                        group_A_d1list = [group_A_d1list; {ppantdirs(icount).name}];
                    case 0
                        group_nA_d1list =[group_nA_d1list ; {ppantdirs(icount).name}];
                        
                end
                
            case '2'
                switch params.AttendEXP
                    case 0 %Attend second day
                        
                        group_A_d2list = [group_A_d2list; {ppantdirs(icount).name}];
                    case 1
                        group_nA_d2list =[group_nA_d2list ; {ppantdirs(icount).name}];
                        
                end
                
        end
        icount=icount+1;
    end
    
    
    cd(savedatadir)
end
group_A_list.day(1).list=group_A_d1list;
group_A_list.day(2).list=group_A_d2list;
group_nA_list.day(1).list=group_nA_d1list;
group_nA_list.day(2).list=group_nA_d2list;

nppants=length(ppantdirs);
%
%
for igroup=1:2
    switch igroup
        case 1
            usegroup = group_A_list;
        case 2
            usegroup = group_nA_list;
            
    end
    
    for iDay=1:2
        switch iDay
            case 1
                if igroup==1
                    attendcond='Attending';
                else
                    attendcond='Non-Attending';
                end
                plDAY='1';
            case 2
                
                if igroup==2
                    attendcond='Attending';
                else
                    attendcond='Non-Attending';
                end
                plDAY='2';
        end
        
        ppantdirs = usegroup.day(iDay).list;
        nppants=size(ppantdirs,1);
        AcrossallPPANTs = nan(nppants, 3,2,3, 421); % ppants, xmod, phase, hz, samps
        for ippant = 1:nppants
            
            cd(savedatadir)
            folppant=(ppantdirs{ippant});
            cd(num2str(folppant))
            
            disp([ 'loading directory ' ppantdirs{ippant}])
            load('PpanttrackingbyType(xmod,phase,hz,trials,samps).mat')
            load('Seed_Data', 'params'); %find out which group they belong to.
            %take mean across trials.
            ppantmean = squeeze(mean(ParticipantBehaviouralTracking,4));
            if isnan(squeeze(mean(mean(mean(mean(ppantmean))))))
                error('echeck for nan')
            end
            AcrossallPPANTs(ippant,:,:,:,:)=ppantmean;
            
            
            
        end
        
        %% Print the result per day/group.
        clf
        pl=[];
        
        % separate in phase and out of phase
        for iphase=1:2
            % for iplot=1:2
            %
            subplot(1,2,iphase)
            %in phase first
            %
            switch iphase
                case 1
                    titlep = 'In phase ';
                case 2
                    titlep= 'Out of phase ';
            end
            
            
            plcounter=1;
            %
            for xmod=1:3
                switch xmod
                    case 1
                        marker='-.';
                    case 2
                        marker = '-';
                    case 3
                        marker = ':';
                end
                for ihz = 1:3
                    switch ihz
                        case 1
                            colorin = 'b'; %low hz
                        case 2
                            colorin = 'r'; %High hz
                            case 3
                            colorin = 'k'; %low hz
                    end
                    
                    tmp=squeeze(AcrossallPPANTs(:,xmod,iphase,ihz,:));
                    stErr = std(tmp)/sqrt(size(tmp,1));
                    plotme= mean(tmp,1);
                    if usesmooth==1
                        plotme = smooth(plotme,15);
                        stErr=smooth(stErr,15);
                    end
                    timing = [1:length(tmp)]/scrRate;
                    if useSherrbar==1
                        plt=shadedErrorBar(timing, plotme, stErr, [colorin marker],1);
                        if plcounter==1
                            pl=plt;
                        else
                            pl(plcounter)=plt;
                        end
                    else
                        pl(plcounter)=plot(timing, plotme, [colorin marker], 'linewidth', 3);
                    end
                    hold on
                    plcounter=plcounter+1;
                    ylim([.3 1])
                    xlim([0 timing(end)])
                    
                end
                title(['Day' num2str(plDAY) ' ' attendcond ' ' titlep ' n= ' num2str(nppants) ' .'],'fontsize', 20)
                xlabel('Time (secs)', 'fontsize', 20)
                ylabel('Prob', 'fontsize', 20)
                plot(xlim, [0.5 0.5], ['k' '-'])
                set(gca, 'fontsize', 15)
                
                
            end
            if useSherrbar==1
                lg=legend([pl(1).mainLine, pl(2).mainLine, pl(3).mainLine, pl(4).mainLine, pl(5).mainLine, pl(6).mainLine], {'AnT L' , 'AnT H', 'Aud L', 'Aud H', 'Tac L', 'Tac H'});
            else
                lg=legend([pl(1), pl(2), pl(3), pl(4), pl(5), pl(6)], {'AnT L' , 'AnT H', 'Aud L', 'Aud H', 'Tac L', 'Tac H'});
            end
         set(lg, 'fontsize', 15)    
        end
       
        shg
        
        cd(savedatadir)
%         cd('figs')
%         cd('Behavioural Tracking by modality, Across all')
        
%         if usesmooth==1
%             print('-dpng', ['Across ' num2str(nppants) ' ppants, Day ' num2str(plDAY) ' ' attendcond ' In Phase vs Out of phase Tracking, Smoothed'])
%         else
%             print('-dpng', ['Across ' num2str(nppants) ' ppants, Day ' num2str(plDAY) ' ' attendcond ' In Phase vs Out of phase Tracking'])
%         end
        %%
        %Now print combined In phase and out of phase.
%         
%         plcounter=1;
%         figure()
%         for xmod=1:3
%             switch xmod
%                 case 1
%                     marker='-.';
%                 case 2
%                     marker = '-';
%                 case 3
%                     marker = ':';
%             end
%             for ihz = 1:2
%                 switch ihz
%                     case 1
%                         colorin = 'b'; %low hz
%                     case 2
%                         colorin = 'r'; %low hz
%                 end
%                 
%                 tmp1=squeeze(AcrossallPPANTs(:,xmod,:,ihz,:));
%                 tmp=squeeze(mean(tmp1,1)); %take mean of both in phase and out of phase.
%                 stErr = std(tmp)/sqrt(size(tmp,1));
%                 plotme= mean(tmp,1);
%                 if usesmooth==1
%                     plotme=smooth(plotme,15);
%                     stErr=smooth(stErr,15);
%                 end
%                 
%                 timing = [1:length(tmp)]/scrRate;
%                 if useSherrbar==1
%                     pl(plcounter)=shadedErrorBar(timing, plotme, stErr, [colorin marker],1);
%                 else
%                     pl(plcounter)=plot(timing, plotme, [colorin marker], 'linewidth', 3);
%                 end
%                 hold on
%                 plcounter=plcounter+1;
%                 ylim([.1 .9])
%                 xlim([0 timing(end)])
%                 
%             end
%             title(['Day ' num2str(plDAY) ' ' attendcond ' Combined In and Out of phase'],'fontsize', 15)
%             xlabel('Time (secs)', 'fontsize', 15)
%             ylabel('Prob')
%             
%             plot(xlim, [0.5 0.5], ['k' '-'])
%             
%             
%             
%         end
%         if useSherrbar==0
%             legend([pl(1), pl(2), pl(3), pl(4), pl(5), pl(6)], {'AnT L' , 'AnT H', 'Aud L', 'Aud H', 'Tac L', 'Tac H'})
%         end
%         shg
%         cd(savedatadir)
%         cd('figs')
%         if usesmooth==1
%             print('-dpng', ['Across ' num2str(nppants) ' ppants, Day ' num2str(plDAY) ' ' attendcond ' Combined Tracking, Smoothed'])
%         else
%             print('-dpng', ['Across ' num2str(nppants) ' ppants, Day ' num2str(plDAY) ' ' attendcond ' Combined Tracking'])
%         end
        
        cd(savedatadir)
        cd('figs')
        
        %save per group
        
                switch igroup
                    case 1
                        group_A_Data.day(iDay).data=AcrossallPPANTs;
                    case 2
                        group_nA_Data.day(iDay).data=AcrossallPPANTs;
                end
                
                  
           
           
        end
    end
save('groupTracking_byday(nppant,xmod,iph,ihz,samps)', 'group_A_Data', 'group_nA_Data', 'group_A_list', 'group_nA_list', '-append')