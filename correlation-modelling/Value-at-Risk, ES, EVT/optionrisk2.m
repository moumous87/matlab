function [parEst, VaR, ES]=optionrisk2(inputdata, alpha)
% function to estimate VaR and ES for an option porfolio (short straddle position) with a linear delta-gamma-vega approximation
% 1st method: historical simulation (enriched with  EVT)
% 2nd method: Monte Carlo simulation of a Heston-type model
% inputdata: input file with past stock prices in first column and past
% volatility values in second column
% alpha: confidence level for VaR estimate (e.g. 0.95)

S=inputdata(:,1);
nobs=length(S);
DS=S(2:nobs)-S(1:(nobs-1));                         % past daily changes in stock prices
ivol=inputdata(:,2);
Dvol=ivol(2:nobs)-ivol(1:(nobs-1));                 % past daily changes in volatility

% greeks of call and put included in the straddle (we assume that gamma and vega are equal for call and put). 
deltaput=-0.40;
deltacall=0.50;
gamma=0.02;
vega=25.42;

%historical simulation of losses in option portfolio. Option portfolio is short straddle (short 1-year call and 1-year put ATM)
DP=-(deltaput*DS+deltacall*DS+0.5*2*gamma*(DS.^2)+2*vega*Dvol);         % changes in portfolio value
losses=-DP;                                                             % daily losses in portfolio value
Nloss=length(losses);
losses=sort(losses);

empvar=prctile(losses, alpha*100)                                      % VaR estimate
if round(Nloss*(1-alpha))==Nloss*(1-alpha)                              % ES estimate (with correction when Nloss*(1-alpha) is not integer
    empes=(1/(Nloss*(1-alpha)))*sum(losses(losses>empvar));
else
    empes=((1/(Nloss*(1-alpha)))*(sum(losses(Nloss+2-ceil(Nloss*(1-alpha)):Nloss))+(Nloss*(1-alpha)-floor(Nloss*(1-alpha)))*losses(Nloss+1-ceil(Nloss*(1-alpha)))));                              % expected shortfall estimate
end

% Extreme Value Theory

% choice of most appropriate threshold (expressed in percentage, i.e. 0.8 or 0.9)
h=0;
for i=0.60:0.005:0.95
    u=prctile(losses, i*100);                                 % threshold as percentile of empirical loss distribution
    h=h+1;
    threshold_range(h)=i;
    meanexcessfunction(h)=mean(losses(losses>u)-u);            % mean excess function  over threshold
end
scatter(threshold_range, meanexcessfunction)                    % plot of mean excess function as function of the threshold
threshold=input('Enter optimal threshold: ');

u=prctile(losses, threshold*100);               % threshold as percentile of empirical loss distribution
tailosses=losses(losses>u)-u;                   % excess losses over threshold
nu=length(tailosses);

parEst = gpfit(tailosses);                      % Fit of a Generalized Pareto density to empirical tail losses (1st param shape, 2nd param scale)
 
% % visual inspection of the fit
xgrid=linspace(0,1.1*max(tailosses),100);
ygrid=(1/parEst(2)).*((1+(parEst(1)/parEst(2)).*xgrid).^(-1-1/parEst(1)));      % plot of GPD
bins=0:0.5:10;
h=bar(bins, histc(tailosses,bins)/(length(tailosses)*0.02),'histc');              % plot of empirical threshold exceedances
hold on;
plot(xgrid, ygrid);
hold off;
 
% estimate of VaR and ES according to EVT 
VaREVT=u+(parEst(2)/parEst(1))*((nobs*(1-alpha)/nu)^(-parEst(1))-1);
ESEVT=VaREVT/(1-parEst(1))+(parEst(2)-u*parEst(1))/(1-parEst(1));


% Monte Carlo simulation of losses in option portfolio.
% we assume that stock and volatility process follow a Heston-type of specification:
%   dS= rSdt + S*sqrt(v)*sqrt(dt)*epsilon1
%   dv= (alphaheston-betaheston*v)dt+volvol*sqrt(v)*sqrt(dt)*epsilon2    - NB v is variance, not volatility!
%   corr(epsilon1, epsilon2)= rho

niter=3000;
                            % bivariate normal random numbers 
mu=[0 0];
rho=-0.76;                  % correlation changes in stock prices - changes in volatility
riskfree=0.048;
alphaheston=0.20;           %inputs to the Heston model
betaheston=2.5;
volvol=0.09;
dt=1/252;
sigma=[1 rho; rho 1];
epsilon = mvnrnd(mu,sigma,niter);
DSMC=riskfree*S(nobs)*dt+S(nobs)*ivol(nobs)*sqrt(dt)*epsilon(:,1);                                  %simulated changes in S
DVARMC=abs((alphaheston-betaheston*(ivol(nobs)^2))*dt+volvol*ivol(nobs)*sqrt(dt)*epsilon(:,2));     %simulated changes in var
DVOLMC=DVARMC.^(0.5);
DPMC=-(deltaput*DSMC+deltacall*DSMC+0.5*2*gamma*(DSMC.^2)+2*vega*DVOLMC);           % changes in portfolio value
lossesmc=-DPMC;                                                                     % daily losses in portfolio value
lossesmc=sort(lossesmc);
mcvar=prctile(lossesmc, alpha*100);                                                 % VaR estimate
Nlossmc=length(lossesmc);

if round(Nlossmc*(1-alpha))==Nlossmc*(1-alpha)
    mces=(1/(Nlossmc*(1-alpha)))*sum(lossesmc(lossesmc>mcvar));
else
    mces=((1/(Nlossmc*(1-alpha)))*(sum(lossesmc(Nlossmc+2-ceil(Nlossmc*(1-alpha)):Nlossmc))+(Nlossmc*(1-alpha)-floor(Nlossmc*(1-alpha)))*lossesmc(Nlossmc+1-ceil(Nlossmc*(1-alpha)))));                               % expected shortfall estimate
end


VaR=[empvar;  VaREVT; mcvar];
ES=[empes;  ESEVT; mces];