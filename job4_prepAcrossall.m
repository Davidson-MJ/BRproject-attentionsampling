% function job4_prepAcrossall(pathtoEpocheddata, Epochlength)
%concatenates Across all participants, and reshapes to be user friendly for
%next analysis.
%changed to reduce file size (save conditions independently)
Fs=250;
absEpochdur = sum(abs(Epochlength(1)) + Epochlength(2))*Fs +1;


cd(pathtoEpocheddata)
%%
allppants = dir(['ppant*']);
%%
%preallocate for speed
% [nppants, nphase, nhz, nblocks* ntrials, nchans, nsamps]=size(ACROSS_allAUD);
%separate save for group A and nA
ACROSS_all = zeros(length(allppants),2 ,2, 24,64, absEpochdur);

%%

%labour intensive, use one day at a time.
% for
idayis=1; %save at the end according to which day for each group.
Attending_day1group_count=1;
nAttending_day1group_count=1;


Attendingnow_allAnT = zeros(size(ACROSS_all));
nAttendingnow_allAnT = zeros(size(ACROSS_all));

Attendingnow_allAUD = zeros(size(ACROSS_all));
nAttendingnow_allAUD = zeros(size(ACROSS_all));

Attendingnow_allTAC = zeros(size(ACROSS_all));
nAttendingnow_allTAC = zeros(size(ACROSS_all));

%% %rerun from here and work through all ppants.
for ippant = 1:3%10%length(allppants)
    
    cd(allppants(ippant).name)
    load('GroupedEpochsStructure')
    
    
    if size(allAnT.day,2)>=idayis %only continue if second day data exists.
        for icomb=1:6
            switch icomb
                case 1
                    usedata=allAnT.day(idayis).Inphase;
                    phaseis=1;
                case 2
                    usedata=allAnT.day(idayis).Outofphase;
                    phaseis=2;
                case 3
                    usedata=allAUD.day(idayis).Inphase;
                    phaseis=1;
                case 4
                    usedata=allAUD.day(idayis).Outofphase;
                    phaseis=2;
                case 5
                    phaseis=1;
                    usedata=allTAC.day(idayis).Inphase;
                case 6
                    usedata=allTAC.day(idayis).Outofphase;
                    phaseis=2;
            end
            
            %concatenate trials (n=6) across blocks(n=4).
            datatmp=zeros(4,2,6,64,absEpochdur);
            
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
            
            datatmp=[]; %clear as we go.
            
            if strcmp(day1cond, 'Attend')  %each participant.
                if idayis==1
                    switch icomb
                        case {1, 2}
                            Attendingnow_allAnT(Attending_day1group_count,phaseis,:,:,:,:)= nowdata;
                        case { 3, 4}
                            Attendingnow_allAUD(Attending_day1group_count,phaseis,:,:,:,:)= nowdata;
                        case {5,6}
                            Attendingnow_allTAC(Attending_day1group_count,phaseis,:,:,:,:)= nowdata;
                    end
                    
                    
                else %still Attend condition on day 1, but now it's day 2
                    
                    switch icomb
                        case {1, 2}
                            nAttendingnow_allAnT(Attending_day1group_count,phaseis,:,:,:,:)= nowdata;
                        case {3, 4}
                            nAttendingnow_allAUD(Attending_day1group_count,phaseis,:,:,:,:)= nowdata;
                        case {5,6}
                            nAttendingnow_allTAC(Attending_day1group_count,phaseis,:,:,:,:)= nowdata;
                    end
                end
                
            else % day1 was nonAttend (opposite case)
                
                if idayis==1
                    switch icomb
                        case {1, 2}
                            nAttendingnow_allAnT(nAttending_day1group_count,phaseis,:,:,:,:)= nowdata;
                        case {3, 4}
                            nAttendingnow_allAUD(nAttending_day1group_count,phaseis,:,:,:,:)= nowdata;
                        case {5,6}
                            nAttendingnow_allTAC(nAttending_day1group_count,phaseis,:,:,:,:)= nowdata;
                    end
                    
                else
                    
                    switch icomb
                        case {1, 2}
                            Attendingnow_allAnT(nAttending_day1group_count,phaseis,:,:,:,:)= nowdata;
                        case { 3, 4}
                            Attendingnow_allAUD(nAttending_day1group_count,phaseis,:,:,:,:)= nowdata;
                        case {5,6}
                            Attendingnow_allTAC(nAttending_day1group_count,phaseis,:,:,:,:)= nowdata;
                    end
                    
                end
            end
        end
        
        
        if strcmp(day1cond, 'Attend') %count how many per group to reduce size.
            
            Attending_day1group_count=Attending_day1group_count+1;
            
        else
            nAttending_day1group_count =nAttending_day1group_count+1;
            
        end
    else
        disp([' No day 2 for ' num2str(ippant)])
    end
    disp(['Fin ppant' num2str(ippant)])
    cd(pathtoEpocheddata)
end

%after each day/exp, save accordingly
Attending_day1group_count=Attending_day1group_count-1; %undo last run.
nAttending_day1group_count=nAttending_day1group_count-1; %undo last run.
if idayis==1
    group_A_allAnT.day(1).data=Attendingnow_allAnT(1:Attending_day1group_count,:,:,:,:,:);
    group_A_allAUD.day(1).data=Attendingnow_allAUD(1:Attending_day1group_count,:,:,:,:,:);
    group_A_allTAC.day(1).data=Attendingnow_allTAC(1:Attending_day1group_count,:,:,:,:,:);
    
    group_nA_allAnT.day(1).data=nAttendingnow_allAnT(1:nAttending_day1group_count,:,:,:,:,:);
    group_nA_allAUD.day(1).data=nAttendingnow_allAUD(1:nAttending_day1group_count,:,:,:,:,:);
    group_nA_allTAC.day(1).data=nAttendingnow_allTAC(1:nAttending_day1group_count,:,:,:,:,:);
    
else %day 2
    
    group_A_allAnT.day(2).data=nAttendingnow_allAnT(1:Attending_day1group_count,:,:,:,:,:);
    group_A_allAUD.day(2).data=nAttendingnow_allAUD(1:Attending_day1group_count,:,:,:,:,:);
    group_A_allTAC.day(2).data=nAttendingnow_allTAC(1:Attending_day1group_count,:,:,:,:,:);
    
    group_nA_allAnT.day(2).data=Attendingnow_allAnT(1:nAttending_day1group_count,:,:,:,:,:);
    group_nA_allAUD.day(2).data=Attendingnow_allAUD(1:nAttending_day1group_count,:,:,:,:,:);
    group_nA_allTAC.day(2).data=Attendingnow_allTAC(1:nAttending_day1group_count,:,:,:,:,:);
    
end

disp(['Fin day ' num2str(idayis) ' all']);
A_Groupcounts(idayis)= Attending_day1group_count;
nA_Groupcounts(idayis)= nAttending_day1group_count;
% end

%%
cd(pathtoEpocheddata)
%%
try
    disp(['Group Count A day 1= ' num2str(A_Groupcounts(1))]);
    disp(['Group Count A day 2= ' num2str(A_Groupcounts(2))]);
    disp(['Group Count nA day 1= ' num2str(nA_Groupcounts(1))]);
    disp(['Group Count nA day 2= ' num2str(nA_Groupcounts(2))]);
catch
end
%%
disp(['Size all = ' num2str(length(allppants))]);

try cd('AcrossALL')
catch
    mkdir('AcrossALL')
    cd('AcrossALL')
end
%%
disp('saving...')
save('AcrossGroup_A', 'group_A_allAnT', 'group_A_allAUD', 'group_A_allTAC')
save('AcrossGroup_nA', 'group_nA_allAnT', 'group_nA_allAUD', 'group_nA_allTAC')

disp('Finished job 4, prepping data across all subjects')
% end
