% VOLATILITY MODELING

clear, clc, close all

% UPLOAD DATASET:
[filename, pathname]= uigetfile('*.xls');
[prices,textdata,raw]=xlsread(filename,1);
%-------------------------------------------------------------------------
% QUESTION 1

date=datenum(textdata(3:end,1), 'dd/mm/yyyy');
f=['02/01/2006';'02/02/2009'; '01/02/2010'];
date_find=datenum(f,'dd/mm/yyyy');
ind=datefind(date_find,date);

% Data transformation and portfolio returns.
% Portfolio (example!): FIAT, DEUTSCHE LUFTHANSA and AIR FRANCE-KLM -
% Equally weighted.

p=prices(:,[7,8,9]);
ret=NaN(rows(p),3);
ret_w=NaN(rows(p),3);
ret(2:end,:)=100*log(p(2:end,:)./ p(1:end-1,:));
ret_w(6:end,:)=100*log(p(6:end,:) ./ p(1:end-5,:));
port_ret=NaN(rows(p),1);
port_ret_w=NaN(rows(p),1);
w=[1/3; 1/3; 1/3];
port_ret=ret*w;
port_ret_w=ret_w*w;

% Plot daily and weekly returns:

f1=['09/01/2006';'30/06/2006';'29/12/2006';'29/06/2007';'31/12/2007';'30/06/2008';'30/01/2009'];
date_find=datenum(f1,'dd/mm/yyyy');
index=datefind(date_find,date(ind(1)+5:ind(2)));

figure;
t=ind(1)+5:ind(2);
plot(t', port_ret(ind(1)+5:ind(2),:), t',port_ret_w(ind(1)+5:ind(2),:));
title('Portfolio returns','fontname','Garamond','fontsize',14);
set(gca,'fontname','garamond','fontsize',10);
set(gca,'xtick',index);
set(gca,'xticklabel','Jan2006|June2006 |Dec2006|June2007|Dec2007|Jun2008|Feb2009');
set(gca,'xlim',[1 rows(t')]);
grid;
ylabel('Returns');
xlabel('Date');
h=legend('Daily Returns', 'Weekly Returns',2);
set(gcf,'color','w');
set(gca,'Box', 'off', 'TickDir', 'out', 'TickLength', [.02 .02],'XMinorTick', 'off','YMinorTick', 'off','XColor', [.3 .3 .3],'YColor',[.3 .3 .3],'LineWidth', 1, 'FontName', 'Times');

%--------------------------------------------------------------------------
% QUESTION N.2

q=port_ret(ind(1):ind(2),:).^2;

figure;
subplot(2,1,1)
autocorr(port_ret(ind(1):ind(2),:),100,[],2);
title('ACF: Returns','fontname','garamond','fontsize',12);
set(gcf,'color','w');
subplot(2,1,2)
autocorr(q,100,[],2);
title('ACF: Squared Returns','fontname','garamond','fontsize',12);
set(gcf,'color','w');
%--------------------------------------------------------------------------
% QUESTION 3

figure
subplot(2,1,1)
hist(port_ret(ind(1):ind(2),:),100);
title('Histogram of daily portfolio returns','fontname','garamond','fontsize',12);
set(gcf,'color','w');
h = findobj(gca,'Type','patch');
set(h, 'facecolor',  [0 .8 0])
set(gca,'Box', 'off', 'TickDir', 'out', 'TickLength', [.02 .02],'XMinorTick', 'off','YMinorTick', 'off','XColor', [.3 .3 .3],'YColor',[.3 .3 .3],'LineWidth', 1, 'FontName', 'Times');
subplot(2,1,2)
hist(port_ret_w(ind(1):ind(2),:),100);
title('Histogram of weekly portfolio returns','fontname','garamond','fontsize',12);
set(gcf,'color','w');
h = findobj(gca,'Type','patch');
set(h, 'facecolor',  [0 .8 0])
set(gca,'Box', 'off', 'TickDir', 'out', 'TickLength', [.02 .02],'XMinorTick', 'off','YMinorTick', 'off','XColor', [.3 .3 .3],'YColor',[.3 .3 .3],'LineWidth', 1, 'FontName', 'Times');
%--------------------------------------------------------------------------
% QUESTION 4

% GARCH(P,Q)

% Estimation:
spec=garchset('P',1,'Q',1);
[coeff, errors,llf,innovation,sigma,summary]=garchfit(spec,port_ret(ind(1):ind(2),:));
garchdisp(coeff,errors);

% Note: sigma is the vector of the GARCH conditional volatility. 

% Compute step by step the vector "sigma":
param(1:4,1)=[coeff.C;coeff.K;coeff.GARCH;coeff.ARCH];
init=param(2)/(1-param(3)-param(4));
cond_var_garch=zeros(rows(port_ret(ind(1):ind(2))),1);
cond_var_garch(1)=init;
for i=1:ind(2)-2
cond_var_garch(i+1)=param(2)+param(3)*cond_var_garch(i)+param(4)*(innovation(i)^2);
end
cond_std_garch=sqrt(cond_var_garch);

% Plot GARCH conditional volatility: 
s=1:ind(2)-1;
figure;
plot(s',cond_std_garch,'-',s',sigma,'--','LineWidth',1.5);
title('GARCH: Conditional Volatility','fontname','Garamond','fontsize',14);
set(gca,'fontname','garamond','fontsize',10);
set(gca,'xtick',index);
set(gca,'xticklabel','Jan2006|June2006 |Dec2006|June2007|Dec2007|Jun2008|Dec2008');
set(gca,'xlim',[1 rows(t')]);
grid;
ylabel('GARCH volatility');
xlabel('Date');
set(gcf,'color','w');
h=legend('cond\_std\_garch','sigma',0);
set(gca,'Box', 'off', 'TickDir', 'out', 'TickLength', [.02 .02],'XMinorTick', 'off','YMinorTick', 'off','XColor', [.3 .3 .3],'YColor',[.3 .3 .3],'LineWidth', 1, 'FontName', 'Times');

% GARCH(1,1) daily and weekly forecasts
spec_pred=garchset('C',coeff.C,'K',coeff.K,'ARCH',coeff.ARCH,'GARCH',coeff.GARCH);
garch_pred_d=NaN(ind(3)-ind(2),1);
garch_pred_w=NaN(ind(3)-ind(2),1);

for i=1:(ind(3)-ind(2))
[SigmaForecast,MeanForecast,SigmaTotal,MeanRMSE] = garchpred(spec_pred,port_ret(ind(1):ind(2)+i-1),5); 
garch_pred_d(i)=SigmaForecast(1);
garch_pred_w(i)=SigmaTotal(5);
end

% EXPONENTIAL SMOOTHING

% Estimation
parm=[0.1];
logL= maxlik('objfunction',parm,[],port_ret(ind(1):ind(2)+1));
lambda=logL.b;
cond_var_es=NaN(ind(2)-1,1);
cond_var_es(1)=init;
for i=1:ind(2)-2
cond_var_es(i+1)=lambda*cond_var_es(i)+(1-lambda)*port_ret(ind(1)+i-1)^2;
end
cond_std_es=sqrt(cond_var_es);

% GARCH vs Exponential Smoothing: estimation
figure;
plot(s',cond_std_garch,'b',s',cond_std_es,'r', 'LineWidth',1.4);
title('GARCH vs Exponential Smoothing','fontname','Garamond','fontsize',14);
set(gca,'fontname','garamond','fontsize',10);
set(gca,'xtick',index);
set(gca,'xticklabel','Jan2006|June2006 |Dec2006|June2007|Dec2007|Jun2008|Dec2008');
set(gca,'xlim',[1 rows(s')]);
grid;
ylabel('Volatilities');
xlabel('Date');
set(gcf,'color','w');
h=legend('GARCH','Exponential Smoothing',0);
set(gca,'Box', 'off', 'TickDir', 'out', 'TickLength', [.02 .02],'XMinorTick', 'off','YMinorTick', 'off','XColor', [.3 .3 .3],'YColor',[.3 .3 .3],'LineWidth', 1, 'FontName', 'Times');

% Forecasting
es_pred_d=NaN(ind(3)-ind(2),1);
es_pred_w=NaN(ind(3)-ind(2),1);
es_pred_d(1,1)=lambda*cond_var_es(ind(2)-1)+(1-lambda)*port_ret(ind(2))^2;
es_pred_w(1,1)=5*es_pred_d(1,1);

for i=1:(ind(3)-ind(2)-1)
es_pred_d(i+1)=lambda*cond_var_es(i)+(1-lambda)*port_ret(ind(2))^2;
es_pred_w(i+1)=5*cond_var_es(i+1,1);
end

es_std_pred_d=sqrt(es_pred_d);
es_std_pred_w=sqrt(es_pred_w);

% GARCH vs Exponential Smoothing: forecasting
f2=['03/02/2009';'31/07/2009';'01/02/2010'];
date_find1=datenum(f2,'dd/mm/yyyy');
index1=datefind(date_find1,date(ind(2)+1:end));

% Daily
m=1:rows(garch_pred_d);
figure;
plot(m',garch_pred_d,'b',m',es_std_pred_d,'r');
title('GARCH vs Exp Smoothing - Daily ','fontname','Garamond','fontsize',14);
set(gca,'fontname','garamond','fontsize',10);
set(gca,'xtick',index1);
set(gca,'xticklabel','3 Feb 2009| 31 July 2009 |1 Feb 2010');
set(gca,'xlim',[1 rows(m')]);
grid;
ylabel('Volatilities');
xlabel('Date');
set(gcf,'color','w');
h=legend('GARCH','Exponential Smoothing',0);
set(gca,'Box', 'off', 'TickDir', 'out', 'TickLength', [.02 .02],'XMinorTick', 'off','YMinorTick', 'off','XColor', [.3 .3 .3],'YColor',[.3 .3 .3],'LineWidth', 1, 'FontName', 'Times');

% Weekly
figure;
plot(m',garch_pred_w,'b',m',es_std_pred_w,'r');
title('GARCH vs Exp Smoothing - Weekly','fontname','Garamond','fontsize',14);
set(gca,'fontname','garamond','fontsize',10);
set(gca,'xtick',index1);
set(gca,'xticklabel','3 Feb 2009| 31 July 2009 |1 Feb 2010');
set(gca,'xlim',[1 rows(m')]);
grid;
ylabel('Volatilities');
xlabel('Date');
set(gcf,'color','w');
h=legend('GARCH','Exponential Smoothing',0);
set(gca,'Box', 'off', 'TickDir', 'out', 'TickLength', [.02 .02],'XMinorTick', 'off','YMinorTick', 'off','XColor', [.3 .3 .3],'YColor',[.3 .3 .3],'LineWidth', 1, 'FontName', 'Times');
%--------------------------------------------------------------------------
% QUESTION N.5

% Daily VaR - 99% confidence level
alpha=0.01;
Var_garch=norminv(alpha,param(1),garch_pred_d);
Var_es=norminv(alpha,param(1),es_std_pred_d);

% Number of violations:
index_garch_d=(port_ret(ind(2)+1:ind(3))<Var_garch);
viol_garch_d=sum(index_garch_d);
index_es_d=(port_ret(ind(2)+1:ind(3))<Var_es);
viol_es_d=sum(index_es_d);

% Plot Daily VaRs and Returns
figure;
plot(m',port_ret(ind(2)+1:ind(3)),m',Var_garch,m',Var_es);
title('Daily VaR','fontname','Garamond','fontsize',14);
set(gca,'fontname','garamond','fontsize',10);
set(gca,'xtick',index1);
set(gca,'xticklabel','3 Feb 2009|31 July 2009|1 Feb 2009');
set(gca,'xlim',[1 rows(m')]);
grid;
set(gcf,'color','w');
h=legend('Returns','VaR GARCH', 'VaR Exp Smoothing',0);
set(gca,'Box', 'off', 'TickDir', 'out', 'TickLength', [.02 .02],'XMinorTick', 'off','YMinorTick', 'off','XColor', [.3 .3 .3],'YColor',[.3 .3 .3],'LineWidth', 1, 'FontName', 'Times');

% Weekly VaR - 99% confidence level
Var_garch_w=norminv(alpha,5*param(1),garch_pred_w);
Var_es_w=norminv(alpha,5*param(1),es_std_pred_w);

% Number of violations:
index_garch_w=(port_ret_w(ind(2)+1:ind(3))<Var_garch_w);
viol_garch_w=sum(index_garch_w);
index_es_w=(port_ret_w(ind(2)+1:ind(3))<Var_es_w);
viol_es_w=sum(index_es_w);

% Plot Weekly VaRs and the returns
figure;
plot(m',port_ret_w(ind(2)+1:ind(3)),m',Var_garch_w,m',Var_es_w);
title('Weekly VaR','fontname','Garamond','fontsize',14);
set(gca,'fontname','garamond','fontsize',9);
set(gca,'xtick',index1);
set(gca,'xticklabel','3 Feb 2009|31 July 2009|1 Feb 2010');
set(gca,'xlim',[1 rows(m')]);
grid;
set(gcf,'color','w');
h=legend('Weekly Returns','VaR GARCH - Weekly', 'VaR Exp Smoothing - Weekly',0);
set(gca,'Box', 'off', 'TickDir', 'out', 'TickLength', [.02 .02],'XMinorTick', 'off','YMinorTick', 'off','XColor', [.3 .3 .3],'YColor',[.3 .3 .3],'LineWidth', 1, 'FontName', 'Times');









