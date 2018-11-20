savedatadir='/Users/MattDavidson/Desktop/XM_Project/DATA_newhope';
cd(savedatadir)
cd('figs')
%%
load('groupTracking_byday(nppant,xmod,iph,ihz,samps)')
%%
getelocs
fontsize= 15;
samplepointsEEG = [.5, 2]; %seconds
sampleprint=[',5 to 2'];
samplepointsBEH = [2 3]; %seconds

job.plotHistograms=1;
job.plotScatterERPvsBEH=0;
job.plotScatterMSIvsBEH=0;
%for each participant, capture average probability between 1.5- 2.5
%seconds.
clf
fontsize=20;
checkchan=4;
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
    
    
    for iattendcond=1:2
        
        
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
        
        samplewindowBEH = [samplepointsBEH(1)*60:samplepointsBEH(2)*60];
        
        if job.plotHistograms
            clf
            
            iplotcount=1;
            
            
            for ihz=1:2
                switch ihz
                    case 1
                        hzis='Low hz';
                        col='b';
                    case 2
                        hzis='High hz';
                        col='r';
                end
                
                
                dataBEH= (squeeze(dataBEHnow(:,:,ihz,samplewindowBEH)));
                
                %take mean over phase aswell.
                %                     dataBEH=squeeze(mean(tmp,2));
                %mean over window
                histo=squeeze(mean(dataBEH,3));
                nppants=size(dataBEH,1);
                
                subplot(2,1,iplotcount)
                %                     subplot(2,2,iplotcount)
                bh=bar(histo, col);
                xt=get(gca, 'xtick');
                xtnew=[];
                for i=1:length(histo);
                    tmp=listppants{i};
                    initialstmp=tmp(1:2);
                    xtnew=[xtnew; {num2str(initialstmp)}];
                end
                set(gca, 'xtick', 1:length(histo), 'xticklabel', xtnew','fontsize', fontsize)
                xlabel('Participant ID')
                ylabel({['Mean Prob for window '];[  num2str(samplepointsBEH(1)) '-' num2str(samplepointsBEH(2)) ' seconds after onset']})
                title({[num2str(attendcond) ' to ' num2str(typemod)];[ num2str(hzis)]})
                iplotcount=iplotcount+1;
                hold on
                plot( xlim, [.5 .5], ['k' '-'])
                xlim([0 nppants+1])
                ylim([0 1])
                switch ihz
                    case 1
                        %Low Freq
                        bh(1).FaceColor= [0 0 1];
                        bh(2).FaceColor= [0 0 .5];
                    case 2
                        %high Freq
                        bh(1).FaceColor= [1 0 0];
                        bh(2).FaceColor= [.5 0 0];
                end
                legend 'In phase'  'Out of phase'
                set(gca, 'fontsize', fontsize)
            end
           
            cd(savedatadir)
            cd('figs')
            cd('Distribution of Probability Tracking, Histograms')
            printfilename=['Distribution of individual tracking probability, ' num2str(samplepointsBEH(1)) ' second to ' num2str(samplepointsBEH(2)) ' seconds, ' num2str(attendcond) ' to ' num2str(typemod)];
            print('-dpng', printfilename)
        end
        
        
        if job.plotScatterERPvsBEH
            
            %now a scatter with both the behavioural and EEG.
            cd('/Users/MattDavidson/Desktop/XM_Project/EEGData/DATA/Processed/EEG_from_Attention_XmodalEXP/j2_AllchanEpoched/AcrossALL')
            %load ERPs for each participant (mean across all trials, within
            %participants).
            load('topoERP_Group_nA.mat')
            load('topoERP_Group_A.mat')
            
            plotDATA=[];
            switch xmod
                case 1
                    if iattendcond==1
                        tmp1= group_A_topoERP_AnT.day(1).data;
                        tmp2=group_nA_topoERP_AnT.day(2).data;
                    else
                        tmp1= group_A_topoERP_AnT.day(2).data;
                        tmp2=group_nA_topoERP_AnT.day(1).data;
                    end
                    
                case 2
                    if iattendcond==1
                        tmp1= group_A_topoERP_AUD.day(1).data;
                        tmp2=group_nA_topoERP_AUD.day(2).data;
                    else
                        tmp1= group_A_topoERP_AUD.day(2).data;
                        tmp2=group_nA_topoERP_AUD.day(1).data;
                    end
                    
                    
                case 3
                    if iattendcond==1
                        tmp1= group_A_topoERP_TAC.day(1).data;
                        tmp2=group_nA_topoERP_TAC.day(2).data;
                    else
                        tmp1= group_A_topoERP_TAC.day(2).data;
                        tmp2=group_nA_topoERP_TAC.day(1).data;
                    end
                    
            end
            %%collect data for all plots
            for itoplot=1:2 %plot over low vs high.
                plotdata=[];
                tmp=[];
                switch itoplot
                    case 1 %low hz
                        plotdata(1,:,:,:)=tmp1.Inphase.Lowhz;
                        plotdata(2,:,:,:)=tmp1.Outofphase.Lowhz;
                        %mean group 1, over phase types.
                        tmpA=squeeze(mean(plotdata,1));
                        
                        plotdata=[];
                        plotdata(1,:,:,:)=tmp2.Inphase.Lowhz;
                        plotdata(2,:,:,:)=tmp2.Outofphase.Lowhz;
                        tmpnA=squeeze(mean(plotdata,1));
                    case 2 %high plot
                        plotdata(1,:,:,:)=tmp1.Inphase.Highhz;
                        plotdata(2,:,:,:)=tmp1.Outofphase.Highhz;
                        %mean group 1, over phase types.
                        tmpA=squeeze(mean(plotdata,1));
                        
                        plotdata=[];
                        plotdata(1,:,:,:)=tmp2.Inphase.Highhz;
                        plotdata(2,:,:,:)=tmp2.Outofphase.Highhz;
                        tmpnA=squeeze(mean(plotdata,1));
                        
                        
                end
                plotdata=cat(1,tmpA,tmpnA);
                plotdata=squeeze(plotdata(:,checkchan,:));
                plotDATA(itoplot,:,:)=plotdata;
            end
            
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
                
                %take care with EEG window, since Epochlength=
                %[-.5 : 4.5]
                samplewindowEEG= [samplepointsEEG(1)*250+(.5*250):samplepointsEEG(2)*250+(.5*250)]; %Fs=250
                dataERP= (squeeze(plotDATA(iplotcount,:,samplewindowEEG)));
                histo2=(mean(dataERP,2));
                %%
                subplot(2,1,iplotcount)
                ps=scatter(histo,histo2, [], col,'filled');
                axis ij
                xlabel({['Mean behavioural probability '];['window of ' num2str(samplepointsBEH(1)) ' - ' num2str(samplepointsBEH(2)) 's']} );
                ylabel({['Mean ERP amplitude (uV) at ' num2str(elocs(checkchan).labels)];['window of ' num2str(samplepointsEEG(1)) ' - ' num2str(samplepointsEEG(2)) 's']} );
                [r,p]=corr(histo,histo2);
                title({[num2str(attendcond) 'to ' num2str(typemod)];[  num2str(samplepointsBEH(1)) '-' num2str(samplepointsBEH(2)) ' seconds after onset'];[ 'grouped phase, ' num2str(hzis)]})
                iplotcount=iplotcount+1;
                hold on
                %                     set(gca, 'Yaxis', 'direction', 'invert')
                xlim([.1 1])
                if mean(histo2)<0 %invert y axis
                    
                    ylim([-15 2])
                    axis ij
                else
                    ylim([-2 15])
                    axis xy
                end
                plot([.5 .5], ylim, ['k' '-'])
                text(.2, -1.5, 'below chance', 'color', 'k' )
                legend(ps, ['Each participant n=' num2str(size(dataERP,1))])
                text(.8, 0, ['r=' num2str(r) ', p=' num2str(p)])
            end
            %             end %removed phase distinction
            cd(savedatadir)
            cd('figs')
            cd('Distribution of Prob vs ERP')
            printfilename=['Distribution ERP amp vs tracking probability, EEG ' sampleprint 'seconds, ' num2str(attendcond) ' to ' num2str(typemod) ', at chan ' num2str(elocs(checkchan).labels)];
            print('-dpng', printfilename)
            
            
            
        end
    end
end
%%

if job.plotScatterMSIvsBEH
    typemod='MSI';
    
    for iattendcond=1:2
        
        %collect all three types of behavioural data to plot against MSI ERP
        switch iattendcond
            case 1
                attendcond='Attending';
                
                tmp1=squeeze(group_A_Data.day(1).data);
                tmp2= squeeze(group_nA_Data.day(2).data);
                
            case 2
                attendcond='non-attending';
                tmp1=squeeze(group_A_Data.day(2).data);
                tmp2= squeeze(group_nA_Data.day(1).data);
        end
        dataBEHnowALL=cat(1,tmp1,tmp2); %need low vs high hz.
        
        samplewindowBEH = [samplepointsBEH(1)*60:samplepointsBEH(2)*60];
        
        
        %now a scatter with both the behavioural and EEG.
        cd('/Users/MattDavidson/Desktop/XM_Project/EEGData/DATA/Processed/EEG_from_Attention_XmodalEXP/j2_AllchanEpoched/AcrossALL')
        %load ERPs for each participant (mean across all trials, within
        %participants).
        load('topoERP_Group_nA.mat')
        load('topoERP_Group_A.mat')
        
        plotDATA=[];
        if iattendcond==1
            tmp1= group_A_topoERP_MSI.day(1).data;
            tmp2=group_nA_topoERP_MSI.day(2).data;
        else
            tmp1= group_A_topoERP_MSI.day(2).data;
            tmp2=group_nA_topoERP_MSI.day(1).data;
        end
        
        %%collect data for all plots
        for itoplot=1:2 %plot over low vs high.
            plotdata=[];
            tmp=[];
            switch itoplot
                case 1 %low hz
                    plotdata(1,:,:,:)=tmp1.Inphase.Lowhz;
                    plotdata(2,:,:,:)=tmp1.Outofphase.Lowhz;
                    %mean group 1, over phase types.
                    tmpA=squeeze(mean(plotdata,1));
                    
                    plotdata=[];
                    plotdata(1,:,:,:)=tmp2.Inphase.Lowhz;
                    plotdata(2,:,:,:)=tmp2.Outofphase.Lowhz;
                    tmpnA=squeeze(mean(plotdata,1));
                case 2 %high plot
                    plotdata(1,:,:,:)=tmp1.Inphase.Highhz;
                    plotdata(2,:,:,:)=tmp1.Outofphase.Highhz;
                    %mean group 1, over phase types.
                    tmpA=squeeze(mean(plotdata,1));
                    
                    plotdata=[];
                    plotdata(1,:,:,:)=tmp2.Inphase.Highhz;
                    plotdata(2,:,:,:)=tmp2.Outofphase.Highhz;
                    tmpnA=squeeze(mean(plotdata,1));
                    
                    
            end
            plotdata=cat(1,tmpA,tmpnA);
            plotdata=squeeze(plotdata(:,checkchan,:));
            plotDATA(itoplot,:,:)=plotdata;
        end
        
        %% now plot
        for icompBEH=1%:3
            switch icompBEH
                case 1
                    behcomp='AnT';
                case 2
                    behcomp='AUD';
                case 3
                    behcomp='TAC';
            end
            
            clf
            iplotcount=1;
            
            for ihz=1:2
                switch ihz
                    case 1
                        hzis='Low hz';
                        col='b';
                    case 2
                        hzis='High hz';
                        col='r';
                end
                
                tmp= (squeeze(dataBEHnowALL(:,icompBEH,:,ihz,samplewindowBEH)));
                %take mean over phase aswell.
                dataBEH=squeeze(mean(tmp,2));
                %take mean per participant over this window
                histo=(mean(dataBEH,2));
                
                %take care with EEG window, since Epochlength=
                %[-.5 : 4.5]
                samplewindowEEG= [samplepointsEEG(1)*250+(.5*250):samplepointsEEG(2)*250+(.5*250)]; %Fs=250
                dataERP= (squeeze(plotDATA(iplotcount,:,samplewindowEEG)));
                histo2=(mean(dataERP,2));
                %%
                subplot(2,1,iplotcount)
                ps=scatter(histo,histo2, [], col,'filled');
                axis ij
                xlabel({['Mean behavioural probability '];['window of ' num2str(samplepointsBEH(1)) ' - ' num2str(samplepointsBEH(2)) 's']} );
                ylabel({['Mean MSI amplitude (uV) at ' num2str(elocs(checkchan).labels)];['window of ' num2str(samplepointsEEG(1)) ' - ' num2str(samplepointsEEG(2)) 's']} );
                [r,p]=corr(histo,histo2);
                title({[num2str(attendcond) 'to ' num2str(behcomp)];[  num2str(samplepointsBEH(1)) '-' num2str(samplepointsBEH(2)) ' seconds after onset'];[ 'grouped phase, ' num2str(hzis)]})
                iplotcount=iplotcount+1;
                hold on
                %                     set(gca, 'Yaxis', 'direction', 'invert')
                xlim([.1 1])
                if mean(histo2)<0 %invert y axis
                    
                    ylim([-15 2])
                    axis ij
                else
                    ylim([-2 15])
                    axis xy
                end
                plot([.5 .5], ylim, ['k' '-'])
                text(.2, -1.5, 'below chance', 'color', 'k' )
                legend(ps, ['Each participant n=' num2str(size(dataERP,1))])
                text(.8, 0, ['r=' num2str(r) ', p=' num2str(p)])
            end
            %             end %removed phase distinction
            cd(savedatadir)
            cd('figs')
              cd('Distribution of Prob vs ERP')
            printfilename=['Distribution MSI ERP amp vs tracking probability, EEG ' sampleprint 'seconds, ' num2str(attendcond) ' to ' num2str(behcomp) ', at chan ' num2str(elocs(checkchan).labels)];
            print('-dpng', printfilename)
        end
    end
end
cd(savedatadir)
cd('figs')
