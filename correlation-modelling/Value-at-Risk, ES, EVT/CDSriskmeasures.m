function [VAR, ES]=CDSriskmeasures(cdsinput, RR, alpha)
% function to calculate VAR and ES measures for a short Credit Default Swap
% position with maturity T (protection seller) in the trading book via Historical Simulation 
% see formulas for MTM value of a CDS position in "VaR for CDS" note on the
% learning space
% input: series of past CDS spreads having maturity T for the reference entity;
%        RR=recovery rate (es. 0.40)
%        alpha=confidence level for VAR estimate (es 0.95) 

T=5;                                  % maturity in years of the CDS contract
rf=0.045;                             % risk free interest rate (annual basis)
N=10000000;                           % notional value of the CDS contract
cdsspread=cdsinput./10000;
Nobs=length(cdsinput);
lambda=(cdsspread)./(1-RR);           %intensity of default calculated for each day in the sample (annual basis)
RPV01=(1-(exp(-(rf+lambda).*T)))./(rf+lambda);      %risky present value calculated for each day in the sample
MTM1day=-N*(cdsspread(2:Nobs)-cdsspread(1:(Nobs-1))).*RPV01(2:Nobs);             % daily MTM for short protection position 
MTM10day=-N*(cdsspread(11:Nobs)-cdsspread(1:(Nobs-10))).*RPV01(11:Nobs);             % 10-daily MTM for short protection position 
[VAR(1), ES(1)]=mtmcalculation(MTM1day, N, alpha);          % daily VaR and ES
[VAR(2), ES(2)]=mtmcalculation(MTM10day, N, alpha);          % 10-day VaR and ES
VAR(3)=sqrt(10)*VAR(1);             %10-day VAR with square root of time rule
ES(3)=sqrt(10)*ES(1);               %10-day ES with square root of time rule

function [VaR1, ES1]=mtmcalculation(mtm, N, alpha)
lossesunsorted=-mtm;                                                             % losses in portfolio value
losses=sort(lossesunsorted);
Nloss=length(losses);

VaR1=(prctile(losses, alpha*100)/N)*100;                                           % VaR estimate (in % of notional N)


%ES estimate (in percentage of notional N) with correction in case Nloss*(1-alpha) is not an integer
if round(Nloss*(1-alpha))==Nloss*(1-alpha)
    ES1=((1/(Nloss*(1-alpha)))*sum(losses(losses>VaR1)))*100/N;
else
    ES1=((1/(Nloss*(1-alpha)))*(sum(losses(Nloss+2-ceil(Nloss*(1-alpha)):Nloss))+(Nloss*(1-alpha)-floor(Nloss*(1-alpha)))*losses(Nloss+1-ceil(Nloss*(1-alpha)))))*100/N;                              
end