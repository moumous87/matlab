clc
clear all
close all

%Read From Excel bootstrapped data
filename='StrippingYield2010.xls';
sheetname='NSInterpolation (Euro)';
datarange='B5:D47';
mktcurve=xlsread(filename,sheetname,datarange);
%extract time to maturities and discount factors
mkt_date=mktcurve(:,1);
mkt_df=mktcurve(:,2);
mkt_spot=mktcurve(:,3);

%assign dates where to interpolate spot and df
%for example the dates are the payment dates of
%a coupon bond paying a 5% coupon quarterly for 5 years
tenor1=0.25
maturity1=5
coupon1=0.05;
notional1=1;
cpndates1=[tenor1:tenor1:maturity1];
%a coupon bond paying a 5% coupon semiannually for 10 years
tenor2=0.5
maturity2=10
coupon2=0.05;
notional2=1;
cpndates2=[tenor2:tenor2:maturity2];

%%%LINEAR INTERPOLATION
%example 1
interpchoice='linear'
li_spot1=interp1(mkt_date, mkt_spot,cpndates1,interpchoice);
li_df1=exp(-li_spot1.*cpndates1);
li_price_1=sum(coupon1*li_df1)*tenor1*notional1+notional1*li_df1(end)

%example 2
li_spot2=interp1(mkt_date, mkt_spot,cpndates2,interpchoice);
li_df2=exp(-li_spot2.*cpndates2);
li_price_2=sum(coupon2*li_df2)*tenor2*notional2+notional2*li_df2(end)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%CUBIC SPLINE INTERPOLATION AND BOND PRICING%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
interpchoice='spline'
%example 1
ci_spot1=interp1(mkt_date, mkt_spot,cpndates1,interpchoice);
ci_df1=exp(-ci_spot1.*cpndates1);
ci_price_1=sum(coupon1*ci_df1)*tenor1*notional1+notional1*ci_df1(end)
%example 2
cpndates=[tenor2:tenor2:maturity2];
ci_spot2=interp1(mkt_date, mkt_spot,cpndates2,interpchoice);
ci_df2=exp(-ci_spot2.*cpndates2);
ci_price_2=sum(coupon2*ci_df2)*tenor2*notional2+notional2*ci_df2(end)


%%%NS INTERPOLATION
mktdata=[mktcurve(:,1) mktcurve(:,3)];
[ns_parameter_fit, lsfit] = lsqnonlin(@(x)ns_fit(x,mktdata),[0.04 0.02 0.01 0.001],[0 0 0 0])
h=figure(1);
plot(mktcurve(:,1), [mktcurve(:,3)  ns_curve(ns_parameter_fit ,mktcurve(:,1))],'*')
title('Market and Nelson-Siegel Interpolation')
legend('Market Spot Rates','NS Spot Rates')
xlabel('Time to Maturity')
xlim([mktcurve(1,1) mktcurve(end,1)])
set(h,'Color',[1 1 1])
print(h,'-dpdf','MktvsNS.pdf')

%%%BOND PRICING
interpchoice='nelsonsiegel'
%example 1
[ns_spot1, ns_df1]=ns_curve(ns_parameter_fit,cpndates1);
ns_price_1=sum(coupon1*ns_df1)*tenor1*notional1+notional1*ns_df1(end)

%example 2
[ns_spot,ns_df2]=ns_curve(ns_parameter_fit,cpndates2);
ns_price_2=sum(coupon2*ns_df2)*tenor2*notional2+notional2*ns_df2(end)


%%%COMPARE FWD CURVES
ci_fwdcurve=(ci_df2(1:end-1)./ci_df2(2:end)-1)/tenor2;
li_fwdcurve=(li_df2(1:end-1)./li_df2(2:end)-1)/tenor2;
ns_fwdcurve=(ns_df2(1:end-1)./ns_df2(2:end)-1)/tenor2;
h=figure(2);
plot(cpndates2(2:end), [ci_fwdcurve'  li_fwdcurve' ns_fwdcurve'])
title('Market and Nelson-Siegel Interpolation')
legend('Cubic','Linear','Nelson-Siegel')
xlabel('Time to Maturity')
xlim([cpndates2(2) cpndates2(end)])
set(h,'Color',[1 1 1])
print(h,'-dpdf','FwdCurveCubvsNS.pdf')

%write to excel different interpolated curves
filename ='StrippingYield2010.xls';
sheetname='NSInterpolation (Euro)';
% 
xlswrite(filename, li_spot1',sheetname,'AF7:AF26')
xlswrite(filename, li_spot2',sheetname,'AF37:AF56')
xlswrite(filename, ci_spot1',sheetname,'X7:X26')
xlswrite(filename, ci_spot2',sheetname,'X37:X56')
