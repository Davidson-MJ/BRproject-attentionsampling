% 
% runs through contents, and jobs
%
% MD 18-10-16
clear all
close all
%
% preprocess EEG data and sort into Trial types. Also adjusts for any frame-lag /delay.
% Dependencies for new Epoch lengths:
% jobs: PreprocessEp.., 
% findEEG.. and
% concat_prep are needed.

job.ExtractStimulusOnsetTimes=0; %requires input
job.PreprocessEpochsusingOnsetTimes=0; %can preprocess, byt at the moment just epochs into trialsxblocks.
job.SortEpochbyxmod_ppant=0; % uses behavioural/experimental data to sort above trials into respective cross-modality.
job.rejectEpochbyxmod_ppant=0; %rejects bad epochs using "ERPexclusion" criteria, and saves in ppant folder.

job.continuePipeline=0; % continue with Behavioural switch analysis.
%% some parameters for analysis to come
%
sanitycheckON = 1; %change to zero to suppress all plots and userinput.

%  set up some directories first
cd('/Users/MattDavidson/Desktop/XM_Project/EEGData')
basedirALL =pwd;
addpath(basedirALL)
% help paths
% cd([basedirALL filesep 'Analysis'])
% addpath(pwd)
% cd([basedirALL filesep 'Analysis' filesep 'AttentionExperiment_Analysis' filesep 'support_forAttention_Xmodal_experiment']);
% addpath(pwd)
% outpath for processed data
cd([basedirALL filesep 'DATA' filesep 'Processed' filesep 'EEG_from_Attention_XmodalEXP'])
savebase = pwd;
addpath(savebase);
% data IN comes from...
cd([basedirALL filesep 'MD_AttentionXmodal'])
eegdataIN = pwd;
addpath(eegdataIN);
pathtobehaviouraldata='/Users/MattDavidson/Desktop/XM_Project/DATA_newhope';
addpath(pathtobehaviouraldata);

Epochlength_secs= [-3.5 6.5]; %seconds for epoch about stim onset during trialpresentation, downsampled at 250hz.
%tones were 2.6-4  seconds duration
pathtoOnsets = [savebase filesep 'j1_Onsets'];
pathtoEpocheddata = [savebase filesep 'j2_AllchanEpoched'];
printtofold = [savebase filesep 'j3_4_ERPs'];
checkchan = 44; %FC4, used for some sanity checks (centroparietal)
clustercriteria= 0;%.01;  % in (s) number of significant points required in group, for the embedded p value to be considered for selection in some scripts.

%% %%%%%%%%%%% %%%%%%%%%%%%% %%%%%%%%%%% 
% start pipeline with Stimulus 
%Job1 - %Load EEG, record EEGonset times for stim per ppant

if job.ExtractStimulusOnsetTimes==1            
 job1_ExtractStimulusOnsetTimes(savebase, eegdataIN, sanitycheckON);
end
%% Epoch and sort all trials
%labour intensive!  
%note: epochs according to type after preprocessing in NEXT job.(reref , downsample, detrend and bandp filt)
 if job.PreprocessEpochsusingOnsetTimes==1
     %doesnt actually do it by type of xmod.
job2_preprocessExperimentEpochsbyType(savebase, eegdataIN, pathtoOnsets, pathtobehaviouraldata, Epochlength_secs);
end
%%
%sort and save each ppant's trials according to modality (Aud, Tact, AnT)
%creates as structure. 
tic
if job.SortEpochbyxmod_ppant==1
job3_prepbytype(pathtoEpocheddata)


%added this function to also store visual only 'trials' based on trigger
%% times within 'Grouped Structure' in ppant folder.
job3A_prepbytype_Visonly(savebase, eegdataIN, pathtoOnsets, pathtobehaviouraldata, Epochlength_secs);
end
toc

% %% skipped for now, as rejection without filtering eliminates too many
% trials.
if job.rejectEpochbyxmod_ppant
% saves 'good trials' after ERP exclusion, leaving xamount per channel in a structure, per xmod. 
    job_4prepAcrossall_extraslim(pathtoEpocheddata, Epochlength_secs);
end
%% Start second pipeline, using behavioural data to check switch activity, attention, etc.

if job.continuePipeline==1; % continue with Behavioural switch analysis.
BRSwitch_Attention_pipeline;
end




