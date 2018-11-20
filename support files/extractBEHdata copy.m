function r_ranked=extractBEHdata(BEHwindow,MismorMatch,AUC,collectVIS)


dbstop if error
% add ppant prob tracking to ANOVAdatafile

try cd('/Users/MattDavidson/Desktop/XM_Project/DATA_newhope/figs')
catch
    cd('/Users/MatthewDavidson/Desktop/XMODAL/DATA_newhope/figs')
end
%
load('groupTracking_byday(nppant,xmod,iph,ihz,samps).mat');
%%
% so organise into the appropriate trace
if MismorMatch~=3
switch MismorMatch
    case 1
        d1=group_A_Data_MISMATCH;
        d2=group_nA_Data_MISMATCH;
    case 2
        d1=group_A_Data_MATCH;
        d2=group_nA_Data_MATCH;
        
end
%%
%now construct single ppant trace, per type (4 options: A/nA, L/H)
trcount=1;
outn=zeros(4,34);
outn_V=zeros(2,34);
for iatt=1:2
    
    switch iatt
        case 1
             tmp1=squeeze(nanmean(d1.day(1).data,2));
            tmp2= squeeze(nanmean(d2.day(2).data,2));
        case 2
            tmp1=squeeze(nanmean(d1.day(2).data,2));
            tmp2= squeeze(nanmean(d2.day(1).data,2));
    end
    
    
            dataBEHnow=cat(1,tmp1,tmp2); %need low vs high hz.
            %1-4second window.
            samplewindowBEH = [BEHwindow(1)*60:BEHwindow(2)*60];
            
            
            for ihz=1:2
                %look at hz
            tmp= (squeeze(dataBEHnow(:,:,ihz,samplewindowBEH)));
            
            %take mean over phase aswell.
            dataBEH=squeeze(mean(tmp,2));
            %take mean over this window
            if AUC~=1
                dataBEH=squeeze(mean(dataBEH,2));
            else
                %or data by Area Under the Curve
                dataBEH = trapz(1:length(samplewindowBEH), dataBEH');
            end
            outn(trcount,:)=dataBEH';
            trcount=trcount+1;
            end
            
            
            %also collect VISUAL only.
            tmp= (squeeze(dataBEHnow(:,:,3,samplewindowBEH)));
            
            %take mean over phase aswell.
            dataBEH=squeeze(mean(tmp,2));
            %take mean over this window
            if AUC~=1
                dataBEH=squeeze(mean(dataBEH,2));
            else
                %or data by Area Under the Curve
                dataBEH = trapz(1:length(samplewindowBEH), dataBEH');
            end
            outn_V(iatt,:)=dataBEH';
            

end
%perform subtraction - we want attL - rest
r_ranked = outn(1,:) - mean(outn(2:4,:),1);

%attl - nattL
% r_ranked = outn(1,:) - outn(3,:);


% or we can collect the visual only trace for comparison.
if collectVIS==1
    r_ranked = outn(1,:)- mean(outn_V,1);
end
else
    %need to crank out the trace difference for Mism - Match (AttL)
    %find ATT low mism
    trcount=1;
    outn=zeros(2,34);
    
    for mm=1:2
        switch mm
            case 1
                d1=group_A_Data_MISMATCH;
                d2=group_nA_Data_MISMATCH;
                %collect attending mismatch from both groups.
                
                case 2
                d1=group_A_Data_MATCH;
                d2=group_nA_Data_MATCH;
                %collect attending Match from both groups.
        end
        
        %extract Attend conditions.
          tmp1=squeeze(nanmean(d1.day(1).data,2));
          tmp2= squeeze(nanmean(d2.day(2).data,2));
          
          dataBEHnow=cat(1,tmp1,tmp2); %need low vs high hz.
            %1-4second window?
            samplewindowBEH = [BEHwindow(1)*60:BEHwindow(2)*60];
            
        
            ihz=1; %just Lowhz
            %look at hz
            tmp= (squeeze(dataBEHnow(:,:,ihz,samplewindowBEH)));
            %take mean over phase aswell.
            dataBEH=squeeze(mean(tmp,2));
            if AUC~=1
                dataBEH=squeeze(mean(dataBEH,2));
            else
                %or data by Area Under the Curve
                dataBEH = trapz(1:length(samplewindowBEH), dataBEH');
            end
            
            outn(trcount,:)=dataBEH';
            trcount=trcount+1;
    end
        %perform subtraction - we want attLMism - AttLMatch
        r_ranked = outn(1,:) - outn(2,:);
    
    
    end
    
end
