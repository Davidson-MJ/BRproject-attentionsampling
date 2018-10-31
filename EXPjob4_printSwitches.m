%print switch related SNR for SSVEP activity.

clearvars -except allEEG*
job.plotIndividualSwitchActivity=0 ;%and concatenate across all.
job.plotAcrossALLSwitchActivity_sepDaysandGroups=0;
job.plotAcrossALLSwitchActivity_alltogetherbyAttendcondition=1;

 %%

pathtoEpocheddataEXP= allEEGblockdatadir;

smoothing=0; %change to zero for raw trace.
fontsize =15;
refreshrate=60;
epochlength=[-5 5];
% ylimsat=[-3.5 3.5];
plotbestcomparison = 0; %zero for all signals, 1 or just 3Vf1 vs vf2.

%which conditions to plot? Note, need to have been precalculated.
ichan='Oz';
basesubtract=0; %2 to change to the version with 2s subtracted.

cd(pathtoEpocheddataEXP);
allppants=dir(['ppant*']);
nppants=length(allppants);

%note have removed ppants KS, and... ? for poor attention performance.


for plotswitchesdur = [0]% [.1, .5, 1, 1.5, 2, 2.5, 3]; %seconds duration to keep for plot
    
    allplotsfor_groupA=[];
    allplotsfor_groupnA=[];
    A_count=1;
    nA_count=1;
    if job.plotIndividualSwitchActivity
        %need to store across all ppants.
        allplots_to_pf1=[]; %
        allplots_to_pf2=[]; %
        
%%
        for ppantIN=1:nppants
            
            allplots_to_pf1=[]; %
            allplots_to_pf2=[]; % %reset each day?
            
            cd(pathtoEpocheddataEXP)
            ppantfol=dir(['ppant' num2str(ppantIN) '_*']);
            cd(ppantfol.name)
            %
            %skip removed ppant 30
            initials= ppantfol.name(end-1:end);
            %how many days of data?
            AllEEG=dir(['AllAlignedEEGswitchData_Day*'   num2str(basesubtract) 's_brem_chan_' num2str(ichan) '*']);
            nDays=length(AllEEG);
            for iday = 1:nDays
                attendcond=[];
                allplots_to_pf1=[]; %
                allplots_to_pf2=[]; % %reset each day?
                
                cd(pathtoEpocheddataEXP)
                ppantfol=dir(['ppant' num2str(ppantIN) '_*']);
                cd(ppantfol.name)
                %
                load(['AllAlignedEEGswitchData_Day' num2str(iday) '_' num2str(basesubtract) 's_brem_chan_' num2str(ichan) '.mat'])
                
                
                if strcmp(attendcond,'on')
                    attendcond='Attending';
                else
                    attendcond='non-Attending';
                end
                
                
                clf
                %For switch related trace activity.
                %find index for longer durations
                plotlims = plotswitchesdur*params.Fs + params.Fs*2;
                switchdurinframes = plotswitchesdur*refreshrate;
                
                goodL = max(find(sortnewtoLow>switchdurinframes));
                goodH = max(find(sortnewtoHigh>switchdurinframes));
                
                %
                for iperceptdirection = 1:2
                    
                    plotSNR_toP_gooddur=[];
                    plotSNR_tonP_gooddur=[];
                    
                    switch iperceptdirection
                        case 1 %pf2-> pf1
                            if plotbestcomparison == 0 % plot all flickers and harmonics
                                plotSNR_toP_gooddur(1).data = EEGdata_to_pf1_sorted.SNR_f1(1:goodL, :);
                                plotSNR_toP_gooddur(2).data = EEGdata_to_pf1_sorted.SNR_2f1(1:goodL, :);
                                plotSNR_toP_gooddur(3).data = EEGdata_to_pf1_sorted.SNR_3f1(1:goodL, :);
                                
                                plotSNR_tonP_gooddur(1).data = EEGdata_to_pf1_sorted.SNR_f2(1:goodL, :);
                                plotSNR_tonP_gooddur(2).data = EEGdata_to_pf1_sorted.SNR_2f2(1:goodL, :);
                            else %just 3vf1 vs vf2
                                plotSNR_toP_gooddur(1).data = EEGdata_to_pf1_sorted.SNR_f1(1:goodL, :);
                                
                                plotSNR_tonP_gooddur(1).data = EEGdata_to_pf1_sorted.SNR_f2(1:goodL, :);
                            end
                            
                            perceptdirection = 'pf2->pf1';
                            
                            clist = goodL;
                            
                        case 2
                            if plotbestcomparison==0
                                plotSNR_tonP_gooddur(1).data = EEGdata_to_pf2_sorted.SNR_f1(1:goodH, :);
                                plotSNR_tonP_gooddur(2).data = EEGdata_to_pf2_sorted.SNR_2f1(1:goodH, :);
                                plotSNR_tonP_gooddur(3).data = EEGdata_to_pf2_sorted.SNR_3f1(1:goodH, :);
                                
                                plotSNR_toP_gooddur(1).data = EEGdata_to_pf2_sorted.SNR_f2(1:goodH, :);
                                plotSNR_toP_gooddur(2).data = EEGdata_to_pf2_sorted.SNR_2f2(1:goodH, :);
                            else
                                
                                plotSNR_tonP_gooddur(1).data = EEGdata_to_pf2_sorted.SNR_f1(1:goodH, :);
                                
                                plotSNR_toP_gooddur(1).data = EEGdata_to_pf2_sorted.SNR_f2(1:goodH, :);
                                
                            end
                            perceptdirection = 'pf1->pf2';
                            clist = goodH;
                            
                    end
                    %%
                    clf
                    x=times - epochlength(2);
                    
                    for itrace = 1:length(plotSNR_toP_gooddur)
                        
                        switch itrace
                            case 1
                                linet='-';
                            case 2
                                linet='-.';
                            case 3
                                linet = ':';
                        end
                        %                 if length(plotSNR_toP_gooddur)>2
                        %                     colorp='b';
                        %                 else
                        %                     colorp='r';
                        %                 end
                        if iperceptdirection==1
                            colorp='b';
                        else
                            colorp='r';
                        end
                        tmp = plotSNR_toP_gooddur(itrace).data;
                        
                        stErr = std(tmp,1)/(sqrt(clist));
                        %
                        toplot = squeeze(mean(tmp,1));
                        
                        
                        if smoothing==1
                            toplot=smooth(toplot);
                        end
                        to_p(itrace)=shadedErrorBar(x, toplot, stErr,[linet colorp], 1);
                        % xlim([-plotlims plotlims])
                        hold on
                        
                        if size(toplot,1)>size(toplot,2)
                            toplot=toplot';
                        end
                        %SAVE congruent data
                        switch iperceptdirection %save individual traces for averaging across participants.
                            case 1 %pf2-> pf1
                                switch itrace
                                    case 1
                                        try
                                            allplots_to_pf1.f1data = [allplots_to_pf1.f1data; toplot];
                                        catch
                                            allplots_to_pf1.f1data = [toplot];
                                        end
                                        
                                    case 2
                                        try allplots_to_pf1.twof1data = [allplots_to_pf1.twof1data; toplot];
                                        catch
                                            allplots_to_pf1.twof1data = [toplot];
                                        end
                                    case 3
                                        try allplots_to_pf1.threef1data = [allplots_to_pf1.threef1data;toplot];
                                        catch
                                            allplots_to_pf1.threef1data = [toplot];
                                        end
                                end
                                
                            case 2        %pf1->pf2
                                switch itrace
                                    case 1
                                        try  allplots_to_pf2.f2data = [allplots_to_pf2.f2data; toplot];
                                        catch
                                            allplots_to_pf2.f2data = [ toplot];
                                        end
                                    case 2
                                        
                                        try  allplots_to_pf2.twof2data = [allplots_to_pf2.twof2data; toplot];
                                        catch
                                            allplots_to_pf2.twof2data = [ toplot];
                                        end
                                end
                        end
                        
                        
                    end
                    
                    % plot opposite trace
                    for itrace = 1:length(plotSNR_tonP_gooddur)
                        switch itrace
                            case 1
                                linet='-';
                            case 2
                                linet='-.';
                            case 3
                                linet = ':';
                        end
                        %                 if length(plotSNR_tonP_gooddur)>2
                        %                     colorp='b';
                        %                 else
                        %                     colorp='r';
                        %                 end
                        if iperceptdirection==1
                            colorp='r';
                        else
                            colorp='b';
                        end
                        
                        tmp = plotSNR_tonP_gooddur(itrace).data;
                        
                        stErr = std(tmp,1)/(sqrt(clist));
                        %
                        toplot = squeeze(mean(tmp,1));
                        
                        
                        if smoothing==1
                            toplot=smooth(toplot);
                        end
                        
                        to_np(itrace)=shadedErrorBar(x, toplot, stErr,[linet colorp], 1);
                        % xlim([-plotlims plotlims])
                        hold on
                        
                        if size(toplot,1)>size(toplot,2)
                            toplot=toplot';
                        end
                        
                        
                        
                        %                         if iday==1
                        %                             if strcmp(attendcond,'on')
                        
                        %                                 try allplotsfor_groupA.day(iday).allplots_to_pf1=allplots_to_pf1;
                        
                        %                                 allplotsfor_groupA.day(iday).allplots_to_pf1=allplots_to_pf1;
                        %                                 allplotsfor_groupA.day(iday).allplots_to_pf2=allplots_to_pf2;
                        % %                             else
                        %
                        %                                 allplotsfor_groupnA.day(iday).allplots_to_pf1=allplots_to_pf1;
                        %                                 allplotsfor_groupnA.day(iday).allplots_to_pf2=allplots_to_pf2;
                        %                             end
                        %                         else %second day
                        %                             if strcmp(attendcond,'on')
                        %                                 allplotsfor_groupnA.day(iday).allplots_to_pf1=allplots_to_pf1;
                        %                                 allplotsfor_groupnA.day(iday).allplots_to_pf2=allplots_to_pf2;
                        %                             else
                        %
                        %                                 allplotsfor_groupA.day(iday).allplots_to_pf1=allplots_to_pf1;
                        %                                 allplotsfor_groupA.day(iday).allplots_to_pf2=allplots_to_pf2;
                        %                             end
                        %                         end
                        
                        switch iperceptdirection %save individual traces for averaging across participants.
                            case 1 %pf2-> pf1 %reversed as we are plotting non-congruent Percept trace
                                %                         'pf2->pf1';
                                switch itrace
                                    case 1
                                        try allplots_to_pf1.f2data = [allplots_to_pf1.f2data; toplot];
                                        catch
                                            allplots_to_pf1.f2data = [ toplot];
                                        end
                                    case 2
                                        try allplots_to_pf1.twof2data = [allplots_to_pf1.twof2data; toplot];
                                        catch
                                            allplots_to_pf1.twof2data = [ toplot];
                                        end
                                end
                                
                            case 2        %pf1->pf2
                                switch itrace
                                    case 1
                                        try allplots_to_pf2.f1data = [allplots_to_pf2.f1data; toplot];
                                        catch
                                            allplots_to_pf2.f1data = [ toplot];
                                        end
                                    case 2
                                        
                                        try allplots_to_pf2.twof1data = [allplots_to_pf2.twof1data; toplot];
                                        catch
                                            allplots_to_pf2.twof1data = [ toplot];
                                        end
                                    case 3
                                        try allplots_to_pf2.threef1data = [allplots_to_pf2.threef1data; toplot];
                                        catch
                                            allplots_to_pf2.threef1data = [ toplot];
                                        end
                                end
                                
                        end
                        
                        
                    end
                    
                    
                    axis tight
                    %%
                    ylabel('SNR', 'fontsize', fontsize)
                    xlabel('time(sec)', 'fontsize', fontsize)
                    %                     ylim([ylimsat]);
                    
                    plot([0 0], ylim, ['k' ':'])
                    plot(xlim, [0 0], ['k' ':'])
                    yl=get(gca, 'Ytick');
                    
                    text(0.1, yl(1)+.2, 'ButtonPress', 'fontsize', fontsize)
                    title({['Day ' num2str(iday) ' ( ' num2str(attendcond) ')'];[ 'SNR and stErr for ' num2str(perceptdirection) ' when percept >' num2str(plotswitchesdur) ' (s)'];[' nswitches = ' num2str(clist) ]}, 'fontsize', fontsize);
                    set(gca, 'fontsize', fontsize)
                    if plotbestcomparison==0
                        if iperceptdirection==1 %pf2-pf1, therefore extra lowhz at toP
                            leg= legend([to_p(1).mainLine, to_p(2).mainLine to_p(3).mainLine to_np(1).mainLine to_np(2).mainLine], {'Vf1' '2Vf1' '3Vf1' 'Vf2' '2Vf2'});
                        else
                            leg= legend([to_np(1).mainLine, to_np(2).mainLine to_np(3).mainLine to_p(1).mainLine to_p(2).mainLine], {'Vf1' '2Vf1' '3Vf1' 'Vf2' '2Vf2'});
                        end
                    else
                        
                        if iperceptdirection==1 %pf2-pf1, therefore extra lowhz at toP
                            leg= legend([to_p(1).mainLine, to_np(1).mainLine ], {'Vf1'  'Vf2' });
                        else
                            leg= legend([ to_np(1).mainLine to_p(1).mainLine ], {'Vf1' 'Vf2' });
                        end
                        
                    end
                    
                    set(leg, 'Location', 'SouthWest', 'fontsize', fontsize);
                    
                    
                    %%
                    
                    cd(pathtoEpocheddataEXP)
                    try cd('BinocularRivalrySwitchSNR')
                    catch
                        mkdir('BinocularRivalrySwitchSNR');
                        cd('BinocularRivalrySwitchSNR')
                    end
                    try cd(ppantfol.name)
                    catch
                        mkdir(ppantfol.name);
                        cd(ppantfol.name)
                    end
                    
                    
                    
                    
                    if smoothing==1
                        printfilename = (['Ppant ' num2str(ppantIN) '_' num2str(initials) ', Day' num2str(iday) ', (' num2str(attendcond) ') BPress aligned SNR, ' num2str(basesubtract) 's brem,, at chan ' ichan ' for switches >' num2str(plotswitchesdur) '(smoothed).png']);
                    else
                        printfilename = (['Ppant ' num2str(ppantIN) '_' num2str(initials) ', Day' num2str(iday) ', (' num2str(attendcond) ') BPress aligned SNR, ' num2str(basesubtract) 's brem, at chan ' ichan ' for switches >' num2str(plotswitchesdur) '.png']);
                    end
                    
                    set(gcf, 'Name', printfilename, 'color', 'w')
                    
                     print('-dpng', [num2str(perceptdirection) ' ' printfilename])
                    % clf
                    %                 cd ../
                end
                
                
                if iday==1
                    if strcmp(attendcond,'Attending') %first day and attending.
                        try
                            allplotsfor_groupA.day(1).allplots_to_pf1=[allplotsfor_groupA.day(1).allplots_to_pf1; allplots_to_pf1];
                            allplotsfor_groupA.day(1).allplots_to_pf2=[allplotsfor_groupA.day(1).allplots_to_pf2; allplots_to_pf2];
                        catch
                            allplotsfor_groupA.day(1).allplots_to_pf1=allplots_to_pf1;
                            allplotsfor_groupA.day(1).allplots_to_pf2=allplots_to_pf2;
                        end
                    else %first day but not attending
                        
                        try
                            allplotsfor_groupnA.day(1).allplots_to_pf1=[allplotsfor_groupnA.day(1).allplots_to_pf1; allplots_to_pf1];
                            allplotsfor_groupnA.day(1).allplots_to_pf2=[allplotsfor_groupnA.day(1).allplots_to_pf2; allplots_to_pf2];
                        catch
                            allplotsfor_groupnA.day(1).allplots_to_pf1=allplots_to_pf1;
                            allplotsfor_groupnA.day(1).allplots_to_pf2=allplots_to_pf2;
                            
                        end
                    end
                        
                else %we're on the second day.
                    if strcmp(attendcond,'Attending') %SECOND day and attending.
                        try
                            allplotsfor_groupnA.day(2).allplots_to_pf1=[allplotsfor_groupnA.day(2).allplots_to_pf1; allplots_to_pf1];
                            allplotsfor_groupnA.day(2).allplots_to_pf2=[allplotsfor_groupnA.day(2).allplots_to_pf2; allplots_to_pf2];
                        catch
                            allplotsfor_groupnA.day(2).allplots_to_pf1=allplots_to_pf1;
                            allplotsfor_groupnA.day(2).allplots_to_pf2=allplots_to_pf2;
                        end
                    else %SeCOND day but NOT attending.
                        
                        try
                            allplotsfor_groupA.day(2).allplots_to_pf1=[allplotsfor_groupA.day(2).allplots_to_pf1; allplots_to_pf1];
                            allplotsfor_groupA.day(2).allplots_to_pf2=[allplotsfor_groupA.day(2).allplots_to_pf2; allplots_to_pf2];
                        catch
                            allplotsfor_groupA.day(2).allplots_to_pf1=allplots_to_pf1;
                            allplotsfor_groupA.day(2).allplots_to_pf2=allplots_to_pf2;
                            
                        end
                    end
                end
                
                
            end
        end
        
        
        %%
        cd(pathtoEpocheddataEXP)
        %
        cd('AcrossAll')
        savename=['allBRswitchactivity_' num2str(basesubtract) 's_brem_' num2str(ichan) ',switch duration > ' num2str(plotswitchesdur) 's'];
        save(savename, 'allplotsfor_groupA', 'allplotsfor_groupnA', 'smoothing', 'times')
    end
    
    %%
    if job.plotAcrossALLSwitchActivity_sepDaysandGroups
        cd(pathtoEpocheddataEXP)
        %%
        cd('AcrossAll')
        load(['allBRswitchactivity_' num2str(basesubtract) 's_brem_' num2str(ichan) ',switch duration > ' num2str(plotswitchesdur) 's'])
        cd('BRswitchactivity')
        %%
        
        for iday=1:2
            for igroup=1:2
                switch igroup
                    case 1 % groupA
                        if iday==1
                            attendcond='Attending';
                            
                        else
                            attendcond='non-Attending';
                        end
                        useData= allplotsfor_groupA.day(iday);
                    case 2 %group nA
                        if iday==1
                            attendcond='non-Attending';
                        else
                            attendcond='Attending';
                        end
                        useData= allplotsfor_groupnA.day(iday);
                end
                
                for iperceptdirection = 1:2
                    
                    plotSNR_toP_gooddur=[];
                    plotSNR_tonP_gooddur=[];
                    %%
                    switch iperceptdirection
                        case 1 %pf2-> pf1
                            perceptdirection = 'pf2->pf1';
                            if plotbestcomparison==0
                                
                                for ippant=1:size(useData.allplots_to_pf1,1)
                                    
                                    plotSNR_toP_gooddur(1).data(ippant,:) = useData.allplots_to_pf1(ippant).f1data;
                                    plotSNR_toP_gooddur(2).data(ippant,:) = useData.allplots_to_pf1(ippant).twof1data;
                                    plotSNR_toP_gooddur(3).data(ippant,:) = useData.allplots_to_pf1(ippant).threef1data;
                                    
                                    plotSNR_tonP_gooddur(1).data(ippant,:) = useData.allplots_to_pf1(ippant).f2data;
                                    plotSNR_tonP_gooddur(2).data(ippant,:) = useData.allplots_to_pf1(ippant).twof2data;
                                end
                            else
                                
                                for ippant=1:size(useData.allplots_to_pf1,1)
                                    
                                    plotSNR_toP_gooddur(1).data(ippant,:) = useData.allplots_to_pf1(ippant).f1data;
                                    
                                    plotSNR_tonP_gooddur(1).data(ippant,:) = useData.allplots_to_pf1(ippant).f2data;
                                end
                                
                                
                            end
                            
                            
                        case 2
                            perceptdirection = 'pf1->pf2';
                            if plotbestcomparison==0
                                for ippant=1:size(useData.allplots_to_pf1,1)
                                    plotSNR_tonP_gooddur(1).data(ippant,:) = useData.allplots_to_pf2(ippant).f1data;
                                    plotSNR_tonP_gooddur(2).data(ippant,:) = useData.allplots_to_pf2(ippant).twof1data;
                                    plotSNR_tonP_gooddur(3).data(ippant,:) = useData.allplots_to_pf2(ippant).threef1data;
                                    
                                    plotSNR_toP_gooddur(1).data(ippant,:) = useData.allplots_to_pf2(ippant).f2data;
                                    plotSNR_toP_gooddur(2).data(ippant,:) = useData.allplots_to_pf2(ippant).twof2data;
                                end
                            else
                                for ippant=1:size(useData.allplots_to_pf1,1)
                                    plotSNR_toP_gooddur(1).data(ippant,:) = useData.allplots_to_pf2(ippant).f2data;
                                    
                                    plotSNR_tonP_gooddur(1).data(ippant,:) = useData.allplots_to_pf2(ippant).f1data;
                                end
                            end
                            
                            
                    end
                    clist=size(plotSNR_toP_gooddur(1).data,1);
                    %%
                    clf
                    x=times - epochlength(2);
                    
                    for itrace = 1:length(plotSNR_toP_gooddur)
                        switch itrace
                            case 1
                                linet='-';
                            case 2
                                linet='-.';
                            case 3
                                linet = ':';
                        end
                        %         if length(plotSNR_toP_gooddur)>2
                        %             colorp='b';
                        %         else
                        %             colorp='r';
                        %         end
                        %
                        if iperceptdirection==1
                            colorp='b';
                        else
                            colorp='r';
                        end
                        
                        tmp = plotSNR_toP_gooddur(itrace).data;
                        
                        stErr = std(tmp,1)/(sqrt(clist));
                        %
                        toplot = mean(tmp,1);
                        
                        
                        if smoothing==1
                            toplot=smooth(toplot);
                        end
                        
                        to_p(itrace)=shadedErrorBar(x, toplot, stErr,[linet colorp], 1);
                        % xlim([-plotlims plotlims])
                        hold on
                        
                        
                        
                    end
                    
                    % plot opposite trace
                    for itrace = 1:2%length(plotSNR_tonP_gooddur)
                        switch itrace
                            case 1
                                linet='-';
                            case 2
                                linet='-.';
                            case 3
                                linet = ':';
                        end
                        %         if length(plotSNR_tonP_gooddur)>2
                        %             colorp='b';
                        %         else
                        %             colorp='r';
                        %         end
                        
                        if iperceptdirection==1
                            colorp='r';
                        else
                            colorp='b';
                        end
                        
                        tmp = plotSNR_tonP_gooddur(itrace).data;
                        
                        stErr = std(tmp,1)/(sqrt(clist));
                        %
                        toplot = mean(tmp,1);
                        
                        
                        if smoothing==1
                            toplot=smooth(toplot);
                        end
                        
                        to_np(itrace)=shadedErrorBar(x, toplot, stErr,[linet colorp], 1);
                        % xlim([-plotlims plotlims])
                        hold on
                        
                    end
                    
                    
                    axis tight
                    %%
                    ylabel('SNR', 'fontsize', fontsize)
                    xlabel('time(sec)', 'fontsize', fontsize)
                    if basesubtract==1 
                    ylim([-2 2]);
                    end
                    plot([0 0], ylim, ['k' ':'])
                    plot(xlim, [0 0], ['k' ':'])
                    text(0.1, -1.8, 'ButtonPress', 'fontsize', fontsize)
                    
                    title({['Day ' num2str(iday) ' (' num2str(attendcond) '), SNR for ' num2str(perceptdirection) ' when percept >' num2str(plotswitchesdur) ' (s)'];[' n = ' num2str(clist) ]}, 'fontsize', fontsize);
                    %%
                    if plotbestcomparison==0
                        
                        if iperceptdirection==1 %pf2-pf1, therefore extra lowhz at toP
                            leg= legend([to_p(1).mainLine, to_p(2).mainLine  to_np(1).mainLine to_np(2).mainLine], {'Vf1' '2Vf1'  'Vf2' '2Vf2'});
                        else
                            leg= legend([to_np(1).mainLine, to_np(2).mainLine  to_p(1).mainLine to_p(2).mainLine], {'Vf1' '2Vf1'  'Vf2' '2Vf2'});
                        end
                    else
                        
                        
                        if iperceptdirection==1 %pf2-pf1, therefore extra lowhz at toP
                            leg= legend([to_p(1).mainLine, to_np(1).mainLine ], {'Vf1' 'Vf2' });
                        else
                            leg= legend([to_np(1).mainLine, to_p(1).mainLine], { 'Vf1' 'Vf2' });
                        end
                    end
                    set(leg, 'Location', 'SouthWest', 'fontsize', fontsize);
                    
                    if smoothing==1
                        printfilename = (['Day ' num2str(iday) ', ' num2str(attendcond) ', AcrossALL,  BPress aligned SNR, ' num2str(basesubtract) 's brem, at chan ' ichan ' for switches >' num2str(plotswitchesdur) '(smoothed).png']);
                    else
                        printfilename = (['Day ' num2str(iday) ', ' num2str(attendcond) ', AcrossALL, BPress aligned SNR, ' num2str(basesubtract) 's brem, at chan' ichan ' for switches >' num2str(plotswitchesdur) '.png']);
                    end
                    
                    set(gcf, 'Name', printfilename, 'color', 'w')
                    set(gca, 'fontsize', fontsize)
                    %%
                    print('-dpng',[ num2str(perceptdirection) ' ' printfilename])
                    % clf
                end
            end
        end
    end
    
    
    %%
    if job.plotAcrossALLSwitchActivity_alltogetherbyAttendcondition
        
        cd(pathtoEpocheddataEXP)
        %%
        cd('AcrossAll')
        load(['allBRswitchactivity_' num2str(basesubtract) 's_brem_' num2str(ichan) ',switch duration > ' num2str(plotswitchesdur) 's'])
        cd('BRswitchactivity')
        %%
        
        
        allAttend=[];
        allnAttend=[];
        %for each percept direction, concatenate structures.
        allAttend.allplots_to_pf1=[allplotsfor_groupA.day(1).allplots_to_pf1; allplotsfor_groupnA.day(2).allplots_to_pf1];
        allAttend.allplots_to_pf2=[allplotsfor_groupA.day(1).allplots_to_pf2; allplotsfor_groupnA.day(2).allplots_to_pf2];
        
        
        allnAttend.allplots_to_pf1=[allplotsfor_groupA.day(2).allplots_to_pf1; allplotsfor_groupnA.day(1).allplots_to_pf1];
        allnAttend.allplots_to_pf2=[allplotsfor_groupA.day(2).allplots_to_pf2; allplotsfor_groupnA.day(1).allplots_to_pf2];
        for iAttendcond=1:2
            switch iAttendcond
                case 1
                    useData=allAttend;
                    attendcond='Attending';
                case 2
                    useData=allnAttend;
                    attendcond= 'non-attending';
                    
            end
            for iperceptdirection = 1:2
                
                plotSNR_toP_gooddur=[];
                plotSNR_tonP_gooddur=[];
                
                %need to concatenate across both groups/days
                
                switch iperceptdirection
                        case 1 %pf2-> pf1
                            perceptdirection = 'pf2->pf1';
                            if plotbestcomparison==0
                                
                                for ippant=1:size(useData.allplots_to_pf1,1)
                                    
                                    plotSNR_toP_gooddur(1).data(ippant,:) = useData.allplots_to_pf1(ippant).f1data;
                                    plotSNR_toP_gooddur(2).data(ippant,:) = useData.allplots_to_pf1(ippant).twof1data;
                                    plotSNR_toP_gooddur(3).data(ippant,:) = useData.allplots_to_pf1(ippant).threef1data;
                                    
                                    plotSNR_tonP_gooddur(1).data(ippant,:) = useData.allplots_to_pf1(ippant).f2data;
                                    plotSNR_tonP_gooddur(2).data(ippant,:) = useData.allplots_to_pf1(ippant).twof2data;
                                end
                            else
                                
                                for ippant=1:size(useData.allplots_to_pf1,1)
                                    
                                    plotSNR_toP_gooddur(1).data(ippant,:) = useData.allplots_to_pf1(ippant).f1data;
                                    
                                    plotSNR_tonP_gooddur(1).data(ippant,:) = useData.allplots_to_pf1(ippant).f2data;
                                end
                                
                                
                            end
                            
                            
                        case 2
                            perceptdirection = 'pf1->pf2';
                            if plotbestcomparison==0
                                for ippant=1:size(useData.allplots_to_pf1,1)
                                    plotSNR_tonP_gooddur(1).data(ippant,:) = useData.allplots_to_pf2(ippant).f1data;
                                    plotSNR_tonP_gooddur(2).data(ippant,:) = useData.allplots_to_pf2(ippant).twof1data;
                                    plotSNR_tonP_gooddur(3).data(ippant,:) = useData.allplots_to_pf2(ippant).threef1data;
                                    
                                    plotSNR_toP_gooddur(1).data(ippant,:) = useData.allplots_to_pf2(ippant).f2data;
                                    plotSNR_toP_gooddur(2).data(ippant,:) = useData.allplots_to_pf2(ippant).twof2data;
                                end
                            else
                                for ippant=1:size(useData.allplots_to_pf1,1)
                                    plotSNR_toP_gooddur(1).data(ippant,:) = useData.allplots_to_pf2(ippant).f2data;
                                    
                                    plotSNR_tonP_gooddur(1).data(ippant,:) = useData.allplots_to_pf2(ippant).f1data;
                                end
                            end
                            
                            
                    end
                clist=size(useData.allplots_to_pf1,1);
                %%
                clf
                x=times - epochlength(2);
                %% plot how many harmonics? (just one for f1 and 2f1)
                if iperceptdirection==1 
                    ntraces=2;
                else
                    ntraces=1;
                end
                    
                for itrace = 1:ntraces% length(plotSNR_toP_gooddur)
                    switch itrace
                        case 1
                            linet='-';
                        case 2
                            linet='-.';
                        case 3
                            linet = ':';
                    end
                    %         if length(plotSNR_toP_gooddur)>2
                    %             colorp='b';
                    %         else
                    %             colorp='r';
                    %         end
                    %
                    if iperceptdirection==1
                        colorp='b';
                    else
                        colorp='r';
                    end
                    
                    tmp = plotSNR_toP_gooddur(itrace).data;
                    
                    stErr = std(tmp,1)/(sqrt(clist));
                    %
                    toplot = mean(tmp,1);
                    
                    
                    if smoothing==1
                        toplot=smooth(toplot);
                    end
                    
                    to_p(itrace)=shadedErrorBar(x, toplot, stErr,[linet colorp], 1);
                    % xlim([-plotlims plotlims])
                    hold on
                    
                    
                    
                end
                
                % plot opposite trace
                for itrace = 1:ntraces%length(plotSNR_tonP_gooddur)
                    switch itrace
                        case 1
                            linet='-';
                        case 2
                            linet='-.';
                        case 3
                            linet = ':';
                    end
                    %         if length(plotSNR_tonP_gooddur)>2
                    %             colorp='b';
                    %         else
                    %             colorp='r';
                    %         end
                    
                    if iperceptdirection==1
                        colorp='r';
                    else
                        colorp='b';
                    end
                    
                    tmp = plotSNR_tonP_gooddur(itrace).data;
                    
                    stErr = std(tmp,1)/(sqrt(clist));
                    %
                    toplot = mean(tmp,1);
                    
                    
                    if smoothing==1
                        toplot=smooth(toplot);
                    end
                    
                    to_np(itrace)=shadedErrorBar(x, toplot, stErr,[linet colorp], 1);
                    % xlim([-plotlims plotlims])
                    hold on
                    
                end
                
                
                axis tight
                %%
                ylabel('SNR', 'fontsize', fontsize)
                xlabel('time(sec)', 'fontsize', fontsize)
                 if basesubtract~=0
                ylim([-2 2]);
                 end
                plot([0 0], ylim, ['k' ':'])
                plot(xlim, [0 0], ['k' ':'])
                text(0.1, -1.8, 'ButtonPress', 'fontsize', fontsize)
                
                title({['When ' num2str(attendcond) ' to tones' ] ;['SNR for ' num2str(perceptdirection) ' when percept >' num2str(plotswitchesdur) ' (s)'];[' n = ' num2str(clist) ', at ' num2str(ichan)]}, 'fontsize', fontsize);
                %%
                if plotbestcomparison==0
                    
                    if iperceptdirection==1 %pf2-pf1, therefore extra lowhz at toP
                        
                            leg= legend([to_p(1).mainLine, to_np(1).mainLine ], {'Vf1' 'Vf2' });                        
%                             leg= legend([to_p(1).mainLine, to_p(2).mainLine to_np(1).mainLine to_np(2).mainLine], {'Vf1' '2Vf1' 'Vf2' '2Vf2'});
                        
                    else
                                                  leg= legend([to_p(1).mainLine, to_np(1).mainLine ], {'Vf2' 'Vf1' });                        

%                             leg= legend([to_np(1).mainLine, to_np(2).mainLine  to_p(1).mainLine to_p(2).mainLine], {'Vf1' '2Vf1' 'Vf2' '2Vf2'});
                      
                    end
                else
                    
                    
                    if iperceptdirection==1 %pf2-pf1, therefore extra lowhz at toP
                        leg= legend([to_p(1).mainLine, to_np(1).mainLine ], {'Vf1' 'Vf2' });
                    else
                        leg= legend([to_np(1).mainLine, to_p(1).mainLine], { 'Vf1' 'Vf2' });
                    end
                end
                set(leg, 'Location', 'SouthWest', 'fontsize', fontsize);
                
                if smoothing==1
                    printfilename = ([num2str(attendcond) ' to tones, Across both days, BPress aligned SNR, ' num2str(basesubtract) 's brem, at chan ' ichan ' for switches >' num2str(plotswitchesdur) '(smoothed).png']);
                else
                    printfilename = ([num2str(attendcond) ' to tones, Across both days, BPress aligned SNR, ' num2str(basesubtract) 's brem, at chan' ichan ' for switches >' num2str(plotswitchesdur) '.png']);
                end
                
                set(gcf, 'Name', printfilename, 'color', 'w')
                set(gca, 'fontsize', fontsize)
                %%
                print('-dpng',[ num2str(perceptdirection) ' ' printfilename])
                % clf
            end
        end
    end
    
    
    
    
end

