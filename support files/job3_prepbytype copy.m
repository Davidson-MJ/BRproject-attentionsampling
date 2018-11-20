% function job3_prepbytype(pathtoEpocheddata)


cd(pathtoEpocheddata)

allppants = dir(['ppant*']);
%%
for ippant = 1:length(allppants)
    cd(allppants(ippant).name)
    load('downsampledprocd_EpochedbytypeLONG(day,block,trial,chans,samps).mat')
    
    allAnT=[];
    allAUD=[];
    allTAC=[];
    
%     absEpochdur=size(preprocdhigh_long,ndims(preprocdhigh_long));
    
    %new Exp has 24 blocks, types 1:6.
    %odd numbers are in phase, even are out of phase.
    %1,2 = AnT. 3,4=Aud, 5,6=Tac. Each repeated 4 times (=24)
    %each block has 3 length of stim, short(x3), med(x2) and long(x1).
    for idayis=1:2
        
        %for robustness to only save those we have
        if idayis==1
            contfn = 'Y'; %continue function. 
        else %if day 2, only want to continue if the data has been collected!
            if size(preprocdlow_short,1)<2
                contfn='N';
            end
        end
        if strcmp(contfn,'Y')
            for imod = 1:6 %AnT, Aud, Tac.
                %new data book per freqxphase
                
                %[nblocks, ntrials, nchans, nsamps]
                dataALL_Low=[];
                dataALL_High=[];
                %
                
                countblocks = 1; %1:4 per modality (6*4 = 24)
                
                targetblocks = find(blockTYPES(idayis,:,1)==imod);
                
                if length(targetblocks)~=4 %numblocks.
                    error('count off for saved types of xmodal experiment type')
                end
                
                for iblock = 1:length(targetblocks)
                    getblock = targetblocks(iblock);
                    
                    tmp_L=[];
                    tmp_H=[];
                    
                    tmp_L.short = squeeze(preprocdlow_short(idayis,getblock,:,:,:));
                    tmp_L.medium = squeeze(preprocdlow_med(idayis,getblock,:,:,:));
                    tmp_L.long = squeeze(preprocdlow_long(idayis,getblock,:,:,:));
                    
                    
                    tmp_H.short = squeeze(preprocdhigh_short(idayis,getblock,:,:,:));
                    tmp_H.medium = squeeze(preprocdhigh_med(idayis,getblock,:,:,:));
                    tmp_H.long = squeeze(preprocdhigh_long(idayis,getblock,:,:,:));
                    
                    
                    dataALL_Low.Block(countblocks)=tmp_L;
                    
                    dataALL_High.Block(countblocks)=tmp_H;
                    
                    
                    countblocks = countblocks+1;
                end
                
                %save appropriately
                switch imod
                    case 1
                        allAnT.day(idayis).Inphase.LowHz = dataALL_Low;
                        allAnT.day(idayis).Inphase.HighHz=dataALL_High;
                        
                    case 2
                        allAnT.day(idayis).Outofphase.LowHz = dataALL_Low;
                        allAnT.day(idayis).Outofphase.HighHz=dataALL_High;
                    case 3
                        allAUD.day(idayis).Inphase.LowHz = dataALL_Low;
                        allAUD.day(idayis).Inphase.HighHz=dataALL_High;
                    case 4
                        allAUD.day(idayis).Outofphase.LowHz = dataALL_Low;
                        allAUD.day(idayis).Outofphase.HighHz=dataALL_High;
                    case 5
                        allTAC.day(idayis).Inphase.LowHz = dataALL_Low;
                        allTAC.day(idayis).Inphase.HighHz=dataALL_High;
                    case 6
                        allTAC.day(idayis).Outofphase.LowHz = dataALL_Low;
                        allTAC.day(idayis).Outofphase.HighHz=dataALL_High;
                        
                end
                
            end
        end
    end
    
    save('GroupedEpochsStructure', 'allAnT', 'allAUD', 'allTAC', 'day1cond')
    
    disp(['finished for ppant' num2str(ippant) ', ' num2str(allppants(ippant).name)]);
    cd(pathtoEpocheddata)
    
end
disp('Finished Job 3 prep');
