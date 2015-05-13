% Gaussian Mixture model

% Upload data
data=xlsread('data.xls',1);

%********************** GAUSSIAN MIXTURE ****************************
%Compute returns
ret=log(data(2:end,:)./data(1:end-1,:));

%Compute moments
Mean=mean(ret);
Mean_ann=Mean*256;
Std=std(ret);
Std_ann=Std*sqrt(256);
N=size(ret,1);

%Parameters estimation
param0=[0.82;0.010;0.03];
fun=@objfunction;
% options=optimset('LargeScale','off');
% A=[0,1,-1];
% b=0;
% lb=zeros(3,1);
% ub=ones(3,1);
%param = fmincon(fun,param0,A,b,[],[],lb,ub,[],options,ret)
result = maxlik(fun,param0,[],ret)
P1=result.b(1);
STD1=result.b(2);
STD2=result.b(3);

% Computing returns using empirical mean and standard deviation
sd=[-5.2:0.2:5.2]';
returns=Mean+sd*Std;

% Creating the two gaussian density
Gauss_1=normpdf(returns,Mean,STD1);
Gauss_2=normpdf(returns,Mean,STD2);
Mix_gauss=Gauss_1*P1+Gauss_2*(1-P1);
Gauss_emp=normpdf(returns,Mean,Std);

% Computing the cdf
CDF_1=normcdf(Gauss_1,Mean,STD1);
CDF_2=normcdf(Gauss_2,Mean,STD2);
CDF_Mix=CDF_1*P1+CDF_2*(1-P1);
CDF_emp=normcdf(Gauss_emp,Mean,Std);

%Plot
figure
plot(returns,[Gauss_1 Gauss_2 Mix_gauss Gauss_emp],'-d','MarkerSize',5)
title('Density Functions')
xlabel('Returns')
h=legend('PDF1(x;m,s1)','PDF2(x;m,s2)','MIX PDF','PDF(x;m,s)',2);
axis([-0.15 0.15 0 30]);

figure
plot(returns,[Gauss_1 Gauss_2],'-d','MarkerSize',5)
title('Comparison between the two estimated density functions')
xlabel('Returns')
h=legend('PDF1(x;m,s1)','PDF2(x;m,s2)',2);
axis([-0.15 0.15 0 30]);

figure
plot(returns,[Mix_gauss Gauss_emp],'-d','MarkerSize',5)
title('Comparison between the mixture density functions and the single gaussian')
xlabel('Returns')
h=legend('MIX PDF','PDF(x;m,s)',2);
axis([-0.15 0.15 0 25]);

figure
plot(returns,[log(Mix_gauss) log(Gauss_emp)],'-d','MarkerSize',5)
title('Comparison between the log of the mixture density functions and the single gaussian')
xlabel('Returns')
h=legend('ln(MIX PDF)','ln(PDF(x;m,s))',2);
axis([-0.15 0.15 -12 4]);

figure
plot(returns(1:20),[CDF_Mix(1:20) CDF_emp(1:20)],'-d','MarkerSize',5)
title('Comparison between the left tail of the mixture density functions and the single gaussian')
xlabel('Returns')
h=legend('MIX PDF','PDF(x;m,s)',2);
%axis([-0.15 0.15 -12 4]);
