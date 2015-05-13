%CHAPTER 2

%UPLOAD DATASET FOR CHAPTER 2

[filename,pathname]=uigetfile('*.xls');
[prices,textdata,raw] = xlsread(filename,1);

%--------------------------------------------------------------------------

%QUESTION N.1

%select the analysis period
date=datenum(textdata(3:end,1),'dd/mm/yyyy');
f=['03/01/2006';'31/10/2008'];
date_find=datenum(f,'dd/mm/yyyy');
ind=datefind(date_find,date);
prices_in=prices(ind(1):ind(2),:);

%construct portfolio return: in this example we choose 3 stocks.
port_prices=prices_in(:,[7,8,9]);
port_returns= 100*log(port_prices(2:end,:)./port_prices(1:end-1,:));
port_returns=port_returns*[1/3;1/3;1/3];
%--------------------------------------------------------------------------

%QUESTION N.2

[ACF,Lags,Bounds]=autocorr(port_returns,100,[],2);
[ACF,Lags,Bounds]=autocorr(port_returns.^2,100,[],2);
%--------------------------------------------------------------------------

%QUESTION N.3

%plot the histogram of returns
hist(port_returns, 100)
title('Istogramma dei rendimenti giornalieri del portafoglio considerato')
%--------------------------------------------------------------------------

%QUESTION N.4

%definition of the out-of-sample period
g=['20/01/2009'];
date_find=datenum(g,'dd/mm/yyyy');
index=datefind(date_find,date);
prices_out=prices(ind(2):index,8);
port_returns_out=100*log(prices_out(2:end,:)./prices_out(1:end-1,1));

%GARCH(1,1) estimation
spec=garchset('Distribution','Gaussian','VarianceModel','GARCH','P',1,'Q',1,'K',0.00005,'GARCH',0.85,'ARCH',0.1);
[coeff,errors,llf,innovation,sigma,summary]=garchfit(spec,port_returns);
% [parameters, likelihood, ht, stderrors, robustSE, scores, grad] = garchpq(port_returns, 1 , 1 , [0.00005; 0.1; 0.85],[]);

%GARCH(1,1) forecast
spec_out=garchset('Distribution','Gaussian','VarianceModel','GARCH','P',1,'Q',1,'K',coeff.K,'GARCH',coeff.GARCH,'ARCH',coeff.ARCH,'C',coeff.C);
[sigmaf, meanf, sigmat]=garchpred(spec_out,port_returns(end,:),1);
cond_std_garch(1,1)=sigmaf;
for i=1:index-ind(2)
    [sigmaf, meanf, sigmat]=garchpred(spec_out,port_returns_out(i,:),1);
    cond_std_garch(i+1)=sigmaf;
end
% cond_var_garch(1,1)=parameters(1)+parameters(2)*port_returns(end,:)^2+parameters(3)*ht(end,:);
% for i=1:size(port_returns_out,1)-1
%      cond_var_garch(i+1)=parameters(1)+parameters(2)*port_returns_out(i,:)^2+parameters(3)*cond_var_garch(i);
% end
% cond_std_garch=sqrt(cond_var_garch);

%ESPONENTIAL SMOOTHING estimation
parm=[0.1];
fun=@objfunction;
options=optimset('LargeScale','off');
%x1=fminunc(fun,parm,options,port_returns);
x = maxlik('objfunction',parm,[],port_returns);
x1=x.b;

%ESPONENTIAL SMOOTHING forecast
cond_var_es(1,1)=var(port_returns);
for i=2:size(port_returns_out,1)-1
cond_var_es(i,1)=(1-x1)*port_returns_out(i-1,1).^2+x1*cond_var_es(i-1,1);
end
cond_std_es=sqrt(cond_var_es);

%Plot the results
figure
plot(cond_std_garch,'r')
hold on
plot(cond_std_es)
hold off
title('GARCH vs Esponential Smoothing')
set(gca,'XTickLabel',textdata(ind(2)+1:index+1,1))
h = legend('GARCH Variance','ES Variance',2);
%--------------------------------------------------------------------------

%QUESTION N.5


%Daily VaR @ 99% confidence level
alpha=0.01;
Var_garch=norminv(alpha,0,cond_std_garch);
Var_es=norminv(alpha,0,cond_std_es);

%Weekly VaR @ 99% confidence level
%weekly variane forecasting
[sigmaf, meanf, sigmat]=garchpred(spec_out,port_returns(end,:),4);
cond_std_garch_W(1,1)=sigmat(end);
for i=1:index-ind(2)
    [sigmaf, meanf, sigmat]=garchpred(spec_out,port_returns_out(i,:),4);
    cond_std_garch_W(i+1)=sigmat(end);
end
% K=4
% sigma_long=parameters(1)/(1-parameters(2)-parameters(3));
% s=sum((parameters(2)+parameters(3)).^([1:4]-1),2);
% for i=1:size(port_returns_out,1)-4
% cond_var_garch_W(i)=K*sigma_long+s*(cond_var_garch(i)-sigma_long);
% end
% cond_std_garch_W=sqrt(cond_var_garch_W);

%VaR caluculation
cond_std_es_W=cond_std_es*sqrt(4);
Var_garch_W=norminv(alpha,0,cond_std_garch_W);
Var_es_W=norminv(alpha,0,cond_std_es_W);

%PLOT THE RESULTS
%Daily VaR
figure
plot(Var_garch,'r')
hold on
plot(port_returns_out)
plot(Var_es,'g')
hold off
h = legend('VaR with GARCH','Portfolio','VaR with ES',2);

%Weekly VaR
for i=1:size(port_returns_out,1)-4
    port_returns_out_w(i)=sum(port_returns_out(i:3+i));
end
figure
plot(port_returns_out_w')
hold on
plot(Var_garch_W,'r')
plot(Var_es_W,'g')
hold off
h = legend('Weekly Portfolio','Weekly VaR with GARCH','Weekly VaR with ES',2);


