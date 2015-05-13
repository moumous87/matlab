function tcopulaest(PRICES)
% function to estimate a Student's t copula from empirical data using different methods
% input: matrix of PRICES of two financial assets (bivariate case)

[nr, nc]=size(PRICES);
logret=log(PRICES(2:nr,:))-log(PRICES(1:(nr-1),:));                 % daily log-returns calculation
logret1=logret(:,1);
logret2=logret(:,2);
empcorrmatr=corr(logret);
empcorr=empcorrmatr(1,2);

% 1. Method of Inference Functions for Margins (IFM)
% Requires separate identification and estimation of the various marginal distributions

% Assumption of normal distribution for the marginals

[muhat, sigmahat] = normfit(logret) 

un(:,1)=normcdf(logret1,muhat(1), sigmahat(1));               % calculation of the pseudo-sample from the copula
un(:,2)=normcdf(logret2,muhat(2), sigmahat(2)); 

% parameter estimation for the Student's t copula - correlation coefficient and degrees of freedom
lowerbound=[-0.99 0.5];                                         
upperbound=[0.99 20];
cop0=[empcorr 2];                                        %initial guess for parameters
options=optimset('LargeScale','off','MaxFunEval',50000,'MaxIter',50000);        % set options for optimization routine
copulan=fmincon(@tnegloglikcompl,cop0,[],[],[],[],lowerbound,upperbound,[], options,un)  


% Assumption of Student's t distribution for the marginals

% parameter estimation for the marginals (mean, location, degrees of freedom):
lowerbound=[-inf 0.00001 1];                                         
upperbound=[inf inf 20];
parEst0=[0 0.015 4];                                        %initial guess for parameters
options=optimset('LargeScale','off','MaxFunEval',50000,'MaxIter',50000);        % set options for optimization routine
parEst1=fmincon(@tnegloglik,parEst0,[],[],[],[],lowerbound,upperbound,[], options, logret1)       %recall constrained minimization routine to min -loglikelihood function of t
parEst2=fmincon(@tnegloglik,parEst0,[],[],[],[],lowerbound,upperbound,[], options, logret2)

stdlogret1=(logret1-parEst1(1))./parEst1(2);                % standardization of log returns
stdlogret2=(logret2-parEst2(1))./parEst2(2);

% parameter estimation for the Student's t copula - correlation coefficient and degrees of freedom
ut(:,1)=tcdf(stdlogret1, parEst1(3));               % calculation of the pseudo-sample from the copula
ut(:,2)=tcdf(stdlogret2, parEst2(3));

lowerbound=[-0.99 0.5];                                         
upperbound=[0.99 100];
cop0=[empcorr 3];                                        %initial guess for parameters
options=optimset('LargeScale','off','MaxFunEval',50000,'MaxIter',50000);        % set options for optimization routine
copulat=fmincon(@tnegloglikcompl,cop0,[],[],[],[],lowerbound,upperbound,[], options,ut)  


% 2. Canonical Maximum Likelihood Method (CML)
% does not require parametric specification of the marginals

for i=1:(nr-1)                                 % empirical cumulative distr. functions for the marginals
    uemp(i,1)=length(logret1(logret1<=logret1(i)))/(nr);
    uemp(i,2)=length(logret2(logret2<=logret2(i)))/(nr);
end

% parameter estimation for the Student's t copula - correlation coefficient and degrees of freedom
lowerbound=[-0.99 0.5];                                         
upperbound=[0.99 100];
cop0=[empcorr 3];                                        %initial guess for parameters
options=optimset('LargeScale','off','MaxFunEval',50000,'MaxIter',50000);        % set options for optimization routine
copulaemp=fmincon(@tnegloglikcompl,cop0,[],[],[],[],lowerbound,upperbound,[], options,uemp)  

% 3. Rank correlation measures
% The correlation coeff. is determined via Kendall's t and the degrees of  freedom via Maximum Likelihood

ktau=corr(logret,'type','Kendall');                 %empirical estimation Kendall's tau
trho=sin((pi/2)*ktau(1,2))                          %estimation correlation coefficient for bivariate t copula

% estimation of degrees of freedom for Student's t copula via maximum likelihood
lowerbound=[0.5];                                         
upperbound=[100];
df0=[3];                                        %initial guess for parameters
options=optimset('LargeScale','off','MaxFunEval',50000,'MaxIter',50000);        % set options for optimization routine
dfreed=fmincon(@tnegloglik2,df0,[],[],[],[],lowerbound,upperbound,[], options,uemp,trho)  

