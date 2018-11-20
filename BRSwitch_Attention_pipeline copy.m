%% Behavioural analysis pipeline for button-press data
clear all
close all

job.individualanalysis=0; %plot individual congruent tracking and grouped tracking by day/type
job.newBlockbyBlockBatch=0; %calculate switch/maintenance trials per ppant.
%
% From here, working on replicating the results of Lunghi et al., JNS 2014.
%
job.calculateprobs_perppant=0; % calculate the probabilities of switch/maintenance based on trial counts above. 
job.printAcrossAll_switchvsMaintenance=0; %uses the probs first calculated at the participant level.
job.calcGaussandScatter=0;%plot individual histograms and scatter combined with ERP amp.
job.calcAttn_Sw_Scatter=0;
job.AdjustTriggerOnsetTimes=0; %intensive- locate physical onset of tones based on EEG channels and adjust frame delay in Button press data. Requires user input.
job.EpochSwitchesinBPdata=0; %epoch all switches and plot their timecourse in BP data.
% uses at the moment a 2second baseline subtraction, and channel POz.

%launch firstswitchpipeline
job.firstswitchpipeline_focus=0

sanitycheckON=0;

% set up directories.
% dataIn path
try cd('/Users/MattDavidson/Desktop/XM_Project')
    basedir=pwd;
    addpath([basedir filesep 'Task Program/Supportfor_newExp'])
catch
    cd('/Users/MatthewDavidson/Desktop/XMODAL')    
    addpath('/Users/matthewdavidson/Documents/GitHub/Crossmodal_BinocularRivalry-Supportfiles-master')
    addpath('/Users/matthewdavidson/Documents/GitHub/Crossmodal_BinocularRivalry-master')
end
basedir=pwd;
cd([basedir filesep 'DATA_newhope'])

pathtoBehaviouraldata=pwd;
%% 
%support paths.
addpath([basedir filesep 'EEGData/Analysis'])


%dataOUtpath
pathtoProcdatadir=[basedir filesep 'EEGData/DATA/Processed/EEG_from_Attention_XmodalEXP/jSW_1_blockEpoched'];
allEEGblockdatadir= [basedir filesep 'EEGData/DATA/Processed/EEG_from_Attention_XmodalEXP/jSW_1_blockEpoched'];

allBPdatadir= [basedir filesep 'DATA_newhope'];
addpath= [basedir filesep 'EEGData/Analysis/AttentionExperiment_Analysis/support_forAttention_Xmodal_experiment'];

addpath([basedir filesep 'jobX_support_for']);
%%


if job.individualanalysis
showBehaviouralTracking; %recalc and plot for indiv ppants
showTrackingAcrossPpants %concatenated 
showSeparateTracking %xmods separated by Group and Day.
% 
end 
%%
if job.newBlockbyBlockBatch==1 %
    %crunching and making probabilities at the block-byblocklevel.
   tic
    %creates the fromLowtoHighcounts etc.
    newBlockByBlock_BatchAnalysis%(pathtoBehaviouraldata, sanitycheckON) 
   
end
%%
if job.calculateprobs_perppant==1   
    % this is for the relevant bar charts. Over whole exp.         
%     calculateprobs_perppant%(pathtoBehaviouraldata);
    
    % concats prior to plottig.
%     concatenateprobs_byblocktype%(pathtoBehaviouraldata);   
end

if job.printAcrossAll_switchvsMaintenance==1
%     addpath
toc
    Rebuttal_1_calcMDOMDURs;
printAcrosssall_switchvsmaintenance%(pathtoBehaviouraldata) 
end
%%
if job.calcGaussandScatter
  calcGaussfortypes; %plotted histograms per ppant, of Behavioural tracking prob.
end

if job.calcAttn_Sw_Scatter==1
   calcAttn_Sw_Scatter; 
   %NOTE that this removes XX from behavioural analysis. 
end




%% plot the new plots for powerpoint and tracking etc.
% plotBPduringpercepts_new

% Next job is to adjust behavioural data to actual physical onset.
sanitycheckON=0;

if job.AdjustTriggerOnsetTimes
EXPjob1_epochAttnEXPTRIALS  %realigns each BP and EEG trace to match,
% based on the onset of physical stimuli.
end
%%
if job.EpochSwitchesinBPdata %change within here to perform baseline subtraction.
 EXPjob2_EpochSwitchEvents_BP
end

%  %%
%  if job.AlignEEGtoSwitchData
%      sanitycheckON=0;
%  EXPjob3_AlignEEGtoSwitches
%  end
%  %%
%  if job.printEEGswitches 
%  EXPjob4_printSwitches  
%  end
% %  
% %  if job.printEEGabsSNRafterBPress
% %      EXPjob5_printabsSNRafterBPress  
% %  end
     

%ALSO first switch analysis:
if job.firstswitchpipeline_focus==1
    createDATAfile_wrespecttoBP;
    analyzeBehaviouralDatafile;
    Createfor_alignmentofSwitches;
    
    %plot
    %Plotfirstswitches_xmod

end