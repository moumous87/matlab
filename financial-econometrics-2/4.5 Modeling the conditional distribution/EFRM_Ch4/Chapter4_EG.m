clc, clear, close all

path(path,'C:\Program Files\MATLAB\R2009a\toolbox\lesage\optimize');
path(path,'C:\Program Files\MATLAB\R2009a\toolbox\lesage\util');

%% CHRISTOFFERSEN CHAPTER 4: MODELLING THE CONDITIONAL DISTRIBUTION

% UPLOAD THE DATASET AND COMPUTE RETURNS

[filename,pathname]=uigetfile('*.xls');
[prices, textdata]=xlsread(filename,1);

date=datenum(textdata(3:end,1),'dd/mm/yyyy');
f1=['02/01/1997';'02/01/1998';'04/01/1999';'03/01/2000';'02/01/2001';'31/12/2001'];
date_find=datenum(f1,'dd/mm/yyyy');
index=datefind(date_find,date);

sp_price=prices(:,3);
sp_ret=log(sp_price(2:end)./ sp_price(1:end-1));

%% EXERCISE 1

unc_std=std(sp_ret);
std_ret=sp_ret./ unc_std;

% QQ-plot(auto)
figure;
qqplot(std_ret);
set(gcf,'color','w');

%% QQ-plot (constructed from scratch)
z=sort(std_ret);
rank=(1:rows(z))';
n=rows(z);
quant=norminv(((rank-0.5)./n),0,1);

l=zeros(rows(std_ret),1);

figure;
plot(2*quant,2*l,'k',2*l,2*z,'k',1.8*quant,1.8*quant,'r-.');
hold on
plot(quant,z,'b*');
ylabel('Data Quantile');
xlabel('Unconditional Normal Quantile');
set(gcf,'color','w');
set(gca,'Box', 'on','XColor', [.3 .3 .3],'YColor',[.3 .3 .3],'LineWidth', 1,'fontname','garamond','fontsize',10,'xlim',[-6 6],'ylim',[-6 6]);
title('QQ Plot of Sample Data versus Standard Normal','fontname','garamond','fontsize',12,'Color', [.3 .3 .3]);

%% EXERCISE 2 (NGARCH)

par_initial(1:4,1)=[0.000005;0.1;0.5;0.85]; % par_init=[omega;alpha;theta;beta]
[param,mle_ng]=fminsearch('ngarch',par_initial,[],sp_ret);

disp('NGARCH estimated parameters (assuming normal innovations):'); 
 fprintf('omega  ');  fprintf('%5.3f ',param(1,1));fprintf('\n');
 fprintf('alpha  ');  fprintf('%5.3f ',param(2,1));fprintf('\n');
 fprintf('theta  ');  fprintf('%5.3f ',param(3,1));fprintf('\n');
 fprintf('beta   ');  fprintf('%5.3f ',param(4,1));fprintf('\n');
 
[mle,z_ng,cond_var_ng]=ngarch(param,sp_ret);

%% EXERCISE 3

% QQ-plot(auto) of conditional NGARCH returns
figure;
qqplot(z_ng);
set(gcf,'color','w');

%% QQ-plot (constructed from scratch)
z_ngarch=sort(z_ng);

figure;
plot(2*quant,2*l,'k',2*l,2*z_ngarch,'k',1.8*quant,1.8*quant,'r-.');
hold on
plot(quant,z_ngarch,'b*');
ylabel('Data Quantile');
xlabel('Conditional Normal Quantile');
set(gcf,'color','w');
set(gca,'Box', 'on','XColor', [ .3 .3 .3],'YColor',[.3 .3 .3],'LineWidth', 1,'fontname','garamond','fontsize',10,'xlim',[-6 6],'ylim',[-6 6]);
title('QQ Plot of Returns Standardized by NGARCH versus Standard Normal','fontname','garamond','fontsize',12,'Color', [.3 .3 .3]);

%% EXERCISE 4 (QMLE Garch standardized t(d))
df_init=10;
[df,qmle]=fminsearch('logL1',df_init,[],sp_ret,sqrt(cond_var_ng));

disp('QML estimated degrees of freedom:'); 
 fprintf('df  ');  fprintf('%5.3f ',df);fprintf('\n');
 
quant_tstud=tinv(((rank-0.5)/n),df);
cond_var_qmle=cond_var_ng;

%% QQ-plot standardized returns vs. t~(df) (auto)
figure
qqplot(sqrt((df-2)/df)*quant_tstud,z_ngarch);
set(gcf,'color','w');
title('QQ Plot of Sample Data versus Standardized t(d) Distribution (QMLE Method)');

%% QQ-plot (constructed from scratch)

figure;
plot(2*quant_tstud,2*l,'k',2*l,2*z,'k',1.8*quant_tstud,1.8*quant_tstud,'r-.');
hold on
plot(sqrt((df-2)/df)*quant_tstud,z_ngarch,'b*');
ylabel('Data Quantile');
xlabel('Standardized T-student Quantile');
set(gcf,'color','w');
set(gca,'Box', 'on','XColor', [.3 .3 .3],'YColor',[.3 .3 .3],'LineWidth', 1,'fontname','garamond','fontsize',10,'xlim',[-6 6],'ylim',[-6 6]);
title('QQ Plot of Sample Data versus Standardized t(d) Distribution (QMLE Method)','fontname','garamond','fontsize',12,'Color', [.3 .3 .3]);

%% EXERCISE 5 (MLE Garch standardized t(d))
initial=[param;10];
[fit_par,mle]=fminsearch('logL2',initial,[],sp_ret);

disp('NGARCH estimated parameters (assuming std. t innovations):'); 
 fprintf('omega  ');  fprintf('%5.3f ',fit_par(1,1));fprintf('\n');
 fprintf('alpha  ');  fprintf('%5.3f ',fit_par(2,1));fprintf('\n');
 fprintf('theta  ');  fprintf('%5.3f ',fit_par(3,1));fprintf('\n');
 fprintf('beta   ');  fprintf('%5.3f ',fit_par(4,1));fprintf('\n');
 fprintf('t~ d.f ');  fprintf('%5.3f ',fit_par(5,1));fprintf('\n'); 

df_mle=fit_par(5,1);
quant_ts_mle=tinv(((rank-0.5)/n),df_mle);
[a,z_lev_mle,condvar_mle]=ngarch(fit_par,sp_ret);
z_mle=sort(z_lev_mle);

%% QQ-plot(auto)
figure
qqplot(sqrt((df_mle-2)/df_mle)*quant_ts_mle,z_mle);
set(gcf,'color','w');
title('QQ Plot of Sample Data versus Standardized t(d) Distribution (MLE Method)');

%% QQ-plot (constructed)

figure;
plot(2*quant,2*l,'k',2*l,2*z,'k',1.8*quant,1.8*quant,'r-.');
hold on
plot(sqrt((df_mle-2)/df_mle)*quant_ts_mle,z_mle,'b*');
ylabel('Data Quantile');
xlabel('T-Students Quantile');
set(gcf,'color','w');
set(gca,'Box', 'on','XColor', [.3 .3 .3],'YColor',[.3 .3 .3],'LineWidth', 1,'fontname','garamond','fontsize',10,'xlim',[-6 6],'ylim',[-6 6]);
title('QQ Plot of Sample Data versus Standardized t(d) Distribution (MLE Method)','fontname','garamond','fontsize',12,'Color', [.3 .3 .3]);

%% Compare the conditional volatilities of questions 3,4,5.
figure;
t=1:rows(sp_ret);
plot(t',cond_var_ng,'k',t',cond_var_qmle,'r',t',condvar_mle,'b');
set(gca,'xtick',index,'xticklabel','Jan1997|Jan1998|Jan1999|Jan2000|Jan2001|Dec2001','xlim',[1 rows(t')+1]);
set(gca,'yticklabel',[0 0.0002 0.0004 0.0006 0.0008 0.0010 0.0012]);
ylabel('Volatilities');
xlabel('Time');
title('Modeling the conditional distribution','fontname','garamond','fontsize',12,'Color', [.3 .3 .3]);
h=legend('NGARCH with normal innov.', 'QMLE standardized t(d)', 'MLE standardized t(d)',1);
set(h,'fontsize',8);
set(gcf,'color','w');
set(gca,'Box', 'off', 'TickDir', 'out', 'TickLength', [.02 .02],'XMinorTick', 'off','YMinorTick', 'off','XColor', [.3 .3 .3],'YColor',[.3 .3 .3],'LineWidth', 1, 'FontName', 'Times');

%% EXERCISE 6

p_VaR=0.0001;

% Hill Estimator
std_loss=-z_ng;
[sorted_loss I]=sort(std_loss,'descend');
u=quantile(sorted_loss,0.95);
tail=sorted_loss(sorted_loss>u);
Tu=rows(tail);
T=rows(std_loss);
xi=(1/Tu)*sum(log(tail./u));

% Quantiles
q_EVT=u*(p_VaR./(Tu/T)).^(-xi);
q_norm=norminv(1-p_VaR,0,1);
q_tstud=sqrt((df-2)/df)*tinv((1-p_VaR),df);
zeta_1=skewness(z_ng);
zeta_2=kurtosis(z_ng)-3;
inv=norminv(1-p_VaR,0,1);
q_CF=inv+(zeta_1/6)*(inv^2-1)+(zeta_2/24)*(inv^3-3*inv)-(zeta_1^2/36)*(2*(inv^3)-5*inv);

% 1day 0.01%VaRs
cond_std=sqrt(cond_var_ng);
VaR_norm=cond_std.*q_norm;
VaR_EVT=cond_std.*q_EVT;
VaR_tstud=cond_std.*q_tstud;
VaR_CF=cond_std.*q_CF;

fprintf('Estimated VaRs (pct points), p='); fprintf('%5.4f',p_VaR);fprintf('\n');
 fprintf('Normal NGARCH   ');  fprintf('%5.3f ',100*VaR_norm(T,1));fprintf('\n');
 fprintf('Std-T  NGARCH   ');  fprintf('%5.3f ',100*VaR_tstud(T,1));fprintf('\n');
 fprintf('Cornish Fisher  ');  fprintf('%5.3f ',100*VaR_CF(T,1));fprintf('\n');
 fprintf('Extreme Value   ');  fprintf('%5.3f ',100*VaR_EVT(T,1));fprintf('\n');
 

%% EXERCISE 7
% QQ-plot(auto)

Fy=u*((I-0.5)./Tu).^(-xi);
x=Fy(I<=Tu);
figure
qqplot(-x,-tail);
set(gcf,'color','w');
title('QQ Plot of Sample Data versus the EVT Distribution');

%% QQ-plot (constructed)
x1=sort(x,'descend');
figure;
plot(2*quant,2*l,'k',2*l,2*z,'k',1.8*quant,1.8*quant,'r');
hold on
plot(-x1,-tail,'b*');
ylabel('Data Quantile');
xlabel('EVT Quantile');
set(gcf,'color','w');
set(gca,'Box', 'on','XColor', [.3 .3 .3],'YColor',[.3 .3 .3],'LineWidth', 1,'fontname','garamond','fontsize',10,'xlim',[-6 6],'ylim',[-6 6]);
title('QQ Plot of Sample Data versus the EVT Distribution','fontname','garamond','fontsize',12,'Color', [.3 .3 .3]);
