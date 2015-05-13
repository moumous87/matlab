% VaR Computation

% Upload data
data=xlsread('data.xls',1);

%************************** Gaussian VaR *********************************
%Compute returns
ret=log(data(2:end,2)./data(1:end-1,2));

%Compute moments
Mean=mean(ret);
Std=std(ret);
N=size(ret,1);

%Compute Gaussian VaR
W=10000;
alpha=[0.005,0.01,0.025,0.05];
quantile_G=norminv(alpha, Mean,Std);
Var_G=W*(exp(quantile_G)-1);
Var_G_apx=W*quantile_G;

%*************************************************************************
%************************** Nonparametric VaR ****************************

%Compute Nonparametric VaR
alpha_N=[0.001,0.005,0.01,0.025,0.05];
quantile_N=prctile(ret,alpha_N*100);
Var_N=W*(exp(quantile_N)-1);
Var_N_apx=W*quantile_N;

%Compute VaR using confidence intervals
lower_k=N*alpha_N-1.96*sqrt(N*alpha_N.*(1-alpha_N));
E=sort(ret);
quantile_CI=E(round(lower_k(2:end)));
Var_CI=W*(exp(quantile_CI)-1);
Var_CI_apx=W*quantile_CI;

%*************************************************************************
%************************** Semiparametric VaR ****************************

%Linear Regression
A=cumsum(ones(N,1)*1/N);
Log_A=log(A);
Log_E=log(-E);
fit1=fit(Log_E(1:137),Log_A(1:137),'poly1');

%Compute Semiparametric VaR
alpha_S=[0.1,0.05,0.025];
Emp=prctile(ret,alpha_S*100);
required_alpha=0.01;
quantile_SP=Emp.*((alpha_S/required_alpha).^(1/abs(fit1.p1)));
Var_SP=W*(exp(quantile_SP)-1);
Var_SP_apx=W*quantile_SP;

%Graphs
figure
scatter(Log_E(1:1229),Log_A(1:1229))
title('log (k/n) vs log(-r(k))')
xlabel('log(-r(k))')
ylabel('log(k/n)')

figure
scatter(Log_A(1:137),Log_E(1:137))
hold on
plot(fit1.p1*Log_E(1:137)+fit1.p2,Log_E(1:137),'r','LineWidth',2)
title('Regression data')
xlabel('log(-r(k))')
ylabel('log(k/n)')
hold off
%*************************************************************************




