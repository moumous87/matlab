function [GrossPrice, NetPrice]=Annuity_FCN(Settle, Maturity, Period, Basis,Coupon, CreditSpread,NSparameters)

%This Function computes the price of a Fixed Coupon Bond
%INPUT: 
%       Settle:     Settlement date in this format: "dd-mm-yyyyy";
%       Maturity:   Maturity date in this format: "dd-mm-yyyyy";
%       Period:     Coupons per year of the bond;
%       Basis:      Basis: 0 = actual/actual, 1= 30/360, 2= actual/360, 3=actual/365;
%       Coupon:     The fixed coupon in decimal terms;
%       Spread:     The relative spread of the bond in decimal terms;
%       CreditSpread: The credit spread of the bond in decimal terms;
%       NSparameters:   The Nelson-Siegel Interpolation parameters;
%OUTPUT:
%       GrossPrice:  The gross price of the Fixed Coupon Bond
%       NetPrice:    The clean price of the Fixed Coupon Bond

% Compute the Cash Flows Dates
Maturity=datenum(Maturity,'dd-mm-yyyy');
Settle=datenum(Settle,'dd-mm-yyyy');
LastCouponDate=cpndatep(Settle, Maturity, Period, Basis);

CFlowDates=cfdates(Settle,Maturity, Period, Basis, 0);
CFlowDates=[LastCouponDate;CFlowDates'];

% Adjust the Cash Flows Dates for the business day
busday=isbusday(CFlowDates);
f=find(busday==0);
CFlowDates(f,1)=CFlowDates(f,1)+1;
busday=isbusday(CFlowDates);
f=find(busday==0);
if isempty(f)
else
    CFlowDates(f,1)=CFlowDates(f,1)+1;

end 

% Compute the Tenor
R=size(CFlowDates,1);
%tenor(1,1)=yearfrac(LastCouponDate,CFlowDates(1,1),Basis);
tenor=yearfrac(CFlowDates(1:end-1,1),CFlowDates(2:end,1),Basis);

% Compute the Time Factors corresponding to bond cash flow dates
TF=yearfrac(Settle*ones(R-1,1),CFlowDates(2:end),Basis);

% Compute the Discount Factors
NSparameters(1)=NSparameters(1)+CreditSpread;
ns_spot=ns(NSparameters,TF);
DF=exp(-TF.*ns_spot);


% Compute the Expected Coupons
Exp_Coupon(1:R-1)=tenor(1:end)*Coupon;
Exp_Coupon(end)=Exp_Coupon(end)+1;

% Compute the Discounted Expected Coupons
Dis_Coupon=Exp_Coupon'.*DF;

% Compute the GROSS PRICE
GrossPrice=sum(Dis_Coupon);

%Accrued Interest
NumDaysPrevious = cpndaysp(Settle, Maturity, Period, Basis);
NumDaysNext = cpndaysn(Settle, Maturity, Period, Basis);
frac=NumDaysPrevious/(NumDaysPrevious+NumDaysNext);
AccInter=frac*Coupon/Period;

% Compute the GROSS PRICE
NetPrice=GrossPrice-AccInter;


