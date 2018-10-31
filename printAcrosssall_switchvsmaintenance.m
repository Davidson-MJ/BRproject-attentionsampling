% function printAcrosssall_switchvsmaintenance(pathtobehaviouraldata)
%%
%Note that this prints the averages for each cross-modal type, after first
%averaging within participant
pathtoBehaviouraldata='/Users/MattDavidson/Desktop/XM_Project/DATA_newhope';
cd(pathtoBehaviouraldata)
load('Acrossall_Prob_by(ppant,blocktype,attn,freq).mat')
%%

job.plotHzPhaseseparate=0;
job.plotHztogethervsLunghi=0;
job.plotPhasetogethervsLunghi=0;
job.plotCombinedacrossphaseandModality=1;
fontsize=20;
nppants=34;
if job.plotHzPhaseseparate==1



for plotme = 1 %switches then maintenance.
    switch plotme
        case 1
            databook = sw_dataProbabilities_AcrossALL;
            typeis = 'Switching to Congruent Percept';
            yvec=[.4 .8];
        case 2
            databook = maint_dataProbabilities_AcrossALL;
            typeis = 'Maintaining Congruent Percept';
            yvec=[.1 .7];
    end
       
    %     [nppants,ntypes,nattnd,nfreqs]= size(databook);
    %%
    for iattndcond = 1%:2
        
        switch iattndcond
            case 1
                condwas='while Attending to cross-modal stimulation';
            case 2
                condwas='while ignoring cross-modal stimulation';
        end
        
    datanow= squeeze(databook(:,:,iattndcond,:));
    
    % retain in phase and out of phase together
    bar_AnT_Low=datanow(:,1:2,1); %prob for low freq
    bar_AnT_High=datanow(:,1:2,2); %prob for high freq
    bar_AnT_vis=datanow(:,1:2,3); %prob for visual only  
    %
    bar_AUD_Low=datanow(:,3:4,1);
    bar_AUD_High=datanow(:,3:4,2);
    bar_AUD_vis=datanow(:,3:4,3); 
    
    
    bar_TAC_Low=datanow(:,5:6,1);
    bar_TAC_High=datanow(:,5:6,2);
    bar_TAC_vis=datanow(:,5:6,3); 
    
    % set up data for barplot.    
    m_bar = [[mean(nanmean(bar_AUD_vis,1)), nanmean(bar_AUD_Low,1), nanmean(bar_AUD_High,1)];...
        [mean(nanmean(bar_TAC_vis,1)), nanmean(bar_TAC_Low,1), nanmean(bar_TAC_High,1)];...
        [mean(nanmean(bar_AnT_vis,1)), nanmean(bar_AnT_Low,1), nanmean(bar_AnT_High,1)]];
    % %
    clf;
    set(gcf, 'visible', 'off')
    bhandle=bar(m_bar);
    
    
    % now plot error bars
    err_bar = [[nanmean(nanstd(bar_AUD_vis)./sqrt(nppants)), nanstd(bar_AUD_Low)./sqrt(nppants), nanstd(bar_AUD_High)./sqrt(nppants)];...
        [nanmean(nanstd(bar_TAC_vis)./sqrt(nppants)), nanstd(bar_TAC_Low)./sqrt(nppants), nanstd(bar_TAC_High)./sqrt(nppants)];...
        [nanmean(nanstd(bar_AnT_vis)./sqrt(nppants)), nanstd(bar_AnT_Low)./sqrt(nppants), nanstd(bar_AnT_High)./sqrt(nppants)]];
    %
    %%
    hold on
    numgroups = 3;
    numbars = 5; %per group
    groupwidth = min(0.8, numbars/(numbars+1.5));
    allxt = []; %save xlocations
    for i = 1:numbars
        % Based on barweb.m by Bolu Ajiboye from MATLAB File Exchange
        x = (1:numgroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*numbars);  % Aligning error bar with individual bar
        errorbar(x, m_bar(:,i), err_bar(:,i), 'k', 'linestyle', 'none');
        allxt = [allxt, x];
    end
    allxt = sort(allxt); %arrange ascending for plot.
    
    %% now plot if significant or not
    testdata = [[bar_AUD_Low(:,1)']; [bar_AUD_Low(:,2)']; [bar_AUD_High(:,1)']; [bar_AUD_High(:,2)'];...
        [bar_TAC_Low(:,1)'];[bar_TAC_Low(:,2)']; [bar_TAC_High(:,1)'];[bar_TAC_High(:,2)']; ...
        [bar_AnT_Low(:,1)'];[bar_AnT_Low(:,2)']; [bar_AnT_High(:,1)'];[bar_AnT_High(:,2)']];
    %%
    
    visAUD = mean(bar_AUD_vis,2);
    visTAC = mean(bar_TAC_vis,2);
    visAnT = mean(bar_AnT_vis,2);
    for itest=1:size(testdata,1)
    testme= testdata(itest,:);
    switch itest
        case {1 2 3 4}
            testagainst = visAUD';
        case {5 6 7 8}
            testagainst = visTAC';
        case {9 10 11 12}
            testagainst = visAnT';
    end
    
    [~,presult(itest)]=ttest(testme, testagainst, .05);
    end
    % correct for multiple comparisons
    threshq = fdr(presult, .000001);
    %
    presult(presult>threshq)=nan;
    presult(presult<=threshq)= (yvec(2)-.1);
    
    %% plot each if significant
    hold on
    plot(allxt(1,[2:5,7:10, 12:15]), presult, ['k' '*'], 'markersize', fontsize)
    % color the bar graph for interpretation
    %vis only
    
    bhandle(1).FaceColor= [.5 .5 .5]; %grey for vis only
    
    %ow Freq
    bhandle(2).FaceColor= [0 0 1];
    bhandle(3).FaceColor= [0 0 .5];
    
    %high Freq
    bhandle(4).FaceColor= [1 0 0];
    bhandle(5).FaceColor= [.5 0 0];
    
    %label 
    set(gca,'xticklabel', {'Auditory', 'Tactile', 'Auditory and Tactile'}, 'fontsize', fontsize)
    set(gca, 'fontsize', fontsize)
   lg= legend('Visual only', 'Low Hz In phase', 'Low Hz Antiphase', 'High Hz In phase', 'High Hz Antiphase', ['SE (N=' num2str(nppants) ')']);
    set(lg, 'location', 'northeast')
    ylim([yvec])
    ylabel(['Probability of ' num2str(typeis)], 'fontsize', fontsize)
    %%
    title({['Probability of ' num2str(typeis)];[condwas]}, 'fontsize', fontsize*1.5)
    xlabel('Cross-modal Stimulation type', 'fontsize', fontsize*1.5)
    cd('figs')
   cd('A_ProbabilityBargraphs')
   shg

   %%
    print('-dpng', ['Probability of ' typeis ' ' condwas  ])
%     shg
    cd(pathtoBehaviouraldata)
    end %attend
    %%
end %switch/maint
end

if job.plotHztogethervsLunghi==1
%% ALSO plot combined Hz case for comparison to Lunghi et al.
plotsinglevis=1; %change to zero if separating visonly conditions by modality

for plotme = 1:2 %switches then maintenance.
    switch plotme
        case 1
            databook = sw_dataProbabilities_AcrossALL;
            typeis = 'Switching to Congruent Percept';
            yvec=[.4 .7];
            col=[0, 1, 0];
        case 2
            databook = maint_dataProbabilities_AcrossALL;
            typeis = 'Maintaining Congruent Percept';
            yvec=[.1 .5];
            col=[1,.6,0];
    end
       
    %     [nppants,ntypes,nattnd,nfreqs]= size(databook);
    %%
    for iattndcond = 1:2
        
        switch iattndcond
            case 1
                condwas='while Attending to cross-modal stimulation';
            case 2
                condwas='while ignoring cross-modal stimulation';
        end
        
    datanow= squeeze(databook(:,:,iattndcond,:));
    
    % retain in phase and out of phase together
    
    % combine for this plot    
    bar_AnT=squeeze(datanow(:,1:2,1:2));
    bar_AnT_both=reshape(bar_AnT, [34,4]);
     
    
    
    bar_AUD=squeeze(datanow(:,3:4,1:2));
    bar_AUD_both =reshape(bar_AUD, [34,4]);
    
    
    
    bar_TAC=squeeze(datanow(:,5:6,1:2));
    bar_TAC_both=reshape(bar_TAC, [34,4]);
    
    
    
    
    bar_AnT_vis=datanow(:,1:2,3); 
    bar_AUD_vis=datanow(:,3:4,3); 
    bar_TAC_vis=datanow(:,5:6,3); 
    
    
    
    % set up data for barplot.    (single value for all modalities - comb
    % hz and phase).
    if plotsinglevis~=1
    m_bar = [[mean(nanmean(bar_AUD_vis,1)), mean(nanmean(bar_AUD_both,1))];...
        [mean(nanmean(bar_TAC_vis,1)), mean(nanmean(bar_TAC_both,1))];...
        [mean(nanmean(bar_AnT_vis,1)), mean(nanmean(bar_AnT_both,1))]];
    
    % now plot error bars
    err_bar = [[nanmean(nanstd(bar_AUD_vis)./sqrt(nppants)), nanmean(nanstd(bar_AUD_both)./sqrt(nppants))];...
        [nanmean(nanstd(bar_TAC_vis)./sqrt(nppants)), nanmean(nanstd(bar_TAC_both)./sqrt(nppants))];...
        [nanmean(nanstd(bar_AnT_vis)./sqrt(nppants)), nanmean(nanstd(bar_AnT_both)./sqrt(nppants))]];

    else
%     % %
%plot single visual horizontal bar to compare to Lunghi.
  m_bar = [[mean(nanmean(bar_AUD_both,1))];...
        [ mean(nanmean(bar_TAC_both,1))];...
        [ mean(nanmean(bar_AnT_both,1))]];
    
    
    err_bar = [[ nanmean(nanstd(bar_AUD_both)./sqrt(nppants))];...
        [ nanmean(nanstd(bar_TAC_both)./sqrt(nppants))];...
        [ nanmean(nanstd(bar_AnT_both)./sqrt(nppants))]];
    end
    % %
    clf;
    set(gcf, 'visible', 'off')
    bhandle=bar(m_bar, .5);
    
    
   
    %%
    hold on
    %
    if plotsinglevis~=1
    numgroups = 3;
    numbars = 2; %per group
    groupwidth = min(0.8, numbars/(numbars+1.5));
    allxt = []; %save xlocations
    for i = 1:numbars
        % Based on barweb.m by Bolu Ajiboye from MATLAB File Exchange
        x = (1:numgroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*numbars);  % Aligning error bar with individual bar
        errorbar(x, m_bar(:,i), err_bar(:,i), 'k', 'linestyle', 'none');
        allxt = [allxt, x];
    end
    allxt = sort(allxt); %arrange ascending for plot.
    else
        errorbar(1:3, m_bar, err_bar, 'k', 'linestyle', 'none');
    end
    %% now plot if significant or not
    testdata = [[mean(bar_AUD_both,2)']; [mean(bar_TAC_both,2)'];...
        [mean(bar_AnT_both,2)']]; 
    %%
    
    visAUD = mean(bar_AUD_vis,2);
    visTAC = mean(bar_TAC_vis,2);
    visAnT = mean(bar_AnT_vis,2);
    
    visall = mean([visAUD, visTAC, visAnT],2)';
    
    presult=[];
    for itest=1:size(testdata,1)
    testme= testdata(itest,:);
    switch itest
        case 1 
            if plotsinglevis~=1
            testagainst = visAUD';
            else
                testagainst = visall;
            end
        case 2
            if plotsinglevis~=1
            testagainst = visTAC';
            else
                testagainst = visall;
            end
        case 3
            if plotsinglevis~=1
            testagainst = visAnT';
            else
                testagainst = visall;
            end
    end
    
    [~,presult(itest)]=ttest(testme, testagainst, .05);
    end
    
    if plotsinglevis==1
        %%
        plot(xlim, [mean(visall) mean(visall)], 'color', [.5 .5 .5], 'linewidth', 5);
        
    end
    
    % correct for multiple comparisons
    threshq = fdr(presult, .05);
    %
    presult(presult>threshq)=nan;
    presult(presult<=threshq)= (yvec(2)-.05);
    
    %% plot each if significant
    hold on
    if plotsinglevis~=1
    plot(allxt(1,[2 4 6]), presult, ['k' '*'], 'markersize', fontsize)
    else
    plot(1:3, presult, ['k' '*'], 'markersize', fontsize)
    end
    if plotsinglevis~=1
    % color the bar graph for interpretation
    %vis only    
    bhandle(1).FaceColor= [.5 .5 .5]; %grey for vis only    
    %all in green
    bhandle(2).FaceColor= col;
    else
        bhandle(1).FaceColor= col;
    end
    
    
    %label 
    set(gca,'xticklabel', {'Auditory', 'Tactile', 'Auditory and Tactile'}, 'fontsize', fontsize)
    set(gca, 'fontsize', fontsize)
    if plotsinglevis~=1
   lg= legend('Visual only', 'Combined Hz and phase', ['SE (N=' num2str(nppants) ')']);
    else
        lg= legend('Combined Hz and phase', ['SE (N=' num2str(nppants) ')'], 'Visual only periods');
    end
    set(lg, 'location', 'southeast')
    ylim([yvec])
    ylabel(['Probability of ' num2str(typeis)], 'fontsize', fontsize)
    %%
    title({['Probability of ' num2str(typeis)];[condwas]}, 'fontsize', fontsize)
    xlabel('Cross-modal Stimulation type', 'fontsize', fontsize)
    cd('figs')
   cd('A_ProbabilityBargraphs')
   shg

   %%
    print('-dpng', ['Probability of ' typeis ' ' condwas   ' combining all to compare to Lunghi'])
%     shg
    cd(pathtoBehaviouraldata)
    end
    %%
end

end


if job.plotPhasetogethervsLunghi==1
%% ALSO plot combined Hz case for comparison to Lunghi et al.
plotsinglevis=0; %change to zero if separating visonly conditions by modality
figure(1)
clf
plotcount=1;
for plotme = 1:2 %switches then maintenance.
    
    switch plotme
        case 1
            databook = sw_dataProbabilities_AcrossALL;
            typeis = 'switching to congruent percept';
            yvec=[.4 .7];
            col=[0, 0, 1];
        case 2
            databook = maint_dataProbabilities_AcrossALL;
            typeis = 'maintaining congruent percept';
            yvec=[.1 .5];
            col=[1,0,0];
    end
       
    %     [nppants,ntypes,nattnd,nfreqs]= size(databook);
    %%
    for iattndcond = 1%:2
        subplot(2,2,plotcount)
        switch iattndcond
            case 1
                condwas='while Attending to cross-modal stimulation';
            case 2
                condwas='while ignoring cross-modal stimulation';
        end
        
    datanow= squeeze(databook(:,:,iattndcond,:));
    
    % retain in phase and out of phase together
    
    % combine for this plot    
    bar_AnT=squeeze(datanow(:,1:2,1:2));
%     bar_AnT_both=reshape(bar_AnT, [34,4]);
     bar_AnT_hz = squeeze(nanmean(bar_AnT,2));
    
    
    bar_AUD=squeeze(datanow(:,3:4,1:2));
%     bar_AUD_both =reshape(bar_AUD, [34,4]);
bar_AUD_hz = squeeze(nanmean(bar_AUD,2));
    
    
    
    bar_TAC=squeeze(datanow(:,5:6,1:2));
%     bar_TAC_both=reshape(bar_TAC, [34,4]);
bar_TAC_hz = squeeze(nanmean(bar_TAC,2));
    
    
    
    
    bar_AnT_vis=datanow(:,1:2,3); 
    bar_AUD_vis=datanow(:,3:4,3); 
    bar_TAC_vis=datanow(:,5:6,3); 
    
    
    
    % set up data for barplot.    (single value for all modalities - comb
    % hz and phase).
    if plotsinglevis~=1
    m_bar = [[mean(nanmean(bar_AUD_vis,1)), (nanmean(bar_AUD_hz,1))];...
        [mean(nanmean(bar_TAC_vis,1)), (nanmean(bar_TAC_hz,1))];...
        [mean(nanmean(bar_AnT_vis,1)), (nanmean(bar_AnT_hz,1))]];
    %organised visual low, high hz.
    
    % now plot error bars
    err_bar = [[mean(nanstd(bar_AUD_vis)./sqrt(nppants)), (nanstd(bar_AUD_hz)./sqrt(nppants))];...
        [mean(nanstd(bar_TAC_vis)./sqrt(nppants)), (nanstd(bar_TAC_hz)./sqrt(nppants))];...
        [mean(nanstd(bar_AnT_vis)./sqrt(nppants)), (nanstd(bar_AnT_hz)./sqrt(nppants))]];

    else
%     % %
%plot single visual horizontal bar to compare to Lunghi.
  m_bar = [[(nanmean(bar_AUD_hz,1))];...
        [ (nanmean(bar_TAC_hz,1))];...
        [ (nanmean(bar_AnT_hz,1))]];
    
    
    err_bar = [[ (nanstd(bar_AUD_hz)./sqrt(nppants))];...
        [ (nanstd(bar_TAC_hz)./sqrt(nppants))];...
        [ (nanstd(bar_AnT_hz)./sqrt(nppants))]];
    end
    % %
%     
%     set(gcf, 'visible', 'off')
    bhandle=bar(m_bar, .5);
    
    
   
    %%
    hold on
    %
    if plotsinglevis~=1
    numgroups = 3;
    numbars = 3; %per group
    groupwidth = min(0.8, numbars/(numbars+1.5));
    allxt = []; %save xlocations
    for i = 1:numbars
        % Based on barweb.m by Bolu Ajiboye from MATLAB File Exchange
        x = (1:numgroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*numbars);  % Aligning error bar with individual bar
        errorbar(x, m_bar(:,i), err_bar(:,i), 'k', 'linestyle', 'none');
        allxt = [allxt, x];
    end
    allxt = sort(allxt); %arrange ascending for plot.
    else
% %         errorbar(1:3, m_bar, err_bar, 'k', 'linestyle', 'none');
        errorbar(m_bar, err_bar, 'k', 'linestyle', 'none');
    end
    %% now plot if significant or not
%     testdata = [[mean(bar_AUD_hz,2)']; [mean(bar_TAC_hz,2)'];...
%         [mean(bar_AnT_hz,2)']]; 
    %%
    
    
    visAUD = mean(bar_AUD_vis,2);
    visTAC = mean(bar_TAC_vis,2);
    visAnT = mean(bar_AnT_vis,2);
    
    visall = mean([visAUD, visTAC, visAnT],2)';
    
    YData = [bar_AnT_hz(:,1);bar_AnT_hz(:,2);bar_AUD_hz(:,1);bar_AUD_hz(:,2);bar_AUD_hz(:,1);bar_AUD_hz(:,2); visall']
    
    YXMOD =[ ones(34,1); ones(34,1);ones(34,1)*2; ones(34,1)*2; ones(34,1)*3; ones(34,1)*3; ones(34,1)*4;]; 
    YHz= [ ones(34,1); 2*ones(34,1);ones(34,1); 2*ones(34,1); ones(34,1); 2*ones(34,1); ones(34,1)*3;]; 
    
    [p, atab]=anovan(YData, {YXMOD ,YHz}, 'display', 'off');
    
   
    
    
    if plotsinglevis==1
        %%
        plot(xlim, [mean(visall) mean(visall)], 'color', [.5 .5 .5], 'linewidth', 5);
        
    end
    
    % correct for multiple comparisons
    threshq = fdr(presult, .05);
    %
    presult(presult>threshq)=nan;
    presult(presult<=threshq)= (yvec(2)-.05);
    
    %% plot each if significant
    hold on
    if plotsinglevis~=1
    plot(allxt(1,[2 4 6]), presult, ['k' '*'], 'markersize', fontsize)
    else
    plot(1:3, presult, ['k' '*'], 'markersize', fontsize)
    end
    if plotsinglevis~=1
    % color the bar graph for interpretation
    %vis only    
    bhandle(1).FaceColor= [.5 .5 .5]; %grey for vis only    
    %all in green
    bhandle(2).FaceColor= [0,0,1];
    bhandle(3).FaceColor = [1,0,0];
    else
        bhandle(1).FaceColor= col;
    end
    
    bhandle(1).BarWidth = .9;
    %label 
    set(gca,'xticklabel', {'Auditory', 'Tactile', 'Auditory and Tactile'}, 'fontsize', fontsize)
    set(gca, 'fontsize', fontsize)
    if plotsinglevis~=1
   lg= legend('Visual only', 'Low Hz', 'High Hz',  ['SE (\itN \rm=' num2str(nppants) ')']);
    else
        lg= legend('Combined Hz and phase', ['SE (N=' num2str(nppants) ')'], 'Visual only periods');
    end
    set(lg, 'location', 'northeast')
%     ylim([yvec])
ylim([ 0 .9])
    ylabel(['Proportion of trials'], 'fontsize', fontsize)
    %%
%     title({['Probability of ' num2str(typeis)];[condwas]}, 'fontsize', fontsize)
title({['Proportion for ' num2str(typeis)];['over trial types']}, 'fontsize', fontsize)
    xlabel('Cross-modal Stimulation type', 'fontsize', fontsize)
    cd('figs')
   cd('A_ProbabilityBargraphs')
   shg
set(gca, 'fontsize', fontsize*1.5)

   %%
%     print('-dpng', ['Probability of ' typeis ' ' condwas   ' combining all to compare to Lunghi'])
    
%     shg
    cd(pathtoBehaviouraldata)
%     plotcount=plotcount+1;
    end
    %%
end
%%
set(gcf, 'color', 'w')
%%
print('-dpng', ['Probability of ' typeis ' ' condwas   ' combining all to compare to ASSC'])
end


if job.plotCombinedacrossphaseandModality==1
    
for plotme = 1%:2 %switches then maintenance.
    switch plotme
        case 1
            databook = sw_dataProbabilities_AcrossALL;
            typeis = 'Switching to Congruent Percept';
            yvec=[.4 .7];
            col=[0, 1, 0];
        case 2
            databook = maint_dataProbabilities_AcrossALL;
            typeis = 'Maintaining Congruent Percept';
            yvec=[.1 .5];
            col=[1,.6,0];
    end
       
    %     [nppants,ntypes,nattnd,nfreqs]= size(databook);
    %%
    
        
    datanow= squeeze(databook(:,:,:,:));
    
    %
%     [nppants, nxmodsXphase,LowHzHighhzVis] = dims datanow
    % For this plot, just keep Hz separate
    bar_Low=squeeze(nanmean(datanow(:,:,:,1),2));
    bar_High = squeeze(nanmean(datanow(:,:,:,2),2));
    bar_Vis = squeeze(nanmean(datanow(:,:,:,3),2));
    
%     % %
%plot single visual horizontal bar to compare to Lunghi.
%% first column is Attend, second is  Ignored xmodal.
m_bar = [nanmean(bar_Low(:,1)), nanmean(bar_High(:,1)), nanmean(bar_Vis(:,1));...
nanmean(bar_Low(:,2)), nanmean(bar_High(:,2)), nanmean(bar_Vis(:,2))];
    
    %also stErrmean for each.
    err_bar = [[(nanstd(bar_Low(:,1))./sqrt(nppants))],...
        [ (nanstd(bar_High(:,1))./sqrt(nppants))],...
        [(nanstd(bar_Vis(:,1))./sqrt(nppants))];...
        [(nanstd(bar_Low(:,2))./sqrt(nppants))],...
        [ (nanstd(bar_High(:,2))./sqrt(nppants))],...
        [(nanstd(bar_Vis(:,2))./sqrt(nppants))]];
    
    % %
    clf;
    set(gcf, 'visible', 'on')
    bhandle=bar(m_bar, .5);
    
   bhandle(1).FaceColor = [0 0 1];
   bhandle(2).FaceColor = [1 0 0];
   bhandle(3).FaceColor = [.5 .5 .5];
   
    %
    hold on
      numgroups = 2;
    numbars = 3; %per group
    groupwidth = min(0.8, numbars/(numbars+1.5));
    allxt = []; %save xlocations
    for i = 1:numbars
        % Based on barweb.m by Bolu Ajiboye from MATLAB File Exchange
        x = (1:numgroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*numbars);  % Aligning error bar with individual bar
        errorbar(x, m_bar(:,i), err_bar(:,i), 'k', 'linestyle', 'none');
        allxt = [allxt, x];
    end
    shg
    
    %% now plot if significant or not
    testdata = [bar_Low; bar_High;bar_Vis]; 
    
%     
%     
%     %% plot each if significant
%     hold on
%     if plotsinglevis~=1
%     plot(allxt(1,[2 4 6]), presult, ['k' '*'], 'markersize', fontsize)
%     else
%     plot(1:3, presult, ['k' '*'], 'markersize', fontsize)
%     end
%     if plotsinglevis~=1
%     % color the bar graph for interpretation
%     %vis only    
%     bhandle(1).FaceColor= [.5 .5 .5]; %grey for vis only    
%     %all in green
%     bhandle(2).FaceColor= col;
%     else
%         bhandle(1).FaceColor= col;
%     end
%     
%     
    %label 
    set(gca,'xticklabel', {'Low Freq', 'High Freq', 'Visual only'}, 'fontsize', fontsize)
    set(gca, 'fontsize', fontsize)
    
%     if plotsinglevis~=1
%    lg= legend('Visual only', 'Combined Hz and phase', ['SE (N=' num2str(nppants) ')']);
%     else
%         lg= legend('Combined Hz and phase', ['SE (N=' num2str(nppants) ')'], 'Visual only periods');
%     end
%     set(lg, 'location', 'southeast')
    ylim([yvec])
    ylabel(['Probability of ' num2str(typeis)], 'fontsize', fontsize)
    %%
    title({['Probability of ' num2str(typeis)];[condwas]}, 'fontsize', fontsize)
    xlabel('Cross-modal Stimulation type', 'fontsize', fontsize)
    cd('figs')
   cd('A_ProbabilityBargraphs')
   shg

   %%
    print('-dpng', ['Probability of ' typeis ' ' condwas   ' combining all to compare to Lunghi'])
%     shg
    cd(pathtoBehaviouraldata)
    
    %%
end

end