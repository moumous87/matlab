function [varmeas, expshmeas, lossdistr]=paramestimationnew(pricematrix, alpha, lambda)
% Function to compute value-at-risk and expected shortfall for a portfolio
% of stocks under the assumptions of 1) normal distribution with sample mean and covariance (unconditional distribution); 
% 2) normal distribution with sample mean and EWMA covariance matrix (conditional distribution) of the risk factors (changes in log-prices)
% pricematrix is the matrix of the prices (observations in rows, variables in columns)
% alpha is the confidence level (e.g. 0.95)
% lambda is the decay coefficient for the EWMA (e.g. 0.94)

[nrows,ncols]= size(pricematrix);
retmatrix=log(pricematrix(2:nrows,:))-log(pricematrix(1:(nrows-1),:));      %calculation of daily log returns
lastprice=pricematrix(nrows,:);     %most recent prices in lastprice

nstock1=input('Enter number of stocks invested in the first asset: ');
nstock2=input('Enter number of stocks invested in the second asset: ');
nstock3=input('Enter number of stocks invested in the third asset: ');
nstocks=[nstock1 nstock2 nstock3];
V=sum(nstocks.*lastprice);          %portfolio's value
weights=(nstocks.*lastprice)./V;    %portfolio weights

%estimate of historical mean and var-cov matrix for the unconditional distribution of log returns
mret=mean(retmatrix);               
covretsample=cov(retmatrix);

% VaR and expected shortfall for the unconditional loss distribution
[varmeas(1) expshmeas(1)]=calcmeas(V, weights, mret, covretsample, alpha);


%estimate of mean and var-cov matrix with Exponentially Weighted Moving Average for the conditional
%distribution of log returns
[mretewma, covretewma] = ewstats(retmatrix, lambda);                    %obtain ewma estimates for mean and var/cov matrix

%check on the positive semi-definitess of the variance-covariance matrix
eigenvalues=eig(covretewma);
if isreal(eigenvalues) & (eigenvalues>=0)
    msgbox('Var-Cov matrix is positive semidefinite')
else
    msgbox('Var-Cov matrix is not positive semi-definite!','error')
end

% VaR and expected shortfall for the conditional loss distribution
[varmeas(2) expshmeas(2)]=calcmeas(V, weights, mretewma, covretewma, alpha);

% estimate of the empirical loss distribution according to the historical
% simulation approach
lossdistr=(-V*weights*retmatrix')';

function [VaRnorm, expshortnorm]=calcmeas(V, weights, mret, covret, alpha)              %subfunction for the computation of var and expected shortfall

%loss function is a normal distribution with parameters:
mlossnorm=-V*weights*mret';
varlossnorm=(V^2)*(weights*covret*weights');
stdlossnorm=sqrt(varlossnorm);

VaRnorm=mlossnorm+stdlossnorm*norminv(alpha);   %Value-at-Risk estimate
expshortnorm=mlossnorm+stdlossnorm*(normpdf(norminv(alpha),0,1))/(1-alpha); %expected shortfall estimate