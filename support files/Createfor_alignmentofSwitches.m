clearvars -except f DOMppant
try cd('/Users/MattDavidson/Desktop/XM_Project/ANOVAdata_allppants')
catch
    cd('/Users/MatthewDavidson/Desktop/XMODAL/ANOVAdata_allppants')
end
basedir=pwd;

dbstop if error
%%
%%%%%


iperiod=6; % for supp figures: change to 2 for post stim offset, 3 for nextSW (within XMODonly.).
%4 for next sw(could include offset of tone)
%5 for nextSW (withinXMODonly) aligned to onset
%6 for 1st switch after onset, unconditional.
%%%%

% change to create and save with new params:
job.createdataset=1; 

%SELECT only one at a time! >
job.collectDatatype1 =0; %only Congruent switches during Low Hz. separated by xmod, and phase.
job.collectData_Incorr = 0; %all attended Incongruent switches during Low Hz. separated by xmod, and phase.

job.collectVISonly_firstswitches=0;



%%%% for review/rebutatl figures create (concat) combinations:
job.CombineallCongruentvsIncongruentswitchdata=0;
job.CombineallAttendvsnAttend=0;
job.CombineNEW4WorkingMemoryHypothesis=0;

% loads based on the datatype indicated above
%%
%%%%
usenew=1;

tic
if job.createdataset==1
    
    
    switch iperiod
        case 1
            timeis='postonset';
        case 2
            timeis='postoffset';
        case 3
            timeis='2ndwithinXMOD';
            case 4
            timeis='2ndUnconditional';
    end
    
    
    
    InphaseData= [];
    OutofphaseData=[];
    
    for ixmod=1:3
        %collect per XMOD.
        cd(basedir)
        switch ixmod
            case 1
                cd('AnT')
                xmodis = 'AnT';
            case 2
                cd('AUD')
                xmodis = 'AUD';
            case 3
                cd('TAC')
                xmodis = 'TAC';
        end
        load('newnoswRemovalAcrossALL_Behaviouraldata_nocollapsing.mat');
        if useTopppants==1
            rvals=unique(cell2mat(Acrossall_behaviour{:,36}));
            medianr= median(rvals);
        else
            medianr= -1; %everyone will be above this cuttoff.
        end
            
        for ippant = 1:34
            Inphase = [];
            Outofphase=[];
            
            
            
            %%% two types of datacollection. The first is more restrictive. (Low hz
            %%% congruent only).
            
            if job.collectDatatype1==1 %attending to low hz, first congruent  switch
                for irow = 1:size(Acrossall_behaviour,1)
                    %if attend low hz, collect switch time for in and out of phase [&& cell2mat(Acrossall_behaviour{irow, 35})>.4]
                    if strcmp(Acrossall_behaviour{irow, 5}, 'On') ...
                            && strcmp(Acrossall_behaviour{irow,14}, 'Low')...
                            && strcmp(Acrossall_behaviour{irow,19}, 'Highp') ... % high percept pre onset.
                            && (Acrossall_behaviour{irow,1})==ippant
%                         && (cell2mat(Acrossall_behaviour{irow,36})>medianr)
                        %check phase of block
                        if strcmp(Acrossall_behaviour{irow, 15}, 'In')
                            
                            switch iperiod
                                case 1
                                    %only store if within stim period.
                                     if Acrossall_behaviour{irow,31}< str2num(cell2mat(Acrossall_behaviour{irow,16})) %make sure still during XMOD. % 
                                    Inphase = [Inphase, (Acrossall_behaviour{irow, 31})]; % This is for switches during stim
                                     end
                                case 2                                        
                                        Inphase = [Inphase, (Acrossall_behaviour{irow, 34})]; % This is for switches following offset
                                case 3
                                    %only if second switch after first is still within
                                    %duration of XMOD
                                    tmpdur=(Acrossall_behaviour{irow,32} - Acrossall_behaviour{irow, 31});
                                    
                                    if Acrossall_behaviour{irow,32} < str2num(cell2mat(Acrossall_behaviour{irow, 16}))
                                        Inphase = [Inphase, tmpdur]; % 
                                    end
                                case 4
                                    tmpdur=(Acrossall_behaviour{irow,32} - Acrossall_behaviour{irow, 31});
                                
                                    Inphase = [Inphase, tmpdur]; 
                                case 5
                                    
                                    tmpdur= Acrossall_behaviour{irow,32}; %aligned to onset
                                    
                                    if Acrossall_behaviour{irow,32} < str2num(cell2mat(Acrossall_behaviour{irow, 16}))
                                        Inphase = [Inphase, tmpdur]; % 
                                    end
                                    
                                case 6 %first switch unconditional.
                                     
                                    %Store no matter what                                     
                                    Inphase = [Inphase, (Acrossall_behaviour{irow, 31})]; % This is for switches during stim
                                     
                                    
                                    
                                    
                                        
                            end
                        elseif strcmp(Acrossall_behaviour{irow, 15}, 'Outof')
                            switch iperiod
                                case 1
                                     if Acrossall_behaviour{irow,31}< str2num(cell2mat(Acrossall_behaviour{irow,16})) %make sure still during XMOD. % 
                                    Outofphase = [Outofphase, (Acrossall_behaviour{irow, 31})]; %this is for switches during stim
                                     end
                                    
                                case 2
                                    
                                    Outofphase = [Outofphase, (Acrossall_behaviour{irow, 34})]; %this is for switches following offset
                                case 3
                                    %only if second switch after first is still within
                                    %duration of XMOD
                                    tmpdur=(Acrossall_behaviour{irow,32} - Acrossall_behaviour{irow, 31});
                                    if Acrossall_behaviour{irow,32} < str2num(cell2mat(Acrossall_behaviour{irow, 16}))
                                        Outofphase= [Outofphase, tmpdur]; % This is for switches following offset
                                    end
                                case 4
                                    tmpdur=(Acrossall_behaviour{irow,32} - Acrossall_behaviour{irow, 31});
                                    Outofphase= [Outofphase, tmpdur]; % This is for switches following offset
                             case 5
                                    tmpdur= Acrossall_behaviour{irow,32};
                                    
                                    if Acrossall_behaviour{irow,32} < str2num(cell2mat(Acrossall_behaviour{irow, 16}))
                                        Outofphase= [Outofphase, tmpdur]; % This is for switches following offset
                                    end
                                case 6
                                    Outofphase = [Outofphase, (Acrossall_behaviour{irow, 31})]; %this is for switches during stim
                                    
                                    
                            end
                        end
                        
                    end
                end
                
           
            elseif job.collectData_Incorr==1
                
                for irow = 1:size(Acrossall_behaviour,1)
                    %if attend low hz, collect switch time for in and out of phase [&& cell2mat(Acrossall_behaviour{irow, 35})>.4]
                    if strcmp(Acrossall_behaviour{irow, 5}, 'On') ...
                            && strcmp(Acrossall_behaviour{irow,14}, 'Low')...
                            && strcmp(Acrossall_behaviour{irow,19}, 'Lowp') ... %starting low, so incongruent switch.
                            && (Acrossall_behaviour{irow,1})==ippant...
                        
%                     && (cell2mat(Acrossall_behaviour{irow, 36})>medianr)... %top half of attending ppants.
                        %check phase of block
                        if strcmp(Acrossall_behaviour{irow, 15}, 'In')
                            
                            switch iperiod
                                case 1
                                    
                                    if(Acrossall_behaviour{irow,31})< str2num(cell2mat(Acrossall_behaviour{irow,16})) %make sure still during XMOD.
                                    Inphase = [Inphase, (Acrossall_behaviour{irow, 31})]; % This is for switches during stim
                                    end
                                case 2
                                    
                                        
                                    Inphase = [Inphase, (Acrossall_behaviour{irow, 34})]; % This is for switches following offset
                                case 3
                                    %only if second switch after first is still within
                                    %duration of XMOD
                                    tmpdur=(Acrossall_behaviour{irow,32} - Acrossall_behaviour{irow, 31});
                                    if Acrossall_behaviour{irow,32}  < str2num(cell2mat(Acrossall_behaviour{irow, 16}))
                                        Inphase = [Inphase, tmpdur]; % This is for switches following offset
                                    end
                                case 4
                                    tmpdur=(Acrossall_behaviour{irow,32} - Acrossall_behaviour{irow, 31});
                                    Inphase = [Inphase, tmpdur]; % This is for switches following offset
                                case 5
                                    tmpdur=Acrossall_behaviour{irow,32} ;
                                    if Acrossall_behaviour{irow,32}  < str2num(cell2mat(Acrossall_behaviour{irow, 16}))
                                        Inphase = [Inphase, tmpdur]; % This is for switches following offset
                                    end
                                case 6
                                    Inphase = [Inphase, (Acrossall_behaviour{irow, 31})]; % This is for switches during stim
                            end
                        elseif strcmp(Acrossall_behaviour{irow, 15}, 'Outof')
                            switch iperiod
                                case 1
                                     if(Acrossall_behaviour{irow,31})< str2num(cell2mat(Acrossall_behaviour{irow,16})) %make sure still during XMOD.
                                    Outofphase = [Outofphase, (Acrossall_behaviour{irow, 31})]; %this is for switches during stim
                                    end
                                    
                                case 2
                                    
                                        Outofphase = [Outofphase, (Acrossall_behaviour{irow, 34})]; %this is for switches following offset
                                case 3
                                    %only if second switch after first is still within
                                    %duration of XMOD
                                    tmpdur=(Acrossall_behaviour{irow,32} - Acrossall_behaviour{irow, 31});
                                    if Acrossall_behaviour{irow,32} <str2num( cell2mat(Acrossall_behaviour{irow, 16}))
                                        Outofphase = [Outofphase, tmpdur]; % This is for switches following offset
                                    end
                                case 4
                                    tmpdur=Acrossall_behaviour{irow,32} ;
                                     if Acrossall_behaviour{irow,32} <str2num( cell2mat(Acrossall_behaviour{irow, 16}))
                                        Outofphase = [Outofphase, tmpdur]; % This is for switches following offset
                                     end 
                                case 6
                                    Outofphase = [Outofphase, (Acrossall_behaviour{irow, 31})]; %this is for switches during stim
                            end
                        end
                        
                    end
                end
                
                
           
            elseif job.collectVISonly_firstswitches==1
                
                 for irow = 1:size(Acrossall_behaviour,1)
                    
                    if (strcmp(Acrossall_behaviour{irow,14}, 'Vis')...                            
                            && (Acrossall_behaviour{irow,1})==ippant)
                        
                        if strcmp(Acrossall_behaviour{irow, 15}, 'In')
                            
                            switch iperiod
                                case 1
                                    if (Acrossall_behaviour{irow,31})< str2double(cell2mat(Acrossall_behaviour{irow,16})) %make sure still during XMOD.
                                        
                                        Inphase = [Inphase, (Acrossall_behaviour{irow, 31})]; % This is for switches during stim
                                    end
                                case 2                                        
                                        Inphase = [Inphase, (Acrossall_behaviour{irow, 34})]; % This is for switches following offset
                                case 3
                                    %only if second switch after first is still within
                                    %duration of XMOD
                                    tmpdur=(Acrossall_behaviour{irow,32} - Acrossall_behaviour{irow, 31});
                                    
                                    if Acrossall_behaviour{irow,32}  < str2num(cell2mat(Acrossall_behaviour{irow, 16}))
                                        Inphase = [Inphase, tmpdur]; % This is for switches following offset
                                    end
                                case 4
                                    tmpdur=(Acrossall_behaviour{irow,32} - Acrossall_behaviour{irow, 31});
                                    Inphase = [Inphase, tmpdur]; % This is for switches following offs
                                case 6
                                    %store regardless if still in XMOD or
                                    %not.
                                    Inphase = [Inphase, (Acrossall_behaviour{irow, 31})]; % This is for switches during stim
                                    
                            end
                        elseif strcmp(Acrossall_behaviour{irow, 15}, 'Outof')
                            switch iperiod
                                case 1
                                    if (Acrossall_behaviour{irow,31})< str2double(cell2mat(Acrossall_behaviour{irow,16})) %make sure still during XMOD.
                                        
                                        Outofphase = [Outofphase, (Acrossall_behaviour{irow, 31})]; %this is for switches during stim
                                    end
                                    
                                case 2
                                    
                                    Outofphase = [Outofphase, (Acrossall_behaviour{irow, 34})]; %this is for switches following offset
                                case 3
                                    %only if second switch after first is still within
                                    %duration of XMOD
                                    tmpdur=(Acrossall_behaviour{irow,32} - Acrossall_behaviour{irow, 31});
                                    if Acrossall_behaviour{irow,32} < str2num(cell2mat(Acrossall_behaviour{irow, 16}))
                                        Outofphase= [Outofphase, tmpdur]; % This is for switches following offset
                                    end
                                case 4
                                    tmpdur=(Acrossall_behaviour{irow,32} - Acrossall_behaviour{irow, 31});
                                    Outofphase= [Outofphase, tmpdur]; % This is for switches following offset
                                case 6
                                    
                                    Outofphase = [Outofphase, (Acrossall_behaviour{irow, 31})]; %this is for switches during stim
                                    
                            end
                        end
                        
                    end
                end
                
                
            end
        
                
            %should have all RTs per ppant now. so preprocess.
            %preprocess
            
            for inandout=1:2
                
                
                
                switch inandout
                    case 1
                        dis = Inphase;
                    case 2
                        dis = Outofphase;
                end
                
                
                %remove timepoints if necesary
                
%                 dis(dis<timewin(1))=[];
%                 dis(dis>timewin(2))=[];
                %%
%                 dis(isnan(dis))=[];
                % store all ppant RTs for sanity checks later.
%                 
%                 %create vector of binneddata.
                
                switch inandout
                    case 1
                        InphaseData.allRTs(ixmod,ippant,:) = {dis};
%                         InphaseData.trace(ixmod,ippant,:) = spikes;
%                         InphaseData.spec(ixmod,ippant,:) = s1;
%                         InphaseData.SNR(ixmod,ippant,:) = SNRppant;
                    case 2
                        OutofphaseData.allRTs(ixmod,ippant,:) = {dis};
%                         OutofphaseData.trace(ixmod,ippant,:) = spikes;
%                         OutofphaseData.spec(ixmod,ippant,:) = s1;
%                         OutofphaseData.SNR(ixmod,ippant,:) = SNRppant;
                end
                
            end
        end
    end
    %%
    
    %%
    cd(basedir)
    
    if job.collectDatatype1==1
        savename ='newallRTdata_AttLowCongruentSwitches';
    elseif  job.collectData_Incorr==1
        savename=['newallRTdata_AttLowIncongruentSwitches'];
    elseif job.collectVISonly_firstswitches ==1
        savename = 'newallRTdata_Visonly1stswitch';
    end
    %%
    if iperiod==2
        savename = [savename '_afteroffset'];
    elseif iperiod==3
         savename = [savename '_2ndwinXMOD_alignedtofirstswitch'];
    elseif iperiod==4
        savename = [savename '_2ndUnconditional'];
    elseif iperiod==5
        savename = [savename '_2ndwinXMOD_alignedtoOnset'];
        elseif iperiod==6
        savename = [savename '_Unconditional'];
    end
    %%
    
    try save(savename, 'InphaseData', 'OutofphaseData','-append')
    catch
        save(savename, 'InphaseData', 'OutofphaseData')
    end
    toc
end

% 
if job.CombineallCongruentvsIncongruentswitchdata==1

cd(basedir)
for itype= 1:2
    
    Combinedby=[];
    switch itype
        case 1 %congruent data types
            lnames = [{Datanames(1).name}; 
                {Datanames(3).name}; 
                {Datanames(5).name}; 
                {Datanames(7).name}]; 
        case 2
            lnames = [{Datanames(2).name}; 
                {Datanames(4).name}; 
                {Datanames(6).name}; 
                {Datanames(8).name}]; 
    end
    
    %load each and save.
    for icomb= 1:4
    InphaseData=[];
    OutofphaseData=[];
    lnamet=lnames{icomb};
    if usenew==1
        lnamet=['new' lnamet];
    end
    
    load(lnamet);    
    d= cat(4, InphaseData.trace, OutofphaseData.trace);
        tmp = squeeze(nansum(d,4));
        tmp = squeeze(nansum(tmp,1));


Combinedby(:,:, icomb) = tmp;
    end
    
    switch itype
        case 1
            
            allCongr = Combinedby;
            save('allRTdata_CombinedCongruentSwitches', 'allCongr', 'lnames')
        case 2
            allIncongr=Combinedby;
            save('allRTdata_CombinedIncongruentSwitches', 'allIncongr', 'lnames')
    end
    
end
end

if job.CombineallAttendvsnAttend==1
cd(basedir)
for itype= 1:2
    
    Combinedby=[];
    switch itype
        case 1 %Att
            lnames = [{Datanames(1).name}; 
                {Datanames(2).name}; 
                {Datanames(3).name}; 
                {Datanames(4).name}]; 
        case 2
            lnames = [{Datanames(5).name}; 
                {Datanames(6).name}; 
                {Datanames(7).name}; 
                {Datanames(8).name}]; 
    end
    
    %load each and save.
    for icomb= 1:4
    InphaseData=[];
    OutofphaseData=[];
    
    lnamet=lnames{icomb};
    if usenew==1
        lnamet=['new' lnamet];
    end
    load(lnamet);    
 d= cat(4, InphaseData.trace, OutofphaseData.trace);
        tmp = squeeze(nansum(d,4));
        tmp = squeeze(nansum(tmp,1));


Combinedby(:,:, icomb) = tmp;
    end
    
    switch itype
        case 1
            
            allAtt = Combinedby;
            save('allRTdata_CombinedAttendedSwitches', 'allAtt', 'lnames')
        case 2
            allnAtt=Combinedby;
            save('allRTdata_CombinednonAttendedSwitches', 'allnAtt', 'lnames')
    end
    
end
end
if job.CombineNEW4WorkingMemoryHypothesis==1
cd(basedir)
for itype= 1:4
    
    Combinedby=[];
    switch itype
        case 1 %WMholds Low dur mismatch
            lnames = [{Datanames(1).name}; 
                {Datanames(7).name}];
        case 2
            lnames = [{Datanames(2).name}; 
                {Datanames(6).name}]; 
        case 3
            lnames = [{Datanames(3).name}; 
                {Datanames(5).name}]; 
        case 4
            lnames = [{Datanames(4).name}; 
                {Datanames(8).name}]; 
            
    end
    
    %load each and save.
    newInphase=[];
    newOutofphase=[];
    
    for icomb= 1:2
    InphaseData=[];
    OutofphaseData=[];
    lnamet=lnames{icomb};
    if usenew==1
        lnamet=['new' lnamet];
    end
    load(lnamet);    
    %combine all the subfields and save as new.
    
% newInphase.
 

Combinedby(:,:, icomb) = tmp;
    end
    
    switch itype
        case 1
            
            allWML_durmismatch = Combinedby;
            
        case 2
            allWML_nomismatch=Combinedby;
        case 3
            allWMH_durmismatch=Combinedby;
        case 4
            allWMH_nomismatch=Combinedby;
    end
    
end
savename = 'allRTdata_WMhypothesis';
if usenew==1
    savename = 'newallRTdata_WMhypothesis';
end
    save(savename, 'allWML_durmismatch', 'allWML_nomismatch', ...
        'allWMH_durmismatch', 'allWMH_nomismatch');
    
    
    
end



    