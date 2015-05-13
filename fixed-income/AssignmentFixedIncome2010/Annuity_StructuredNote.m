function price=Annuity_StructuredNote(Settle, Maturity, Period, Basis,NSparameters,CreditSpread,Caprate,Vol,type,phi)

% This function computes the price of different blocks of a Structured note at the Settlement date
%INPUT: 
%       Settle:     Settlement date in this format: "dd-mm-yyyyy";
%       Maturity:   Maturity date in this format: "dd-mm-yyyyy";
%       Period:     Coupons per year of the bond;
%       Basis:      Basis: 0 = actual/actual, 1= 30/360, 2= actual/360, 3=actual/365;
%       CreditSpread: The credit spread of the bond in decimal terms;
%       NSparameters:   The Nelson-Siegel Interpolation parameters;
%       Phi: logical value: phi=1 for caplet (F>K) and phi=-1 for floorlet (F<K);
%       Caprate: a value of the Stike Price (annual rate);
%       Vol:     a scalar with flat volatility value;
%       Type:   the type of note: 1 = Asset/Nothing; 2 = Cash/Nothing1; 3 = Caplet/Floorlet;
%       Phi: logical value: phi=1 for call payoff (F>K) and phi=-1 for put payoff (F<K);
%OUTPUT:
%       Price:      The price of the choosen option



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
tenor=yearfrac(CFlowDates(1:end-1,1),CFlowDates(2:end,1),Basis);

% Compute the Time Factors corresponding to bond cash flow dates
TF=yearfrac(Settle*ones(R-1,1),CFlowDates(2:end),Basis);

% Compute the Discount Factors
ns_spot=ns(NSparameters,TF);
DF_risky=exp(-TF.*(ns_spot+CreditSpread));

% Compute the Forward rates
DF=exp(-TF.*ns_spot);
fwd_rate=(DF(1:end-1)./DF(2:end)-1)./(tenor(2:end));

% Compute the undiscounted coupons 
if type == 1
    [und_value]=UndiscountedBlackDigitalAN(phi,fwd_rate,Caprate,Vol,TF(1:end-1),tenor(2:end));
elseif type == 2
    [und_value]=UndiscountedBlackDigitalCN(phi,fwd_rate,Caprate,Vol,TF(1:end-1),tenor(2:end));
elseif type == 3
    [und_value]=UndiscountedBlackCapFloor(phi,fwd_rate,Caprate,Vol,TF(1:end-1),tenor(2:end));
end

%Compute the dicounted price of the note
price=sum(DF_risky(2:end).*und_value);
    
    







