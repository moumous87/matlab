%This script bootstrap a Discount Factors curve starting from a Cash,Futures and Swap rates.
%It supports a xls file called "dataF.xls", where users can upload their rates.
%The format of the xls file doesn't have to be modified. 
%At the end of the code there is a Nelson-Siegel interpolation. In order to
%run it, it is necessary to add to the Matlab path the nelson-siegel
%function, downloadable from the same webpage.

% Bootstrapping Euro Yield Curve
clear all;
% Upload data
[cash text_c]=xlsread('dataF.xls');
[fut text_f]=xlsread('dataF copia.xls');
[swap text_s]=xlsread('dataF copia 2.xls');

% Valuation date
start=datenum('05/05/2009','mm/dd/yyyy');

Year=year(start);
Month=month(start);
Day=day(start);

%************* Construct the date-point for the yield curve **************

% ****** Cash date **********
% Default date
% date(1,1)=start;
% Expiry date of the O/N deposit
date_c(1,1)=start+1;
% Expiry date of the T/N deposit
date_c(2,1)=start+2;
% Expiry date of the 1W deposit
date_c(3,1)=start+7;
% Expiry date of the 2W deposit
date_c(4,1)=start+14;
% Expiry date of the 3W deposit
date_c(5,1)=start+21;
% Expiry dates of the 1M deposit up to the 12M deposits
date_c(6:17)=datenum(Year,Month+[1:12],Day);

% Find the indices of the cash rates specified by the user
ind=find(cash(:,4));
% Set the dates for the deposits
date_c=date_c(ind);

% Load future date
for i=1:size(fut,1)
    % Problem with the extraction of the month, adjustment +10
    m(i,1)=month(datenum(text_f{1+i},'mm/dd/yyyy')+10); 
    y(i,1)=year(datenum(text_f{1+i},'mm/dd/yyyy'));
end
% Set the expiry dates and the delivery dates for the STIR contracts
[ExpiryDates, DeliveryDates] = thirdwednesday(m, y);

% Insert STUB date 
index=find(ExpiryDates(1,1)<date_c,1);
drop_cash_date=date_c(index);

% ****** Future date **********
N=size(ExpiryDates,1);
%Verificare EndDate +1 del prof.Fusai
date_f=[ExpiryDates;DeliveryDates(end)];

% ****** Swap date ************
%Ultimo anno delle date futures
y_f=year(date_f(end));
%Differenza tra l'anno della start date e l'ultimo future
if Month > month(DeliveryDates(end))
    diff_s=ceil(y_f-Year);
else
    diff_s=ceil(y_f-Year)+1;
end
%Trova la posizione dei tassi swap
ind_s=find(swap(:,5));
%Numero anni swap da inserire
r=ind_s(end)-diff_s;
%Date swap, mantenendo fisso il mese ed il giorno
date_s=datenum(Year+[1:ind_s(end)]',Month*ones(ind_s(end),1),Day*ones(ind_s(1),1));
%********************************

%Creo il vettore date finali
date = [date_c(1:index-1);date_f;date_s(diff_s:end,1)];

% %Adjust the date for the business day
busday=isbusday(date);
f=find(busday==0);
date(f,1)=date(f,1)+1;
busday=isbusday(date);
f=find(busday==0);
if isempty(f)
else
    date(f,1)=date(f,1)+1;

end 

%Compute the Year Fraction
% Calcola la frazione di anno con base act/360 cash
Fraction_c = yearfrac(start*ones(ind,1), date_c, 2);
% Calcola la frazione di anno con base act/360 futures
Fraction_f = yearfrac(start*ones(N+1,1), date_f, 2);
% Calcola la frazione di anno con base 30/360 (swaps) - contrllare il +1
Fraction_s = yearfrac(start*ones(ind_s(end),1), date_s, 1);  
% Vettore finale 
Fraction=[Fraction_c(1:index-1);Fraction_f;Fraction_s(diff_s:end,1)];

%************************************************************************
%***************** Discount factors *************************************

%Cash Discount factors
df_c(1:index,1)=1./(1+(cash(ind(1:index),1)./100).*Fraction_c(1:index,1));

%STUB Date discount factor
frac_cash_date= yearfrac(start,drop_cash_date, 2);
%Controllare
%df_frac=1/(1+(cash(index,1)/100).*frac_cash_date);
df_f(1,1)= spline([date_c(index-1,1);date_c(index)],[df_c(index-1);df_c(index)],date_f(1,1));
%DF(index)=0.991649171760;

% Future Discount factors
fra_ret=(100-fut(:,1))./100;
fut_df=1./(1+(fra_ret*91/360));
%df_f(2:size(fut_df,1)+1)=df_f(1,1)*cumprod(fut_df);

 for i= 1:size(fut_df,1)
    df_f(i+1,1)=fut_df(i)*df_f(i,1);
 end

% Swap Discount factors
% Insert the interpoled swap rates 
TF = find(swap(:,5));
x=swap(TF,2);
swap_rate=interp1(TF,x,[1:ind_s(end)])'/100;

% Interpolate the first swap rates
df_s = spline(date_f, df_f, date_s(1:diff_s-1,1));
annuity = cumsum(df_s);
% Per controllo tassi swap interpolati
swap_rate_1 = (1-df_s)./annuity;

% Compute the zero coupon swap rates 
Maturity=date_s;
Coupon=[swap_rate_1; swap_rate(diff_s:end,1)];
Face=100*ones(TF(end),1);
Period=ones(TF(end),1);
Basis=ones(TF(end),1);
End=zeros(TF(end),1);
Bonds=[Maturity Coupon Face Period Basis End];
Prices=100*ones(TF(end),1);
Settle=start;
OutputCompounding=-1;
[ZeroRates, SwapDates] = zbtprice(Bonds, Prices, Settle, OutputCompounding);

% Compute the discount factors from the zero coupon swap rates 
df_s=exp(-ZeroRates.*Fraction_s);

% Set the discount factors
df = [df_c(1:index-1);df_f;df_s(diff_s:end,1)];

plot(Fraction,df);

%Compute the Spot and fwd rate
zero_spot_rate=-log(df)./Fraction;
zero_fwd_rate=-365*(log(df(2:end)./df(1:end-1))./(date(2:end)-date(1:end-1)));

%Plot the curves
figure
plot(Fraction(2:end,1),[zero_spot_rate(2:end,1) zero_fwd_rate],'--d','MarkerSize',5)
title('Zero Spot and Forward Rates');
h=legend('Spot rates','Forward rates',2);

%************************************************************************
%*********************************,***************************************

% %Nelson-Siegel Interpolation
% [parameters nsfit]=nelson_siegel(Fraction,df);
% ns_spot=ns(parameters,Fraction);
% ns_DF=exp(-Fraction.*ns_spot);
% spot=-log(DF)./Fraction;
% % Plot the Euro Discount Factor Curve
% figure
% subplot(2,1,1);
% plot(Fraction,DF,'--d',Fraction,ns_DF,'*','MarkerSize',5)
% title('Euro Discount Curve');
% h=legend('Discount Curve','NS Discount Curve',3);
% axis([0 Fraction(end) 0 1])
% subplot(2,1,2);
% plot(Fraction,spot,'--d',Fraction,ns_spot,'*','MarkerSize',5)
% title('Euro Spot Curve');
% h=legend('Spot Curve','NS Spot Curve',3);
% axis([0 Fraction(end) min(min([spot,ns_spot])) max(max([spot,ns_spot]))])
