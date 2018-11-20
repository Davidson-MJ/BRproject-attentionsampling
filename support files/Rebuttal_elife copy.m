%% Matlab code 
% phases = 2*pi*rand(30,1000); %low trial count condition 
% otherphases = 2*pi*rand(90,1000); %high trial count condition 
% downsampled_otherphases = otherphases(1:30,:); %downsample high trial count % WITHOUT replacement.
% upsampled_phases = repmat(phases,3,1); %upsample low trial count 
% 
% ITPC = abs(mean(exp(1i*phases),1)); 
% otherITPC = abs(mean(exp(1i*otherphases),1)); 
% downsampledITPC = abs(mean(exp(1i*downsampled_otherphases),1)); 
% upsampledITPC = abs(mean(exp(1i*upsampled_phases),1)); 
% 
% figure; hold on
% subplot(2,3,1); hist(ITPC); title('Original phases (low N)'); set(gca,'xlim',[0 0.4],'ylim',[0 250]); xlabel('ITPC'); 
% subplot(2,3,4); hist(otherITPC); title('Original phases (high N)'); set(gca,'xlim',[0 0.4],'ylim',[0 250]); xlabel('ITPC'); 
% 
% subplot(2,3,2); hist(upsampledITPC); title('Upsampled phases (low N)'); set(gca,'xlim',[0 0.4],'ylim',[0 250]); xlabel('ITPC'); 
% subplot(2,3,5); hist(otherITPC); title('Original phases (high N)'); set(gca,'xlim',[0 0.4],'ylim',[0 250]); xlabel('ITPC'); 
% 
% 
% subplot(2,3,3); hist(ITPC); title('Original phases (low N)'); set(gca,'xlim',[0 0.4],'ylim',[0 250]); xlabel('ITPC'); 
% subplot(2,3,6); hist(downsampledITPC); title('Downsampled phases (high N)'); set(gca,'xlim',[0 0.4],'ylim',[0 250]); xlabel('ITPC'); 
%%
% %% End Matlab code 
% 
% %replot with bootstrapping analysis.
% % but compare the same data, with two resample strategies:
% phases = 2*pi*rand(30,1000); %low trial count condition 
% 
% availabletrials=30;
% 
% %original ITPC
% ITPC = abs(mean(exp(1i*phases),1)); 
% 
% nshuffles=200;
% 
% %compare downsampling to upsampling , on the same original dataset.
% %(with replacement).
% 
% trialcounts =[15,30, 50];
% 
% for resampletype=1:3
%     
%     resampleto = trialcounts(resampletype);
%     
%     shuffoutput=zeros(nshuffles,size(phases,2));
%     
% for ishuff=1:nshuffles
%         
%     shuffindx = randi(availabletrials,1, resampleto);
%    resampleddata= phases(shuffindx,:);
% 
%    ITPCtmp = abs(mean(exp(1i*resampleddata),1)); 
%    shuffoutput(ishuff, :)= ITPCtmp;
% end
% 
% switch resampletype
%     case 2
%         resampleITPC = squeeze(mean(shuffoutput,1));
%     case 1
%         downsampledITPC = squeeze(mean(shuffoutput,1));
%     case 3
%         upsampledITPC= squeeze(mean(shuffoutput,1));
% end
% 
% end
% 
% 
% figure(1); clf 
% subplot(4,1,1); hist(ITPC); title(['Original ITPC (N=' num2str(size(phases,1)) ')']); set(gca,'xlim',[0 0.4],'ylim',[0 250]); xlabel('ITPC'); 
% subplot(4,1,2); hist(resampleITPC); title(['resampled with replacement (n=' num2str(trialcounts(2)) ')']); set(gca,'xlim',[0 0.4],'ylim',[0 250]); xlabel('ITPC'); 
% subplot(4,1,3); hist(downsampledITPC); title(['ITPC downsampled with replacement (n=' num2str(trialcounts(1)) ')']); set(gca,'xlim',[0 0.4],'ylim',[0 250]); xlabel('ITPC'); 
% subplot(4,1,4); hist(upsampledITPC); title(['ITPC upsampled with replacement (n=' num2str(trialcounts(2)) ')']); set(gca,'xlim',[0 0.4],'ylim',[0 250]); xlabel('ITPC'); 
% 

%%
%replot with bootstrapping analysis. with and without replacement.

%% Matlab code 
% 
% Replotting ITPC with bootstrapping analysis;
% but compare the same data, with different resample strategies:
% i.e. compare downsampling to upsampling , on the same original dataset.
% (bootstrapping with and without replacement).

%original trial count condition 
phases = 2*pi*rand(30,1000); 
availabletrials=30;

%original ITPC
ITPC = abs(mean(exp(1i*phases),1)); 
bootstraps=200;


figure(1)
clf
placeat=2;% subplot panel ID.
for withreplacementANDwithout=1:2

for resampletype=1:2

%compare resampling original n with/out replacement, to
% downsampling and upsampling with/out replacement.

trialcounts =[15,50]; 
strategiesare = {'downsampling', 'upsampling'};
resampleto = trialcounts(resampletype);
    
shuffoutput=zeros(bootstraps,size(phases,2));
    
    for iboot=1:bootstraps
        if withreplacementANDwithout==1 % then we can have the same trial indices
            shuffindx = randi(availabletrials,1, resampleto);
            %select a subset of trials from those available.            
            %ie with replacement
            rtype='with replacement';
            
        else % if without replacement, then we need to ensure no doubles:
            rtype='without replacement';
            shuffindx = randi(availabletrials,1, availabletrials);
            
            if resampleto<=availabletrials
                while  length(unique(shuffindx))<resampleto
                    %iflength of unique trials does not match needed trials, shuffle remaining.                    
                    %find the length of trials still needed
                    %
                    shuffindx=sort(unique(shuffindx));
                    ntrials = resampleto-(length(shuffindx));
                    
                    remainingtrials = setdiff([1:availabletrials],shuffindx);
                    y=datasample(remainingtrials, ntrials);
                    % add to shuff
                    shuffindx= [shuffindx, y];
                    shuffindx=unique(shuffindx);
                end
            else
                %can't upsample without replacement
                continue
            end
        end
        % now collect the appropriate trials,
    resampleddata= phases(shuffindx,:);
    %take ITPC, 
    %store per shuffle
   ITPCtmp = abs(mean(exp(1i*resampleddata),1)); 
   shuffoutput(iboot, :)= ITPCtmp;
    end
    
    
    %prepare plots.
strategyis=strategiesare{resampletype};

if any(shuffoutput)
subplot(2,2,placeat);
%place original ITPC, then overlay shuffled result.
hs=histogram(ITPC); hold on
histogram( squeeze(mean(shuffoutput,1))); 
title([strategyis ', n=' num2str(trialcounts(resampletype)) '*' num2str(bootstraps) ', ' rtype]); 
set(gca,'xlim',[0 0.4],'ylim',[0 250], 'fontsize', 15); xlabel('ITPC'); 
end
placeat=placeat+1;
end
    
subplot(2,2,1); histogram(ITPC);
title(['Original ITPC (N=' num2str(size(phases,1)) ')'])
set(gca,'xlim',[0 0.4],'ylim',[0 250], 'fontsize', 15); xlabel('ITPC'); 


set(gcf, 'color', 'w')

end
%% End Matlab code
%%
figure(1); clf 
subplot(4,1,1); hist(ITPC); title(['Original ITPC (N=' num2str(size(phases,1)) ')']); set(gca,'xlim',[0 0.4],'ylim',[0 250]); xlabel('ITPC'); 
subplot(4,1,2); hist(resampledITPC); title(['ITPC resampled with replacement * ' num2str(bootstraps) ' (n=' num2str(trialcounts(2)) ')']); set(gca,'xlim',[0 0.4],'ylim',[0 250]); xlabel('ITPC'); 
subplot(4,1,3); hist(downsampledITPC); title(['ITPC downsampled with replacement * ' num2str(bootstraps) '(n=' num2str(trialcounts(1)) ')']); set(gca,'xlim',[0 0.4],'ylim',[0 250]); xlabel('ITPC'); 
subplot(4,1,4); hist(upsampledITPC); title(['ITPC upsampled with replacement* ' num2str(bootstraps) ' (n=' num2str(trialcounts(3)) ')']); set(gca,'xlim',[0 0.4],'ylim',[0 250]); xlabel('ITPC'); 

%% third version, compare downsmapling/upsampling with and without replacement.
%replot with bootstrapping analysis.
% but compare the same data, with two resample strategies:
phases = 2*pi*rand(30,1000); %low trial count condition 

availabletrials=30;

%original ITPC
ITPC = abs(mean(exp(1i*phases),1)); 

bootstraps=200;

%compare downsampling to upsampling , on the same original dataset.
%(with replacement).

trialcounts =15;

for resampletype=1:2
    
%     resampleto = trialcounts(resampletype);
    
    shuffoutput=zeros(bootstraps,size(phases,2));
    
for iboot=1:bootstraps
        
    shuffindx = randi(availabletrials,1, resampleto);
    if resampletype==1 %without replacement
        while length(unique(shuffindx))~= length(shuffindx)
            shuffindx = randi(availabletrials,1, resampleto);
        end
        
    else
        %continue (sampling with replacement, can have same trials selected.
    end
   resampleddata= phases((shuffindx),:);

   ITPCtmp = abs(mean(exp(1i*resampleddata),1)); 
   shuffoutput(iboot, :)= ITPCtmp;
end

switch resampletype
    case 1
        
        resampledITPC_wo= squeeze(mean(shuffoutput,1));
    case 2    
            resampledITPC_with= squeeze(mean(shuffoutput,1));
    
%     case 2
%         resampledITPC= squeeze(mean(shuffoutput,1));
%     case 3
%         upsampledITPC= squeeze(mean(shuffoutput,1));
end

end


figure(1); clf 
subplot(4,1,1); hist(ITPC); title(['Original ITPC (N=' num2str(size(phases,1)) ')']); set(gca,'xlim',[0 0.4],'ylim',[0 250]); xlabel('ITPC'); 
subplot(4,1,2); hist(resampledITPC_wo); title(['ITPC resampled without replacement (n=' num2str(trialcounts) ')']); set(gca,'xlim',[0 0.4],'ylim',[0 250]); xlabel('ITPC'); hold on
subplot(4,1,3); hist(resampledITPC_with); title(['ITPC downsampled with replacement (n=' num2str(trialcounts) ')']); set(gca,'xlim',[0 0.4],'ylim',[0 250]); xlabel('ITPC'); 
% subplot(4,1,4); hist(upsampledITPC); title(['ITPC upsampled with replacement (n=' num2str(trialcounts(3)) ')']); set(gca,'xlim',[0 0.4],'ylim',[0 250]); xlabel('ITPC'); 
%%
figure(1); clf;
for ip=1:5;
    hold on
    plot(shuffoutput(ip,:));
end
    

