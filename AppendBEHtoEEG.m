%% ITPC results, from eeg+BEH data.
% need to reshuffle ppant EEG into all mismatched vs matched,
% attend/nonattend,low/high freq.
clear all
getelocs
try cd('/Users/matthewdavidson/Desktop/XMODAL/j2_AllchanEpoched')
catch
    cd('/Users/MattDavidson/Desktop/XM_Project/EEGData/Data/Processed/EEG_from_Attention_XmodalEXP/j2_AllchanEpoched')
end
    
basedir=pwd;
ppantdirs = dir([pwd filesep 'ppant*']);
%%

job.appendalloutcomestoEEGinfo=0; % creates table of epoch information (trial counts etc).
job.collecttrialtypesperppant=0; % populates table.

job.appendVisonlyswitches=0; % added to also account for visual only 'cues'.
job.performparticipantITPC=0; %
job.concatAcrossallITPC=0;
job.checkfigs=0; % rough figs (not pub quality).
job.checkCorr=0;




% this is a combination of prev support files:
% findEEGforperceptsinaboveTrials
% concatEEG,

if job.appendalloutcomestoEEGinfo==1;
    for  ippant=1:34;
        cd(basedir)
        filename = ppantdirs(ippant).name;
        %use initials to be safe
        initials= [num2str(filename(end-1)), num2str(filename(end))];
        %change to datapath
        
        %create large empty
        %cell/Users/matthewdavidson/Desktop/XMODAL/DATA_newhopec
        
        
        %place all in table, then sort by trialtype (HzDur) for comparison with EEG
        tblA =cell2table(cell(720,4), 'VariableNames', {'Match_is_1', 'Attend_is_1', 'HzDur', 'XMOD'});
        
        
        %cycle through in the same order as we created the stack.
        for iday=1:2
            
            try cd('/Users/matthewdavidson/Desktop/XMODAL/DATA_newhope')
            catch
                cd('/Users/MattDavidson/Desktop/XM_Project/DATA_newhope')
            end
            dayfol = dir([pwd filesep initials '*Day' num2str(iday) '*']);
            cd(dayfol.name)
            if strcmp(dayfol.name(end), 'n')
                attending = 1;
            else
                attending=0;
            end
            %     if iday==2
            %         error('check next row entry')
            %     end
            for iblock=1:24
                blockfol=dir([pwd filesep 'Block' num2str(iblock) 'Exp*']);
                %load button press data for this block.
                load(blockfol.name)
                
                trialsin = [1:15] + 15*(iblock-1) + 360*(iday-1);
                trialOrder=blockout.Order;
                %just first BP
                trialsBP = blockout.congrtrackingData(:,1);
                %find the correct block data, load congrtracking data. and trial
                %types
                for itrial = 1:15
                    tblA{trialsin(itrial),1} = {(trialsBP(itrial))}; %1 for congruent.
                    tblA{trialsin(itrial),2} = {attending}; %1 for congruent.
                    tblA{trialsin(itrial),3} = {trialOrder(itrial)}; %1 for congruent.
                    tblA{trialsin(itrial),4} = {blockout.Casetype}; % XMOD type
                    
                end
            end
        end
        % now sort according to trial type, and append to allEEG.
        %%
        arrayTypes= cell2mat(tblA{:,3});
        [typez,id]=sort(arrayTypes);
        %move all visual only trials to the end
        indx1=find(typez(typez==1)); %should be 144
        
        %place these at end.
        id2= [[id(length(indx1)+1:end)]' , [id(1:length(indx1))]'];
        % typez2 =[[typez(length(indx1)+1:end)]' , [typez(1:length(indx1))]'];
        
        %% create index based on this information.
        infoorder =zeros(720,1);
        for i=1:length(id2);
            %find trial location (chronological)
            %then place the number for EEG concat
            infoorder(id2(i)) = i;
        end
        
        tblA.concatinEEGas = infoorder;
        %sort by this columns'values
        tblB = sortrows(tblA, 'concatinEEGas');
        %%
        
        cd(basedir)
        cd(ppantdirs(ippant).name)
        Epochinformation = tblB;
        %save this info so we can sort EEG accordingly
        save(['ppantEEGEpochs_p' num2str(ippant)], 'Epochinformation');
    end
end

if job.collecttrialtypesperppant==1
    %%
    tblGrFX =cell2table(cell(24,42));%, 'VariableNames', {'XMOD', 'Attend_is_1', 'HzDur', 'Matchis1'});
    %%
    %populate table.
    %xmods
    tblGrFX{1:8,1} = {'Auditory and Tactile'};
    tblGrFX{9:16,1} = {'Auditory'};
    tblGrFX{17:24,1} = {'Tactile'};
    
    %attnd
    Attnd= [1:4, 9:12, 17:20];
    tmp=1:24;
    tmp(Attnd)=[];
    nAttnd=tmp;
    
    tblGrFX{Attnd,2} = {1};
    tblGrFX{nAttnd,2} = {0};
    
    
    %hz
    Low= [1:2, 5:6, 9:10, 13:14, 17:18, 21:22 ];
    tmp=1:24;
    tmp(Low)=[];
    High=tmp;
    tblGrFX{Low,3} = {'Low'};
    tblGrFX{High,3} = {'High'};
    
    %mism or match
    mism=1:2:24;
    match=2:2:24;
    tblGrFX{mism,4} = {0};
    tblGrFX{match,4} = {1};
    %%
    for  ippant=1:34;
        %%
        cd(basedir)
        filename = ppantdirs(ippant).name;
        cd(filename);
        load(['ppantEEGEpochs_p' num2str(ippant) '.mat'], 'Epochinformation');
        %%
        for irow= 1:size(tblGrFX,1)
            
            %match the rows in Epoch information, to info needed in across
            %ppant table
            
            XMODsearch= cell2mat(tblGrFX{irow,1});
            AC= cell2mat(tblGrFX{irow,2});
            Hzsearch= cell2mat(tblGrFX{irow,3});
            MM= cell2mat(tblGrFX{irow,4});
            %%
            switch Hzsearch
                case 'Low'
                    trialcount= cell2mat(Epochinformation.Match_is_1)==MM &...
                        cell2mat(Epochinformation.Attend_is_1)==AC & ...
                        cell2mat(Epochinformation.HzDur)<92 & ...
                        cell2mat(Epochinformation.HzDur)>1 & ...
                        strcmp(Epochinformation.XMOD,XMODsearch);
                case 'High'
                    trialcount= cell2mat(Epochinformation.Match_is_1)==MM &...
                        cell2mat(Epochinformation.Attend_is_1)==AC & ...
                        cell2mat(Epochinformation.HzDur)>84 & ...
                        strcmp(Epochinformation.XMOD,XMODsearch);
            end
            %%
            ntrials=length(find(trialcount));
            %%
            %add new COlumn
            %     tblGrFX = [tblGrFX, '
            
            tblGrFX{irow,ippant+4} = {ntrials};
            
        end
        if ippant==1
            tblGrFX.Properties.VariableNames(1:4)={'XMOD', 'Attend_is_1', 'HzDur', 'Matchis1'};
            tblGrFX.Properties.VariableNames(5)={['Ppant' num2str(ippant)]};
        else
            tblGrFX.Properties.VariableNames(ippant+4)= {['Ppant' num2str(ippant)]};
        end
    end
    %%
%     collect range per 
    tblGrFX =[tblGrFX, cell(size(tblGrFX,1),1), cell(size(tblGrFX,1),1)];
    %%
    tblGrFX.Properties.VariableNames(39) = {'Min'} ;
    tblGrFX.Properties.VariableNames(40) = {'Max'} ;
    tblGrFX.Properties.VariableNames(41) = {'Mean'} ;
    tblGrFX.Properties.VariableNames(42) = {'Median'} ;
    %%
    %populate final column
    for irow=1:size(tblGrFX,1)
        tmp=cell2mat(tblGrFX{irow,5:38});
        tblGrFX{irow, 39} = {[min(tmp)]};
        tblGrFX{irow, 40} = {[max(tmp)]};
         tblGrFX{irow, 41} = {[mean(tmp)]};
         tblGrFX{irow, 42} = {[median(tmp)]};
    end
    %%
    try cd('/Users/matthewdavidson/Desktop/XMODAL/j2_AllchanEpoched/AcrossALL')
    catch
        cd('/Users/MattDavidson/Desktop/XM_Project/EEGData/Data/Processed/EEG_from_Attention_XmodalEXP/j2_AllchanEpoched/AcrossALL')
    end
    AcrossppantTrialcounts = tblGrFX;
    save('AcrossppantTrialcounts' , 'AcrossppantTrialcounts')
end


if job.appendVisonlyswitches==1;
    %piggy back on earlier scripts, to concatenate the visual only switches
    %for BR processing.
   
    
    
    
end
    
    %


if job.performparticipantITPC==1;
    %%
    % Set up T-Freq params
    t= ([1:2501]/250) -3.5; %10second downsampled epochs.
    [~,tneg2 ] = min(abs(t-(-2)));
    [~,timezero ] = min(abs(t));
    [~,tplus2] = min(abs(t-2));
    params.Fs=250;
    params.fpass= [0 30];
    params.tapers = [1,1];
    
    for ippant=1:34;
        cd(basedir)
        cd(ppantdirs(ippant).name)
        load(['ppantEEGEpochs_p'  num2str(ippant) '.mat']);
        
        
        %         newEEG=laplacian_perrinX(newEEG, [elocs(1:64).X], [elocs(1:64).Y], [elocs(1:64).Z]);
        
        
        complex2sbeforeandafter=[];
        for itrial=1:size(newEEG,3)
            
            datatrial = squeeze(newEEG(:,:,itrial))';
            
            %perform ITPC before and after
            for iwin=1:2
                switch iwin
                    case 1
                        
                        tdata = datatrial(tneg2:timezero,:);
                    case 2
                        
                        tdata = datatrial(timezero:tplus2,:);
                end
                %set up fft
                N=size(tdata,1);
                nfft=max(2^(nextpow2(N)),N);
                [f,findx]=getfgrid(params.Fs,nfft,params.fpass);
                tapers=dpsschk(params.tapers,N,params.Fs); % check tapers
                
                J=mtfftc(tdata,tapers,nfft,params.Fs);
                J=J(findx,:,:);
                %store
                complex2sbeforeandafter(:,iwin,itrial,:) = squeeze(J)';
            end
            
        end
        %now sort according to type.
        
        for typeis = 1:8
            switch typeis
                case 1
                    %AttMismLow
                    rows = cell2mat(Epochinformation.Match_is_1)<1 &...
                        cell2mat(Epochinformation.Attend_is_1)>0 & ...
                        cell2mat(Epochinformation.HzDur)<92 & ...
                        cell2mat(Epochinformation.HzDur)>1;
                    
                case 2
                    %AttMismHigh
                    rows = cell2mat(Epochinformation.Match_is_1)<1 &...
                        cell2mat(Epochinformation.Attend_is_1)>0 & ...
                        cell2mat(Epochinformation.HzDur)>84;
                    
                case 3
                    %nAMismLow
                    rows = cell2mat(Epochinformation.Match_is_1)<1 &...
                        cell2mat(Epochinformation.Attend_is_1)<1 & ...
                        cell2mat(Epochinformation.HzDur)<92 & ...
                        cell2mat(Epochinformation.HzDur)>1;
                case 4
                    %nAMismHigh
                    rows = cell2mat(Epochinformation.Match_is_1)<1 &...
                        cell2mat(Epochinformation.Attend_is_1)<1 & ...
                        cell2mat(Epochinformation.HzDur)>84;
                    
                case 5 % now all MATCHED cases.
                    %AttMatchLow
                    rows = cell2mat(Epochinformation.Match_is_1)>0 &...
                        cell2mat(Epochinformation.Attend_is_1)>0 & ...
                        cell2mat(Epochinformation.HzDur)<92 & ...
                        cell2mat(Epochinformation.HzDur)>1;
                case 6
                    %AttMatchHigh
                    rows = cell2mat(Epochinformation.Match_is_1)>0 &...
                        cell2mat(Epochinformation.Attend_is_1)>0 & ...
                        cell2mat(Epochinformation.HzDur)>84;
                case 7
                    %nonAttMatchLow
                    rows = cell2mat(Epochinformation.Match_is_1)>0 &...
                        cell2mat(Epochinformation.Attend_is_1)<1 & ...
                        cell2mat(Epochinformation.HzDur)<92 & ...
                        cell2mat(Epochinformation.HzDur)>1;
                    
                case 8
                    %nonAttMatchHigh
                    %nAMismHigh
                    rows = cell2mat(Epochinformation.Match_is_1)>0 &...
                        cell2mat(Epochinformation.Attend_is_1)<1 & ...
                        cell2mat(Epochinformation.HzDur)>84;
                    
                    
            end
            
            
            epochindex = find(rows);
            
            %collect all trials this type.
            ITPCcols = complex2sbeforeandafter(:,:,epochindex,:);
            
            %           calculate ITPC
            N=size(ITPCcols,3); %ntrials.
            %%
            ITPC=ITPCcols./abs(ITPCcols); %divide by amp to make unit length
            ITPC=(sum(ITPC,3)); % sum angles in complex plane,
            ITPC=squeeze(abs(ITPC)./N); %norm. average of these
            %%
            % compare to average within each channel
            
            %store
            switch typeis
                case 1
                    AttMismLow_ITPC = ITPC;
                    AttMismLow= epochindex;
                case 2
                    AttMismHigh_ITPC = ITPC;
                    AttMismHigh= epochindex;
                case 3
                    
                    nAttMismLow_ITPC = ITPC;
                    nAttMismLow= epochindex;
                case 4
                    nAttMismHigh_ITPC = ITPC;
                    nAttMismHigh= epochindex;
                case 5
                    AttMatchLow_ITPC = ITPC;
                    AttMatchLow= epochindex;
                case 6
                    AttMatchHigh_ITPC = ITPC;
                    AttMatchHigh= epochindex;
                case 7
                    
                    nAttMatchLow_ITPC = ITPC;
                    nAttMatchLow= epochindex;
                case 8
                    nAttMatchHigh_ITPC = ITPC;
                    nAttMatchHigh= epochindex;
                    
                    
            end
            
            
            
        end
        %% save our ITPC data, for average across participants.
        freqITPC=f;
        save('ppantEEG_ITPC', ...
            'AttMatchHigh_ITPC',...
            'AttMatchLow_ITPC',...
            'AttMismHigh_ITPC',...
            'AttMismLow_ITPC',...
            'nAttMatchHigh_ITPC',...
            'nAttMatchLow_ITPC',...
            'nAttMismHigh_ITPC',...
            'nAttMismLow_ITPC','freqITPC');
        
        %also save trial indices for later.
        save(['ppantEEGEpochs_p' num2str(ippant)],...
            'AttMatchHigh',...
            'AttMatchLow',...
            'AttMismHigh',...
            'AttMismLow',...
            'nAttMatchHigh',...
            'nAttMatchLow',...
            'nAttMismHigh',...
            'nAttMismLow', '-append');
        
        disp(['FinITPCforppant ' num2str(ippant)])
        %%
        %         figure(2);topoplot(squeeze(ITPC(:,2,4)), elocs(1:64));
        %         hold on , title('postlaplacian');
        
    end
end

if job.concatAcrossallITPC==1;
    %%
    for MismatchorMatch = 1:2
        acrossall = zeros(34,2,2,64,2,62);
        %     [ppants, attendorNo,  hz, chans, prepost, freqs]=size(acrossall);
        for ippant=1:34
            %%
            cd(basedir)
            cd(ppantdirs(ippant).name)
            %%
            load('ppantEEG_ITPC')
            switch MismatchorMatch
                case 1 %att, l
                    acrossall(ippant,1,1,:,:,:) = AttMismLow_ITPC;
                    acrossall(ippant,1,2,:,:,:) = AttMismHigh_ITPC;
                    
                    acrossall(ippant,2,1,:,:,:) = nAttMismLow_ITPC;
                    acrossall(ippant,2,2,:,:,:) = nAttMismHigh_ITPC;
                case 2
                    
                    acrossall(ippant,1,1,:,:,:) = AttMatchLow_ITPC;
                    acrossall(ippant,1,2,:,:,:) = AttMatchHigh_ITPC;
                    
                    acrossall(ippant,2,1,:,:,:) = nAttMatchLow_ITPC;
                    acrossall(ippant,2,2,:,:,:) = nAttMatchHigh_ITPC;
                    
            end
            
        end
        
        switch MismatchorMatch
            case 1
                %             Mismatched_laplacITPC = acrossall;
                Mismatched_ITPC = acrossall;
            case 2
                %             Matched_laplacITPC = acrossall;
                Matched_ITPC = acrossall;
        end
    end
    %%
    cd(basedir)
    cd ../ANOVAdata_allppants
    save('ITPC(ppants,attend,hz,chans, prepost, freqs)', 'Mismatched_ITPC', 'Matched_ITPC', 'freqITPC')
    
end


if job.checkfigs==1
    %%
    cd(basedir)
    cd ../ANOVAdata_allppants    
    load('ITPC(ppants,attend,hz,chans, prepost, freqs)')
    
    
    hzcheck =3.5;
    MismatchorMatch=4;
    switch MismatchorMatch
        case 1
            
            dataplot = Mismatched_ITPC;
        case 2
            
            dataplot = Matched_ITPC;
        case 3 %difference.
%             dataplot = Mismatched_ITPC- Matched_ITPC;
        case 4
%             dataplot = Matched_ITPC-Mismatched_ITPC;
    end
    
    [~, hzid]= min(abs(freqITPC-hzcheck));
    if MismatchorMatch<3 %compares post period to pre period.
        tmp2 = squeeze(dataplot(:,1,1,:, 2, hzid));
        tmp1 = squeeze(dataplot(:,1,1,:, 1, hzid));
    else
        tmp=[];
        %attL mismatch
        tmp2 = squeeze(dataplot(:,1,1,:,2,hzid));
        
        % all other types
        %nonattend L
        tmp(1,:,:) = squeeze(dataplot(:,2,1,:,2,hzid));
        
        %AttH
        tmp(2,:,:) = squeeze(dataplot(:,1,2,:,2,hzid));
        
        %nAttH
        tmp(3,:,:) = squeeze(dataplot(:,2,2,:,2,hzid));
        
        
        tmp1=squeeze(nanmean(tmp,1));
    end
    %check for sig increase by chan
    p=[];
    for ichan=1:64
        [~, p(ichan)] =ttest(squeeze(tmp2(:,ichan)), squeeze(tmp1(:,ichan)));
        
    end
    %
    sigchans= find(fdr(p)~=1);
    sigchans= find(p<.05);
    %
    spatialClusterFDR_new % opens summary figure for spatial cluster
    %corrections for MCP.
    
    tmp= tmp2-tmp1;
    plottmp= squeeze(mean(tmp,1));
    %
    clf;
    subplot(211)
    topoplot(plottmp, elocs(1:64), 'emarker2', {[sigchans], '*' ,'w', 10, 35 }); colorbar;
    topoplot(plottmp, elocs(1:64), 'emarker2', {[sigchans], 'o' ,'k', 10, 5 }); colorbar;
    set(gcf, 'color', 'w');
    caxis([-.05 .05])
    shg
    %
    set(gca, 'fontsize', 45)
    
    
    
    
end
if job.checkCorr==1;
    
    EEGITPCtype=2;
    %1 is old, average over XMODS
    %2 is new, across all xmods
    
    
    postperiod=2;
    %%%%
    BEHdatatype=2; %mismatches(2), Matches(3).
    %%%%
    hztocheck = 3.5;
    
    
    
    try cd('/Users/MattDavidson/Desktop/XM_Project/ANOVAdata_allppants/Combined_acrossXMODs');
    catch
        cd('/Users/MatthewDavidson/Desktop/XMODAL/ANOVAdata_allppants/Combined_acrossXMODs');
    end
    basedir=pwd;
    
    load('allProbabilities_forcorrelation(attn,hz,nppants).mat')
    
    %load ITPC
    cd('/Users/matthewdavidson/Desktop/XMODAL/ANOVAdata_allppants')
    switch EEGITPCtype
        case 1
            load('AllcuetoSwitchvsStaytopos.mat');
        case 2
            
            load('ITPC(ppants,attend,hz,chans, prepost, freqs).mat');
            
    end
    
    
    
    [~, hzid]= min(abs(freqITPC- hztocheck));
    switch BEHdatatype
        case 1
            allppantprobtouse  = allppants_Probs;
        case 2
            allppantprobtouse  = allppants_Probs_Mismatched;
        case 3
            allppantprobtouse  = allppants_Probs_Matched;
    end
    
    
    %attending low hz. - others
    r_tmp = squeeze(allppantprobtouse(1,1,:)); % att low
    %subtract remaining conditions)
    r_sub(1,:) =  squeeze(allppantprobtouse(2,1,:)); % natt low
    r_sub(2,:) =  squeeze(allppantprobtouse(1,2,:)); % att High
    r_sub(3,:) =  squeeze(allppantprobtouse(2,2,:)); % natt High
    %     r_sub(4:5,:)= squeeze(allppants_Probs_Matched(1:2,1,:)); %
    %     r_sub(6:7,:)= squeeze(allppants_Probs_Matched(1:2,2,:)); %
    
    % %organize for scatter
    r_ranked = r_tmp' - squeeze(mean(r_sub,1));
    r_ranked=r_ranked';
    % organize ITPC
    
    %first dim is attend condition
    if EEGITPCtype==1
        data1=squeeze(ITPCLowHzdataSWITCH(1,:,:,:,:,:,:));
        
        
        %create new var, get ready to average acrosss remaining conds.
        %unsuccessful mismatched cues
        data1_sub=[];
        data1_sub(1,:,:,:,:,:) = squeeze(ITPCLowHzdataSWITCH(2,:,:,:,:,:,:)); %low nonattend
        
        data1_sub(2:3,:,:,:,:,:) = squeeze(ITPCHighHzdataSWITCH(1:2,:,:,:,:,:,:)); %high attend and nattend
        %     data1_sub(4,:,:,:,:,:) = squeeze(ITPCLowHzdataSTAY(2,:,:,:,:,:,:)); %
        %     data1_sub(5:6,:,:,:,:,:) = squeeze(ITPCHighHzdataSTAY(1:2,:,:,:,:,:,:));
        
        data1_sub = squeeze(nanmean(data1_sub,1));
        datatype = data1-data1_sub;
        %take mean over xmods
        datatype = squeeze(mean(datatype));
        
        
        %just post period?
        
        if postperiod==2;
            
            datatype =squeeze(datatype(:,:,2,:));
        else
            
            datatype =squeeze(datatype(:,:,2,:))-squeeze(datatype(:,:,1,:));
        end
        
        
        datais = squeeze(datatype(:,:,[hzid]));
        
        
        
        
    else %use combined data (different dimensions).
        switch BEHdatatype
            case 2
                tmp=[];
                %attL mismatch
                tmp2 = squeeze(Mismatched_ITPC(:,1,1,:,2,hzid));
                % all other mismatch
                %nonattend L
                tmp(1,:,:) = squeeze(Mismatched_ITPC(:,2,1,:,postperiod,hzid));
                %AttH
                tmp(2,:,:) = squeeze(Mismatched_ITPC(:,1,2,:,postperiod,hzid));
                %nAttH
                tmp(3,:,:) = squeeze(Mismatched_ITPC(:,2,2,:,postperiod,hzid));
                
                tmp1=squeeze(nanmean(tmp,1));
                
            case 3
                tmp=[];
                %attL mismatch
                tmp2 = squeeze(Matched_ITPC(:,1,1,:,2,hzid));
                % all other mismatch
                %nonattend L
                tmp(1,:,:) = squeeze(Matched_ITPC(:,2,1,:,postperiod,hzid));
                %AttH
                tmp(2,:,:) = squeeze(Matched_ITPC(:,1,2,:,postperiod,hzid));
                %nAttH
                tmp(3,:,:) = squeeze(Matched_ITPC(:,2,2,:,postperiod,hzid));
                
                tmp1=squeeze(nanmean(tmp,1));
        end
        datais = tmp2-tmp1;
        
    end
    
    %%%%%%%%%%% now plotting
    getelocs
    fontsize=15;
    
    r=[];
    p=[];
    for iplot = 1:64
        
        dtmp= datais(:,iplot)';
        
        %
        % hold on
        %
        % ps=scatter((dtmp),r_ranked, [2], ['b' '*'], 'linewidth',1);
        %
        [r(iplot),p(iplot)]= corr((dtmp'), r_ranked);
        % % plotr(iROI)=p;
        % tmpr=sprintf('%.3f',r(iplot));
        % tmpp=sprintf('%.3f', p(iplot));
        % hold on
        % %also line of best fit.
        % b1= polyfit((dtmp),r_ranked,1);
        % %         xt = [min(r_ranked) max((dtmp))];
        % xt = [min(dtmp) max((dtmp))];
        %
        % yt = polyval(b1, [min(dtmp), max(dtmp)]);
        % pl=plot(xt,yt,'b');
        %
        %
        % if p(iplot)<.07
        % title([num2str(elocs(iplot).labels) ' ' tmpp], 'fontsize', 15)
        % else
        %     title([num2str(elocs(iplot).labels) ], 'fontsize', 10)
        % end
        %
        % %         xlim([0 25])
        % %         print('-dpng', ['Interaction Data for ' chanis])
        % set(gcf, 'color', 'w')
        %
        % %         title({['Pariticipant EEG '];['and behavioural cross-modal effects']})
        % hold on
        % plot(xlim,[.5  .5], ['k' '-'])
        %
        % axis tight
        % ylim([.4 .85])
        
        % set(gca, 'fontsize', 50, 'linewidth', 5, 'ytick', [.4 :.1 :.8])
        % set(lg, 'Location', 'NorthEast', 'fontsize', 50)
        %%% also plot single for inspection
        
        if iplot==64
            %%
            figure(2);
            clf
            %     subplot(2,1,2)
            checkchans=find(sigchans);
            
            
            dtmp = squeeze(mean(datais(:, checkchans),2));
            
            xlabel(['\Delta ' num2str(hztocheck) ' Hz ITPC'])
            ylabel({['\Delta Probability']})
            hold on
            ps=scatter((dtmp),r_ranked, [1000], ['m' '*'], 'linewidth',5);
            [rlast,plast]= corr((dtmp), r_ranked);
            % plotr(iROI)=p;
            tmpr=sprintf('%.3f',rlast);
            tmpp=sprintf('%.3f', plast);
            hold on
            %also line of best fit.
            b1= polyfit((dtmp),r_ranked,1);
            %         xt = [min(r_ranked) max((dtmp))];
            xt = [min(dtmp) max((dtmp))];
            
            yt = polyval(b1, [min(dtmp), max(dtmp)]);
            pl=plot(xt,yt,'k');
            pl.LineWidth=10;
            % title(['AttL Match vs nAttL'])
            
            nppants=34;
            %         lg=legend([ps, pl], {[' Subjects, \itN\rm=' num2str(nppants)], ['\itr \rm= ' num2str(tmpr) ', \itp \rm=' num2str(tmpp)]});
            %         lg=legend([pl],  ['\itr \rm= ' num2str(tmpr) ', \itp \rm=' num2str(tmpp)]);
            
            set(gcf, 'color', 'w')
            
            %         title({['Pariticipant EEG '];['and behavioural cross-modal effects']})
            hold on
            % plot(xlim,[.5  .5], ['k' '-'])
            
            axis tight
            ylim([-.15  .4])
            xlim([ -.2 .25])
            set(gca, 'fontsize', 50, 'linewidth', 5)%, 'ytick', [.4 :.1 :.8])
            % set(lg, 'Location', 'NorthEast', 'fontsize', 50)
            shg
            xlim([-.15 .25])
            ylim([-.075 .3])
        end
        
        
    end
    %
    figure(2)
    
    sigchans = find(p<=.05);
    subplot(2,2,1:2)
    tp=topoplot(r, elocs(1:64), 'emarker2', {[sigchans], '*', 'w', 20, 5});
    %
    %
    hold on
    topoplot(r, elocs(1:64), 'emarker2', {[sigchans], 'o', 'k', 20, 5});
    c=colorbar;
    ylabel(c, {['Pearsons \itr ']})
    set(gca, 'fontsize', 30);
    set(gcf, 'color', 'w')
    caxis([ -.5 .5])
    shg
end



    
    
    


