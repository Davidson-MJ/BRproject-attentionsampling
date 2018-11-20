
% get channel info.
getelocs
%check if tvals at wanted chans exceed shuffled likelihood.
%% compare the increase in ASH to zero (since a diff already)
% extract tvalues at spatially coincident p<05 electrodes,
%(uncorrected)
checkchans=sigchans

% clf
ASHt1=tmp1;
ASHt2=tmp2;
% figure(2)
% clf
% % colormap('parula')
% % subplot(211); topoplot(mean(ASHt1,1)-mean(ASHt2,1),elocs(1:64),'emarker2', {[checkchans], '*', 'w', 10, 5});
%%

if exist('picexist')
    delete(picexist)
end
%
tvalsperchan = zeros(1,length(checkchans));

nshuff=2000;

storemax = zeros(nshuff,1);
for itest = [1:length(checkchans)]
    ichan = checkchans(itest);
    data1 = ASHt1(:,ichan);
    data2 = ASHt2(:,ichan);
    
    testmenow = data1-data2;
    [~, p, ~,stat]= ttest(testmenow);
    
    
    tvalsperchan(1,itest) = stat.tstat;
end
% this the accrued test statistic (total), we have to
% check against, after shuffling the data (Maris&Oostenveld)

observedCV = sum((tvalsperchan));

observedCV = sum(abs(tvalsperchan));
%
% now repeat the above process, but create random partitions:
sumTestStatsShuff = zeros(1,nshuff);

for irand = 1:nshuff
    %testing the null that it isn't mismatched - matched at time 2
    % which creates a diff. so select from either!
    
    shD= zeros(2,64,34);
    
    for ipartition = 1:2
        for ippant = 1:34
            for ichan=1:64
                if mod(randi(100),2)==0 %if random even number
                    %                             pdata = ASHt1(randi(34), ichan); %select both chans
                    pdata = ASHt1(ippant, ichan); %select both chans
                else %
                    %                         pdata = ASHt2(randi(34), ichan); %select both chans
                    pdata = ASHt2(ippant, ichan); %select both chans
                    
                end
                
                shD(ipartition,ichan,ippant) = pdata;
            end
        end
    end
    
    %now compute difference between our hypothetical topoplots,
    % and test for sig, checking the accumulated test statistic at our
    % chans of interest
    
    tvalsperchan2 = zeros(1,length(checkchans));
    
    %             if length(checkchans>1)
    %             testdata = squeeze(shD(1,:,:)) - squeeze(shD(2,:,:));
    %             else
    %                 testdata = (shD(1,:,:)) - (shD(2,:,:));
    %                 testdata=testdata';
    %             end
    
    for itest = 1:64
        
        if length(checkchans)>1
            [~, p(itest), ~,stat]= ttest(testdata(itest,:));
        else
            [~, p(itest), ~,stat]= ttest(testdata);
        end
        
        tvalsperchan2(1,itest) = stat.tstat;
    end
    
    
    
    % now the crucial part. Find the max tstat, and nearest
    % neighbour.
    
    
    [~,mxchn] = (max(tvalsperchan2));
    
    
    
    %find sig neighbours, take max.
    
    %consult the neighbours
    neighbchan = elocs_neighbours(mxchn).neighbnum;
    
    % remove diagnoals if <3.5 inter-elec dist.
    diffch= mxchn-neighbchan;
    rmdiag=find(abs(diffch)<12); % horiz and vert offset electrodes are closest, with diffs in elec numbers <|12|
    neighbchan(rmdiag)=[];
    
    %populate neighbs with tscores and pvals
    tneighbs=[];
    pneighbs =[];
    for ineighbs = 1:length(neighbchan)
        tneighbs(ineighbs) = tvalsperchan2(neighbchan(ineighbs));
        %                 pneighbs(ineighbs) = p(neighbchan(ineighbs));
    end
    
    [~,nmax ]= max((tneighbs));
    %should be sig
    
    
    %store max
    tvalsthisshuff = [tvalsperchan2(mxchn), tneighbs(nmax)];
    %then store.
    
    sumTestStatsShuff(1,irand) = sum((tvalsthisshuff));
    
    %             storemax(irand)=mxchn;
    
end %repeat nshuff times
% %
% %
clf
%       picexist=subplot(211);
%plot histogram:
H=histogram(abs(sort(sumTestStatsShuff)));
% fit CDF
cdf= cumsum(H.Data)/ sum(H.Data);
%the X values (actual CV) corresponding to .01
[~,cv05uncorr] = (min(abs(cdf-.95)));
[~,cv005uncorr] = (min(abs(cdf-.995)));
[~,cv001uncorr] = (min(abs(cdf-.999)));
hold on

%
yt=ylim;
pCV=plot([observedCV observedCV],[0 yt(2)/2], ['r-'], 'linew', 2);
text(H.Data(cv05uncorr)-.2, yt(2)/2 + yt(2)/10, '95%', 'fontsize', 20)
plot([H.Data(cv05uncorr) H.Data(cv05uncorr)], [0 yt(2)/2], ['k:'], 'linew', 2)

legend([pCV ], {['Observed [' num2str(elocs(checkchans(1)).labels) ',' num2str(elocs(checkchans(2)).labels) ']']})

xlabel('maximum clustered \itt\rm-scores per shuffle')
ylabel(['\itN \rm =' num2str(nshuff) ' shuffles'])
%                     xlim([0 7])




if observedCV>H.Data(cv05uncorr)
    %observed pvalue in distribution=
    [~, c2] = min(abs(H.Data-observedCV)); %closest value.
    pvalis= 1-cdf(c2);
    %
else
    %                         title('Spatial Cluster  ns!')
end
set(gca, 'fontsize', 15)
set(gcf, 'color', 'w')
shg


%%
cd('/Users/matthewdavidson/Desktop')
print('-dpng', 'cluster2')
