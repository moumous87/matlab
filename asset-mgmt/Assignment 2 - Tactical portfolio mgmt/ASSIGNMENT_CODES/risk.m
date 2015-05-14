
clc

%% RUNNING A MULTIVARIATE PANEL REGRESSION ON THE OUT-OF-SAMPLE DATA


load database


ti=unique(time);
nd=size(ti,1);

%Take only the out-of-sample portion
osdb=db(year(journal)>2001,:);

osdates=unique(journal(year(journal)>2001));
ostime=time(year(journal)>2001);
osti=unique(ostime);
osnd=size(osti,1);

vr=[1 2 6 8 15];


%We Isolate the variables that we want to use

sn=signames(vr)';
mod=db(:,vr);

dbx=[mod ret];

%We now run a Panel Regression Model with time fixed effects

np=floor((osnd-60)/3);

pan=zeros(11,size(vr,2));
ris=zeros(np,2*size(vr,2)+1);
coef=zeros(np,size(vr,2));


for j=1:np

    %We individuate the time indicator of the observation
    t=(j-1)*3+12+1;

    %We extract the sub-database with the observations that we
    %will use in this particular iteration
    dbm=dbx((ostime<=osti(t) & ostime>osti(t-12)),:);  
    tim=time((ostime<=osti(t) &ostime>osti(t-12)),:);

    %We run the univariate panel regression
    [b de st]=panel(dbm(:,1:size(vr,2)), dbm(:,end), tim);

    ris(j,:)=[b(2:size(vr,2)+1)' st.p(2:size(vr,2)+1)' 1-(nanvar(st.resid)/nanvar(dbm(:,end)))];
    
    coef(j,:)=b(2:size(vr,2)+1)';

end


for i=1:size(vr,2)

    
    [h p]=ttest(ris(:,i));
    
    pan(1,i)=size(ris(ris(:,i)>0),1)/np; % Positive beta
    pan(2,i)=size(ris(ris(:,i)<0),1)/np; % Negative beta
    pan(3,i)=size(ris(ris(:,size(vr,2)+i)<0.1),1)/np; % Significant beta
    pan(4,i)=size(ris(ris(:,i)>0 & ris(:,size(vr,2)+i)<0.1 ),1)/np; % Pos & Sig
    pan(5,i)=size(ris(ris(:,i)<0 & ris(:,size(vr,2)+i)<0.1 ),1)/np; % Neg & Sig
    pan(6,i)=mean(ris(:,2*size(vr,2)+1)); %- Mean R-Squared
    pan(7,i)=p; %- P-Value
    pan(8,i)=mean(ris(:,i))*100; %- Mean Coeff. X 100
    pan(9:11,i)=quantile(ris(:,i),[.50 .25 .75])*100; %  median, 1st quartile, 3rd quartile x 100
    
end


dateb(np,1)=0;

for j=1:np
    
    t=(j-1)*3+12+1;

    dateb(j)=osdates(t);
    
end

figure
plot(dateb,coef);
grid on
legend(sn,'location','northwest')
dateaxis('x',12)
title('Coefficienti')
xlim([dateb(1) dateb(end)])
grid on


%xlswrite('pan.xls',pan,'pan_expost','B2')

% WE DIDN'T USE XLSWRITE FOR PROBLEMS OF INCOMPATIBILITY WITH OUR OPERATING
% SYSTEMS... SO WE JUST COPIED AND PASTED THE RESULTS JUST OPENING THE
% VARIABLES IN THE WORKSPACE

%% ESTIMATING BENCHMARK VOLATILITY WITH EXPONENTIAL SMOOTHING

spec=garchset('P',1,'Q',1);
[coeff, errors,~,~,~,~]=garchfit(spec,benchmark);
garchdisp(coeff,errors);

param(1:4,1)=[coeff.C;coeff.K;coeff.GARCH;coeff.ARCH];

parm=0.1;
logL=maxlik('objfunction',parm,[],benchmark);
lambda=logL.b;

cond_var_es=NaN(nd,1);

cond_var_es(1)=param(2)/(1-param(3)-param(4));

for i=2:nd
cond_var_es(i)=lambda*cond_var_es(i-1)+(1-lambda)*benchmark(i-1)^2;
end

vol=sqrt(cond_var_es);


clear param coeff errors
clc

% plot volatility
figure
plot(dates,vol,'b')
hold on
plot(dates,benchmark,'k')
dateaxis('x',12)
xlim([dates(1) dates(end)])
title('Volatility estimated with the Exponential Smoothing')
legend('volatility','benchmark')
grid on


% VALUE AT RISK

start=find(dates==datesp(1))+3;
VaR=-vol(start:end)*norminv(0.99);

figure
plot(dates(start:end),VaR,'r','linewidth',2)
hold on
plot(dates(start:end),[po1 ben])
dateaxis('x',12)
xlim([dates(start) dates(end)])
title('VaR (portfolio and benchmark)')
legend('VaR','portfolio','benchmark')
grid on


%% RISK-ADJUSTED PERFORMANCE MEASURES
clc



sharpe1=12*mean(pon1)/std(pon1)
sharpe2=12*mean(pon2)/std(pon2)

[b,dev,st]=glmfit(pon1,ben);
[b2,dev2,st2]=glmfit(pon2,ben);

treynor1=12*mean(pon1)/b(2)
treynor2=12*mean(pon2)/b(2)

alpha1=b(1)
alpha2=b2(1)

RAROC=-pon1./VaR  

% You'll see displayed the results of of the above risk-adjusted
% performance measure in the Command Window 








