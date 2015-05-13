function copulasim(coeffcorr, df1)
% function to simulate bivariate gaussian and Student's t copulae for different choices of marginals 
% coeffcorr: correlation coefficient - parameter of Gaussian and Student's t
% copula
% df1: degrees of freedom for t-copula

stdret=[0.02 0.025];                                                 % std. dev. daily log-returns for each asset
df2=[4 3];
corr1=[1 coeffcorr; coeffcorr 1];                                              % correlation matrix of log-returns

% Simulation of a Gaussian copula
% C=chol(corr1);                                                       % Choleski decomposition of the correlation matrix C'C=corr
% Zind=randn(2, 5000);                                                % simulation of 1000 bivariate independent normal variables
% Z=transpose(C'*Zind);                                               % transformation of independent variables into bivariate variables having correlation = corr1 

%more simply...
%Z=mvnrnd([0 0], corr1, 5000);
%Ugauss=[normcdf(Z(:,1),0,1), normcdf(Z(:,2),0,1) ];                 % random vector U has distr function equal to the Gaussian copula with correlation corr1

%even more simply....
Ugauss=copularnd('Gaussian',coeffcorr,5000);

% Simulation of a Student's t copula
                                                              % degrees of freedom of the t copula
%Zstudt = mvtrnd(corr1,df1,5000);                                     % simulation of bivariate t random numbers having correlation = corr and df1 degrees of freedom
%Ustudt=[tcdf(Zstudt(:,1),df1), tcdf(Zstudt(:,2),df1)];           % random vector U has distr function equal to the Student's t copula with correlation corr

%or alternatively....
Ustudt=copularnd('t',coeffcorr,df1, 5000);

Xstudt1=[stdret(1)*tinv(Ugauss(:,1),df2(1)),  stdret(2)*tinv(Ugauss(:,2),df2(2))];
Xstudt2=[stdret(1)*tinv(Ustudt(:,1),df2(2)), stdret(2)*tinv(Ustudt(:,2),df2(2))];

% bidimensional scatter plots
subplot(1,2,1), scatter(Xstudt1(:,1), Xstudt1(:,2))                 % gaussian copula with t margins
xlabel('1')
ylabel('2')

title('Gaussian copula')
axis([-0.3 0.3 -0.3 0.3])

subplot(1,2,2), scatter(Xstudt2(:,1),Xstudt2(:,2))               % t copula with t margins
xlabel('1')
ylabel('2')
title('Students t copula')
axis([-0.3 0.3 -0.3 0.3 ])