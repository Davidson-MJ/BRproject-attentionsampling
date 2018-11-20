% function job4_prepAcrossall_extraslim(pathtoEpocheddata, Epochlength)
%New script to store 'kept trials' after ERP exclusion per ppant.

clearvars -except pathtoEpocheddata Epochlength*
Fs=250;
absEpochdur = sum(abs(Epochlength(1)) + Epochlength(2))*Fs +1;


cd(pathtoEpocheddata)
%%
allppants = dir(['ppant*']);
%%
%% %rerun from here and work through all ppants.
for ippant = 1:length(allppants)
    
    cd(pathtoEpocheddata)
    
    %cd and load ppant info
    cd(allppants(ippant).name)
    load('GroupedEpochsStructure')
    
    %% 34 ppants, having already excluded KS based on poor behavioural performance.
    
    %labour intensive, use one xmod at a time.
    for ixmod=1:3 %for AnT. Just do one at a time to save computational load.
        newdata=[];
        for idayis=1:2 %save at the end according to which day for each group.
            
            
            switch ixmod
                case 1
                    usedataIN =allAnT.day(idayis).Inphase;
                    usedataOUT=allAnT.day(idayis).Outofphase;
                    
                case 2
                    usedataIN =allAUD.day(idayis).Inphase;
                    usedataOUT=allAUD.day(idayis).Outofphase;
                    
                case 3
                    usedataIN =allTAC.day(idayis).Inphase;
                    usedataOUT=allTAC.day(idayis).Outofphase;
                    
            end
            
            %concatenate trials (n=6) across blocks(n=4).
            
            for iphase=1:2
                datatmp=zeros(4,2,6,64,absEpochdur);
                switch iphase
                    case 1
                        usedata=usedataIN;
                    case 2
                        usedata=usedataOUT;
                end
                %prep for outgoing Across all.
                [nblocks, nhztypes,ntrials,nchans,nsamps]=size(datatmp);
                
                for ifillblock=1:4
                    datatmp(ifillblock,1,1:3,:,:)=usedata.LowHz.Block(ifillblock).short;
                    datatmp(ifillblock,1,4:5,:,:)=usedata.LowHz.Block(ifillblock).medium;
                    datatmp(ifillblock,1,6,:,:)=usedata.LowHz.Block(ifillblock).long;
                    
                    datatmp(ifillblock,2,1:3,:,:)=usedata.HighHz.Block(ifillblock).short;
                    datatmp(ifillblock,2,4:5,:,:)=usedata.HighHz.Block(ifillblock).medium;
                    datatmp(ifillblock,2,6,:,:)=usedata.HighHz.Block(ifillblock).long;
                end
                
                
                nowdata=reshape(datatmp, [nhztypes,ntrials*nblocks, nchans, nsamps]);
                
                
                %% EXTRA SLIM< perform trial rejection now before attempting to store.
                
                %ERP exclusion per ppant, open "ERP exclusion" for specs
                nowdata_clean=[];
                for ihztype=1:2
                    for ichan= 1:64
                        tmpchk= squeeze(nowdata(ihztype, :, ichan, :));
                        
                        %remaining good trials per channel.
                        goodtrials = ERPexclusion(tmpchk);
                        
                        switch ihztype
                            case 1
                                nowdata_clean.LowHz.chan(ichan).alltrials = goodtrials;
                            case 2
                                nowdata_clean.HighHz.chan(ichan).alltrials= goodtrials;
                        end
                    end
                    
                end
                
                
                
                switch iphase
                    case 1
                        nowdataIN = nowdata_clean;
                    case 2
                        nowdataOUT=nowdata_clean;
                end
            end
            
            %now have a separate databook for across this ppants xmod, day,
            %and phase types.
            
            newdata.day(idayis).Inphase = nowdataIN;
            newdata.day(idayis).Outofphase=nowdataOUT;
        end
        
        switch ixmod
            case 1
                allAnT_cleaned = newdata;
            case 2
                allAUD_cleaned = newdata;
            case 3
                allTAC_cleaned = newdata;
                
        end
        
        ixmod
        
    end
    
    save('GroupedEpochStructure_afterrejection', 'allAnT_cleaned', 'allAUD_cleaned', 'allTAC_cleaned')
    disp(['fin ERP rejection for ppant ' num2str(ippant) ]) 
end