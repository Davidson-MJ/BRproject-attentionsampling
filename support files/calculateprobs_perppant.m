 function calculateprobs_perppant(pathtoBehaviouraldata)


for itype=1:6
    cd(pathtoBehaviouraldata)
    dataM=zeros;
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

    ppants= dir(['*_On*']);
     
    for ippant=1:length(ppants)
        load(ppants(ippant).name);
        
        %% calculate probabilities over entire experiment, and append to file.
        
        sanitycheckON=0; %suppress plots.
        dataout=switch_maintaincountAttnExp(fromHIGHtoLOW_ALLstim, fromLOWtoHIGH_ALLstim, maintainedduringHIGH_All,...
            maintainedduringLOW_All, failed_swHIGHtoLOWall, failed_swLOWtoHIGHall, [],[],[],sanitycheckON);
        
        
        probabilitydata=dataout;
        save(ppants(ippant).name, 'probabilitydata', '-append')
        
        
        
        
        %store for later in matrix.
        
        
    end 
end