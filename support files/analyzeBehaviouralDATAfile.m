
clear all
close all


%set up base directories
try cd('/Users/MattDavidson/Desktop/XM_Project')
catch
    cd('/Users/MatthewDavidson/Desktop/XMODAL')
end
basedir = pwd;

job.ConcatallwithoutCollapsing =1;
% cycle through each modality.

if job.ConcatallwithoutCollapsing==1
    
    for iXMOD = 1:3
        cd(basedir)
    cd('ANOVAdata_allppants')
        switch iXMOD
            case 1
                XMOD='AnT';
            case 2
                XMOD='AUD';
            case 3
                XMOD='TAC';
        end
        %fill with ppant data, per MOD
        Acrossall_behaviour=[];
        
        cd(XMOD)
%         allppants = dir([pwd filesep 'new' XMOD 'Behaviouraldatafile' '*']);
        allppants = dir([pwd filesep 'newNOshortswRemoval' XMOD 'Behaviouraldatafile' '*']);
        
        % start by concatenating all ppants into one.
        for ippant = 1:length(allppants)
            load(allppants(ippant).name)
            
            %create
            NEWtable1=[];
            NEWtable2=[];
            tablenow=[];
            NEWtable1 = cell2table(datafile(2:end,1:27), 'VariableNames',datafile(1,1:27));
            %%
            tmp = datafile(2:241,28);
            
            %%
            %have to hack around to keep the BP trace in a single cell.
            for ir =1:240
                datain = tmp{ir,:};
                NEWtable1{ir,28} = {datain};
            end
            NEWtable1.Properties.VariableNames( 28 ) = {'congruentTrace0to7sec'};
            %%
            NEWtable2 = cell2table(datafile(2:end, 29:35),'VariableNames',datafile(1,29:35));
            %%
            NEWtable2{:,8} = {rall}; 
             NEWtable2.Properties.VariableNames([ 8 ]) = {'ppantAttendR'};
            %%1
            tablenow = [NEWtable1, NEWtable2];
            %%%%%%%%
            %%%%%%%%
            % Now Concat across ppants, per modality.
            Acrossall_behaviour = [Acrossall_behaviour; tablenow];
            
        end
        save('newnoswRemovalAcrossALL_Behaviouraldata_nocollapsing', 'Acrossall_behaviour')
    end
end