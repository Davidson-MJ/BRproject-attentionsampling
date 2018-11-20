% clear all
savedatadir='/Users/MattDavidson/Desktop/XM_Project/DATA_newhope';
cd(savedatadir)
cd('figs')
load('groupTracking_byday(nppant,xmod,iph,ihz,samps)')
%%
usesmooth=0;
useSherrbar=1;
scrRate=60;
usesig=.05;
fontsize=15;
%%
job.plotdaysSep=0;
job.plotdaysTogether=1;
job.plotLowHzonlyTogether_sepphase=1;
job.plotLowHzonlyTogether_combphase=1;
%include plots for different days.
if job.plotdaysSep==1
    for xmod=1:3
        clf
        set(gcf,'visible', 'off')
        
        
        switch xmod
            case 1
                xmarker='AnT';
            case 2
                xmarker = 'AUD';
            case 3
                xmarker = 'TAC';
        end
        plotcount=1;
        for igroup=1:2 %2 rows in a plot
            switch igroup
                case 1
                    useData= group_A_Data;
                case 2
                    useData=group_nA_Data;
            end
            
            for iDay=1:2 %2 columns in each row
                
                linecounter=1;
                pl=[];
                
                
                if iDay==1
                    if igroup==1
                        attendcond='Attending';
                    else
                        attendcond= 'non-Attending';
                    end
                else
                    
                    if igroup==1
                        attendcond='non-Attending';
                    else
                        attendcond= 'Attending';
                    end
                end
                
                AcrossallPPANTs=useData.day(iDay).data;
                nppants=size(AcrossallPPANTs,1);
                
                subplot(2,2,plotcount)
                
                for ihz = 1:2
                    switch ihz
                        case 1
                            colorin = 'b'; %low hz
                        case 2
                            colorin = 'r'; %low hz
                    end
                    for iph=1:2
                        switch iph
                            case 1
                                marker = '-';
                            case 2
                                marker=':';
                        end
                        
                        tmp1=squeeze(AcrossallPPANTs(:,xmod,iph,ihz,:));
                        
                        stErr = std(tmp1)/sqrt(size(tmp1,1));
                        plotme= mean(tmp1,1);
                        if usesmooth==1
                            plotme=smooth(plotme,15);
                            stErr=smooth(stErr,15);
                        end
                        hold on
                        
                        timing = [1:length(tmp1)]/scrRate;
                        if useSherrbar==1
                            p=shadedErrorBar(timing, plotme, stErr, [marker, colorin] ,1);
                            pl(linecounter).mainLine=p.mainLine;
                        else
                            pl(linecounter)=plot(timing, plotme, [marker, colorin], 'linewidth', 3);
                            hold on
                            for ippant=1:size(tmp1,1)
                                plot(timing, smooth(squeeze(tmp1(ippant,:))),[marker,colorin],'linewidth',1);
                            end
                        end
                        
                        hold on
                        
                        %also calculate and plot significance
                        for itime=1:length(tmp1) %at each timeponit
                            tmp= tmp1(:,itime);
                            [H(itime),presult(itime)]= ttest(tmp,.5,'alpha', .05);
                            if mean(tmp)<.5
                                %only keep increases in probability.
                                H(itime)=0;
                            end
                        end
                        
                        %FDR correction
                        pthresh=fdr(presult, usesig);
                        
                        switch ihz
                            case 1 %low hz
                                
                                height=.8;
                            case 2
                                height=.75; %place on plot.
                                
                        end
                        if iph==2
                            height=height-.025;
                            
                        end
                        hold on
                        %%
                        for i=1:length(presult)
                            if presult(i)<pthresh
                                if mean(plotme(:,i),1) <.5
                                    
                                    text(i/60, height-.4,marker, 'color', colorin, 'fontsize', fontsize*1.1)
                                else
                                    text(i/60, height,marker, 'color', colorin, 'fontsize', fontsize*1.1)
                                end
                            end
                        end
                        %%
                        
                        linecounter=linecounter+1;
                    end
                    
                end
                ylim([.3 .85])
                xlim([0 timing(end)])
                title({['Group ' num2str(igroup)];['Day ' num2str(iDay) ' '  attendcond ' ' num2str(xmarker) ' In and Out of phase,'];[' sig at .05 after FDR, n=' num2str(nppants) ' .']},'fontsize', fontsize)
                xlabel('Time after onset (secs) ', 'fontsize', fontsize)
                ylabel('Probability of congruent button press', 'fontsize', fontsize)
                
                plot(xlim, [0.5 0.5], ['k' '-'])
                
                if useSherrbar==0
                    lg=legend([pl(1), pl(2), pl(3), pl(4)], {'Low In' , 'Low Out', 'High In', 'High Out'});
                else
                    lg=legend([pl(1).mainLine, pl(2).mainLine, pl(3).mainLine, pl(4).mainLine], {'Low Hz In Phase' , 'Low Hz Antiphase', 'High Hz In Phase', 'High Hz Antiphase'});
                end
                plotcount=plotcount+1;
                set(lg, 'fontsize', fontsize)
                set(gca, 'fontsize', fontsize)
            end
            
        end
        
        
        cd(savedatadir)
        cd('figs')
        cd('Behavioural Probability Tracking by modality, Across all')
        shg
        %%
        print('-dpng',[ num2str(xmarker) ' compare attend conditions, days separate Tracking'])
    end
end

if job.plotdaysTogether==1
    
    %     Now combine across days.
    for xmod=1:3
        clf
        set(gcf,'visible', 'off')
        
        
        switch xmod
            case 1
                xmarker='AnT';
            case 2
                xmarker = 'AUD';
            case 3
                xmarker = 'TAC';
        end
        plotcount=1;
        
        
        %%
        for iattendcond=1:2
            
            pl=[];
            p=[];
            switch iattendcond
                case 1
                    attendcond='Attending';
                    
                    tmp1=squeeze(group_A_Data.day(1).data(:,xmod,:,:,:));
                    tmp2= squeeze(group_nA_Data.day(2).data(:,xmod,:,:,:));
                    listppants=[group_A_list.day(1).list; group_nA_list.day(2).list];
                    
                case 2
                    attendcond='non-attending';
                    tmp1=squeeze(group_A_Data.day(2).data(:,xmod,:,:,:));
                    tmp2= squeeze(group_nA_Data.day(1).data(:,xmod,:,:,:));
                    listppants=[group_A_list.day(2).list; group_nA_list.day(1).list];
            end
            dataBEHnow=cat(1,tmp1,tmp2); %need low vs high hz.
            
            
            AcrossallPPANTs=dataBEHnow;
            nppants=size(AcrossallPPANTs,1);
            
            subplot(1,2,plotcount)
            linecounter=1;
            for ihz = 1:2
                switch ihz
                    case 1
                        colorin = 'b'; %low hz
                    case 2
                        colorin = 'r'; %low hz
                end
                for iph=1:2
                    switch iph
                        case 1
                            marker = '-';
                        case 2
                            marker=':';
                    end
                    
                    tmp1=squeeze(AcrossallPPANTs(:,iph,ihz,:));
                    
                    stErr = std(tmp1)/sqrt(size(tmp1,1));
                    plotme= mean(tmp1,1);
                    if usesmooth==1
                        plotme=smooth(plotme,15);
                        stErr=smooth(stErr,15);
                    end
                    hold on
                    p=[];
                    timing = [1:length(tmp1)]/scrRate;
                    if useSherrbar==1
                        p=shadedErrorBar(timing, plotme, stErr, [marker, colorin] ,1);
                        pl(linecounter)=p.mainLine;
                    else
                        pl(linecounter)=plot(timing, plotme, [marker, colorin], 'linewidth', 3);
                        
                        hold on
                        for ippant=1:size(tmp1,1)
                            plot(timing, smooth(squeeze(tmp1(ippant,:))),[marker,colorin],'linewidth',1);
                        end
                    end
                    
                    hold on
                    
                    %also calculate and plot significance
                    for itime=1:length(tmp1); %at each timeponit
                        tmp= tmp1(:,itime);
                        [H(itime),presult(itime)]= ttest(tmp,.5,'alpha', .05);
                        if mean(tmp)<.5
                            %only keep increases in probability.
                            H(itime)=0;
                        end
                    end
                    
                    %FDR correction
                    pthresh=fdr(presult, usesig);
                    
                    switch ihz
                        case 1 %low hz
                            colorin='b';
                            height=.8;
                        case 2
                            height=.75; %place on plot.
                            colorin='r';
                    end
                    hold on
                    %%
                    if iph==2
                        height=height-.025;
                        
                    end
                    hold on
                    %%
                    for i=1:length(presult)
                        if presult(i)<pthresh
                            if mean(plotme(:,i),1) <.5
                                
                                text(i/60, height-.4,marker, 'color', colorin, 'fontsize', fontsize*1.1)
                            else
                                text(i/60, height,marker, 'color', colorin, 'fontsize', fontsize*1.1)
                            end
                        end
                    end
                    
                    
                    linecounter=linecounter+1;
                end
                
            end
        
            ylim([.3 .85])
            xlim([0 timing(end)])
            title({['All ' num2str( attendcond) ' ' num2str(xmarker) ]},'fontsize', fontsize)
            xlabel('Time after onset (secs) ', 'fontsize', fontsize)
            ylabel('Probability of congruent button press', 'fontsize', fontsize)
            
            plot(xlim, [0.5 0.5], ['k' '-'])
            hold on
            
            lg=legend([pl(1), pl(2), pl(3), pl(4)], {'Low In' , 'Low Out', 'High In', 'High Out'});
            
            set(lg, 'fontsize', fontsize*1.5)
            plotcount=plotcount+1;
            set(gca, 'fontsize', fontsize*1.5)
            
        end
        
        
        cd(savedatadir)
        cd('figs')
        cd('Behavioural Probability Tracking by modality, Across all')
        shg
        print('-dpng', [ num2str(xmarker) ' compare attend conditions, Tracking'])
    end
end



if job.plotLowHzonlyTogether_sepphase==1
    
    for iph =1:2
        clf
        switch iph
            case 1
                phaseis='Inphase';
            case 2
                phaseis = 'Out of phase';
        end
        linecounter=1;
        pl=[];
        for xmod=1:3
            switch xmod
                case 1
                    xmarker='AnT';
                    
                    colorin = 'k';
                case 2
                    xmarker = 'AUD';
                    
                    colorin='b';
                case 3
                    xmarker = 'TAC';
                    
                    colorin='r';
            end
            marker='-';
            
            
            
            %% only plot attend cond
            iattendcond=1;
            
            
            p=[];
            
            attendcond='Attending';
            
            tmp1=squeeze(group_A_Data.day(1).data(:,xmod,:,:,:));
            tmp2= squeeze(group_nA_Data.day(2).data(:,xmod,:,:,:));
            listppants=[group_A_list.day(1).list; group_nA_list.day(2).list];
            
            dataBEHnow=cat(1,tmp1,tmp2); %need low vs high hz.
            
            
            AcrossallPPANTs=dataBEHnow;
            nppants=size(AcrossallPPANTs,1);
            
            %             subplot(2,1,plotcount)
            
            
            
            ihz=1;
            
            tmp1=squeeze(AcrossallPPANTs(:,iph,ihz,:));
            
            stErr = std(tmp1)/sqrt(size(tmp1,1));
            plotme= mean(tmp1,1);
            if usesmooth==1
                plotme=smooth(plotme,15);
                stErr=smooth(stErr,15);
            end
            hold on
            p=[];
            timing = [1:length(tmp1)]/scrRate;
            if useSherrbar==1
                p=shadedErrorBar(timing, plotme, stErr, [marker, colorin] ,1);
                pl(linecounter)=p.mainLine;
            else
                pl(linecounter)=plot(timing, plotme, [marker, colorin], 'linewidth', 3);
                
                hold on
                for ippant=1:size(tmp1,1)
                    plot(timing, smooth(squeeze(tmp1(ippant,:))),[marker,colorin],'linewidth',1);
                end
            end
            
            hold on
            
            %also calculate and plot significance
            for itime=1:length(tmp1); %at each timeponit
                tmp= tmp1(:,itime);
                [H(itime),presult(itime)]= ttest(tmp,.5,'alpha', .05);
                if mean(tmp)<.5
                    %only keep increases in probability.
                    H(itime)=0;
                end
            end
            
            %FDR correction
            pthresh=fdr(presult, usesig);
            
            
            height=.7 + (xmod*.025);
            
            hold on
            
            %%
            for i=1:length(presult)
                if presult(i)<pthresh
                    if mean(plotme(:,i),1) <.5
                        
                        text(i/60, height-.5,'*', 'color', colorin, 'fontsize', fontsize*2.1)
                    else
                        text(i/60, height,'*', 'color', colorin, 'fontsize', fontsize*2.1)
                    end
                end
            end
            linecounter=linecounter+1;
            
            
            
            
        end
        
        ylim([.2 .85])
        xlim([0 timing(end)])
        title({['All ' num2str( attendcond) ' Low Hz cross modal stimulation' ];[phaseis]},'fontsize', fontsize)
        xlabel('Time after onset (secs) ', 'fontsize', fontsize)
        ylabel('Probability of congruent button press', 'fontsize', fontsize)
        
        plot(xlim, [0.5 0.5], ['k' '-'])
        plot([2.6 2.6], [.4 .7], ['r' ':'], 'linewidth', 2)
        hold on
        
        lg=legend([pl(1), pl(2), pl(3)], {'AnT' , 'AUD', 'TAC'});
        
        set(lg, 'fontsize', fontsize*1.5)
        set(gca, 'fontsize', fontsize*1.5)
        
        
        cd(savedatadir)
        cd('figs')
        cd('Behavioural Probability Tracking by modality, Across all')
        shg
        print('-dpng', ['All ' num2str( attendcond) ' Low Hz cross modal stimulation ' phaseis ])
    end
    
    
end

if job.plotLowHzonlyTogether_combphase==1
    
    linecounter=1;
    pl=[];
    for xmod=1:3
        switch xmod
            case 1
                xmarker='AnT';
                
                colorin = 'k';
            case 2
                xmarker = 'AUD';
                
                colorin='b';
            case 3
                xmarker = 'TAC';
                
                colorin='r';
        end
        marker='-';
        
        
        
        %% only plot attend cond
        iattendcond=1;
        
        
        p=[];
        
        attendcond='Attending';
        
        tmp1=squeeze(group_A_Data.day(1).data(:,xmod,:,:,:));
        tmp2= squeeze(group_nA_Data.day(2).data(:,xmod,:,:,:));
        listppants=[group_A_list.day(1).list; group_nA_list.day(2).list];
        
        dataBEHnow=cat(1,tmp1,tmp2); %need low vs high hz.
        
        
        AcrossallPPANTs=dataBEHnow;
        nppants=size(AcrossallPPANTs,1);
        
        %             subplot(2,1,plotcount)
        
        
        
        ihz=1;
        
        tmp1=squeeze(AcrossallPPANTs(:,:,ihz,:));
        %take mean over phase
        tmp1 =squeeze(mean(tmp1,2));
        
        stErr = std(tmp1)/sqrt(size(tmp1,1));
        plotme= mean(tmp1,1);
        if usesmooth==1
            plotme=smooth(plotme,15);
            stErr=smooth(stErr,15);
        end
        hold on
        p=[];
        timing = [1:length(tmp1)]/scrRate;
        if useSherrbar==1
            p=shadedErrorBar(timing, plotme, stErr, [marker, colorin] ,1);
            pl(linecounter)=p.mainLine;
        else
            pl(linecounter)=plot(timing, plotme, [marker, colorin], 'linewidth', 3);
            
            hold on
            for ippant=1:size(tmp1,1)
                plot(timing, smooth(squeeze(tmp1(ippant,:))),[marker,colorin],'linewidth',1);
            end
        end
        
        hold on
        
        %also calculate and plot significance
        for itime=1:length(tmp1); %at each timeponit
            tmp= tmp1(:,itime);
            [H(itime),presult(itime)]= ttest(tmp,.5,'alpha', .05);
            if mean(tmp)<.5
                %only keep increases in probability.
                H(itime)=0;
            end
        end
        
        %FDR correction
        pthresh=fdr(presult, usesig);
        
        
        height=.7 + (xmod*.025);
        
        hold on
        
        %%
        for i=1:length(presult)
            if presult(i)<pthresh
                if mean(plotme(:,i),1) <.5
                    
                    text(i/60, height-.5,'*', 'color', colorin, 'fontsize', fontsize*2.1)
                else
                    text(i/60, height,'*', 'color', colorin, 'fontsize', fontsize*2.1)
                end
            end
        end
        linecounter=linecounter+1;
        
        
        
        
    end
    
    ylim([.2 .85])
    xlim([0 timing(end)])
    title({['All ' num2str( attendcond) ' Low Hz cross modal stimulation' ];['Combined phase']},'fontsize', fontsize)
    xlabel('Time after onset (secs) ', 'fontsize', fontsize)
    ylabel('Probability of congruent button press', 'fontsize', fontsize)
    
    plot(xlim, [0.5 0.5], ['k' '-'])
    plot([2.6 2.6], [.4 .7], ['r' ':'], 'linewidth', 2)
    hold on
    
    lg=legend([pl(1), pl(2), pl(3)], {'AnT' , 'AUD', 'TAC'});
    
    set(lg, 'fontsize', fontsize*1.5)
    set(gca, 'fontsize', fontsize*1.5)
    
    
    cd(savedatadir)
    cd('figs')
    cd('Behavioural Probability Tracking by modality, Across all')
    shg
    print('-dpng', ['All ' num2str( attendcond) ' Low Hz cross modal stimulation combined phase' ])
    
    
    
end







