function [percexceedunc, percexceedcond, expectedexceed]=backtestingvar(pricematrix, alpha, lambda)
% Function to backtest value-at-risk for a portfolio
% of stocks under the assumptions of 1) normal unconditional distribution with sample mean and sample covariance matrix
% 2) normal conditional distribution with EWMA moments of the risk factors (changes in log-prices)
% pricematrix is the matrix of the prices (observations in rows, variables in columns)
% alpha is the confidence level (e.g. 0.95)
% lambda is the decay coefficient for the EWMA (e.g. 0.94)
% output: 1) percentage of VaR violations under unconditional normal
% assumption; 2) percentage of VaR violations under conditional normal
% assumption; 3) expected percentage of VaR violations

[nrows,ncols]= size(pricematrix);
retmatrix=log(pricematrix(2:nrows,:))-log(pricematrix(1:(nrows-1),:));      %calculation of daily log returns
nrowsest=floor(nrows*(2/3));                                                %take two thirds of the observations to estimate risk measures
countexceedunc=0;
countexceedcond=0;
nstock1=input('Enter number of stocks invested in the first asset: ');
nstock2=input('Enter number of stocks invested in the second asset: ');
nstock3=input('Enter number of stocks invested in the third asset: ');
nstocks=[nstock1 nstock2 nstock3];

for i=nrowsest:(nrows-1)
    lastprice=pricematrix(i,:);         %most recent prices in lastprice
    V=sum(nstocks.*lastprice);          %portfolio's value
    weights=(nstocks.*lastprice)./V;    %portfolio weights
    
    %unconditional normal distribution: estimation of sample mean and
    %sample variance
    mret=mean(retmatrix((i-nrowsest+1):(i-1),:));               
    covretsample=cov(retmatrix((i-nrowsest+1):(i-1),:));
    [varuncnorm]=varmeas(V, weights, mret, covretsample, alpha);
    varuncvector(i-nrowsest+1)=varuncnorm;              % vector of VaR under the assumption of unconditional normal
    
    %estimate of mean and var-cov matrix with Exponentially Weighted Moving Average for the conditional
    %distribution of log returns
    [mretewma, covretewma] = ewstats(retmatrix((i-nrowsest+1):(i-1),:), lambda);                        
    [varcondnorm]=varmeas(V, weights, mretewma, covretewma, alpha);
    varcondvector(i-nrowsest+1)=varcondnorm;            % vector of VaR under the assumption of conditional normal
    nextprice=pricematrix(i+1,:);
    actualret=log(nextprice)-log(lastprice);    
    actualchange=-V*weights*actualret';                 %calculation of actual change in portfolio's value
    actualPL(i-nrowsest+1)=actualchange;                % vector of actual P&L
    if actualchange>varuncnorm
        countexceedunc=countexceedunc+1;                %count number of exceedances wrt unconditional VaR
    end
    if actualchange>varcondnorm
        countexceedcond=countexceedcond+1;              %count number of exceedances wrt conditional VaR
    end
    
end
expectedexceed=1-alpha;  %theoretical percentage of exceedances
percexceedunc=countexceedunc/length(varcondvector);
percexceedcond=countexceedcond/length(varcondvector);
%plot VaR (unconditional and conditional) vs actual P&L
subplot(2,1,1)
plot(varuncvector)
hold on
plot(actualPL)
hold off
subplot(2,1,2)
plot(varcondvector)
hold on
plot(actualPL)
hold off


function [VaRnorm]=varmeas(V, weights, mret, covret, alpha)              %subfunction for the computation of var and expected shortfall

%loss function is a normal distribution with parameters:
mlossnorm=-V*weights*mret';
varlossnorm=(V^2)*(weights*covret*weights');
stdlossnorm=sqrt(varlossnorm);
VaRnorm=mlossnorm+stdlossnorm*norminv(alpha);   %Value-at-Risk estimate
