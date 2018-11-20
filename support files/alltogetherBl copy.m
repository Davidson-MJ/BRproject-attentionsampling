
% plots changes in Button-press probability by cue type.

try cd('/Users/MattDavidson/Desktop/XM_Project/DATA_newhope/figs')
catch
    cd('/Users/MatthewDavidson/Desktop/XMODAL/DATA_newhope/figs')
end
load('groupTracking_byday(nppant,xmod,iph,ihz,samps).mat')
%%

job.plotseparate=1; % separates crossmodal cue types by color/saturation
performRMANOVA=0;

job.plotVisincludedSepattenddays=0;

job.plottogether=0; %combines all non-low attended hz.



%for easy access.
xmodcols(1).ncolor=[0 .5 0];
xmodcols(1).marker='-';
xmodcols(2).ncolor=[0 .5 0];
xmodcols(2).marker='-';
xmodcols(3).ncolor=[.5 .5 1];
xmodcols(3).marker='x-';

%%
usesmooth=0;
fontsize= 15;
scrRate=60;
useSherrbar=1;
usesig = .05;
%     Now combine across days.
if job.plotseparate==1
    
    counter=1;
    % vector for plot handles.
    legendprint=[]
    clf
    for xmod=1%:3
        figure(1)
%         clf
        set(gcf,'visible', 'on', 'color', 'w')
%         pchB=patch([0.5 0.5 2 2], [0 1 1 0], [.7 .7 .7]) ;
        alpha('.5')
        switch xmod
            case 1
                xmarker='Auditory and Tactile';
                %                 marker='*-';
                %                  ncolor=[ 0 0 .8]; %dark blue
%                 colorin='b';
            case 2
                xmarker='Auditory';
                %                 ncolor=[ 0  0 1];
                %                 marker='o-';
                %             checkchan= 6;
%                 colorin='m';
            case 3
                xmarker='Tactile';
                
        end
        
        anovadata=[];
        plotcount=1;
        
        
        
        marker=xmodcols(xmod).marker;
        ncolor=xmodcols(xmod).ncolor;
        %
        linecounter=1;
        for iattendcond=1:2
            
            
            p=[];
            switch iattendcond
                case 1
                    attendcond='Attended';
                    %                     marker='*-';
                    marker='-';
%                                         tmp1=squeeze(group_A_Data.day(1).data(:,xmod,:,:,:));
%                                         tmp2= squeeze(group_nA_Data.day(2).data(:,xmod,:,:,:));
                    tmp1=squeeze(mean(group_A_Data.day(1).data(:,:,:,:,:),2));
                    tmp2= squeeze(mean(group_nA_Data.day(2).data(:,:,:,:,:),2));
                    
                    listppants=[group_A_list.day(1).list; group_nA_list.day(2).list];
                    
                case 2
                    attendcond='Non-attended';
%                                         tmp1=squeeze(group_A_Data.day(2).data(:,xmod,:,:,:));
%                                         tmp2= squeeze(group_nA_Data.day(1).data(:,xmod,:,:,:));
                    tmp1=squeeze(mean(group_A_Data.day(2).data(:,:,:,:,:),2));
                    tmp2= squeeze(mean(group_nA_Data.day(1).data(:,:,:,:,:),2));
                    listppants=[group_A_list.day(2).list; group_nA_list.day(1).list];
                    marker='-';
            end
            dataBEHnow=cat(1,tmp1,tmp2); %need low vs high hz.
            
            
            AcrossallPPANTs=dataBEHnow;
            nppants=size(AcrossallPPANTs,1);
            
            %             subplot(1,2,plotcount)
            
            for ihz = 1:3
                switch ihz
                    case 1
                        colorin =[ 0 .5 0];
                        ncolor=[ 0 .5 0];
                    case 2
                        colorin = 'r'; %high
                        ncolor='r';
                        
                        case 3
                        colorin = 'k'; %vis
                        ncolor='k';
                end
                
                
                tmp1=squeeze(AcrossallPPANTs(:,:,ihz,:));
                %mean over phase
                tmp1=squeeze(mean(tmp1,2));
                
                %use the combined value for visual only periods (attend +
                %nonattend).
%                 if ihz==3
% %                     tmp1=squeeze(
%                 
                %save the visual only plot until after both conditions ?
                if ihz==3 && iattendcond==3
%                     tmpv=tmp1;
                    continueYN='n';
                elseif ihz==3 && iattendcond==2
%                     tmpV=cat(1,tmpv,tmp1);
                    %take mean
                    
                    continueYN='y';
                else
                    continueYN='y';
                end
                
                if strcmp(continueYN, 'y')
                
                stErr = std(tmp1)/sqrt(size(tmp1,1));
                plotme= mean(tmp1,1);
                if usesmooth==1
                    plotme=smooth(plotme,15);
                    stErr=smooth(stErr,15);
                end
                hold on
                
                
                %store for later sig tests:
                anovadata(counter,:,:)= tmp1;
                
                
                
                timing = [1:length(tmp1)]/scrRate;
                stretchedplot = find(mod(1:length(plotme), 10)==0);
                if useSherrbar==1
                    psh= shadedErrorBar(timing, plotme, stErr, [ 'k'] ,1);
                    
                    if iattendcond==1
                        psh.mainLine.LineWidth=5;
                    else
                        psh.mainLine.LineWidth=2;
                    end
                    
                    %               p.mainLine.MarkerSize=10;
                    psh.mainLine.Color=[colorin];
                    psh.edge(1).Color=colorin;
                    psh.edge(2).Color=colorin;
                    psh.patch.FaceColor=colorin;
                    
                    legendprint= [legendprint, psh.mainLine];
                    hold on
                    for im = 1:length(stretchedplot)
                        placeis= stretchedplot(im);
                        p=plot(timing(placeis), mean(plotme(placeis)), [marker,colorin], 'markersize', fontsize, 'linewidth' ,2);
                        p.Color= ncolor;
                        p.MarkerSize = 30;
                    end
                    
                    pl(linecounter)=p;
                else
                    pl(linecounter)=plot(timing, plotme, [marker, colorin], 'linewidth', 3);
                    
                    hold on
                    for ippant=1:size(tmp1,1)
                        plot(timing, (squeeze(tmp1(ippant,:))),[marker,colorin],'linewidth',2);
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
                
% %                 FDR correction
                pthresh=fdr(presult, usesig);
                
                switch ihz
                    case 1 %low hz
                        
                        height=.675;
                        %                             height = .6;
                    case 2
                        height=.775; %place on plot.
                        %                             height=.575; %place on plot.
                        
                        
                end
                hold on
                %%
                
                %%
                
                if iattendcond==1
                    sigsize = 55;
                    height= height+.01;
                else
                    sigsize = 35;
                end
                sigmarker = '*';
                
                pstamps = find(mod(1:length(presult), 10)==0);
% %                 if ihz==1
%                     for i=pstamps
%                         if presult(i)<pthresh
%                             if mean(plotme(:,i),1) <.5
%                                 
%                                 text(i/60, height-.325,'*', 'color', ncolor, 'fontsize', fontsize*3.1)
%                             else
%                                 text(i/60, height,'*', 'color', ncolor, 'fontsize', fontsize*3.1)
%                             end
%                         end
%                     end
%                 end
                
                linecounter=linecounter+1;
                ylim([.3 .85])
                xlim([0 timing(end)])
                %             xlim([0 5.5])
                %             title({[ num2str( attendcond) ' '  num2str(xmarker)  ' stimulation']},'fontsize', fontsize)
                xlabel({['Time after cue onset [s]']}, 'fontsize', fontsize)
                %             ylabel({['Overall proportion of'];[' congruent button presses'];[' [ P(congruent) ]']}, 'fontsize', fontsize)
                ylabel({['Probability of seeing'];['congruent flicker']}, 'fontsize', fontsize)
                
%                 plot(xlim, [0.5 0.5], ['k' '-'])
                hold on
                
                
                plotcount=plotcount+1;
                set(gca, 'fontsize', fontsize*1.75)
                hold on
                set(gca, 'ytick', [.3:.1:.9])
                set(gca, 'xtick', [0:1:7])
                %             pc=plot([2.6 2.6], ylim, ['k' ':'], 'linewidth', 3);
                %%
                set(gcf,'color', 'w')
                %                 cd(figsdir)
                %
                %         print('-dpng', [ 'MidCand ' num2str(xmarker) ' compare attend conditions, Tracking'])
                %         print('-dpng', [ 'ASSC BP compare attend conditions, Tracking ' num2str(linecounter-1)])
                ylim([.35 .75])
                shg
                end
                counter=counter+1;
            end
        end
    end
        if performRMANOVA==1
            
            %set up RMANOVA params
            nppantstest=34;
            %set up factor array.
            factorarray=[];
            %also subj arrays
            subjects=[];
            ss=[1:nppantstest]';
            for ifactor=1:size(anovadata,1)
                factorlevel = repmat(ifactor,nppantstest,1);
                factorarray = [factorarray;factorlevel];
                
                subjects=[subjects;ss];
            end            
                
                
                %store ANOVA results
                presult=nan(1,size(anovadata,3)); %one per time point.
                
                %store planned comparisons; for AttL vs nAttL
                presultPC=nan(1,size(anovadata,3));
                
                for itime=2:size(anovadata,3) %at each timeponit
                    
                    %arrange for rmanova. single cols.
                    %                     rmanova(data,factorarray,subjects,varnames, btw_ss_col)
                    %need a single column of data
                    datat=[];
                    for ifactor=1:size(anovadata,1)
                        datat=[datat; squeeze(anovadata(ifactor,:,itime))'];
                    end
                    
                    %perform RM anova.
                    anvret=rmanova(datat,factorarray,subjects);
                    presult(itime)=anvret.p(1);

        
        
                        %can also do a ttest betweetween certain prob
                        %traces (e.g. ATTL and VIS)
                 [~, presultPC(itime)]=ttest(squeeze(anovadata(1,:,itime)),squeeze(anovadata(3,:,itime)), .05);
        
                end
                
                %FDR correction
                pthresh=fdr(presult, usesig);
                pthreshPC=fdr(presultPC, usesig);
                

                                
                hold on
                
              %% %now plot
                    sigsize = 55;
                    height= .7;
              
                sigmarker = '*';
                
                
                pstamps = find(mod(1:length(presult), 10)==0);
                for i=pstamps
                    if i/60< 6.95
%                         if presult(i)<pthresh                            
%                                 text(i/60, height+.005,sigmarker, 'color', 'm', 'fontsize', sigsize)
% %                             
%                         end
                        
                        if presultPC(i)<pthreshPC
                                 text(i/60, height, sigmarker, 'color', [0 .5 0], 'fontsize', sigsize)
                        end
                    end
                end
            
            
            
        end
        %%
        %
        %%         %
%     end
    %%
    try cd('/Users/matthewdavidson/Desktop')
    catch
        
        cd('/Users/mattdavidson/Desktop')
    end
    %%
    
    
    
    lg=legend([legendprint(1), legendprint(2), legendprint(4), legendprint(5), legendprint(3),legendprint(6)],...
        {'Attended Low', 'Attended High', 'Non-attended Low', 'Non-attended High', 'Visual only (Att.)','Visual only (nAtt.)'});
    set(lg, 'Location', 'NorthEastoutside')
    
    %%
    asdf
    print('-dpng', 'Combined Behavioral trace')
end


if job.plotVisincludedSepattenddays==1;

  for xmod=1%1:3
        figure(1)
        clf
        set(gcf,'visible', 'on', 'color', 'w')
       
        hold on;
        plotcount=1;
        colorin='b';
        marker=xmodcols(xmod).marker;
        ncolor=xmodcols(xmod).ncolor;
        %
        % this time, two separate figures.
        for iattendcond=1:2
            subplot(1,2,iattendcond);
             pchB=patch([0.5 0.5 2 2], [0 1 1 0], [.7 .7 .7]) ;
        alpha('.5')
      
        linecounter=1;    
            
            p=[];
            switch iattendcond
                case 1
                    attendcond='Attended';
                    %                     marker='*-';
                    marker='-';
                    %                     tmp1=squeeze(group_A_Data.day(1).data(:,xmod,:,:,:));
                    %                     tmp2= squeeze(group_nA_Data.day(2).data(:,xmod,:,:,:));
                    tmp1=squeeze(mean(group_A_Data.day(1).data(:,:,:,:,:),2));
                    tmp2= squeeze(mean(group_nA_Data.day(2).data(:,:,:,:,:),2));
                    
                    listppants=[group_A_list.day(1).list; group_nA_list.day(2).list];
                    
                case 2
                    attendcond='Non-attended';
                    %                     tmp1=squeeze(group_A_Data.day(2).data(:,xmod,:,:,:));
                    %                     tmp2= squeeze(group_nA_Data.day(1).data(:,xmod,:,:,:));
                    tmp1=squeeze(mean(group_A_Data.day(2).data(:,:,:,:,:),2));
                    tmp2= squeeze(mean(group_nA_Data.day(1).data(:,:,:,:,:),2));
                    listppants=[group_A_list.day(2).list; group_nA_list.day(1).list];
                    marker='-';
            end
            dataBEHnow=cat(1,tmp1,tmp2); %need low vs high hz.
            
            
            AcrossallPPANTs=dataBEHnow;
            nppants=size(AcrossallPPANTs,1);
            
            %             subplot(1,2,plotcount)
            
            for ihz = 1:3
                switch ihz
                    case 1
                        colorin = 'g'; %low hz
                        ncolor=[ 0 .5 0];
                    case 2
                        colorin = 'r'; %high
                        ncolor='r';
                        
                        case 3
                        colorin = 'k'; %vis
                        ncolor='k';
                end
                
                
                tmp1=squeeze(AcrossallPPANTs(:,:,ihz,:));
                %mean over phase
                tmp1=squeeze(mean(tmp1,2));
                
                %Store each for later significance tests
                switch ihz
                    case 1
                        tmpLOW=tmp1;
                    case 2
                        tmpHIGH=tmp1;
                    case 3
                        tmpVIS=tmp1;
                end
                
                
               
                
                stErr = std(tmp1)/sqrt(size(tmp1,1));
                plotme= mean(tmp1,1);
                if usesmooth==1
                    plotme=smooth(plotme,15);
                    stErr=smooth(stErr,15);
                end
                hold on
                
                timing = [1:length(tmp1)]/scrRate;
                stretchedplot = find(mod(1:length(plotme), 10)==0);
                if useSherrbar==1
                    psh= shadedErrorBar(timing, plotme, stErr, [ colorin] ,1);
                    
                    if iattendcond==1
                        psh.mainLine.LineWidth=5;
                    else
                        psh.mainLine.LineWidth=2;
                    end
                    
                    %               p.mainLine.MarkerSize=10;
                    psh.mainLine.Color=[ncolor];
                    psh.edge(1).Color=ncolor;
                    psh.edge(2).Color=ncolor;
                    psh.patch.FaceColor=ncolor;
                    
                    
                    hold on
                    for im = 1:length(stretchedplot)
                        placeis= stretchedplot(im);
                        p=plot(timing(placeis), mean(plotme(placeis)), [marker,colorin], 'markersize', fontsize, 'linewidth' ,2);
                        p.Color= ncolor;
                        p.MarkerSize = 30;
                    end
                    
                    pl(linecounter)=p;
                else
                    pl(linecounter)=plot(timing, plotme, [marker, colorin], 'linewidth', 3);
                    
                    hold on
                    for ippant=1:size(tmp1,1)
                        plot(timing, (squeeze(tmp1(ippant,:))),[marker,colorin],'linewidth',2);
                    end
                end
                
                hold on
            end
            
            
            
            % we'll use rm anova compared to vis?
              for ihzTest=1:2
                  switch ihzTest
                      case 1
                          used=tmpLOW;
                          ncolor=[ 0 .5 0];
                      case 2
                          used=tmpHIGH;
                          ncolor='r';
                  end
                  
                  presult=[];
                for itime=1:length(tmp1) %at each timeponit
                    
                   
                    [H(itime),presult(itime)]= ttest(used(:,itime),tmpVIS(:,itime));
                   
                end
                
                %FDR correction
                pthresh=fdr(presult, usesig);
                
                switch ihzTest
                    case 1 %low hz
                        
                        height=.675;
                        %                         
                    case 2
                        height=.775; %place on plot.
                        %                             height=.575; %place on plot.
                        
                        
                end
                hold on
                %%
                
                
                sigsize = 55;
                sigmarker = '*';
                
                pstamps = find(mod(1:length(presult), 10)==0);
%                 if ihz==1
                    for i=pstamps
                        if presult(i)<pthresh
                          
                            % where to place sig marker?
                                if nanmean(used(:,i),1)<nanmean(tmpVIS(:,i),1)
                                    % if tested is below visual only
                                text(i/60, height-.3,'*', 'color', ncolor, 'fontsize', fontsize*3.1)
                                else
                                    text(i/60, height,'*', 'color', ncolor, 'fontsize', fontsize*3.1)
                                end
                          
                        end
                    end
%                 end
                
              end
              %%
                ylim([.3 .85])
                xlim([0 timing(end)])
                %             xlim([0 5.5])
                %             title({[ num2str( attendcond) ' '  num2str(xmarker)  ' stimulation']},'fontsize', fontsize)
                xlabel({['Time after cue onset'];[' [secs]']}, 'fontsize', fontsize)
                %             ylabel({['Overall proportion of'];[' congruent button presses'];[' [ P(congruent) ]']}, 'fontsize', fontsize)
                ylabel({['Probability of '];['seeing congruent']}, 'fontsize', fontsize)
                
%                 plot(xlim, [0.5 0.5], ['k' '-'])
                hold on
                
                
                plotcount=plotcount+1;
                
                hold on
                set(gca, 'ytick', [.3:.1:.9])
                set(gca, 'xtick', [0:1:7])
                %             pc=plot([2.6 2.6], ylim, ['k' ':'], 'linewidth', 3);
                %%
                set(gcf,'color', 'w')
                %                 cd(figsdir)
                %
                %         print('-dpng', [ 'MidCand ' num2str(xmarker) ' compare attend conditions, Tracking'])
                %         print('-dpng', [ 'ASSC BP compare attend conditions, Tracking ' num2str(linecounter-1)])
                ylim([.35 .75])
                xlabel(['Time after cue onset [sec]'])
                set(gca, 'fontsize', fontsize*1.5)
                shg
                
            
        end
        %%
        %
        %%         %
    end
    %%
    try cd('/Users/matthewdavidson/Desktop')
    catch
        cd('/Users/mattdavidson/Desktop')
    end
    print('-dpng', 'Combined Behavioral trace')
end


if job.plottogether==1
    for xmod=1%1:3
        figure(3)
        clf
        
        meanPLOTs=[];
        
        set(gcf,'visible', 'on', 'color', 'w')
        pchB=patch([0.5 0.5 2 2], [0 1 1 0], [.7 .7 .7]) ;
        alpha('.5')
        switch xmod
            case 1
                xmarker='Auditory and Tactile';
                %                 marker='*-';
                %                  ncolor=[ 0 0 .8]; %dark blue
            case 2
                xmarker='Auditory';
                %                 ncolor=[ 0  0 1];
                %                 marker='o-';
                %             checkchan= 6;
            case 3
                xmarker='Tactile';
                %                 ncolor= [.5 .5 1];
                %                 marker='x-';
        end
        plotcount=1;
        plcount=1;
        colorin='b';
        marker=xmodcols(xmod).marker;
        ncolor=xmodcols(xmod).ncolor;
        %
        linecounter=1;
        pl=[];
        for iattendcond=1:2
            
            
            p=[];
            
            switch iattendcond
                case 1
                    attendcond='Attended';
                    %                     marker='*-';
                    marker='-';
                    %                     tmp1=squeeze(group_A_Data.day(1).data(:,xmod,:,:,:));
                    %                     tmp2= squeeze(group_nA_Data.day(2).data(:,xmod,:,:,:));
                    tmp1=squeeze(mean(group_A_Data.day(1).data(:,:,:,:,:),2));
                    tmp2= squeeze(mean(group_nA_Data.day(2).data(:,:,:,:,:),2));
                    
                    listppants=[group_A_list.day(1).list; group_nA_list.day(2).list];
                    
                case 2
                    attendcond='Non-attended';
                    %                     tmp1=squeeze(group_A_Data.day(2).data(:,xmod,:,:,:));
                    %                     tmp2= squeeze(group_nA_Data.day(1).data(:,xmod,:,:,:));
                    tmp1=squeeze(mean(group_A_Data.day(2).data(:,:,:,:,:),2));
                    tmp2= squeeze(mean(group_nA_Data.day(1).data(:,:,:,:,:),2));
                    listppants=[group_A_list.day(2).list; group_nA_list.day(1).list];
                    marker='-';
            end
            dataBEHnow=cat(1,tmp1,tmp2); %need low vs high hz.
            
            
            AcrossallPPANTs=dataBEHnow;
            nppants=size(AcrossallPPANTs,1);
            
            %             subplot(1,2,plotcount)
            
            for ihz = 1:2
                switch ihz
                    case 1
                        colorin = 'g'; %low hz
                        ncolor=[ 0 .5 0];
                    case 2
                        colorin = 'r'; %low hz
                        ncolor='r';
                end
                
                
                tmp1=squeeze(AcrossallPPANTs(:,:,ihz,:));
                %mean over phase
                tmp1=squeeze(mean(tmp1,2));
                
                
                %store for later plots.
                meanPLOTS(plotcount,:,:) = tmp1;
                
                plotcount=plotcount+1;
            end
        end
        %%
        
        for inewplot = 1:2
            switch inewplot
                case 1
                    
                    tmp1 = squeeze(meanPLOTS(1,:,:));
                    colorin = 'g'; %low hz
                        ncolor=[ 0 .5 0];
                case 2
                    tmp1 = squeeze(mean(meanPLOTS(2:4,:,:),1));
                    colorin='k';
                    ncolor=[ 0 0 0];
            end
            
            
            stErr = std(tmp1)/sqrt(size(tmp1,1));
            plotme= mean(tmp1,1);
            if usesmooth==1
                plotme=smooth(plotme,15);
                stErr=smooth(stErr,15);
            end
            hold on
            
            timing = [1:length(tmp1)]/scrRate;
            stretchedplot = find(mod(1:length(plotme), 10)==0);
            if useSherrbar==1
                psh= shadedErrorBar(timing, plotme, stErr, [ colorin] ,1);
                
                if iattendcond==1
                    psh.mainLine.LineWidth=5;
                else
                    psh.mainLine.LineWidth=2;
                end
                
                %               p.mainLine.MarkerSize=10;
                psh.mainLine.Color=[ncolor];
                psh.edge(1).Color=ncolor;
                psh.edge(2).Color=ncolor;
                psh.patch.FaceColor=ncolor;
                
                
                hold on
                for im = 1:length(stretchedplot)
                    placeis= stretchedplot(im);
                    p=plot(timing(placeis), mean(plotme(placeis)), [marker,colorin], 'markersize', fontsize, 'linewidth' ,2);
                    p.Color= ncolor;
                    p.MarkerSize = 30;
                end
                
                pl(linecounter)=p;
            else
                pl(linecounter)=plot(timing, plotme, [marker, colorin], 'linewidth', 3);
                
                hold on
                for ippant=1:size(tmp1,1)
                    plot(timing, (squeeze(tmp1(ippant,:))),[marker,colorin],'linewidth',2);
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
            
            switch inewplot
                case 1 %low hz
                    
                    height=.8;
                    %                             height = .6;
                case 2
                    height=.8; %place on plot.
                    %                             height=.575; %place on plot.
                    
                    
            end
            hold on
            %%
            
            %%
            if plcount==1
                sigsize = 55;
                height= .8;
            else
                sigsize = 35;
            end
            sigmarker = '*';
            
            pstamps = find(mod(1:length(presult), 10)==0);
            if inewplot==1
                for i=pstamps
                    if presult(i)<pthresh
                        if mean(plotme(:,i),1) <.5
                            
                            text(i/60, height-.46,'*', 'color', ncolor, 'fontsize', fontsize*3.1)
                        else
                            text(i/60, height,'*', 'color', ncolor, 'fontsize', fontsize*3.1)
                        end
                    end
                end
            end
            
            linecounter=linecounter+1;
            ylim([.3 .85])
            xlim([0 timing(end)])
            %             xlim([0 5.5])
            %             title({[ num2str( attendcond) ' '  num2str(xmarker)  ' stimulation']},'fontsize', fontsize)
            xlabel({['Time after cue onset'];[' [secs]']}, 'fontsize', fontsize)
            %             ylabel({['Overall proportion of'];[' congruent button presses'];[' [ P(congruent) ]']}, 'fontsize', fontsize)
            ylabel({['Probability of '];['seeing congruent']}, 'fontsize', fontsize)
            
            plot(xlim, [0.5 0.5], ['k' '-'])
            hold on
            
            
            plotcount=plotcount+1;
            set(gca, 'fontsize', fontsize*1.75)
            hold on
            set(gca, 'ytick', [.3:.1:.9])
            set(gca, 'xtick', [0:1:7])
            %             pc=plot([2.6 2.6], ylim, ['k' ':'], 'linewidth', 3);
            %%
            set(gcf,'color', 'w')
            %                 cd(figsdir)
            %
            %         print('-dpng', [ 'MidCand ' num2str(xmarker) ' compare attend conditions, Tracking'])
            %         print('-dpng', [ 'ASSC BP compare attend conditions, Tracking ' num2str(linecounter-1)])
            ylim([.3 .85])
            shg
        end
        
    end
    %%
    %
    %%         %
    
    %%
    cd('/Users/matthewdavidson/Desktop')
    print('-dpng', 'Combined Behavioral trace')
    
end