clc, clear, close all
%CHAPTER 3

%UPLOAD DATASET FOR CHAPTER 3

[filename,pathname]=uigetfile('*.xls');
[prices1,textdata,raw] = xlsread(filename,1);

%--------------------------------------------------------------------------

%QUESTION N.1

% Calculate the returns
date=datenum(textdata(2:end,1),'dd/mm/yyyy');
f=['03/01/2005';'31/10/2008'];
date_find=datenum(f,'dd/mm/yyyy');
ind=datefind(date_find,date);
prices=prices1(ind(1):ind(2),end-4:end);

returns= 100*log(prices(2:end,:)./prices(1:end-1,:));
returns_eubp=returns(:,1);
returns_euusd=returns(:,2);
returns_msci_eu=returns(:,3);
returns_msci_usa=returns(:,4)+returns_euusd;
returns_msci_uk=returns(:,5)+returns_eubp;
weights=ones(3,1)./3;
port_returns=[returns_msci_eu,returns_msci_usa,returns_msci_uk]*weights;

%QQPlot
 figure
 probplot(port_returns); 
 title('QQplot of an equally weighted portfolio');

 %Jaque-Bera test
 H = jbtest(port_returns);
 %--------------------------------------------------------------------------

%QUESTION N.2

%GARCH(1,1) with Leverage Effect estimation for portfolio returns
spec=garchset('Distribution','Gaussian','VarianceModel','GJR','P',1,'Q',1,'K',0.00005,'GARCH',0.85,'ARCH',0.1,'Leverage',0.05);
[coeff,errors,llf,innovation,ht,summary]=garchfit(spec,port_returns);
%[parameters, likelihood, stderrors, robustSE, ht, scores]=egarch(port_returns,1,1,1,'NORMAL', [],[0.00005;0.1; 2; 0.85]);
port_returns_std= port_returns./ht;

%QQPlot
 figure
 probplot(port_returns_std); 
 title('QQplot of an equally weighted portfolio standardized');

 %Jaque-Bera test
 H_std = jbtest(port_returns_std);
%--------------------------------------------------------------------------

%QUESTION N.3
spec=garchset('Distribution','Gaussian','C',coeff.C,'VarianceModel','GJR','P',coeff.P,'Q',coeff.Q,'K',coeff.K,'GARCH',coeff.GARCH,'ARCH',coeff.ARCH,'Leverage',coeff.Leverage);
[Innovation, sig, Z]= garchsim(spec,1000);
%[simulatedata, H] = egarchsimulate(1000,parameters,1,1, 'NORMAL')

%QQPlot
 figure
 probplot([Z]); 
 title('QQplot of the simulated portfolio');
 
 %Jaque-Bera test
 H_Z = jbtest(Z);
%----------------------------------------------------------------

%QUESTION N.3

% Initialized value for parameters
dEst0=[4];                                       
                                       
% Estimation of the degree of freedom for a t-student via maximum likelihood
options=optimset('Display','Iter','LargeScale','off','MaxFunEval',5000000,'MaxIter',5000000);
dEst=fminunc(@likeli,dEst0,options, port_returns);

%Calculate the returns of the portfolio for the 2008
date=datenum(textdata(2:end,1),'dd/mm/yyyy');
f=['31/10/2008';'20/01/2009'];
date_find=datenum(f,'dd/mm/yyyy');
ind=datefind(date_find,date);
prices=prices1(ind(1):ind(2),end-4:end);

returns= 100*log(prices(2:end,:)./prices(1:end-1,:));
returns_eubp=returns(:,1);
returns_euusd=returns(:,2);
returns_msci_eu=returns(:,3);
returns_msci_usa=returns(:,4)+returns_euusd;
returns_msci_uk=returns(:,5)+returns_eubp;
weights=ones(3,1)./3;
port_returns_2008=[returns_msci_eu,returns_msci_usa,returns_msci_uk]*weights;

cond_std_garch=garchpred(spec,port_returns(end),1);
for i=1: ind(2)-ind(1)-1
    cond_std_garch(i+1) = garchpred(spec,port_returns_2008(i),1);
end

% cond_var_garch(1,1)=parameters(1)+parameters(2)*port_returns(end,:)^2+parameters(3)*ht(end,:);
% for i=1:size(port_returns_2008,1)-1
%      cond_var_garch(i+1)=parameters(1)+parameters(2)*port_returns_2008(i,:)^2+parameters(3)*cond_var_garch(i);
% end
% cond_std_garch=sqrt(cond_var_garch);

alpha=0.01;
%Var 99% Normal Qunatile
Var_norm=norminv(alpha,0,cond_std_garch);
%Var 99% Student's t
Var_stud=tinv(alpha,dEst)*cond_std_garch;
%Var 99% CornishFischer
sku=skewness(port_returns);
eccesskurto=kurtosis(port_returns)-3;
perc=norminv(alpha,0,1);
cf_quintile= perc+(sku/6)*(perc^2-1)+(eccesskurto/24)*(perc^3-3*perc)-(sku^2/36)*(2*(perc^3)-5*perc);
Var_cf=cf_quintile*cond_std_garch;

%Plot the results
figure
plot([Var_norm', Var_stud',Var_cf',port_returns_2008]);
h = legend('Normal','Stundent t','Cornish Fischer','Portfolio',2);