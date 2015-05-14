%%
clear dbxasset pricexasset

close all, clc % the quantity of graphs is becoming a bit huge, that's why I'm closing it automatically
%you just need to delete the command close all to keep the graphs!!!


%% PANEL REGRESSION WITH TIME-FIXED EFFECTS



np=floor((innd-60)/3); % 60 months is the evaluation period, 3 months is the investment period

pan=zeros(11,nv);
ris=zeros(np,3);
betas=zeros(np,nv);



for i=1:nv
    
    for j=1:np
        
        t=(j-1)*3+60+1; %60 months is the evaluation period
        
        dbt=indb((intime>inti(t-12) & intime<=inti(t)),:); % ti(t-12)<time<=ti(t)
        tim=intime((intime>inti(t-12) & intime<=inti(t)),:); % ti(t-12)<time<=ti(t)
        
        [b de st]=panel(dbt(:,i),dbt(:,end),tim);
        
        ris(j,:)=[b(2) st.p(2) 1-(nanvar(st.resid)/nanvar(dbt(:,end)))];
        %         beta p-value                  R2
        
    end
    
    betas(:,i)=ris(:,1);
    
    [h p]=ttest(ris(:,1));
    
    pan(1,i)=size(ris(ris(:,1)>0),1)/np; % Positive beta
    pan(2,i)=size(ris(ris(:,1)<0),1)/np; % Negative beta
    pan(3,i)=size(ris(ris(:,2)<0.1),1)/np; % Significant beta
    pan(4,i)=size(ris(ris(:,1)>0 & ris(:,2)<0.1),1)/np; % Pos & Sig
    pan(5,i)=size(ris(ris(:,1)<0 & ris(:,2)<0.1),1)/np; % Neg & Sig
    pan(6,i)=mean(ris(:,3)); %- Mean R-Squared
    pan(7,i)=p; %- P-Value
    pan(8,i)=mean(ris(:,1))*100; %- Mean Coeff. X 100
    pan(9:11,i)=quantile(ris(:,1),[.50 .25 .75])*100; %  median, 1st quartile, 3rd quartile x 100
    
end

char({'BOOM !!!'})

% PLOT THE COEFFICIENTS PATTERN
dateb(np,1)=0;

for j=1:np
    
    t=(j-1)*3+12+1;

    dateb(j)=indates(t);
    
end

redline(np,1)=0;

cyclepoint=NaN(np,1);
cyclepoint(dateb==datex(peak1))=0;


for i=1:2:nv
    
figure

subplot(2,1,1)
plot(dateb, betas(:,i))
hold on
plot(dateb, redline,'r')
hold on
plot(dateb,pan(8,i)*ones(np,1)/100,'k -.') % ==> mean
hold on
plot(dateb,pan(10,i)*ones(np,1)/100,'k :','LineWidth',2) % ==> 1st quartile
hold on
plot(dateb,pan(11,i)*ones(np,1)/100,'k :','LineWidth',2) % ==> 3rd quartile
hold on
plot(dateb,cyclepoint,'r *','LineWidth',2)
title(strcat(signames(i)))
dateaxis('x',12)
xlim([dateb(1) dateb(end)])
grid on

subplot(2,1,2)
plot(dateb, betas(:,i+1))
hold on
plot(dateb, redline,'r')
hold on
plot(dateb,pan(8,i+1)*ones(np,1)/100,'k -.') % ==> mean
hold on
plot(dateb,pan(10,i+1)*ones(np,1)/100,'k :','LineWidth',2) % ==> 1st quartile
hold on
plot(dateb,pan(11,i+1)*ones(np,1)/100,'k :','LineWidth',2) % ==> 3rd quartile
hold on
plot(dateb,cyclepoint,'r *','LineWidth',2)
title(strcat(signames(i+1)))
dateaxis('x',12)
xlim([dateb(1) dateb(end)])
grid on

end;


% However rough it might be, a visual of the betas does help a lot in
% choosing the best signals...

% Actually we see that the beta of some signals might have a high
% correlation with the ABSOLUTE return... so in very good times we might
% see a high beta, but also in very bad times we might see a high beta...
% the concept of "good times" & "bad times" must be related to the economic
% trend of each industry... but we can link it more generally to the market
% trend (bullish mkt or bearish mkt).

% In any case, it appears that the state of the economy does affect
% strongly the sign and/or the size of the betas...
% ... so it might be a good idea to build up a dynamic model

%% INDICATOR FOR THE STATE OF THE ECONOMY

% We build an indicator for the state of the economy using the past 3-month
% returns of the benchmark (i.e. a lag-benchmark)
% Ex. if we are in June, we look at the returns of March, April, May
% In creating the indicator we'll try 2 opposite  slutions: a dummy 1-0
% (doesn't work when the mkt is bearish), a dummy 0-1 (doesn't work when
% the mkt is bullish)

% We know that this our "mkt-health" indicator is a rough proxy... we also
% had the intuition (looking at the graphs) that actually one driver of the
% behaviour of the signals might be the volatility of the market (the plot
% of the volatility can be found in the last code)... but our model would
% have become terribly complicated!!! 


benchmark3m(:,:)=sum(prod(1+wbr(:,1:3,1:na),2)-1,3); % 3-month benchmark return
lagbench3(nd,1)=NaN;
lagbench3(4:end)=benchmark(1:end-3);

mktsign=sign(lagbench3);

bull(size(db,1),1)=0;

for i=1:nd

    bull((i-1)*na+1:i*na,1)=mktsign(i);

end

bull10=bull;
bull10(bull10<0)=0;
bull01=-bull;
bull01(bull01<0)=0;


dbuz10=[ones(size(db,1),nv) ret];
dbuz01=[ones(size(db,1),nv) ret];


for i=1:nv+1 % also the returns need to be =0 when the signal is =0, 'cause the Hp is that the signal doesn't work
             % ==> we are deleting a portion of the data
    dbuz10(:,i)=db(:,i).*bull10;

end

for i=1:nv+1 % also the returns need to be =0 when the signal is =0, 'cause the Hp is that the signal doesn't work
             % ==> we are deleting a portion of the data
    dbuz01(:,i)=db(:,i).*bull01;

end

% dbuz10 dbuz01:
% column 1:16  =signals
% column 17    =return


%% Now we can re-perform the panel regression on the new signals, and see what happens

indbuz10=dbuz10(year(journal)<=2001,:);
indbuz01=dbuz01(year(journal)<=2001,:);

save('dbuz.mat','dbuz10','dbuz01')
clear dbuz10 dbuz01 mktsign bull


