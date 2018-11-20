% clearvars -except f DOMppant
try cd('/Users/MattDavidson/Desktop/XM_Project/ANOVAdata_allppants')
    addpath('/Users/MattDavidson/Documents/MATLAB/Crossmodal_BinocularRivalry')
    addpath('/Users/MattDavidson/Documents/MATLAB/Crossmodal_BinocularRivalry-Supportfiles')
catch
    cd('/Users/MatthewDavidson/Desktop/XMODAL/ANOVAdata_allppants')
    addpath(genpath('/Users/MatthewDavidson/Documents/Github'));
end
basedir=pwd;

dbstop if error
%%
%%%%%
%current save based on:
params.tapers = [1 1];
params.Fs = 60; %bound by frame rate of computer
% params.fpass = [0 30];
lowpassValues = 0; %change to zero for raw RT output, 1 to low pass.
lowpassis = 20; %hz
detrendValues=0;
%which time window to inspect (in sec)?


timewin = [1/params.Fs 10]; %2.6s is average duration of tones. 2s is minimum attended
t=timewin(1):(1/params.Fs):timewin(2); % we had a maximum of 4second tones.

%%
fftwin1=0.5;
fftwin2=2;
fontsize =15;
nshuff=5000;

useMEDsplit =0; % for reviewers sanity check.

useProportionperPPANT=1;

iperiod=1; % change to 2 for post stim offset, 3 for nextSW (within XMODonly.).4 for next sw(could include offset of tone)

%%%% plotting.
job.plotall=0;
job.plotCumulativeSwitchProb=0;
% loads based on the datatype indicated above
%%

%%%%
usenew=1;

getDatanames;
goodppants =1:34;

if useMEDsplit==1    
    %load 
    cd('/Users/MattDavidson/Desktop/XM_Project/DATA_newhope/figs')
    load('REBUTTAL,ppantsbyDOMDURation.mat');    
 rankedID=orderedIndex;
% note that ppant order in this data type is alphabetic:
% so can use numbers as above.
goodppants = rankedID(1:17); % top half.
% goodppants = rankedID(18:34); % bottom half, base don Mean DOmDURS.
end




%%
if job.plotall==1
    %%
    figure(14)
    clf
    %preallocate vars
    plotwas=[];
    plotsav1=[];
    plotsav2=[];    
    legend1is={};  %[
    legend2is={};  %[
    meanspec = [];
    
    useSherrBar=0;    
    plotdatatype = [101,102,103];
    combineabove = 0;
    specstash=[];
    d_forshuff = zeros(length(plotdatatype), length(goodppants),length(t)) ; % need this for shuff analysis when combining types.
    comb_d=[]; %vector for rough sum of all types.
    
    legendson=0; %0 = off
    
    %% new code for CV figures
    printCVdistribution=1;
    %%
    
    bar3p5acrosscues= zeros(8,1);
    bar8acrosscues = zeros(8,1);
figure(1); clf  
ppantSPECS=[];
    for numplot =   1:length(plotdatatype)

    %%
        switch numplot%ixmod
            case 1
                colis='m';
            case 2           
                
                colis='b';
                                
            case 3
                colis=[[ .5 .5 .5]];

        end
        
        if useMEDsplit==1
            
            %load
            cd('/Users/MattDavidson/Desktop/XM_Project/DATA_newhope/figs')
            load('REBUTTAL,ppantsbyDOMDURation.mat');
            
            rankedID=orderedIndex;
            
            % note that ppant order in this data type is alphabetic:
            % so can use numbers as above.
            switch numplot
                case 1
            goodppants = rankedID(1:17); % top half.
                case 2
            goodppants = rankedID(18:34); % bottom half, base don Mean DOmDURS.
            colis=[.5 .5 .5];
            end
            
        iplot=plotdatatype(1);
        
        else
        iplot= plotdatatype(numplot);
        end
        
        
        
        %bounds for fft.
        [~, t1]= min(abs(t-fftwin1));
        [~, t2]= min(abs(t-fftwin2));
        
        
        
        cd(basedir)
        InphaseData=[];
        OutofphaseData=[];
        
        lname=Datanames(iplot).name;
        
        if usenew==1
            lname = ['new' lname];
        end
        
        load(lname, 'InphaseData', 'OutofphaseData')
        % Pool all ppant RTs.
        %all ppant RTs (for histogram)
        allPpantRTsSep=[];
        allPpantRTsTogether=[];
        allPpantOverallspikes=[];
        
        for ippant = 1:length(goodppants)
            useppant = goodppants(ippant);
            pRTs=[];
            pRTs = [InphaseData.allRTs{:,useppant}, OutofphaseData.allRTs{:,useppant}];
%or use single XMOD.
% pRTs = [InphaseData.allRTs{ixmod,useppant}, OutofphaseData.allRTs{ixmod,useppant}];
            allPpantRTsSep(ippant).RTs = pRTs;
            idall=[];
            allPpantRTsTogether = [allPpantRTsTogether, pRTs];
            %create vector of binneddata.
            spikes = zeros(1,length(t));
            for i=1:length(pRTs)
                %RT
                vtime = double(pRTs(i));
                if ~isnan(vtime)
                    id=[];
                    %                     id=find(t==vtime);
                    [~,id] = min(abs(round(t,3)-round(vtime,3)));
                    %add to the vector each time this RTappears, per ppant.
                    idall=[idall,id];
                    if id==1
                        %                             error('arer')
                    end
                    spikes(id) = spikes(id)+1;
                end
            end
            
            if useProportionperPPANT==1
                spikes = spikes./nansum(spikes);
            end
            allPpantOverallspikes(ippant,:) = spikes;
            
        end
        
%         for plotppant=1:34
            figure(1)
%             clf
        medianswitchpoint = median(allPpantRTsTogether);
%         d=allPpantOverallspikes(plotppant,:);

        %construct sampling trace:
                d=allPpantOverallspikes;
        d_forshuff(numplot,:,1:length(d)) = d;        

        if useProportionperPPANT==1
            d = squeeze(nanmean(d,1));
        else
            d = squeeze(nansum(d,1));
        end%
        
        
        if combineabove==1
            comb_d = [comb_d;d]; %add together: plot together.
            if useProportionperPPANT==0
            d= nansum(comb_d,1);
            else
                d= nanmean(comb_d,1);
            end
        end

        lstyle= '-';
        lwidth=5;
        %           plot(t,(d))
        hold on
        %
        
        if usefftaboutmedswitchpoint==1
            [~, t1]= min(abs(t-(medianswitchpoint-.75)));
            [~, t2]= min(abs(t-(medianswitchpoint+.75)));
            %             [~, t1]= min(abs(t-(0)));
            % [~, t2]= min(abs(t-(2*medianswitchpoint)));
        else
            
            [~, t1]= min(abs(t-(fftwin1)));
            [~, t2]= min(abs(t-(fftwin2)));
        end
        
        
if iplot
            makeShuffled_durplot; % shuffled likelihood for sig tests.
end
            %%
            figure(1)
            hold on

            set(gcf,'visible', 'on')

            if printCVdistribution~=1
                subplot(1,2,1)
            else
                subplot(3,1,1)
            end
                hold on

            set(gca, 'fontsize', 30)

            legend1is = [legend1is  {[Datanames(iplot).nameSimple]}];
            legend2is = [legend2is  {[Datanames(iplot).nameSimple]}];
            %     clf
            
            if iplot ==9 || iplot ==99
                colis= [ .2 .2 .2]; %grey for no stim.
            end
            
            if numplot%==8 % skip if we just want to plot spec output.
            
            if iplot==9  %flip in time.
                
                plotwas(numplot)=plot(t*-1, d, 'linestyle', lstyle, 'color', colis, 'linew', 1); hold on
                plotwas(numplot)=plot(t*-1,((smooth(d))),'linewidth', 6, 'linestyle', lstyle,'color', colis);
                hold on
                plotsav1 = [plotsav1 plotwas(numplot)];
                ylimsare = get(gca, 'ylim');
                %         pch=patch([-2*medianswitchpoint -2*medianswitchpoint 0 0], [0 ylimsare(2)  ylimsare(2) 0], [.3 .3 .3]) ;
                pch=patch([-t(t2) -t(t2) -t(t1) -t(t1) ], [0 ylimsare(2)  ylimsare(2) 0], [.6 .6 .6]) ;
                %         pmed=plot([-1.*medianswitchpoint -1.*medianswitchpoint], ylim, ['k-'], 'linewidth', 3) ;
                
                if legendson==1
                lg=legend([plotsav1 pmed], [legendis, {'median switch point'}]);
                lg1=legend([plotsav1 ], [legend1is]);
                set(lg1,'Location', 'NorthWest', 'fontsize', fontsize)
                end
                pch.FaceAlpha = .15;
                axis tight
                xlim([ -2.5 0])
                xlabel('Time before cue onset [sec]')
            else
                if useSherrBar==0
                plotwas(numplot)=plot(t,(((d))),'linewidth', 1, 'linestyle', lstyle, 'color', colis);
                hold on
                linew2=6;%                     
                plotwas(numplot)=plot(t,((smooth(d))),'linewidth', linew2, 'linestyle', lstyle, 'color', colis);
                else %plot shaded Error bar version.
                    
                    for linew=[1,3]
                        
                        if linew==1
                     stE= std(allPpantOverallspikes)./sqrt(size(allPpantOverallspikes,1));
                     
                    tmp=shadedErrorBar(t, d, stE,[],1);
                    tmp.LineWidth=linew;
                    tmp.LineStyle=lstyle;
                    tmp.mainLine.Color=colis;
                    tmp.patch.FaceColor=colis;
                    tmp.edge(1).Color=colis;
                    tmp.edge(2).Color=colis;
                    plotwas(numplot)=tmp.mainLine;
                        else

%                 plotwas(numplot)=plot(t,((smooth(d))),'linewidth', linew, 'linestyle', lstyle, 'color', colis);
                        end
                
                    end
                    end
                
                plotsav1 = [plotsav1 plotwas(numplot)];
                ylimsare=get(gca, 'ylim');
                %         if numplot==2
                pch=patch([t(t1) t(t1) t(t2) t(t2)], [0 ylimsare(2)+10  ylimsare(2)+10 0], [.6 .6 .6]) ;
                %         end
                % pch=patch([t(t1) t(t1) t(t2) t(t2)], [0 .02  .02 0], [.6 .6 .6]) ;
                pch.FaceAlpha = .15;
                axis tight
                if usefftaboutmedswitchpoint==1
                    pmed=plot([medianswitchpoint medianswitchpoint], ylim, ['k-'], 'linewidth', 3) ;
                    if legendson==1
                        lg1=legend([plotsav1 pmed], [legend1is 'median switch point']);
                            set(lg1,'Location', 'NorthEast', 'fontsize', fontsize)
                    end
                else
                    if legendson==1
                        lg1=legend([plotsav1], [legend1is]);
                        lg1=legend([plotwas(numplot)], [Datanames(iplot).nameSimple] );
                        lg1=legend([plotwas(numplot)], ['All post cue onset'] );
                            set(lg1,'Location', 'NorthEast', 'fontsize', fontsize)
                    end
                end
                
                
                
                xlim([ 0 2.5])

                % axis tight
                ylim([ 0 max(d)])
                ylim([ 0 .013])
%                 ylim([ 0 3])
            end
            % xlim([0 2.5])
            
            %         ylabel({['nswitch count / (all switch) [#]']}, 'fontsize', 15)
            if useProportionperPPANT==1
            ylabel({['Proportion of '];['1st switches']}, 'fontsize', fontsize)
            else
                ylabel({['Perceptual switches [#]']}, 'fontsize', fontsize)
            
            end
            %         xlabel({['\bf\color{red} High \rm\color{black}to \bf\color{blue}Low \rm\color{black}switch after cue [sec]']}, 'fontsize', 15)
            %         xlabel({['switch time relative to cue onset [sec]']}, 'fontsize', fontsize)
            
            switch iplot
                case {1  101}
            xlabel({['Time after mismatched cue [secs]']})
                case {2 102}
                    xlabel({['Time after matched cue [secs]']})
                case 9
                    xlabel({['Time before cue onset [secs]']})
                case 99
                    xlabel({['Time after cue offset [secs]']})
                case 999
                    xlabel(['Time during visual only cue period'])
            end
                    
            set(gca, 'fontsize', fontsize*1.5)
%             set(gca, 'fontsize', fontsize*2)
            
            end
        
            
            
            
            
            if printCVdistribution~=1
                subplot(1,2,2)
            else
                subplot(3,1,2)
            end
            figure(1);
                hold on
            
            %%
            if numplot%==8  %|| numplot==4
                hold on
                
                    %plot observed spectrum:
                    [s,f] = mtspectrumc((d(t1:t2)), params);
                    sCV=s;
                    
                    if numplot==1
                        linewidthuse=6;
                    else
                        linewidthuse=3;
                    end
                       
                    
                    plotwas(numplot)=plot(f,sCV, 'linewidth', linewidthuse, 'color', colis, 'linestyle', lstyle);
%                     meanspec(iplot,:)=s;
                    % also plot sig cutoff:
                    pal1=plot(f,(p_cutoffALLfreqs.uncorr005), [':'],'color', colis, 'linewidth', 3);

                    hold on
                    
                    specstash(numplot,:)= sCV;
                    xlim([0 30])
                    set(gca, 'xtick', 0:1:30, 'xticklabelrotation', 0)
                    %         set(gca, 'xtick', 2:1:30, 'xticklabelrotation', -60)
                    xlabel('Hz')
                    ylabel({['spectral amplitude of'];['1st switches']})
                    hold on
              
                    hold on

                    [~, id3p5] = min(abs(f-3.5));
                    [~, id8] = min(abs(f-8));
                    %store for bar chart
                    bar3p5acrosscues(numplot)=s(id3p5);
                    bar8acrosscues(numplot)=s(id8);
                    
                    
                    
                if legendson==1
                lg2=legend([plotsav2], [legend2is  ]);
                % lg2=legend([plotsav2(1) plotsav2(3) ], [{'2nd switch Crossmodal Match'} {'2nd switch Crossmodal Mismatch' }]);
                 set(lg2, 'fontsize', fontsize*1.5)
                end
                %
                set(gca, 'fontsize', fontsize*2)
                
                %
                xlim([1 15])
                if useMEDsplit==1
                    ytop=.0000008;
                end
                %%
                ytop=14*10^-7;
                ytop=5*10^-7;
                
                ylim([ 0 ytop])
%                                 ylim([ 0 .05])
            end
            %%
            set(gcf, 'color', 'w')
%           set(gca, 'fontsize', fontsize*2)
          set(gca, 'fontsize', fontsize*1.5)            
%           set(gca, 'fontsize', fontsize*2)            
shg

            try cd('/Users/mattdavidson/Desktop')
            catch
                cd('/Users/matthewdavidson/Desktop')
            end
% try cd('/Users/mattdavidson/Desktop/ppantSAMPLING')
% catch
%     cd('/Users/matthewdavidson/Desktop/ppantSAMPLING')
% end
% set(gcf, 'color', 'w')
% print('-dpng', 'specx3')
% print('-dpng', ['figure' num2str(plotppant) ' match'])
% print('-dpng', ['figure ' num2str(iplot)])
%  print('-dpng', ['figure DOMhighnew -mismatch'])
% print('-dpng', ['figure DOMsep -match'])
    




% ppantSPECS(plotppant,numplot,:)=sCV; 
        
%     end %plotppant
        
        
    end
    shg
end
%%
% try    cd('/Users/MattDavidson/Desktop/XM_Project/ANOVAdata_allppants/Combined_acrossXMODs')
% catch
%       cd('/Users/MatthewDavidson/Desktop/XMODAL/ANOVAdata_allppants/Combined_acrossXMODs')
% end
%    save('allProbabilities_forcorrelation(attn,hz,nppants).mat', 'ppantSPECS', 'f', '-append');
% figure(3)




% clf
% subplot(211)
% bh=bar([bar3p5acrosscues]);
% subplot(212)
% bh=bar([bar8acrosscues]);
% %% %% custom combos (ignore cue-opposite ITPC)
% CUEt=[];
% counter=1;
% iplot=[1, 3,5,7];
% for i=[1:8] ;% att/natt, high low
%     ind= i ;
%     
% %     CUEt(counter,:) = [bar3p5acrosscues(i,:), bar8acrosscues(i+1,:)];
% CUEt(counter,:) = [bar3p5acrosscues(i,:), bar8acrosscues(i,:)];
%     counter=counter+1;
% end
% %%
% figure(4)
% clf
% bh=bar(CUEt');
% linewidbar=2;
% linestbar='-.';
% % Attending Low dark green
% bh(1).FaceColor=[0 .4 0];  bh(1).EdgeColor='m'; bh(1).LineStyle=linestbar; bh(1).LineWidth=linewidbar; 
% hold on
% bh(2).FaceColor=[0 .4 0]; bh(2).EdgeColor='b'; bh(2).LineStyle=linestbar;bh(2).LineWidth=linewidbar; 
% % Ignoring Low light green
% bh(3).FaceColor=[.4 .7 .4]; bh(3).EdgeColor='m'; bh(3).LineStyle=linestbar;bh(3).LineWidth=linewidbar;
% bh(4).FaceColor=[.4 .7 .4];  bh(4).EdgeColor='b'; bh(4).LineStyle=linestbar;bh(4).LineWidth=linewidbar;
% 
% % Attending High Dark Red.
% bh(5).FaceColor=[.8 0 0];  bh(5).EdgeColor='m';bh(5).LineStyle=linestbar; bh(5).LineWidth=linewidbar;
% bh(6).FaceColor=[.8 0 0];  bh(6).EdgeColor='b'; bh(6).LineStyle=linestbar;bh(6).LineWidth=linewidbar;
% % Ignoring High light red 
% bh(7).FaceColor=[1 .7 .7]; bh(7).EdgeColor='m';bh(7).LineStyle=linestbar; bh(7).LineWidth=linewidbar;
% bh(8).FaceColor=[1 .7 .7]; bh(8).EdgeColor='b'; bh(8).LineStyle=linestbar;bh(8).LineWidth=linewidbar;
% shg
% %%
% 
% %
% set(gca, 'xticklabel', {['3.5Hz '],['8Hz ']})
% ylabel('spectral amplitude')
% plot([.60 1.5], [.73 .73], ['k:'],'marker','o', 'linew', 2)
% plot([1.5 2.4], [.71 .71], ['b:o' ], 'linew', 2)
% % legend('Attending Low', 'IgnoringLow', 'Attending High', 'Ignoring High', 'q=.005@ 3.5Hz', 'q=.005@ 8Hz')
% lg=legend('Attending Low Mismatch', 'Attending Low Match', ...
%     'Ignoring Low Mism', 'Ignoring Low Match', ...
%     'Attending High Mism', 'Attending High Match',...
%     'Ignoring High Mismatch', 'Ignoring High Match', 'p<.005@ 3.5Hz', 'p<.005@ 8Hz')
% set(lg, 'Location', 'southoutside')
% set(gcf, 'color', 'w')
% set(gca, 'fontsize', 15)
%%
if job.plotCumulativeSwitchProb==1
    %%
    plotwas=[];
%     plotdatatype = [1:8];
%     plotdatatype = [101];
%     plotdatatype=[101,102,103]; %attending low vs vis
    plotdatatype=[108,109,103]; %106,107,108,109,103]; %  all other cues.
    
    %limit time window for CDF
    x1=0; %seconds
    x2=10; %seconds
    
    combineabove = 0;
    d_forshuff = zeros(length(plotdatatype), length(goodppants),length(t)) ; % need this for shuff analysis when combining types.
    comb_d=[]; %vector for rough sum of all types.
    adjustforlowtrialnum=0;
    legendson=0; %0 = off
    
    % new code for CV
    printCVdistribution=0 ;
    %
    tmp2=[];
    bar3p5acrosscues= zeros(8,1);
    bar8acrosscues = zeros(8,1);
    
    fontsize=15;
    
    figure(1)
    clf
    legendprint=[];
    for numplot =   1:length(plotdatatype)
        
        switch numplot
            case 1
             colis='m';
            case 2
                colis='b';                                
            case 3
                colis=[[ .5 .5 .5]];

            case 4
                colis = ['r'];
            case 5
                colis = 'm';
            case 6
                colis = [.2 .6 .2];
        end
        
%         if mod(numplot,2)~=0
%             colis='m';
%         else
%             colis ='b';
%         end
%         if numplot==7
%             colis = [.5 .5 .5];
%         end
            
            
        iplot = plotdatatype(numplot);
        
        %bounds for fft.
        [~, t1]= min(abs(t-fftwin1));
        [~, t2]= min(abs(t-fftwin2));
        
        
        
        cd(basedir)
        InphaseData=[];
        OutofphaseData=[];
        
        lname=Datanames(iplot).name;
        
        if usenew==1
            lname = ['new' lname];
        end
        
        load(lname)
        % Pool all ppant RTs.
        %all ppant RTs (for histogram)
        allPpantRTsSep=[];
        allPpantRTsTogether=[];
        allPpantOverallspikes=[];
        
        for ippant = 1:length(goodppants)
            useppant = goodppants(ippant);
            pRTs=[];
            pRTs = [InphaseData.allRTs{:,useppant}, OutofphaseData.allRTs{:,useppant}];
            allPpantRTsSep(ippant).RTs = pRTs;
            idall=[];
            allPpantRTsTogether = [allPpantRTsTogether, pRTs];
            %create vector of binneddata.
            spikes = zeros(1,length(t));
            for i=1:length(pRTs)
                %RT
                vtime = double(pRTs(i));
                if ~isnan(vtime)
                    id=[];
                    %                     id=find(t==vtime);
                    [~,id] = min(abs(round(t,3)-round(vtime,3)));
                    %add to the vector each time this RTappears, per ppant.
                    idall=[idall,id];
                    if id==1
                        %                             error('arer')
                    end
                    spikes(id) = spikes(id)+1;
                end
            end
            
            
            allPpantOverallspikes(ippant,:) = spikes;
            
        end
        
%         for plotppant=1:34
            if numplot==1
                figure(1); clf
            end
        medianswitchpoint = median(allPpantRTsTogether);
%         d=allPpantOverallspikes(plotppant,:);

        
                d=allPpantOverallspikes;
        d_forshuff(numplot,:,:) = d;
        
        d = squeeze(nansum(d,1)); %sum over ppants
        
        
        if combineabove==1
            comb_d = [comb_d;d]; %add together: plot together.
            d= nansum(comb_d,1);
        end
        
        if adjustforlowtrialnum==1 %account for mismatched numbers of trialdurs.
            for ip = 1:2
                switch ip
                    case 1
                        tmulti= [2*60:1:3.1*60+1];
                        m_amount = 4/3;
                    case 2
                        tmulti= [3.1*60+1:1:4*60];
                        m_amount = 3;
                end
                
                d(tmulti) = d(tmulti).*m_amount;
            end
        end
        
        
        
        
        
        
        %%%        %divide by total number of of RTs (cumm.freq per spiketrain).
        if iplot~=111 || iplot~=133
            % d= d./length(allPpantRTsTogether);
        end
        
        %%%     normalize values for plotting purposes.
        %             d= (d- min(d))./ (max(d) - min(d));
        
        lstyle= '-';
        lwidth=5;
        %           plot(t,(d))
        
        hold on
        %
        
        if usefftaboutmedswitchpoint==1
            [~, t1]= min(abs(t-(medianswitchpoint-.75)));
            [~, t2]= min(abs(t-(medianswitchpoint+.75)));
            %             [~, t1]= min(abs(t-(0)));
            % [~, t2]= min(abs(t-(2*medianswitchpoint)));
        else
            
            [~, t1]= min(abs(t-(fftwin1)));
            [~, t2]= min(abs(t-(fftwin2)));
        end
        
        %%%%%% END of data prep, now we plot etc.
        
        %now plot.        
        acrossPPecdf=[];
        figure(1);
        hold on
        
        for ippant= 1:34            
         tmp=allPpantRTsSep(ippant).RTs;
        %restrict if necessary.
         tmp(tmp<x1)=nan;
        tmp(tmp>x2)=nan;
        
        
        %plotperppant
        subplot(5,7,ippant)
        hold on;
       H=cdfplot(tmp);
H.LineWidth=2;
       H.Color=colis;
title(['participant ' num2str(ippant)])
xlabel('Time after cue onset [s]');
    ylabel(['cdf']);
 
    
    
    %also attempt to store plot function, in same sized vectors, for shaded
    %error bar plots across sub.
    
    [yy,xx,~,~,~] = cdfcalc(tmp);
    %create vectors for easy storage/plotting (taken from within cdfplot.m)
    k = length(xx);
    n = reshape(repmat(1:k, 2, 1), 2*k, 1);
    xCDF    = [-Inf; xx(n); Inf];
    yCDF    = [0; 0; yy(1+n)];
    
    %now xCDF = the timepoints where steps occur. yCDF = step size. So now
    %we fill a nantrain with the appropriate points.
    
    
     %create vector of cdf data.
            spikes = zeros(1,length(t));
            for i=2:length(xCDF)-1
                %RT
                vtime = double(xCDF(i));
                if ~isnan(vtime)
                    id=[];
                    %                     id=find(t==vtime);
                    [~,id] = min(abs(round(t,3)-round(vtime,3)));
                    
                    %add this timepoint, and step in CDF
                    spikes(id) = yCDF(i);
                end
            end
            
            %now, replace 'gaps', to equate step size
            for i=2:length(spikes)
                if spikes(i)==0
                    spikes(i)=spikes(i-1);
                end
            end
                     
            %store for later plots
            %because we have differnt numbers of switches per participants, the length
            %of vectors will not be equal.
            acrossPPecdf(ippant,:)=spikes;
        end
  
    set(gcf, 'color', 'w')
    
    
    % now plot across all summary
    
    
    if numplot==1
                figure(2); clf
    end
    figure(2); hold on;
    
    for isub=2%1:2
%     subplot(1,2,1)
    hold on
    switch isub
        case 1 %across all accumulative.
        tmp=allPpantRTsTogether;
        %restrict if necessary.
         tmp(tmp<x1)=nan;
        tmp(tmp>x2)=nan;

        H=cdfplot(tmp);        
H.LineWidth=2;
H.Color=colis;
title('summed Across all')
        case 2 % plotting mean with errorbars across all.
      mplot=mean(acrossPPecdf,1);      
      X=acrossPPecdf;
      pmean=  mean(acrossPPecdf,2);
      Gmean=mean(pmean);      
      newX= X - repmat(pmean, [1,size(X,2)]) + repmat(Gmean, [size(X,1), size(X,2)]);

      stE=std(newX)./sqrt(34);
        sh=shadedErrorBar(t, mplot, stE,[],0);
        sh.mainLine.Color=colis;
        sh.patch.FaceColor=colis;
        sh.edge(1).Color=colis;
        sh.edge(2).Color=colis;
        
        xlim([x1 x2])
        ylim([0 1])
%         title('participant M and SEM');
        
        legendprint=[legendprint, sh.patch];
    end
        xlabel('Time after cue onset [s]');
        ylabel({['CDF, 1st switch']});
        set(gca, 'fontsize', fontsize)
        
        
    end
    
    tmp2(numplot,:,:)=acrossPPecdf;
    end
    
    set(gcf, 'color', 'w')
    
    if numplot==1
                figure(3); clf
    end
    %
    figure(2); hold on;    
    subplot(1,2,2)
    hold on
    % include the errorbars.
    for ip=1:numplot
        
        
        plotme=squeeze([tmp2(ip,:,:)-tmp2(numplot,:,:)]); %mismatch - visual
        
        %set color:
        if mod(ip,2)~=0
            colis='m';
        else
            colis ='b';
        end
        if ip==7
            colis = [.5 .5 .5];
        end
      mplot=mean(plotme,1);      
      X=plotme;
      pmean=  mean(plotme,2);
      Gmean=mean(pmean);      
      newX= X - repmat(pmean, [1,size(X,2)]) + repmat(Gmean, [size(X,1), size(X,2)]);

      stE=std(newX)./sqrt(34);
        sh=shadedErrorBar(t, mplot, stE,[],1);
        sh.mainLine.Color=colis;
        sh.patch.FaceColor=colis;
        sh.edge(1).Color=colis;
        sh.edge(2).Color=colis;
        
%         ttestdata(ip,:,:)=plotme;
    end
    
    % also place legend
%     subplot(1,2,1);
    lg=legend(legendprint, {'Mismatch', 'Match', 'Visual only'});
    set(lg, 'Location', 'Southeast', 'fontsize', 30)
    
    
    %%
        %perform ttest over time.
        h1=[];
        h2=[];
        p1=[]; p2=[];
        for it=1:size(ttestdata,3);
            [h1(it),p1(it)]=ttest(squeeze(ttestdata(1,:,it)), 0);
            
            [h2(it),p2(it)]=ttest(squeeze(ttestdata(2,:,it)), 0);
        end
        %%
        
        q1=fdr(p1,.05);
        q2=fdr(p2,.05);
        hkeep1=find(p1<q1);
        hkeep2=find(p2<q2);
        
        hold on
        plot(xlim, [0 0], ['-'],'linew', 4, 'color', [.5 .5 .5])
        %%
        for isig=1:2
            switch isig
                case 1
                    h=hkeep1;
                    heightp=.1;
                    col='m';
                case 2
                    h=hkeep2;
                    heightp= -.1;
                    col='b';
                    
            end
%         pstamps=h;
%         pstamps(pstamps<.01)=nan;
%         pstamps(pstamps>0)=heightp;
%         h = find(mod(1:length(h), 10)==0);
%         % reduce size of plot vector.
        tmp=1:length(h);
        for ip=1:length(h)
            if mod(h(ip),10)==0
        plot(t(h(ip)),heightp, '*', 'color', col, 'markersize', 15)
            end
        end
        end
        
        pch=patch([0.5 0.5 2 2 ], [-.2 .2  .2 -.2], [.6 .6 .6]) ;
        alpha(0.25)
        
        xlabel('Time after cue onset [s]');
        ylabel({['\DeltaCDF, 1st switch']});
        set(gca, 'fontsize', 30)
     ylim([-.11 .11])   
     
try      cd('/Users/matthewdavidson/Desktop')
catch
        cd('/Users/mattdavidson/Desktop')
end
    print('-dpng', 'all other CDF ab');
     %
    %now save the CDF data
    
% try     cd('/Users/MattDavidson/Desktop/XM_Project/ANOVAdata_allppants/Combined_acrossXMODs')
% catch
%        cd('/Users/matthewdavidson/Desktop/XMODAL/ANOVAdata_allppants/Combined_acrossXMODs')
% end
% 
%     CDFbyALHztype= ttestdata;
%     
%     save('allProbabilities_forcorrelation(attn,hz,nppants).mat', 'CDFbyALHztype', 'f','-append')
%     
    
    
end