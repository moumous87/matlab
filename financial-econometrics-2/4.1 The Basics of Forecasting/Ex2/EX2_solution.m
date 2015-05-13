
% EXERCISE 1 and EXERCISE 2:

% Run datatran_int.m (NB: only data transformations are needed)

%-------------------------------------------------------------------------
% EXERCISE 3:

% Select the analysis period
date=datenum(textdata(2:end,1),'dd/mm/yyyy');
f1=['31/03/1973'];
f2=['31/12/2009'];
date_find1=datenum(f1,'dd/mm/yyyy');
date_find2=datenum(f2,'dd/mm/yyyy');
first=datefind(date_find1,date);
last=datefind(date_find2,date);

% AR estimation:
spec=garchset('VarianceModel','Constant', 'R', 1);
[coeff,errors,llf,innovation,sigma,summary]=garchfit(spec,us_dy(first:last));
garchdisp(coeff,errors);
us_dy_fit=us_dy(1,1);
us_dy_fit(2:last,1)=coeff.C+coeff.AR*us_dy(first:last-1);

% Plot the estimation results:
s=1:last;

figure;
plot(s',us_dy, 'r', s', us_dy_fit,'--');
set(gca,'fontname','garamond','fontsize',10);
set(gca, 'xtick', [1:8:rows(s')]);
set(gca,'xlim', [1 rows(s')]);
set(gca,'xticklabel','1973|1975|1977|1979|1981|1983|1985|1987|1989|1991|1993|1995|1997|1999|2001|2003|2005|2007|2009');
title('AR(1) Estimation','fontname','garamond','fontsize',14);
h = legend('Actual', 'Fitted',0);
grid;
set(gcf,'color','w');

% AR forecasting:
horz=10*4;

[SigmaForecast,MeanForecast,SigmaTotal,MeanRMSE] = garchpred(coeff,us_dy(first:last),horz);
forecast_ar=MeanForecast;
forecast_up=MeanForecast+2*MeanRMSE;
forecast_down=MeanForecast-2*MeanRMSE;

% Plot the forecasting results:
t=1:horz;

figure;
plot(t',forecast_ar, t', forecast_up, t', forecast_down);
set(gca,'fontname','garamond','fontsize',10,'gridlinestyle',':');
set(gca, 'xtick', [1:4:rows(t')]);
set(gca,'xlim', [1 rows(t')]);
set(gca, 'xticklabel', '2010|2011|2012|2013|2014|2015|2016|2017|2018|2019|2020');
title('AR Forecast','fontname','garamond','fontsize',14);
h = legend('AR', 'Upper Bound' ,'Lower Bound',0);
grid;
set(gcf,'color','w');

%--------------------------------------------------------------------------
% EXERCISE 4

% AR forecasting if beta=1:
spec_forecast1=garchset('VarianceModel', 'Constant', 'C', coeff.C, 'R',1, 'AR',0.999999999, 'K', coeff.K);
[SigmaForecast1,MeanForecast1,SigmaTotal1,MeanRMSE1] = garchpred(spec_forecast1,us_dy(first:last),horz);
forecast_ar1=MeanForecast1;
forecast_up1=MeanForecast1+2*MeanRMSE1;
forecast_down1=MeanForecast1-2*MeanRMSE1;

% Plot the results:
figure;
plot(t',forecast_ar1, t', forecast_up1, t', forecast_down1);
set(gca,'fontname','garamond','fontsize',10,'gridlinestyle',':');
set(gca, 'xtick', [1:4:rows(t')]);
set(gca,'xlim', [1 rows(t')]);
set(gca, 'xticklabel', '2010|2011|2012|2013|2014|2015|2016|2017|2018|2019|2020');
title('AR Forecast if \beta=1','fontname','garamond','fontsize',14);
h = legend('AR', 'Upper Bound' ,'Lower Bound',0);
grid;
set(gcf,'color','w');

% Compare the previous results.
beta=strvcat('\beta=0.98','\beta=1');
X=[forecast_ar forecast_up forecast_down forecast_ar1 forecast_up1 forecast_down1];

figure;
m=0;
for i=1:2
subplot(1,2,i);
plot(X(:,1+m:3+m));
set(gca,'fontname','garamond','fontsize',10);
set(gca, 'xtick', [1:4:rows(t')]);
set(gca,'xlim', [1 rows(t')]);
set(gca, 'xticklabel', '2010|2011|2012|2013|2014|2015|2016|2017|2018|2019|2020');
tit=strcat('AR forecast: ', beta(i,:));
title(tit,'fontname','garamond','fontsize',14);
h = legend('AR', 'Upper Bound' ,'Lower Bound',0);
grid;
set(gcf,'color','w');
m=3;
end

%--------------------------------------------------------------------------
% EXERCISE 5

% Resampling the residuals in (3):
f=ceil(last .*rand(1,last));
shock=innovation(f);

% Initializing the series:
x1=us_dy(1,1);
x2=us_dy(1,1);

% Artificial series:
for i=1:last-1
    x1(i+1,1)=coeff.C+coeff.AR*x1(i,1)+innovation(i+1,1);
    x2(i+1,1)=coeff.C+coeff.AR*x2(i,1)+shock(i+1,1);
end

p=1:last;
figure;
plot(p',x1,'x',p',x2,p',us_dy);
set(gca,'fontname','garamond','fontsize',10);
set(gca, 'xtick', [1:8:rows(p')]);
set(gca,'xlim', [1 rows(p')]);
set(gca,'xticklabel','1973|1975|1977|1979|1981|1983|1985|1987|1989|1991|1993|1995|1997|1999|2001|2003|2005|2007|2009');
title('Artificial Series','fontname','garamond','fontsize',14);
h = legend('x1', 'x2' ,'us\_dy',0);
grid;
set(gcf,'color','w');

%--------------------------------------------------------------------------
% EXERCISE 6

% Error terms:
vol=std(innovation);
u1=vol.*normrnd(0,1,last,1);
u2=vol.*normrnd(0,1,last,1);
u3=vol.*normrnd(0,1,last,1);

% Initializing the series:
xt=us_dy(1,1);
yt=us_dy(1,1);
zt=us_dy(1,1);

% Artificial series:
for i=1:last-1
    xt(i+1,1)=coeff.C+coeff.AR*xt(i,1)+u1(i+1,1);
    yt(i+1,1)=yt(i,1)-0.1*(yt(i,1)-xt(i,1))+u2(i+1,1);
    zt(i+1,1)=zt(i,1)+u3(i+1,1);
end

% Plot the results:
figure;
plot(p',xt,p',yt,p',zt);
set(gca,'fontname','garamond','fontsize',10);
set(gca, 'xtick', [1:8:rows(p')]);
set(gca,'xlim', [1 rows(p')]);
set(gca,'xticklabel','1973|1975|1977|1979|1981|1983|1985|1987|1989|1991|1993|1995|1997|1999|2001|2003|2005|2007|2009');
title('Artificial Series: coeff = - 0.1','fontname','garamond','fontsize',16);
h = legend('xt', 'yt' ,'zt',0);
grid;
set(gcf,'color','w');

%--------------------------------------------------------------------------

% EXERCISE 7

yt2=us_dy(1,1);
for i=1:last-1
yt2(i+1,1)=yt2(i,1)-0.8*(yt2(i,1)-xt(i,1))+u2(i+1,1);
end

% Plot the results:
figure;
plot(p',xt,p',yt2,p',zt);
set(gca,'fontname','garamond','fontsize',10);
set(gca, 'xtick', [1:8:rows(p')]);
set(gca,'xlim', [1 rows(p')]);
set(gca,'xticklabel','1973|1975|1977|1979|1981|1983|1985|1987|1989|1991|1993|1995|1997|1999|2001|2003|2005|2007|2009');
title('Artificial Series: coeff = - 0.8','fontname','garamond','fontsize',16);
h = legend('xt', 'yt2' ,'zt',0);
grid;
set(gcf,'color','w');

% Compare the results in EX6 and EX7

param=strvcat(' coeff = - 0.1', ' coeff = - 0.8');
var=strvcat('yt','yt2');
X1=[yt yt2];

figure;
for i=1:2
subplot(1,2,i)
X=[xt zt X1(:,i)];
plot(X)
set(gca,'fontname','garamond','fontsize',10);
set(gca, 'xtick', [1:12:rows(p')]);
set(gca,'xlim', [1 rows(p')]);
set(gca,'xticklabel','1973|1976|1979|1982|1985|1988|1991|1994|1997|2000|2003|2006|2009');
tit=strcat('Artificial Series: ', param(i,:));
title(tit,'fontname','garamond','fontsize',12);
tit2=(var(i,:));
h = legend('xt', 'yt' ,tit2,0);
grid;
set(gcf,'color','w');
end
%-------------------------------------------------------------------------