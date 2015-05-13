load Assignment_MarketData

%% SUMMARY OF Assignment_MarketData.xls
% EuriborSwap
%columns:   1      2       3    4    5     6
%         Term  Mty/Term  Bid  Mid  Ask  Source
%                                          0=cash rate
%                                          1=swap rate

% Vcub
%columns:   1      2     3     4      5      6      7      8      9     10      11    12     13     14     15     16
%         Term  Strike  ATM  1,75%  2,00%  2,25%  2,50%  3,00%  3,50%  4,00%  5,00%  6,00%  7,00%  8,00%  9,00%  10,00%

%CDS
%columns:   1    2    3   4
%         Date  UBS  JPM  DB


%%
t=EuriborSwap(:,1);
date=EuriborSwap(:,2);
midrate=EuriborSwap(:,4)/100;

busday=isbusday(EuriborSwap(:,2)); % the dates provided are all business days, so no need of adjustment


start=datenum(2005,06,26);
%%

notional=1685.347000;
coupon=0.04019;
issue_date=datenum(2005,06,24);
friday=weekday(issue_date); % remember: 1=Sunday 7=Saturday
maturity_date=datenum(2035,06,29);
singular_contract=notional/4;
maturity=30;

%% DISCOUNT FACTORS
tau(33,1)=0;
tau(2:end,:)=t(2:end)-t(1:end-1);

% LIBOR RATES
disc(1:13,1)=1./(1+midrate(1:13).*tau(1:13));

% SWAP RATES
disc(14,1)=1/(1+midrate(14)); % 1-year

for i=15:33

    disc(i)=(1-midrate(i)*sum(disc(i-1)))/(1+midrate(i)*tau(i));

end

%%
df(1:12,1)=disc(14:25); % Discount 1-12 years
df(15:5:30)=disc(26:29); % Discount 15, 20, 25, 30 years

%Discount factors through exponential interpolation

for j=13:14

    power1=(15-j)/(15-12);
    power2=(j-12)/(15-12);
    df(j)=df(12)^power1*df(15)^power2;
    
end

for j=16:19

    power1=(20-j)/(20-15);
    power2=(j-15)/(20-15);
    df(j)=df(15)^power1*df(20)^power2;
    
end

for j=21:24

    power1=(25-j)/(25-20);
    power2=(j-20)/(25-20);
    df(j)=df(20)^power1*df(25)^power2;
    
end

for j=26:29

    power1=(30-j)/(30-25);
    power2=(j-25)/(30-25);
    df(j)=df(25)^power1*df(30)^power2;
    
end

% BOND PRICE WITH EXPONENTIAL INTERPOLATION
bond_price=sum(coupon*df)+df(end)*notional;


%% NS INTERPOLATION

[pippo,~,~]=xlsread('PaoloEuriborSwap.xls');

mkt_spot=pippo(2:end,end-1);
mkt_time=pippo(2:end,end-3);


cpndates=1:1:maturity;
mktdata=[mkt_time mkt_spot];


[ns_parameter_fit, lsfit] = lsqnonlin(@(x)ns_fit(x,mktdata),[0.04 0.01 0.01 0.001],[0 0 0 0]);


h=figure(1);

plot(mkt_time, [mkt_spot ns_curve(ns_parameter_fit ,mkt_time)],':*')
title('Market and Nelson-Siegel Interpolation')
legend('Market Spot Rates','NS Spot Rates','Location','SouthEast')
xlabel('Time to maturity_date')
xlim([mkt_time(1,1) mkt_time(end,1)])
set(h,'Color',[1 1 1])
print(h,'-dpdf','MktvsNS.pdf')

interpchoice='nelsonsiegel';
[ns_spot, ns_df]=ns_curve(ns_parameter_fit,cpndates);

% BOND PRICING
ns_bond_price=sum(coupon*ns_df)*1*notional+notional*ns_df(end);


%%

% CREDIT SPREAD ==> LOOK AT THE XLS FILE


%%


























%%

