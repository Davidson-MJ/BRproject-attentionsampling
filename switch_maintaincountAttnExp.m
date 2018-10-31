function [dataout] = switch_maintaincountAttnExp(fromHIGHtoLOW_stimtype, fromLOWtoHIGH_stimtype, maintainedduringHIGH, maintainedduringLOW, ...
        failed_swHIGHtoLOW, failed_swLOWtoHIGH, Casetype, phaseis, num,  sanitycheckON)
dbstop if error
%% remove 0 values from indexing, in case from whole experiment level


maintainedduringHIGH(maintainedduringHIGH==0)=[];
maintainedduringLOW(maintainedduringLOW==0)=[];
fromHIGHtoLOW_stimtype(fromHIGHtoLOW_stimtype==0)=[];
fromLOWtoHIGH_stimtype(fromLOWtoHIGH_stimtype==0)=[];
failed_swHIGHtoLOW(failed_swHIGHtoLOW==0)=[];
failed_swLOWtoHIGH(failed_swLOWtoHIGH==0)=[];
%%
fontsize = 15;
% sanitycheckON=0;
%number of switches during stimulus presentation
totalInducedswitches = length(fromHIGHtoLOW_stimtype) + length(fromLOWtoHIGH_stimtype);
totalstimNOswitch = length(maintainedduringHIGH) + length(maintainedduringLOW) + length(failed_swHIGHtoLOW) + length(failed_swLOWtoHIGH);
totalMaintainedclean=length(maintainedduringHIGH) + length(maintainedduringLOW) ;
dataout=[];



%note we can compare to the proportion of events possible, 
compType=1;
% or to the total number of trials (Lunghi eal., 2014).
% compType=2;
% divDenom=3;





%%  First for comparing proportion of stimulus types which contained single evoked switches

sanitycheckON=0;

if sanitycheckON==1
     set(gcf, 'Visible', 'on')
     clf
end

subplot(2,2,1)

for istim = [1,82,83,84,92,93,94]
    
    datacount = length(find(fromHIGHtoLOW_stimtype==istim)) + length(find(fromLOWtoHIGH_stimtype==istim));
    pct = round(100*(datacount/totalInducedswitches));
    %         pct = (100*(datacount/totalInducedswitches));
    switch istim
        case 1
            visonly = pct;
        case 82
            low_short = pct;
        case 83
            low_medium = pct;
        case 84
            low_long = pct;
        case 92
            high_short = pct;
        case 93
            high_medium = pct;
        case 94
            high_long = pct;
            
    end
end

%
%
if sanitycheckON==1 %print results
bar([visonly, 0,0,0,0,0,0], 'FaceColor', [.5 .5 .5], 'BarWidth', 0.6)
hold on
bar([0,low_short, 0, 0, 0,0,0], 'FaceColor', [0 .75 1], 'BarWidth', 0.6 );
bar([0,0, low_medium, 0,0,0,0], 'FaceColor', [0 .75 1],'BarWidth', 0.6);
bar([0,0, 0, low_long, 0,0,0], 'FaceColor', [0 .75 1], 'BarWidth', 0.6);
bar([0,0, 0,0,high_short,0,0], 'FaceColor', [0.5 0 0], 'BarWidth', 0.6);
bar([0,0, 0,0,0,high_medium,0], 'FaceColor', [0.5 0 0], 'BarWidth', 0.6);
bar([0,0, 0,0,0,0,high_long], 'FaceColor', [0.5 0 0], 'BarWidth', 0.6);
ylim([0 100])

text(1, 90, [num2str(visonly) '%'], 'Fontsize', fontsize);
text(2, 90, [num2str(low_short) '%'], 'FontSize', fontsize);
text(3,90, [num2str(low_medium) '%'], 'FontSize', fontsize);
text(4,90, [num2str(low_long) '%'], 'FontSize', fontsize);
text(5,90, [num2str(high_short) '%'], 'FontSize', fontsize);
text(6,90, [num2str(high_medium) '%'], 'FontSize', fontsize);
text(7,90, [num2str(high_long) '%'], 'FontSize', fontsize);
%



set(gca, 'XTickLabel', {'Visonly' 'Low short' 'Low medium' 'Low long' 'High short' 'High medium' 'High long'}, 'fontSize', fontsize)
%

title(['Switches during ' num2str(Casetype) ' ' num2str(phaseis) ' stimulation by type, Nswitch=' num2str(totalInducedswitches)], 'FontSize', fontsize);
ylabel('%');
end

%  congruent breakdown low or high hz

for ihz = 1:2
    successfulsw=[];
    noswitch=[];
    switch ihz
        case 1
            for xmodaltype = 82:84
                successfulswtmp = length(find(fromHIGHtoLOW_stimtype==xmodaltype)); %ie x-modal stim was incongruent to percept
                noswitchtmp = length(find(maintainedduringHIGH==xmodaltype)) + length(find(failed_swHIGHtoLOW==xmodaltype));
                
                successfulsw=[successfulsw, successfulswtmp];
                noswitch = [noswitch, noswitchtmp];
            end
        case 2
            for xmodaltype=92:94
                successfulswtmp = length(find(fromLOWtoHIGH_stimtype==xmodaltype)); %successful switch when highhzinphase was presented
                noswitchtmp = length(find(maintainedduringLOW==xmodaltype)) + length(find(failed_swLOWtoHIGH==xmodaltype)); %no sw
                
                successfulsw=[successfulsw, successfulswtmp];
                noswitch = [noswitch, noswitchtmp];
            end
    end
    
    %prob = #event / #outcomes
    
    if compType==1
    probswXM= sum(successfulsw)/sum((successfulsw+noswitch));
    else
        probswXM= sum(successfulsw)/divDenom; % 6 low / high hz per trial.
    end
        if isnan(probswXM) %after 0/0
           probswXM=[0]; %not a fail per se, because never had the opportunity
        end
    switch ihz
        case 1
            dataout.prob_swXMtype_anyLowhz= probswXM;
            dataout.count_swXMtype_anyLowhz=successfulsw;
        case 2
            dataout.prob_swXMtype_anyHighhz= probswXM;
            dataout.count_swXMtype_anyHighhz=successfulsw;
    end
    
    
    
    
end

% now separate by duration.
for xmodaltype = [82,83,84, 92,93,94]
    
    switch xmodaltype
        case {82,83,84}
            
            successfulsw = length(find(fromHIGHtoLOW_stimtype==xmodaltype)); %ie x-modal stim was incongruent to percept
            noswitch = length(find(maintainedduringHIGH==xmodaltype)) + length(find(failed_swHIGHtoLOW==xmodaltype));
            
        case {92,93,94}
            
            successfulsw = length(find(fromLOWtoHIGH_stimtype==xmodaltype)); %successful switch when highhzinphase was presented
            noswitch = length(find(maintainedduringLOW==xmodaltype))+ length(find(failed_swLOWtoHIGH==xmodaltype)); %no sw
            
    end
    if compType==1
    %prob = #event / #outcomes
    probswXM= sum(successfulsw)/(sum(successfulsw+noswitch));
    else
        probswXM= sum(successfulsw)/divDenom;
    end
%         if isnan(probswXM) %after 0/0
%            probswXM=[0]; %not a fail per se, because never had the opportunity
%         end
    switch xmodaltype
        case 82
            dataout.prob_swXMtype_Lowhz_short= probswXM;
            dataout.count_swXMtype_Lowhz_short=successfulsw;
        case 83
            dataout.prob_swXMtype_Lowhz_medium= probswXM;
            dataout.count_swXMtype_Lowhz_medium=successfulsw;
        case 84
            dataout.prob_swXMtype_Lowhz_long= probswXM;
            dataout.count_swXMtype_Lowhz_long=successfulsw;
        case 92
            dataout.prob_swXMtype_Highhz_short= probswXM;
            dataout.count_swXMtype_Highhz_short=successfulsw;
        case 93
            dataout.prob_swXMtype_Highhz_medium= probswXM;
            dataout.count_swXMtype_Highhz_medium=successfulsw;
        case 94
            dataout.prob_swXMtype_Highhz_long= probswXM;
            dataout.count_swXMtype_Highhz_long=successfulsw;
            
            
    end
    
    
    
    
end

%%
%vis only periods are a special case. Count the
%switches/(switches+maint+ doubles);
successfulvisonlysw = length(find(fromHIGHtoLOW_stimtype==1)) + length(find(fromLOWtoHIGH_stimtype==1));

maintvis = length(find(maintainedduringLOW==1)) + length(find(maintainedduringHIGH==1));
failedvis= length(find(failed_swHIGHtoLOW==1)) + length(find(failed_swLOWtoHIGH==1));
if compType==1
    
probvisonly = successfulvisonlysw/ (successfulvisonlysw + maintvis + failedvis);
else
    probvisonly = successfulvisonlysw/ divDenom;
end

dataout.prob_switchVISonly = probvisonly;
%
if sanitycheckON==1
subplot(2,2,3)
bar([dataout.prob_swXMtype_anyLowhz, 0], 'FaceColor', [0 .75 1], 'BarWidth', 0.6 );
hold on
bar([ 0,          dataout.prob_swXMtype_anyHighhz], 'FaceColor', [1 .49 .31], 'BarWidth', 0.6);
plot(xlim, [probvisonly probvisonly], ['k' '-']);
%

ylim([0 1.05]);
%     text(1, .90, [num2str(probGOODswBOTHfreq)], 'FontSize', fontsize);
%     text(1, .70, ['(Nsw=' num2str(N_IN_IN) ')'], 'FontSize', fontsize);
%     text(2, .90, [num2str(probBADswBOTH)], 'FontSize', fontsize);
%     text(2, .70, ['(Nsw=' num2str(N_IN_OUT) ')'], 'FontSize', fontsize);
%



set(gca, 'XTickLabel', { 'All Low Hz tones' 'All High Hz tones'}, 'fontSize', fontsize)

% title({['Likelihood of switch when x-modal is incongruent to percept'];['At tone onset']}, 'fontsize', fontsize);
ylabel('Probability of switching');


%%
% first plot maintenance trials
subplot(2,2,2)

end

for istim = [1,82,83,84,92,93,94]
    
    datacount = length(find(maintainedduringHIGH ==istim)) + length(find(maintainedduringLOW==istim)); % find stim type during maintenance
    pct = round(100*(datacount/totalMaintainedclean)); %round up to see proportion of total maintenance type, due to stimtype
    %         pct = (100*(datacount/totalstimNOswitch));
    switch istim
        case 1
            visonly = pct;
        case 82
            low_short = pct;
        case 83
            low_medium = pct;
        case 84
            low_long = pct;
        case 92
            high_short = pct;
        case 93
            high_medium = pct;
        case 94
            high_long = pct;
            
    end
end


%
if sanitycheckON==1
bar([visonly, 0,0,0,0,0,0], 'FaceColor', [.5 .5 .5], 'BarWidth', 0.6)
hold on
bar([0,low_short, 0, 0, 0,0,0], 'FaceColor', [0 .75 1], 'BarWidth', 0.6 );
bar([0,0, low_medium, 0,0,0,0], 'FaceColor', [0 .75 1],'BarWidth', 0.6);
bar([0,0, 0, low_long, 0,0,0], 'FaceColor', [0 .75 1], 'BarWidth', 0.6);
bar([0,0, 0,0,high_short,0,0], 'FaceColor', [0.5 0 0], 'BarWidth', 0.6);
bar([0,0, 0,0,0,high_medium,0], 'FaceColor', [0.5 0 0], 'BarWidth', 0.6);
bar([0,0, 0,0,0,0,high_long], 'FaceColor', [0.5 0 0], 'BarWidth', 0.6);
ylim([0 100])

text(1, 90, [num2str(visonly) '%'], 'Fontsize', fontsize);
text(2, 90, [num2str(low_short) '%'], 'FontSize', fontsize);
text(3,90, [num2str(low_medium) '%'], 'FontSize', fontsize);
text(4,90, [num2str(low_long) '%'], 'FontSize', fontsize);
text(5,90, [num2str(high_short) '%'], 'FontSize', fontsize);
text(6,90, [num2str(high_medium) '%'], 'FontSize', fontsize);
text(7,90, [num2str(high_long) '%'], 'FontSize', fontsize);
%



set(gca, 'XTickLabel', {'Visonly' 'Low short' 'Low medium' 'Low long' 'High short' 'High medium' 'High long'}, 'fontSize', fontsize)
%

% title(['Percept maintenance during ' num2str(Casetype) ' stimulation, Nmaint=' num2str(totalMaintainedclean)], 'FontSize', fontsize);
ylabel('%');


%%  congruent breakdown low and high hz for maintenance

% % %c
subplot(2,2,4)
%prob = #event / #outcomes

end
%  congruent breakdown low or high hz

for ihz = 1:2
    successfulmaintained =[];
    failedmaintained =[];
    switch ihz
        case 1
            for xmodaltype=[82:84]
                %for lowflickerinphase
                
                successfulmaintainedtmp = length(find(maintainedduringLOW==xmodaltype));
                failedmaintainedtmp = length(find(fromLOWtoHIGH_stimtype==xmodaltype)) + length(find(failed_swLOWtoHIGH==xmodaltype));
                
                successfulmaintained = [successfulmaintained, successfulmaintainedtmp];
                failedmaintained = [failedmaintained, failedmaintainedtmp];
                
            end
        case 2
            for xmodaltype=[92:94]
                
                successfulmaintainedtmp = length(find(maintainedduringHIGH==xmodaltype));
                failedmaintainedtmp = length(find(fromHIGHtoLOW_stimtype==xmodaltype))  + length(find(failed_swHIGHtoLOW==xmodaltype));
                
                successfulmaintained = [successfulmaintained, successfulmaintainedtmp];
                failedmaintained = [failedmaintained, failedmaintainedtmp];
            end
    end
    
    %prob = #event / #outcomes
    if compType==1
    probmaintXM= sum(successfulmaintained)/sum(successfulmaintained+failedmaintained);
    else
        probmaintXM= sum(successfulmaintained)/divDenom;
    end
    
    switch ihz
        case 1
            dataout.prob_maintXMtype_anyLowHz= probmaintXM;
            dataout.count_maintXMtype_anyLowHz=successfulmaintained;
        case 2
            dataout.prob_maintXMtype_anyHighHz= probmaintXM;
            dataout.count_maintXMtype_anyHighHz=successfulmaintained;
            
    end
end

for xmodaltype= [82,83,84,92,93,94]
    
    switch xmodaltype
        case {82,83,84}
            %for lowflickerinphase
            
            successfulmaintained = length(find(maintainedduringLOW==xmodaltype));
            failedmaintained = length(find(fromLOWtoHIGH_stimtype==xmodaltype));
            
            
            
        case {92,93,94}
            
            
            successfulmaintained = length(find(maintainedduringHIGH==xmodaltype));
            failedmaintained = length(find(fromHIGHtoLOW_stimtype==xmodaltype));
            
    end
    
    if compType==1
    %prob = #event / #outcomes
    probmaintXM= sum(successfulmaintained)/sum(successfulmaintained+failedmaintained);
    else
        probmaintXM= sum(successfulmaintained)/divDenom;
    end
    
%     if isnan(probmaintXM)
%         probmaintXM=0;
%     end
    switch xmodaltype
        case 82
            dataout.prob_maintXMtype_Lowhz_short= probmaintXM;
            dataout.count_maintXMtype_Lowhz_short=successfulmaintained;
        case 83
            dataout.prob_maintXMtype_Lowhz_medium= probmaintXM;
            dataout.count_maintXMtype_Lowhz_medium=successfulmaintained;
        case 84
            dataout.prob_maintXMtype_Lowhz_long= probmaintXM;
            dataout.count_maintXMtype_Lowhz_long=successfulmaintained;
        case 92
            dataout.prob_maintXMtype_Highhz_short= probmaintXM;
            dataout.count_maintXMtype_Highhz_short=successfulmaintained;
        case 93
            dataout.prob_maintXMtype_Highhz_medium= probmaintXM;
            dataout.count_maintXMtype_Highhz_medium=successfulmaintained;
        case 94
            dataout.prob_maintXMtype_Highhz_long= probmaintXM;
            dataout.count_maintXMtype_Highhz_long=successfulmaintained;
            
            
    end
end

%vis only periods are a special case, as no to/from distinction
if compType==1
probmaintvisonly = maintvis / (successfulvisonlysw + maintvis + failedvis);
else
    probmaintvisonly = maintvis / divDenom;
end
    dataout.prob_maintVISonly = probmaintvisonly;

if sanitycheckON==1
subplot(2,2,4)
bar([dataout.prob_maintXMtype_anyLowHz, 0], 'FaceColor', [0 .75 1], 'BarWidth', 0.6 );
hold on
bar([ 0, dataout.prob_maintXMtype_anyHighHz], 'FaceColor', [1 .49 .31], 'BarWidth', 0.6);
plot(xlim, [probmaintvisonly probmaintvisonly], ['k' '-']);
%
%
ylim([0 1.05]);

%%

set(gca, 'XTickLabel', {'All Low Hz tones' 'All High Hz tones'}, 'fontSize', fontsize)
% title({['Likelihood of maintaining when x-modal is congruent to percept'];['At tone onset']});
ylabel('Probability of maintaining');
% dataout
%

%%

% printfilename=['Block ' num2str(num) ' Switch Vs Maintenance, ' num2str(Casetype) ' ' num2str(phaseis)];

% print(gcf, '-dpng', printfilename);
end







