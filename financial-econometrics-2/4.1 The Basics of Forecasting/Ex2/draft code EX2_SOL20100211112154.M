clc, clear, close all;
%Exercise 2

%UPLOAD DATASET 

[filename,pathname]=uigetfile('*.xls');
[data,textdata,raw] = xlsread(filename,1);


%--------------------------------------------------------------------------

% QUESTION N.2

% Data trasformation
us_p=data(:,1);
us_ret_1=NaN(size(us_p));
us_div=NaN(size(us_p));
us_10y=NaN(size(us_p));
us_cpi=data(:,14);
us_infl_1=NaN(size(us_p));
us_dy=NaN(size(us_p));
us_d=NaN(size(us_p));
us_ldiv=NaN(size(us_p));
us_ret_m=NaN(size(us_p));
us_ret_w=NaN(size(us_p));
us_biann=NaN(size(us_p));


% Rendimento trimestrale annualizzato:

us_ret_1(2:end,1)=4*log(data(2:end,2)./data(1:end-1,2));
% Dividend yield trimestrale (log):
us_dy(1:end,1)=log(data(1:end,3)/100);
% Div in livello trimestrale:
us_d(1:end,1)=data(:,3).* data(:,1)/100;
% Div trimestrale annualizzato:
us_div(4:end,1)= 0.25*(us_d(4:end,1)+us_d(3:end-1,1)+us_d(2:end-2,1)+us_d(1:end-3,1));
% Div trimestrale annualizzato (log):
us_ldiv(1:end,1)=log(us_div(1:end,1));

% log stock returns over several maturities

us_ret_m(2:end,1)=(1/3)*log(data(2:end,2) ./ data(1:end-1,2));
us_ret_w(2:end,1)=(1/12)*log(data(2:end,2) ./ data(1:end-1,2));
us_biann(2:end,1)=8*log(data(2:end,2)./data(1:end-1,2));
us_10y(1:end,1)=data(1:end,18)/100;
us_infl_1(2:end,:)=4*(log(us_cpi(2:end,:))-log(us_cpi(1:end-1,:)));
%--------------------------------------------------------------------------

%QUESTION N.3

%select the analysis period
date=datenum(textdata(2:end,1),'dd/mm/yyyy');
f=['31/12/2009'];
date_find=datenum(f,'dd/mm/yyyy');
ind=datefind(date_find,date);

%AR(1) estimation
spec=garchset('VarianceModel','Constant','R',1);
[coeff,errors,llf,innovation,sigma,summary]=garchfit(spec,us_dy(1:ind));
garchdisp(coeff,errors);
%AR forecast
spec_pred=garchset('VarianceModel','Constant','C',coeff.C,'R',1,'AR',coeff.AR,'K',coeff.K);
[SigmaForecast,MeanForecast,SigmaTotal,MeanRMSE] = garchpred(spec_pred,us_10y(1:ind),10*4);
Forecast_ar=MeanForecast;
Forecast_up=MeanForecast+2*MeanRMSE;
Forecast_down=MeanForecast-2*MeanRMSE;

% Plot the result
figure
plot([Forecast_ar Forecast_up Forecast_down]);
title('AR Forecast');
h = legend('AR', 'Upper Level' ,'Lower Level',2);
%--------------------------------------------------------------------------

% QUESTION N.4

% AR forecast with 1 as coefficient
spec_pred1=garchset('VarianceModel','Constant','C',coeff.C,'R',1,'AR',0.999999999,'K',coeff.K);
[SigmaForecast1,MeanForecast1,SigmaTotal1,MeanRMSE1] = garchpred(spec_pred1,us_dy(1:ind),10*4);
Forecast_ar1=MeanForecast1;
Forecast_up1=MeanForecast1+2*MeanRMSE1;
Forecast_down1=MeanForecast1-2*MeanRMSE1;

% Plot the result
figure
plot([Forecast_ar1 Forecast_up1 Forecast_down1]);
title('AR Forecast (\alpha_{1}=1');
h = legend('AR', 'Upper Level' ,'Lower Level',2);
%--------------------------------------------------------------------------

% QUESTION N.5

% Resampling
f = ceil(ind.*rand(1,ind));
shock=innovation(f);

% Construct artificial series
% Inizialising the series
x1(1,1)=us_dy(1,1);
x2(1,1)=us_dy(1,1);
for i=1:ind-1
    x1(i+1,1)=coeff.C+coeff.AR*x1(i,1)+innovation(i+1,1);
    x2(i+1,1)=coeff.C+coeff.AR*x2(i,1)+shock(i+1,1);
end

figure;
plot(x1,'g');
hold on
plot(x2,'b');
hold on
plot(us_dy,'r');
legend('x1','x2','us_10y')
hold off

%--------------------------------------------------------------------------

% QUESTION N.6

u1=std(innovation)*normrnd(0,1,37*4);
u2=std(innovation)*normrnd(0,1,37*4);
u3=std(innovation)*normrnd(0,1,37*4);

% Construct artificial series
% Inizialising the series
x(1,1)=us_dy(1,1);
y(1,1)=us_dy(1,1);
z(1,1)=us_dy(1,1);
for i=1:37*4-1
    x(i+1,1)=coeff.C+coeff.AR*x(i,1)+u1(i+1,1);
    y(i+1,1)=y(i,1)-0.1*(y(i,1)-x(i,1))+u2(i+1,1);
    z(i+1,1)=z(i,1)+u3(i+1,1);
end

% Plot the result
figure
plot([x y z]);
title('Artifical series with coeff -0.1');
h = legend('X', 'Y' ,'Z',2);
%--------------------------------------------------------------------------

% QUESTION N.7

% Changing coefficient
for i=1:37*4-1
    x(i+1,1)=coeff.C+coeff.AR*x(i,1)+u1(i+1,1);
    y(i+1,1)=y(i,1)-0.8*(y(i,1)-x(i,1))+u2(i+1,1);
    z(i+1,1)=z(i,1)+u3(i+1,1);
end

% Plot the result
figure
plot([x y z]);
title('Artifical series with coeff -0.8');
h = legend('X', 'Y' ,'Z',2);

