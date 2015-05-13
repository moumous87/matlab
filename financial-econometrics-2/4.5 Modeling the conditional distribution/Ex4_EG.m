%% WEB EXERCISES -- MODELING THE CONDITIONAL DISTRIBUTION (EFRM CH.4)

clear, clc, close all

path(path,'C:\Program Files\MATLAB\R2009a\toolbox\lesage\optimize');
path(path,'C:\Program Files\MATLAB\R2009a\toolbox\lesage\util');

%% UPLOAD DATASET
[filename,pathname]=uigetfile('*.xls');
[data,textdata,raw]=xlsread(filename,1);

date=datenum(textdata(3:end,1),'dd/mm/yyyy');
f=['02/01/2006'; '31/12/2009'];
date_find=datenum(f,'dd/mm/yyyy');
first=datefind(date_find(1,1),date);
last=datefind(date_find(2,1),date);

%% QUESTION 1: Portfolio
prices=data(:,[18:22]);
returns=100*log(prices(2:end,:)./(prices(1:end-1,:)));
ret_eubp=returns(:,1);
ret_euusd=returns(:,2);
ret_msci_eu=returns(:,3);
ret_msci_usa=returns(:,4)-ret_euusd;
ret_msci_uk=returns(:,5)-ret_eubp;
w=[1/3;1/3;1/3];
port_ret=[ret_msci_eu,ret_msci_usa,ret_msci_uk]*w;

%% Q1: QQ-Plot: Unconditional returns (raw and standardized w/uncond variance)

unc_std=std(port_ret);
std_portret=port_ret./ unc_std;

RET=[port_ret(first:last,1) std_portret(first:last,1)];
label=strvcat('Returns', 'Std Returns');

figure;
for i=1:2
subplot(1,2,i)
qqplot(RET(:,i));
set(gcf,'color','w');
tit=strcat('QQ-plot: ',label(i,:));
title(tit);
set(gca,'ylim',[-8 12]);
end

%% Q1: Jarque-Bera test
[h,p_val,jbstat,critval] = jbtest(port_ret(first:last,1));
[h_std,p_val_std,jbstat_std,critval_std] = jbtest(std_portret(first:last,1));

col1=strvcat(' ','JB statistic:  ','Critical val:','P-value:','Reject H0?');
col2=strvcat('RETURNS     ',num2str(jbstat),num2str(critval),num2str(p_val),num2str(h));
col3=strvcat('STD. RETURNS ',num2str(jbstat_std),num2str(critval_std),num2str(p_val_std),num2str(h_std));
mat=[col1,col2,col3];
disp(['Jarque-Bera test for normality (5%)']);
disp(mat);fprintf('\n');

%% QUESTION 2 -- Leverage effect using GJR-GARCH and garchset
spec_gjr=garchset('VarianceModel','GJR','P',1,'Q',1,'K',0.05,'GARCH',0.85,'ARCH',0.1,'leverage',0.05);
[param_gjr,errors_gjr,llf_gjr,innovation_gjr,sigmas_gjr,summary_gjr]=garchfit(spec_gjr,port_ret(first:last,:));
garchdisp(param_gjr,errors_gjr);
z_gjr= port_ret(first:last,:)./sigmas_gjr;


%% Q2 Alternative model: Leverage effect using NGARCH
par_initial(1:4,1)=[0.05;0.1;0.05;0.85];% par_init=[omega;alpha;theta;beta]
[param_ng,mle_ng]=fminsearch('ngarch',par_initial,[],port_ret(first:last,:));
[mle,z_ng,cond_var_ng]=ngarch(param_ng,port_ret(first:last,:));

% display results
 fprintf('\n');
disp(['NGARCH PARAMETERS']);

 fprintf('omega  ');  fprintf('%5.4f ',param_ng(1,1));fprintf('\n');
 fprintf('alpha  ');  fprintf('%5.4f ',param_ng(2,1));fprintf('\n');
 fprintf('theta  ');  fprintf('%5.4f ',param_ng(3,1));fprintf('\n');
 fprintf('beta   ');  fprintf('%5.4f ',param_ng(4,1));fprintf('\n');
 fprintf('MaxLik ');  fprintf('%5.4f ',mle_ng(1,1));fprintf('\n');
 fprintf('\n');
 
 


%% Standardized returns: NGARCH vs GJR-GARCH
f1=['02/01/2006';'30/06/2006';'29/12/2006';'29/06/2007';'01/01/2008';'30/06/2008';'31/12/2008';'30/06/2009';'31/12/2009';];
date_find1=datenum(f1,'dd/mm/yyyy');
index=datefind(date_find1,date);

t=1:rows(z_ng);
figure;
plot(t',z_ng,'b',t',z_gjr,'r');
set(gca,'fontname','garamond','fontsize',10);
set(gca,'xtick',index,'xticklabel','Jan2006|June2006|Dec2006|June2007|Jan2008|Jun2008|Dec20008|June2009|Dec2009','xlim',[1 rows(t')+1]);
xlabel('Time');
ylabel('Standardized returns');
title('NGARCH vs GJR-GARCH','fontname','garamond','fontsize',10,'Color', [.3 .3 .3]);
h=legend('NGARCH', 'GJR-GARCH',0);
set(h,'fontsize',8);
set(gcf,'color','w');
set(gca,'Box', 'off', 'TickDir', 'out', 'TickLength', [.02 .02],'XMinorTick', 'off','YMinorTick', 'off','XColor', [.3 .3 .3],'YColor',[.3 .3 .3],'LineWidth', 1, 'FontName', 'Garamond','fontsize',10);

%% QQ-Plot: NGARCH vs GJR-GARCH

RET1=[z_ng z_gjr];
label1=strvcat(' NGARCH ', 'GJR-GARCH ');

figure;
for i=1:2
subplot(1,2,i)
qqplot(RET1(:,i));
set(gcf,'color','w');
tit=strcat('QQ-plot (Std Ret):',label1(i,:));
title(tit);
set(gca,'ylim',[-7 4]);
end

%% JB tests:  NGARCH vs GJR-GARCH
[h_ng,p_val_ng,jbstat_ng,critval_ng] = jbtest(z_ng);
[h_gjr,p_val_gjr,jbstat_gjr,critval_gjr] = jbtest(z_gjr);

%display results:
fprintf('\n');
col1=strvcat(' ','JB statistic:  ','Critical val:','P-value:','Reject H0?');
col2=strvcat('NGARCH   ',num2str(jbstat_ng),num2str(critval_ng),num2str(p_val_ng),num2str(h_ng));
col3=strvcat('GJR-Garch ',num2str(jbstat_gjr),num2str(critval_gjr),num2str(p_val_gjr),num2str(h_gjr));
mat=[col1,col2,col3];
disp(['Jarque-Bera test for normality (5%)']);
disp(mat);
fprintf('\n');

%% QUESTION 3: GJR - GARCH Simulation
spec_sim=garchset('Distribution','Gaussian','C',0,'VarianceModel','GJR','P',param_gjr.P,'Q',param_gjr.Q,'K',param_gjr.K,'GARCH',param_gjr.GARCH,'ARCH',param_gjr.ARCH,'Leverage',param_gjr.Leverage);
[ret_sim, sigma2_sim]=garchsim(spec_sim,rows(z_ng));
z_sim=ret_sim ./sqrt(sigma2_sim);

%% GJR-GARCH QQ-Plot: Returns vs Standardized Returns
RET3=[ret_sim z_sim];

figure;
for i=1:2
subplot(1,2,i)
qqplot(RET3(:,i));
set(gcf,'color','w');
tit=strcat('QQ-plot Simulated GJR\_GARCH: ',label(i,:));
title(tit);
set(gca,'ylim',[-5 5]);
end

%% GJR-GARCH JB test: Returns vs Standardized Returns
[h_sim,p_val_sim,jbstat_sim,critval_sim] = jbtest(ret_sim);
[h_sim_std,p_val_sim_std,jbstat_sim_std,critval_sim_std] = jbtest(z_sim);

fprintf('\n');
col1=strvcat(' ','JB statistic:  ','Critical val:','P-value:','Reject H0?');
col2=strvcat('RETURNS (SIM)   ',num2str(jbstat_sim),num2str(critval_sim),num2str(p_val_sim),num2str(h_sim));
col3=strvcat('STD RET (SIM) ',num2str(jbstat_sim_std),num2str(critval_sim_std),num2str(p_val_sim_std),num2str(h_sim_std));
mat=[col1,col2,col3];
disp(['Jarque-Bera test for normality of GJR-GARCH(5%)']);
disp(mat);
fprintf('\n');


%% Question3: NGARCH simulation 
zt=random('Normal',0,1,rows(z_ng),1);
[r_sim,s_sim]=ngarch_sim(param_ng,var(port_ret(first:last,:)),zt); %(Ngarch_parameters,initial variance,innovations);


%% NGARCH QQ-Plot: Returns vs Standardized Returns
RET2=[r_sim zt];

figure;
for i=1:2
subplot(1,2,i)
qqplot(RET2(:,i));
set(gcf,'color','w');
tit=strcat('QQ-plot SIMULATED NGARCH: ',label(i,:));
title(tit);
set(gca,'ylim',[-6 8]);
end

%% NGARCH JARQUE-BERA
[h_sim,p_val_sim,jbstat_sim,critval_sim] = jbtest(r_sim);
[h_sim_std,p_val_sim_std,jbstat_sim_std,critval_sim_std] = jbtest(zt);

fprintf('\n');
col1=strvcat(' ','JB statistic:  ','Critical val:','P-value:','Reject H0?');
col2=strvcat('RETURNS (SIM)   ',num2str(jbstat_sim),num2str(critval_sim),num2str(p_val_sim),num2str(h_sim));
col3=strvcat('STD RET (SIM) ',num2str(jbstat_sim_std),num2str(critval_sim_std),num2str(p_val_sim_std),num2str(h_sim_std));
mat=[col1,col2,col3];
disp(['Jarque-Bera test for normality of NGARCH (5%)']);
disp(mat);
fprintf('\n');

%% QUESTION 4
p_VaR=0.01;

% Estimation of the degrees of freedom for a standardized 
% t-student via quasi maximum likelihood

cond_std=sigmas_gjr;
df_init=4;
[df,qmle]=fminsearch('logL1',df_init,[],port_ret(first:last,:),cond_std);


% estimations of CF parameters
zeta_1=skewness(z_gjr);
zeta_2=kurtosis(z_gjr)-3;
inv=norminv(p_VaR,0,1);

% Quantiles
q_norm=inv;
q_tstud=sqrt((df-2)/df)*tinv((p_VaR),df);
q_CF=inv+(zeta_1/6)*(inv^2-1)+(zeta_2/24)*(inv^3-3*inv)-(zeta_1^2/36)*(2*(inv^3)-5*inv);

cond_std_gjr(rows(port_ret)-last,1)=NaN;
% Forecasted Conditional Standard Deviation of GJR-Garch
for i=1: rows(port_ret)-last
    cond_std_gjr(i) = garchpred(spec_sim,port_ret(last+i),1);
end

% 1day 1%VaRs
VaR_norm=-cond_std_gjr'.*q_norm;
VaR_tstud=-cond_std_gjr'.*q_tstud;
VaR_CF=-cond_std_gjr'.*q_CF;


f2=['01/01/2010';'13/01/2010';'25/01/2010';'01/02/2010'];
date_find2=datenum(f2,'dd/mm/yyyy');
index2=datefind(date_find2,date(last+1:end,:));


p=1:rows(port_ret)-last;
figure
plot(p',VaR_norm,p', VaR_tstud,p', VaR_CF,'Linewidth',2);
set(gca,'fontname','garamond','fontsize',10);
set(gca,'xtick',index2,'xticklabel','01/01/2010|13/01/2010|25/01/2010|01/02/2010','xlim',[1 rows(p')+1]);
xlabel('Time');
ylabel('VaRs');
title('VaRs','fontname','garamond','fontsize',14,'Color', [.3 .3 .3]);
h=legend('VaR\_norm', 'VaR\_tstud','VaR\_CF', 0);
set(h,'fontsize',8);
set(gcf,'color','w');
grid;
set(gca,'Box', 'off', 'TickDir', 'out', 'TickLength', [.02 .02],'XMinorTick', 'off','YMinorTick', 'off','XColor', [.3 .3 .3],'YColor',[.3 .3 .3],'LineWidth', 1, 'FontName', 'Garamond','fontsize',10);

