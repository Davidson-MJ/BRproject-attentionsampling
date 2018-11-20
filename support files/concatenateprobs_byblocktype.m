% function calculateprobs_perppant(pathtoBehaviouraldata)

%NOTE, not separating by days at this point. just attention and modality
%type.

nppants=34;
attnconds=2;
nfreqz=3; %include visual only trials
nblocktypes=6;

dataM=zeros(nppants,attnconds, nfreqz);
%store for plots
sw_dataProbabilities_AcrossALL=zeros(nppants, nblocktypes, attnconds,nfreqz);
maint_dataProbabilities_AcrossALL=zeros(nppants, nblocktypes, attnconds,nfreqz);
figure(1); clf;
for itype=1:nblocktypes
    cd(pathtoBehaviouraldata)
    %save within blocktype folder
    sw_dataM= dataM;
    maint_dataM=dataM;
    
    switch itype
        case 1
            cd('Across Exp Auditory and Tactile, In phase')
        case 2
            cd('Across Exp Auditory and Tactile, Anti phase')
        case 3
            cd('Across Exp Auditory, In phase')
        case 4
            cd('Across Exp Auditory, Anti phase')
        case 5
            cd('Across Exp Tactile, In phase')
        case 6
            cd('Across Exp Tactile, Anti phase')
    end
    for iattndcond=1:2
        switch iattndcond
            case 1
                ppants= dir(['*Attn_On*']);
            case 2
                ppants = dir(['*Attn_Off*']);
        end
        for ippant=1:length(ppants)
            load(ppants(ippant).name);
            
            
            %can use either block level:
            
            %or whole experiment level:
            probabilitydata;
            
            
            %switches: low hz, high hz, vis only.
            sw_dataM(ippant, iattndcond, 1) = probabilitydata.prob_swXMtype_anyLowhz;
            sw_dataM(ippant, iattndcond, 2) = probabilitydata.prob_swXMtype_anyHighhz;
            sw_dataM(ippant, iattndcond, 3) = probabilitydata.prob_switchVISonly;
            
            %Maintenance: low hz, high hz, vis only.
            maint_dataM(ippant, iattndcond, 1) = probabilitydata.prob_maintXMtype_anyLowHz;
            maint_dataM(ippant, iattndcond, 2) = probabilitydata.prob_maintXMtype_anyHighHz;
            maint_dataM(ippant, iattndcond, 3) = probabilitydata.prob_maintVISonly;
            
            
            %store for later in matrix.
            
            
        end %ppant
       
    end %atttndconds
    %saves at block level.
%     subplot(2,3,itype)
%     bar(sw_dataM(:,:,1));
   
    save('Prob_by(ppant,attn,freq)', 'sw_dataM', 'maint_dataM');
    
    %store across all
    sw_dataProbabilities_AcrossALL(:, itype, :,:)= sw_dataM;
    maint_dataProbabilities_AcrossALL(:, itype, :,:)= maint_dataM;

end %blocktypes
%%
cd(pathtoBehaviouraldata)
 save('Acrossall_Prob_by(ppant,blocktype,attn,freq)', 'sw_dataProbabilities_AcrossALL', 'maint_dataProbabilities_AcrossALL')
 