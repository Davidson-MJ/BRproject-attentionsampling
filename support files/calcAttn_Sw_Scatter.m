 savedatadir='/Users/MattDavidson/Desktop/XM_Project/DATA_newhope';
cd(savedatadir)
cd('figs')
load('groupTracking_byday(nppant,xmod,iph,ihz,samps)')
fontsize=20;

samplepointsBEH = [1, 4]; %seconds in tracking trace to observe peak.


job.calcPpantaccuracy=0; %calcs per ppant, concatenates, and plots individualcorrelations per xmod and for all
job.printallblocks=0; %intensive block trace for each block X ppant above.

%not using, since need a polyfit after all.
job.plot_r_Bargraphs=0; %plots r value of actual vs reported and p value, perppant, combining types and each type.

% works out accumulative sum of the difference between Actual and reported tones. Plots combined and separate modalities.
job.plotDiffMetric_histogram=0; 

%plot spread, story for correlation or no...?


% %not using the below anymore, which took the absolute
job.plotDiffMetric_histogram_abs=0; %works out the mean of absolute (actual-reported), plots
job.plotDiffMetric_seperatetypes_histogram_abs=0; %as above but modality separated

% more plotting...
job.plotScatter_DiffMetric_vsBeh=0; %using total Diffbetween actual-reported per ppant, across xmod types.

job.plotScatter_Polyfit_acrossall_byCombining=0; %plots corr for reported vs actual, messy, includes diff corr per ppant.
job.plotScatter_Polyfit_acrossall_byxmod=0;

job.plotScatterAttentionALLvsBeh=1; %using R from combining across xmod types..
job.plotScatterAttentionXMODvsBeh=0; %for separate cross-modal types.
%%
if job.calcPpantaccuracy==1
    %%
    cd(savedatadir)
    allppants=dir(['*Attn_On']);
    nppants=length(allppants);
    allppantScatter=[];
    allppantScatter_byxmod=[];
    allppant_r_and_p=[];
    allppant_r_and_p_byxmod=[];
    allppant_list=[];
    for ippant=1:nppants
        %%
        AttnperBlock = zeros(24,4);
        AttnperXmodtype=zeros(3,8,2);
        AnTcount=1;
        AUDcount=1;
        TACcount=1;
        cd(savedatadir)
        folname= (allppants(ippant).name);
        CountedTones=[];
        initials=folname(1:2);
        if strcmp(folname(end), 'n') %attend condtiion
            cd(folname)
            load('CountedTones')
            for iblock = 1:24
                %%
                blockfile= dir(['Block' num2str(iblock) 'Exp*']);
                load(blockfile.name);
                
                rivTrackingData=blockout.rivTrackingData;
                Chunks=blockout.Chunks;
                Order=blockout.Order;
                Speed=blockout.LeftEyeSpeed;
                casetype = blockout.Casetype;
                xmod=[];
                switch casetype
                    case 'Auditory and Tactile'
                        xmod=1;
                    case 'Auditory'
                        xmod=2;
                    case 'Tactile'
                        
                        xmod = 3;
                end
                
                %%
                TotalExp = rivTrackingData(:,2)- rivTrackingData(:,1); %-1 is left eye.
                ChunkEndtimes=[];
                
                for i = 1:length(Chunks)
                    if mod(i,2)==0 %even numbers
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
                            else %-1 is actually high hz
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
                                    congruentpresentation(1,chcounter) = 1;%success
                                else
                                    congruentpresentation(1,chcounter) = 0;%fail
                                end
                            end
                    end
                    chcounter=chcounter+1;
                end
                
                ActualCongr = sum(congruentpresentation); %num opportunities
                
                Diffcount = abs((AttendCount - ActualCongr)); %offset between 'seen' and actual
                
                BlockAttnAccuracy = abs(ActualCongr-Diffcount)/ActualCongr;
                %
                AttnperBlock(iblock,1) =  ActualCongr;
                AttnperBlock(iblock, 2) = AttendCount;
                AttnperBlock(iblock,3) = Diffcount;
                AttnperBlock(iblock, 4) = BlockAttnAccuracy;
                
                if job.printallblocks==1
                    ProcessingUpstairs=1;
                    miniBlockTrace
                end
                
                switch xmod
                    case 1
                        AttnperXmodtype(1,AnTcount,1)=ActualCongr;
                        AttnperXmodtype(1,AnTcount,2)=AttendCount;
                        AnTcount=AnTcount+1;
                    case 2
                        
                        AttnperXmodtype(2,AUDcount,1)=ActualCongr;
                        AttnperXmodtype(2,AUDcount,2)=AttendCount;
                        AUDcount=AUDcount+1;
                    case 3
                        
                        AttnperXmodtype(3,TACcount,1)=ActualCongr;
                        AttnperXmodtype(3,TACcount,2)=AttendCount;
                        TACcount=TACcount+1;
                end
                
            end
            
            %plots the correlation across all attention blocks per ppant.
            clf
            
            fontsize = 15;
            realvsreport = [AttnperBlock(:,1), AttnperBlock(:,2)];
            
            X=realvsreport(:,1);
            Y=realvsreport(:,2);
            % format long
            b1= polyfit(X,Y,1);
            xt = [min(X) max(X)];
            yt = polyval(b1, [min(X), max(X)]);
            
            sc=scatter(X,Y, [400],'k','filled');
            sc.MarkerSize
            hold on
            ylim([ 0 16])
            xlim([0 16])
            pl=plot(xt, yt, 'r', 'linewidth', 5);
            [rall, pall] = corr(X,Y);
            tmpr=sprintf('%.2f',rall);
            tmpp=sprintf('%.2f', pall);
            
            title(['Actual vs Reported congruent tones: ' num2str(initials)], 'fontsize', fontsize+5);
            ylabel('Reported', 'fontsize', fontsize)
            xlabel('Actual', 'fontsize', fontsize)
            lg=legend(pl, {['All Attended Blocks r=' num2str(tmpr) ', p=' num2str(tmpp)]});
            set(lg, 'location', 'SouthEast')
            set(gca, 'Fontsize', fontsize*2)
            set(gcf, 'Color', 'w')
            cd(savedatadir)
            cd('figs')
            cd('Scatter and Polyfit for Attention Accuracy by Individual')
            print('-dpng', ['Actual vs Reported Polyfit, combining modalities for ' num2str(initials)])
            allppantScatter(ippant,:,:)=realvsreport;
            allppant_r_and_p(ippant,1)=rall;
            allppant_r_and_p(ippant,2)=pall;
            
            
            %Also correlation for each xmod type.
            %%
            clf
            ty=[];
            tmpr=[];
            tmpp=[];
            for itype=1:3
                switch itype
                    case 1
                        printmod='AnT';
                        col='k';
                    case 2
                        printmod='AUD';
                        col='b';
                    case 3
                        printmod='TAC';
                        col='g';
                end
                
                useme= squeeze(AttnperXmodtype(itype,:,:));
                fontsize = 15;
                
                X=useme(:,1);
                Y=useme(:,2);
                % format long
                b1= polyfit(X,Y,1);
                xt = [min(X) max(X)];
                yt = polyval(b1, [min(X), max(X)]);
                
                scatter(X,Y, col);
                hold on
                ylim([ 0 16])
                xlim([0 16])
                ty(itype)=plot(xt, yt, col);
                [r(itype), p(itype)] = corr(X,Y);
                tmpr(itype)=str2num(sprintf('%.2f',r(itype)));
                tmpp(itype)=str2num(sprintf('%.2f', p(itype)));
                hold on
            end
            %%
            title(['Actual vs Reported congruent tones, by modality ppant ' num2str(initials)], 'fontsize', fontsize+5);
            ylabel('Reported', 'fontsize', fontsize)
            xlabel('Actual', 'fontsize', fontsize)
            set(gca, 'Fontsize', fontsize)
            set(gcf, 'Color', 'w')
            
            lg=legend([ty(1), ty(2), ty(3)], {['AnT, r=' num2str(tmpr(1)) ', p= ' num2str(tmpp(1)) ], ['Auditory, r=' num2str(tmpr(2)) ', p= ' num2str(tmpp(2)) ], ['Tactile, r=' num2str(tmpr(3)) ', p= ' num2str(tmpp(3)) ]});
            set(lg, 'Location', 'SouthEast');
            print('-dpng', ['Actual vs Reported Polyfit, by modality for ' num2str(initials)])
            %
            rAnT= r(1);
            rAUD=r(2);
            rTAC=r(3);
            pAnT=p(1);
            pAUD=p(2);
            pTAC=p(3);
            cd(savedatadir)
            cd(folname)
            save('CountedTones.mat', 'rAnT', 'rAUD', 'rTAC', 'pAnT', 'pTAC', 'pAUD', '-append')
            
            allppantScatter_byxmod(ippant,:,:,:) =AttnperXmodtype;
            for itype=1:3
                allppant_r_and_p_byxmod(ippant,itype,1)=r(itype);
                allppant_r_and_p_byxmod(ippant,itype,2)=p(itype);
            end
            allppant_list=[allppant_list;  {folname}];
        end
        
    end
    
    cd(savedatadir)
    cd('figs')
    save('AttnCorrelations(ppant,block,realvsreport)', 'allppantScatter', 'allppant_r_and_p', 'allppant_list', 'allppantScatter_byxmod', 'allppant_r_and_p_byxmod')
end

if job.plot_r_Bargraphs==1
    
    cd(savedatadir)
    cd('figs')
    load('AttnCorrelations(ppant,block,realvsreport).mat');
    cd('Distribution of Accuracy, Histograms')
    listppantsTracking=allppant_list;
    
    attendcond='Attending';
    clf
    
    
    histo = allppant_r_and_p(:,1);
    col='b';
    
    pvalues = (allppant_r_and_p(:,2));
    colp='r';
    
    bar(histo, col)
    xt=get(gca, 'Xtick');
    xtnew=[];
    for i=1:length(histo)
        tmp=listppantsTracking{i};
        initialstmp=tmp(1:2);
        xtnew=[xtnew; {num2str(initialstmp)}];
    end
    set(gca, 'Xtick', 1:length(histo), 'xticklabel', xtnew')
    
    
    ylabel(['Pearsons r, correlation coefficient'], 'fontsize', fontsize)
    title({['Individual corr. coeff for Actual vs Reported Congruent Tones'];['Combining modalities, sig at .05']}, 'fontsize', fontsize)
    hold on
    for ip=1:length(pvalues)
        if pvalues(ip) <.05
            text(ip, .95, '*', 'color', colp, 'linewidth', 5);
        end
    end
    
    xlabel(['Participant ID'], 'fontsize', fontsize)
    xlim([0 length(xtnew)+1])
    ylim([-.5 1])
    %%
    print('-dpng', ['Attention correlation coeff and pvals, combining modalities'])
    
    %now per xmod (across all).
    %%
    for xmod=1:3
        clf
        switch xmod
            case 1
                use_randp=squeeze(allppant_r_and_p_byxmod(:,1,:));
                typeis='AnT';
            case 2
                use_randp=squeeze(allppant_r_and_p_byxmod(:,2,:));
                typeis='AUD';
            case 3
                use_randp=squeeze(allppant_r_and_p_byxmod(:,3,:));
                typeis='TAC';
                
                
        end
        
        
        histo = use_randp(:,1);
        
        col='b';
        
        pvalues = (use_randp(:,2));
        
        colp='r';
        
        
        bar(histo, col)
        xt=get(gca, 'Xtick');
        xtnew=[];
        for i=1:length(histo);
            tmp=listppantsTracking{i};
            initialstmp=tmp(1:2);
            xtnew=[xtnew; {num2str(initialstmp)}];
        end
        set(gca, 'Xtick', 1:length(histo), 'xticklabel', xtnew')
        
        
        ylabel(['Pearsons r, correlation coefficient'], 'fontsize', fontsize)
        title({['Individual corr. coeff for Actual vs Reported Congruent Tones'];['for ' num2str(typeis) ', sig at .05']}, 'fontsize', fontsize)
        ylim([-.5 1])
        hold on
        for ip=1:length(pvalues)
            if pvalues(ip) <.05
                text(ip, .95, '*', 'color', colp, 'fontsize', 25);
            end
        end
        
        
        xlabel(['Participant ID'], 'fontsize', fontsize)
        xlim([0 length(xtnew)+1])
        
        
        print('-dpng', ['Attention correlation  coeff and pvals, for ' num2str(typeis)])
        
    end
end

if job.plotDiffMetric_histogram==1
    cd(savedatadir)
    cd('figs')
   
    load('AttnCorrelations(ppant,block,realvsreport).mat');
    %%
    cd('Distribution of Accuracy, Histograms')
    listppantsTracking=allppant_list;
    
    attendcond='Attending';
    %%
    
    clf
    
    tmpActual=allppantScatter(:,:,1);
    tmpReported= allppantScatter(:,:,2);
    dMn = tmpActual-tmpReported;
    
    PpantDiff=sum(dMn,2);
    
    
    histo=PpantDiff;
    
    col='b';
   hn= histfit(histo, length(unique(PpantDiff)))
    hn(2).LineWidth = 4;
    %% also calculate 1.5x to determine outliers. 
    Quarts = (prctile(histo, [25; 75]));    
    IQR=diff(Quarts);
    outlierLow = Quarts(1) - 1.5*IQR;
    outlierHigh = Quarts(2) + 1.5*IQR;
%%
    toolow=find(histo<outlierLow);
    toohigh=find(histo>outlierHigh);
    %%
    
    ylabel('Participant Count', 'fontsize', fontsize)
    title({['Distribution of Participant Accuracy during all Attend conditions'];['\itN\rm\bf = ' num2str(length(histo))]}, 'fontsize', fontsize)
    set(gca, 'ytick', 0:1:6);
    
    ylim([0 5])
    xlabel({['\Sigma (Actual-Reported congruent tones)']}, 'fontsize', fontsize)
    xlim([-75 75])
    set(gca, 'fontsize', fontsize*2)
    %%
%     print('-dpng', ['Distribution of Actual-Reported, combining modalities'])
    print('-dpng', ['MidCand Distribution of Actual-Reported, combining modalities'])
    
    %now per xmod (across all).
    %%
    for xmod=1:3
        clf
        switch xmod
            case 1
                
                typeis='AnT';
            case 2
                
                typeis='AUD';
            case 3
                
                typeis='TAC';
                
                
        end
         tmpActual=squeeze(allppantScatter_byxmod(:,:, xmod,1));
        tmpReported= squeeze(allppantScatter_byxmod(:,:, xmod,2));
       dMn = tmpActual-tmpReported;
%                 dMn=abs(dMn); %not using absolute, but an overall sum
        
        PpantDiff=sum(dMn,2);
% PpantDiff=mean(dMn,2);
        
        histo=PpantDiff;
        
        col='b';
        histfit(histo, length(unique(PpantDiff)))
        
         
   ylabel('Participant Count', 'fontsize', fontsize)
    title({['Accumulative sum of Actual - Reported Congruent Tones'];[num2str(typeis) ' modalities, n=' num2str(length(histo))]}, 'fontsize', fontsize)
    
    xlabel({['Accumulative sum of '];['Actual-Reported congruent tones']}, 'fontsize', fontsize)
%     xlim([-150 150])
    set(gca, 'fontsize', fontsize)
    
    %%
    print('-dpng', ['Distribution of Actual-Reported, ' num2str(typeis) ' modalities'])
    
    end
    
end


if job.plotDiffMetric_histogram_abs==1
    %First plot the histogram across all xmods, each ppant.
    cd(savedatadir)
    cd('figs')
    load('AttnCorrelations(ppant,block,realvsreport).mat');
    %
    cd('Distribution of Accuracy, Histograms')
    listppants_fromAttention=allppant_list;
    
    attendcond='Attending';
    for histis=1:2
        switch histis
            case 1
                histtype='gamma';
            case 2
                histtype='normal';
        end
        clf
        
        tmpActual=allppantScatter(:,:,1);
        tmpReported= allppantScatter(:,:,2);
        dM = tmpActual-tmpReported;
        dMn=abs(dM);
        PpantDiff=mean(dMn,2);
        
        histfit(PpantDiff, length(unique(PpantDiff)), histtype);
        hold on
        plot([0 0], ylim, ['k' '-'])
        ylabel({['Participant Count for Attend conditions'];['N=' num2str(size(PpantDiff,1))]}, 'fontsize', fontsize)
        title({['Distribution of Participant Accuracy'];['During all Attend conditions']}, 'fontsize', fontsize)
        xlabel({['Mean abs(Actual - Reported) congruent tones per participant'];['nblocks= 24']}, 'fontsize', fontsize)
        
        %%
        print('-dpng', ['Mean Attention performance histogram, ' num2str(histtype) ' distribution, combining modalities'])
    end
    %%
end

if job.plotDiffMetric_seperatetypes_histogram_abs==1
    %First plot the histogram across all xmods, each ppant.
    cd(savedatadir)
    cd('figs')
    load('AttnCorrelations(ppant,block,realvsreport).mat');
    
    %%
    cd('Distribution of Accuracy, Histograms')
    listppants_fromAttention=allppant_list;
    attendcond='Attending';
    for histis=1:2
        switch histis
            case 1
                histtype='gamma';
            case 2
                histtype='normal';
        end
        for itype=1:3
            switch itype
                case 1
                    typemod='AnT';
                    
                case 2
                    typemod='AUD';
                    
                case 3
                    typemod='TAC';
            end
            tmpScatter=squeeze(allppantScatter_byxmod(:,itype,:,:));
            clf
            
            tmpActual=tmpScatter(:,:,1);
            tmpReported= tmpScatter(:,:,2);
            dM = tmpActual-tmpReported;
            dMn=abs(dM);
            PpantDiff=mean(dMn,2);
            
            histfit(PpantDiff, size(PpantDiff,1), histtype);
            hold on
            plot([0 0], ylim, ['k' '-'])
            ylabel({['Participant Count for Attending to ' num2str(typemod) ' conditions'];['N=' num2str(size(PpantDiff,1))]}, 'fontsize', fontsize)
            title({['Distribution of Participant Accuracy, attending to ' num2str(typemod)]}, 'fontsize', fontsize)
            xlabel({['Mean abs(Actual - Reported) congruent tones per participant'];['nblocks= 8']}, 'fontsize', fontsize)
            
            %%
            print('-dpng', ['Mean Attention performance histogram, ' num2str(histtype) ' distribution, ' num2str(typemod)])
        end
    end
    %%
    %Now scatter using the behavioural tracking data.
    %now per xmod (across all).
    %%
    
    
end



if job.plotScatter_DiffMetric_vsBeh==1
   %%
    cd(savedatadir)
    cd('figs')
    load('groupTracking_byday(nppant,xmod,iph,ihz,samps)')
    load('AttnCorrelations(ppant,block,realvsreport)')
    %%
    for xmod=1:3
        %for eachstim modality.
        switch xmod
            case 1
                typemod='AnT';
                
            case 2
                typemod='AUD';
                %             checkchan= 6;
            case 3
                typemod='TAC';
                
        end
        
               
        %only have data for Attend days.
        attendcond='Attending';
        
        tmp1=squeeze(group_A_Data.day(1).data(:,xmod,:,:,:));
        tmp2= squeeze(group_nA_Data.day(2).data(:,xmod,:,:,:));
        %maintain order.
        listppantsTracking=[group_A_list.day(1).list; group_nA_list.day(2).list];
        listppantsAttending=allppant_list;
        
        if length(listppantsTracking) ~=length(listppantsAttending)
            error('Miscount between data sets')
        end %Note that these lists need to be sorted to display the same order of participants.
        
        dataBEHnow=cat(1,tmp1,tmp2); %need low vs high hz.
        samplewindowBEH = [samplepointsBEH(1)*60:samplepointsBEH(2)*60];
        
        %A
        %% now plot
        clf
        iplotcount=1;
        % %             for iphase=1:2
        %                 switch iphase
        %                     case 1
        %                         phaseis='In phase';
        %                     case 2
        %                         phaseis='Out of phase';
        %                 end
        
        
        for ihz=1:2
            switch ihz
                case 1
                    hzis='Low hz';
                    col='b';
                case 2
                    hzis='High hz';
                    col='r';
            end
            
            tmp= (squeeze(dataBEHnow(:,:,ihz,samplewindowBEH)));
            %take mean over phase aswell.
            dataBEH=squeeze(mean(tmp,2));
            %take mean per participant over this window
            histo=(mean(dataBEH,2));
            
            
%             %What is each ppant's meanActual-Reported
            findcorrectDiffMetricperppant;
%             
%             %What is each ppant's r value for correlation?
%             
%             [nppants, nxmods, nblocks, nActual, nReported]=size(DiffMetricsActual_Reported);
%             
%             tmpActual=squeeze(DiffMetricsActual_Reported(:,xmod,:,1));
%             tmpReported= squeeze(DiffMetricsActual_Reported(:,xmod,:,2));
%             dM = tmpActual-tmpReported;
%             dMn=abs(dM);
%             PpantDiff=mean(dMn,2);
%             histoX=PpantDiff;
%             
    
    
    
    histoX=DiffMetricsActual_Reported;
%     clf
            subplot(2,1, ihz)
            ps=scatter(histoX,histo, [100], col,'filled');
            %                 axis ij
            ylabel({['Mean behavioural probability of '];['congruent Button Press'];[num2str(samplepointsBEH(1)) ' - ' num2str(samplepointsBEH(2)) 's after onset']}, 'fontsize', fontsize);
            xlabel({['Absolute of the accumulative difference'];['Between actual and reported congruent tones for ' num2str(typemod)]} ,'fontsize', fontsize-2);            
            title({[num2str(attendcond) 'to ' num2str(typemod)];[ 'combined phase, ' num2str(hzis) ', N=' num2str(nppants)]}, 'fontsize', fontsize)
            [r,p]=corr(histoX,histo);
            
            iplotcount=iplotcount+1;
            hold on
            %                     set(gca, 'Yaxis', 'direction', 'invert')
%             xlim([0 1])
            ylim([.2 1])
            plot(xlim,[.5 .5], ['k' '-'])
%             plot(xlim, [0 0], ['k' '-'])
            %             text(.2, -.1, 'below chance', 'color', 'k' )
           
            tmpr=sprintf('%.2f',r);
            tmpp=sprintf('%.2f', p);
            
            %also line of best fit.
            b1= polyfit(histoX,histo,1);
            xt = [min(histoX) max(histoX)];
            yt = polyval(b1, [min(histoX), max(histoX)]);
            pl=plot(xt,yt,'k');
            lg=legend([ps, pl], {['Each participant N=' num2str(nppants)], ['r= ' num2str(tmpr) ', p=' num2str(tmpp)]});
            set(lg, 'fontsize', fontsize);
            set(gca, 'fontsize', fontsize);

        end
        %             end %removed phase distinction
        cd(savedatadir)
        cd('figs')
        cd('Distribution of Prob vs Accuracy')
%         printfilename=['Distribution of Tracking probability (' num2str(samplepointsBEH(1)), '-' num2str(samplepointsBEH(2)) 's), when ' num2str(attendcond) ' to ' num2str(typemod) ' vs mean Congruent-Attention Accuracy for ' num2str(typemod)];
printfilename=['Distribution of Tracking probability (' num2str(samplepointsBEH(1)), '-' num2str(samplepointsBEH(2)) 's), when ' num2str(attendcond) ' to combined modalities vs mean Congruent-Attention Accuracy for ' num2str(typemod)];
        print('-dpng', printfilename)
        
        
        
    end 
    
    
end

if job.plotScatter_Polyfit_acrossall_byCombining
    cd(savedatadir)
    cd('figs')
    load('AttnCorrelations(ppant,block,realvsreport)')
    cd('Scatter and Polyfit for Attention Accuracy Across all')
    clf
    for ippant = 1:size(allppantScatter,1);
        
        realvsreport=squeeze(allppantScatter(ippant,:,:));
        
        X=realvsreport(:,1);
        Y=realvsreport(:,2);
        
        b1= polyfit(X,Y,1);
        xt = [min(X) max(X)];
        yt = polyval(b1, [min(X), max(X)]);
        
        scatter(X,Y);
        hold on
        ylim([ 0 16])
        xlim([0 16])
        [r, p] = corr(X,Y);
        colorp='b';
        pl=plot(xt, yt, 'color', colorp);
        hold on
    end
    
    % plot overall correlation.
    tmp=reshape(allppantScatter, [size(allppantScatter,1)* size(allppantScatter,2), 2]);
    
    Xa= tmp(:,1);
    Ya=tmp(:,2);
    b1= polyfit(Xa,Ya,1);
    xt = [min(Xa) max(Xa)];
    yt = polyval(b1, [min(Xa), max(Xa)]);
    
    scatter(Xa, Ya)
    [rA, pA]=corr(Xa,Ya);
    tmpr=str2num(sprintf('%.2f',rA));
    tmpp=str2num(sprintf('%.2f', pA));
    
    plA=plot(xt,yt, 'color','k', 'linewidth',5);
    lg=legend([pl, plA], {'Individual Correlations', ['Across All r=' num2str(tmpr) ', p=' num2str(pA)]});
    set(lg, 'Location', 'SouthEast')
    
    ylabel('Reported', 'fontsize', fontsize)
    xlabel('Actual', 'fontsize', fontsize)
    set(gca, 'Fontsize', fontsize)
    set(gcf, 'Color', 'w')
    title({['Actual vs Reported Polyfit for n= ' num2str(size(allppantScatter,1)) ' ppants'];['Total blocks = ' num2str(size(tmp,1))]})
    %%
    print('-dpng', ['All ppant Attention correlations, after combining modalities'])
end
%%
if job.plotScatter_Polyfit_acrossall_byxmod
    cd(savedatadir)
    cd('figs')
    load('AttnCorrelations(ppant,block,realvsreport).mat');
    cd('Scatter and Polyfit for Attention Accuracy Across all');
    %%
    for itype=1:3
        clf
        switch itype
            case 1
                allppantScatter= squeeze(allppantScatter_byxmod(:,itype,:,:));
                xmod='AnT';
            case 2
                allppantScatter= squeeze(allppantScatter_byxmod(:,itype,:,:));
                xmod='AUD';
            case 3
                allppantScatter= squeeze(allppantScatter_byxmod(:,itype,:,:));
                xmod='TAC';
                
        end
        
        for ippant = 1:size(allppantScatter,1);
            
            realvsreport=squeeze(allppantScatter(ippant,:,:));
            
            X=realvsreport(:,1);
            Y=realvsreport(:,2);
            
            b1= polyfit(X,Y,1);
            xt = [min(X) max(X)];
            yt = polyval(b1, [min(X), max(X)]);
            
            scatter(X,Y);
            hold on
            ylim([ 0 16])
            xlim([0 16])
            [r, p] = corr(X,Y);
            colorp='b';
            pl=plot(xt, yt, 'color', colorp);
            hold on
        end
        
        % plot overall correlation.
        tmp=reshape(allppantScatter, [size(allppantScatter,1)* size(allppantScatter,2), 2]);
        
        Xa= tmp(:,1);
        Ya=tmp(:,2);
        b1= polyfit(Xa,Ya,1);
        xt = [min(Xa) max(Xa)];
        yt = polyval(b1, [min(Xa), max(Xa)]);
        
        scatter(Xa, Ya)
        [rA, pA]=corr(Xa,Ya);
        tmpr=str2num(sprintf('%.2f',rA));
        tmpp=str2num(sprintf('%.2f', pA));
        
        plA=plot(xt,yt, 'color','k', 'linewidth',5);
        lg=legend([pl, plA], {'Individual Correlations', ['Across All r=' num2str(tmpr) ', p=' num2str(pA)]});
        set(lg, 'Location', 'SouthEast')
        
        ylabel('Reported', 'fontsize', fontsize)
        xlabel('Actual', 'fontsize', fontsize)
        set(gca, 'Fontsize', fontsize)
        set(gcf, 'Color', 'w')
        
        title({['Actual vs Reported Polyfit for ' num2str(xmod) ','];['n= ' num2str(size(allppantScatter,1)) ' ppants'];['Total blocks = ' num2str(size(tmp,1))]})
        
        %
        print('-dpng', ['All ppant Attention correlations, for ' num2str(xmod) ])
        
    end
end

%%



%for each participant, capture average probability between behavioural
%window
if job.plotScatterAttentionALLvsBeh
    cd(savedatadir)
    cd('figs')
    load('groupTracking_byday(nppant,xmod,iph,ihz,samps)')
    load('AttnCorrelations(ppant,block,realvsreport)')
    for xmod=1:3
        %for eachstim modality.
        switch xmod
            case 1
                typemod='AnT';
                
            case 2
                typemod='AUD';
                %             checkchan= 6;
            case 3
                typemod='TAC';
                
        end
       
        %only have data for Attend days.
        attendcond='Attending';
        
        tmp1=squeeze(group_A_Data.day(1).data(:,xmod,:,:,:));
        tmp2= squeeze(group_nA_Data.day(2).data(:,xmod,:,:,:));
        %maintain order.
        listppantsTracking=[group_A_list.day(1).list; group_nA_list.day(2).list];
        listppantsAttending=allppant_list;
        
        if length(listppantsTracking) ~=length(listppantsAttending)
            error('Miscount between data sets')
        end %Note that these lists need to be sorted to display the same order of participants.
        
        dataBEHnow=cat(1,tmp1,tmp2); %need low vs high hz.
        samplewindowBEH = [samplepointsBEH(1)*60:samplepointsBEH(2)*60];
        
        
        %% now plot
        clf
        iplotcount=1;
        % %             for iphase=1:2
        %                 switch iphase
        %                     case 1
        %                         phaseis='In phase';
        %                     case 2
        %                         phaseis='Out of phase';
        %                 end
        
        
        for ihz=1:2
            switch ihz
                case 1
                    hzis='Low hz';
                    col='b';
                case 2
                    hzis='High hz';
                    col='r';
            end
            
            tmp= (squeeze(dataBEHnow(:,:,ihz,samplewindowBEH)));
            %take mean over phase aswell.
            dataBEH=squeeze(mean(tmp,2));
            %take mean per participant over this window
            histo=(mean(dataBEH,2));
            
            
            %What is each ppant's r value for correlation?
            findcorrectRvalueperppant;
            
            [nppants, nxmods, nrandp]=size(randpvalues);
            
            histo2=randpvalues(:,4,1); %collects r values for across all.
            
            subplot(2,1, ihz)
            ps=scatter(histo2,histo, [], col,'filled');
            %                 axis ij
            ylabel({['Mean behavioural probability '];['window of ' num2str(samplepointsBEH(1)) ' - ' num2str(samplepointsBEH(2)) 's']} , 'fontsize', fontsize);
            xlabel({['Correlation coefficient for Attending to tones,'];[' combining modalities']} , 'fontsize', fontsize);
            [r,p]=corr(histo,histo2);
            title({[num2str(attendcond) 'to ' num2str(typemod)];[  num2str(samplepointsBEH(1)) '-' num2str(samplepointsBEH(2)) ' seconds after onset'];[ 'grouped phase, ' num2str(hzis) ', n=' num2str(nppants)]}, 'fontsize', fontsize)
            iplotcount=iplotcount+1;
            hold on
            %                     set(gca, 'Yaxis', 'direction', 'invert')
            xlim([-.5 1])
            ylim([.3 1])
            plot(xlim ,[.5 .5], ['k' ':'])
            
            %             text(.2, -.1, 'below chance', 'color', 'k' )
            legend(ps, ['Each participant n=' num2str(nppants)])
            tmpr=sprintf('%.2f',r);
            tmpp=sprintf('%.2f', p);
            
            %also line of best fit.
            b1= polyfit(histo2,histo,1);
            xt = [min(histo2) max(histo2)];
            yt = polyval(b1, [min(histo2), max(histo2)]);
            pl=plot(xt,yt,'k', 'linewidth', 3);
            lg=legend(pl, ['r= ' num2str(tmpr) ', p=' num2str(tmpp)]);
            set(lg, 'fontsize', fontsize)
            set(gca, 'fontsize', fontsize)
        end
        %             end %removed phase distinction
        cd(savedatadir)
        cd('figs')
        cd('Distribution of Prob vs Accuracy')
        printfilename=['Distribution of Tracking probability (' num2str(samplepointsBEH(1)), '-' num2str(samplepointsBEH(2)) 's), when ' num2str(attendcond) ' to ' num2str(typemod) ' vs individual Accuracy, combining across modalities'];
        print('-dpng', printfilename)
        
        
        
    end
    
end

%plots against the individual attention performance (correlation), within cross-modal sitmulus type
if job.plotScatterAttentionXMODvsBeh 
    cd(savedatadir)
    cd('figs')
    load('groupTracking_byday(nppant,xmod,iph,ihz,samps)')
    load('AttnCorrelations(ppant,block,realvsreport)')
    for xmod=1:3
        %for eachstim modality.
        switch xmod
            case 1
                typemod='AnT';
                
            case 2
                typemod='AUD';
                %             checkchan= 6;
            case 3
                typemod='TAC';
                
        end
        
        
        
        
        
        %only have data for Attend days.
        attendcond='Attending';
        
        tmp1=squeeze(group_A_Data.day(1).data(:,xmod,:,:,:));
        tmp2= squeeze(group_nA_Data.day(2).data(:,xmod,:,:,:));
        %maintain order.
        listppantsTracking=[group_A_list.day(1).list; group_nA_list.day(2).list];
        listppantsAttending=allppant_list;
        
        if length(listppantsTracking) ~=length(listppantsAttending)
            error('Miscount between data sets')
        end %Note that these lists need to be sorted to display the same order of participants.
        
        dataBEHnow=cat(1,tmp1,tmp2); %need low vs high hz.
        samplewindowBEH = [samplepointsBEH(1)*60:samplepointsBEH(2)*60];
        
        
        %% now plot
        clf
        iplotcount=1;
        % %             for iphase=1:2
        %                 switch iphase
        %                     case 1
        %                         phaseis='In phase';
        %                     case 2
        %                         phaseis='Out of phase';
        %                 end
        
        
        for ihz=1:2
            switch ihz
                case 1
                    hzis='Low hz';
                    col='b';
                case 2
                    hzis='High hz';
                    col='r';
            end
            
            tmp= (squeeze(dataBEHnow(:,:,ihz,samplewindowBEH)));
            %take mean over phase aswell.
            dataBEH=squeeze(mean(tmp,2));
            %take mean per participant over this window
            histo=(mean(dataBEH,2));
            
            
            %What is each ppant's r value for correlation?
            findcorrectRvalueperppant;
            
            [nppants, nxmods, nrandp]=size(randpvalues);
            
            histo2=randpvalues(:,xmod,1); %collects r values for specific type of block.
            
            subplot(2,1, ihz)
            ps=scatter(histo,histo2, [], col,'filled');
            %                 axis ij
            xlabel({['Mean behavioural probability '];['window of ' num2str(samplepointsBEH(1)) ' - ' num2str(samplepointsBEH(2)) 's']} );
            ylabel({['Correlation coefficient for Attending to tones,'];[' for ' num2str(typemod)]} );
            [r,p]=corr(histo,histo2);
            title({[num2str(attendcond) 'to ' num2str(typemod)];[  num2str(samplepointsBEH(1)) '-' num2str(samplepointsBEH(2)) ' seconds after onset'];[ 'grouped phase, ' num2str(hzis) ', n=' num2str(nppants)]})
            iplotcount=iplotcount+1;
            hold on
            %                     set(gca, 'Yaxis', 'direction', 'invert')
            xlim([0 1])
            ylim([-.2 1])
            plot([.5 .5], ylim, ['k' '-'])
            plot(xlim, [0 0], ['k' '-'])
            %             text(.2, -.1, 'below chance', 'color', 'k' )
            legend(ps, ['Each participant n=' num2str(nppants)])
            tmpr=sprintf('%.2f',r);
            tmpp=sprintf('%.2f', p);
            
            %also line of best fit.
            b1= polyfit(histo,histo2,1);
            xt = [min(histo) max(histo)];
            yt = polyval(b1, [min(histo), max(histo)]);
            pl=plot(xt,yt,'k');
            legend(pl, ['r= ' num2str(tmpr) ', p=' num2str(tmpp)])
        end
        %             end %removed phase distinction
        cd(savedatadir)
        cd('figs')
        cd('Distribution of Prob vs Accuracy')
        printfilename=['Distribution of Tracking probability (' num2str(samplepointsBEH(1)), '-' num2str(samplepointsBEH(2)) 's), when ' num2str(attendcond) ' to ' num2str(typemod) ' vs individual Accuracy for ' num2str(typemod)];
        print('-dpng', printfilename)
        
        
        
    end
    
end
%%
%
cd(savedatadir)
cd('figs')
