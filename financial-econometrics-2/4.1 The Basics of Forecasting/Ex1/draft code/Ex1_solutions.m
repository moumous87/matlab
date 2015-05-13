%Exercise 1
%To be run after datatran.m

% QUESTION 3

date=datenum(textdata(2:end,1),'dd/mm/yyyy');
f1=['31/03/1976'];
f2=['31/12/2009'];
date_find1=datenum(f1,'dd/mm/yyyy');
date_find2=datenum(f2,'dd/mm/yyyy');
first=datefind(date_find1,date);
last=datefind(date_find2,date);

RET=NaN(rows(us_p),24);
RET(:,1)=us_ret_1;
RET(:,2)=us_ret_4;
RET(:,3)=us_ret_8;
RET(:,4)=us_ret_12;
RET(:,5)=uk_ret_1;
RET(:,6)=uk_ret_4;
RET(:,7)=uk_ret_8;
RET(:,8)=uk_ret_12;
RET(:,9)=ger_ret_1;
RET(:,10)=ger_ret_4;
RET(:,11)=ger_ret_8;
RET(:,12)=ger_ret_12;
RET(:,13)=us_ret_1r;
RET(:,14)=us_ret_4r;
RET(:,15)=us_ret_8r;
RET(:,16)=us_ret_12r;
RET(:,17)=uk_ret_1r;
RET(:,18)=uk_ret_4r;
RET(:,19)=uk_ret_8r;
RET(:,20)=uk_ret_12r;
RET(:,21)=ger_ret_1r;
RET(:,22)=ger_ret_4r;
RET(:,23)=ger_ret_8r;
RET(:,24)=ger_ret_12r;

suffix=strvcat('us1','us4','us8','us12','uk1','uk4','uk8','uk12','ger1','ger4','ger8','ger12','us1r','us4r','us8r','us12r','uk1r','uk4r','uk8r','uk12r','ger1r','ger4r','ger8r','ger12r');
FIT=NaN(rows(us_p),36);
for i=1:24
    spec=garchset('variancemodel','constant','r',1,'Display','off');
    [coeff,errors,llf,innovation,sigma,summary]=garchfit(spec, RET(first:last,i));
    garchdisp(coeff,errors);
    fit1=nan(size(us_p,1),1);
    fit1(first+1:last,1)=coeff.C+coeff.AR*RET(first:last-1,i);
    RSQ1=1-(sum((RET(first+1:last,i)-fit1(first+1:last,1)).^2))./(sum((RET(first+1:last,i)-nanmean(RET(first+1:last,i))).^2));
    pvar1=tpdf(coeff.AR/errors.AR,last-first);
    FIT(:,i)=fit1(:,1);
    var1=strcat('fit1',num2str((suffix(i,:))));
    var2=strcat('RSQ1',num2str((suffix(i,:))));
    var3=strcat('pvar1',num2str((suffix(i,:))));
    assignin('base',var1,fit1);
    assignin('base',var2,RSQ1);
    assignin('base',var3,pvar1);
    clear fit1 RSQ1 pvar1 var1 var2 var3 coeff errors llf innovation sigma summary spec
end;

% GRAPHS AR(1)
country=strvcat('US nominal returns','UK nominal returns','Germany nominal returns','US real returns','UK real returns','Germany real returns');
names=strvcat('1-year','4-year','8-year','12-year');
t=1:rows(us_p);
m=0;
for j=1:6
    figure
for i=1:4
      subplot(2,2,i), h1=plot(t',RET(:,i+m),t',FIT(:,i+m));
      title(['AR(1) models',num2str(country(j,:)),num2str(names(i,:))],'fontname','times','fontangle','italic','fontsize',9);
      set(gca,'fontname','times','fontangle','italic','fontsize',8,'gridlinestyle',':');
      set(gca,'xtick',[1:16:rows(t')]);   
      set(gca,'xlim',[0 rows(t')]);
      set(gca,'xticklabel','1973|1977|1981|1985|1989|1993|1997|2001|2005|2009');
      grid;
      set(gcf,'color','w');
end       
m=m+4;
end

%Correlograms
figure;
autocorr(us_ret_1(first:last),20, [], 2);
title('Correlogram of US Annual Returns');
figure;
autocorr(us_ret_4(first:last),20, [], 2);
title('Correlogram of US 4Y Returns');
figure;
autocorr(us_ret_12(first:last),20, [], 2);
title('Correlogram of US 12 Y Returns');
figure;
autocorr(us_divgr(first:last),20, [], 2);
title('Correlogram of US Dividend Growth');


% QUESTION 4:MA(1)

DIVGR=NaN(rows(us_p),12);
DIVGR(:,1)=us_divgr;
DIVGR(:,2)=us_divgrr;
DIVGR(:,3)=uk_divgr;
DIVGR(:,4)=uk_divgrr;
DIVGR(:,5)=ger_divgr;
DIVGR(:,6)=ger_divgrr;
suffix1=strvcat('us','uk','ger','usr','ukr','gerr');
for i=1:6
    spec=garchset('variancemodel','constant','m',1,'Display','off');
    [coeff,errors,llf,innovation,sigma,summary]=garchfit(spec,DIVGR(first:last,i));
    garchdisp(coeff,errors);
    fit2=nan(size(us_p,1),1);
    fit2(first+1:last,1)=coeff.C+coeff.MA*innovation(1:end-1,1);
    RSQ2=1-(sum((DIVGR(first+1:last,i)-fit2(first+1:last,1)).^2))./(sum((DIVGR(first+1:last,i)-nanmean(DIVGR(first+1:last,i))).^2));
    pvma2=tpdf(coeff.MA/errors.MA,last-first);
    FIT(:,24+i)=fit2(:,1);
    var1=strcat('fit2',num2str((suffix1(i,:))));
    var2=strcat('RSQ2',num2str((suffix1(i,:))));
    var3=strcat('pvma2',num2str((suffix1(i,:))));
    assignin('base',var1,fit2);
    assignin('base',var2,RSQ2);
    assignin('base',var3,pvma2);
    clear fit2 RSQ2 pvma2 var1 var2 var3 coeff errors llf innovation sigma summary spec
    DIVGR(:,i+6)=DIVGR(:,i);
end;

% QUESTION 5:ARMA(1,1)

for i=1:6
spec=garchset('VarianceModel', 'Constant','r',1, 'M', 1, 'Display', 'off');
[coeff, errors,llf,innovation,sigma,summary]=garchfit(spec,DIVGR(first:last,i));
garchdisp(coeff,errors);
    fit3=nan(size(us_p,1),1);
    fit3(first+1:last,1)=coeff.C+coeff.AR*DIVGR(first:last-1,i)+coeff.MA*innovation(1:end-1,1);
    RSQ3=1-(sum((DIVGR(first+1:last,i)-fit3(first+1:last,1)).^2))./(sum((DIVGR(first+1:last,i)-nanmean(DIVGR(first+1:last,i))).^2));
    pvar3=tpdf(coeff.AR/errors.AR,last-first);
    pvma3=tpdf(coeff.MA/errors.MA,last-first);
    FIT(:,30+i)=fit3(:,1);
    var1=strcat('fit2',num2str((suffix1(i,:))));
    var2=strcat('RSQ2',num2str((suffix1(i,:))));
    var3=strcat('pvar3',num2str((suffix1(i,:))));
    var4=strcat('pvma3',num2str((suffix1(i,:))));
    assignin('base',var1,fit3);
    assignin('base',var2,RSQ3);
    assignin('base',var3,pvar3);
    assignin('base',var4,pvma3);
    clear fit3 RSQ3 pvar3 pvma3 var1 var2 var3 var4 coeff errors llf innovation sigma summary spec
end

% Graphs of MA(1) and ARMA(1) models
country1=strvcat('US','UK','Germany');
names1=strvcat('nominal MA(1)','real MA(1)','nominal ARMA(1,1)','real ARMA(1,1)');
m=0;
for j=1:4
    figure
for i=1:3
      subplot(3,1,i), h1=plot(t', DIVGR(:,i+m),t',FIT(:,24+i+m));
   title(['Dividend Growth Models: ',num2str(names1(j,:)),num2str(country1(i,:))],'fontname','times','fontangle','italic','fontsize',9);
   set(gca,'fontname','times','fontangle','italic','fontsize',8,'gridlinestyle',':');
   set(gca,'xtick',[1:16:rows(t')]);   
   set(gca,'xlim',[0 rows(t')]);
set(gca,'xticklabel','1973|1977|1981|1985|1989|1993|1997|2001|2005|2009');
grid;
set(gcf,'color','w');
end
m=m+3;
end;

% QUESTION 6

X=NaN(last-first,2);
X(:,1)=ones(last-first,1);
X(:,2)=us_dy(first:last-1,1);
horizon=strvcat('1Y','4Y','8Y','12Y');
for i=1:4
    result=ols(RET(first+1:last,i),X);
    var1=strcat('result',num2str((horizon(i,:))));
    assignin('base',var1,result);
    %Stimatori OLS artigianali con standard errors
    beta=inv(X'*X)*X'*RET(first+1:last,i);
    fit=beta(1,1)+beta(2,1)*X(:,2);
    resid=RET(first+1:last,i)-fit;
    var_resid=sum(resid(:,1).^2)/((last-first-1)-2);
    std_error=var_resid*inv(X'*X);
    var2=strcat('beta',num2str((horizon(i,:))));
    var3=strcat('std_error',num2str((horizon(i,:))));
    assignin('base',var2,beta);
    assignin('base',var3,std_error);
    clear result var1 var2 beta fit var_resid resid std_error
end;

% QUESTION 7

%Select the forecast horizon
f3=['31/12/1996'];
date_find3=datenum(f3,'dd/mm/yyyy');
prev=datefind(date_find3,date);
spec_est=garchset('variancemodel','constant','r',1,'Display','off');
forecast_ar=NaN(13,1);
for i=4:4:last-prev
[coeff_est,errors_est,llf_est,innovation_est,sigma_est,summary_est]=garchfit(spec_est, us_ret_1(first:prev+i-4));
garchdisp(coeff_est,errors_est);
spec_prev=garchset('variancemodel','constant','C',coeff_est.C,'R',1,'AR',coeff_est.AR,'K',coeff_est.K);
[SigmaForecast,MeanForecast,SigmaTotal,MeanRMSE]=garchpred(spec_prev,us_ret_1,4);
forecast_ar((i)/4,1)=sum(MeanForecast(1:4,1))/4;
clear coeff_est errors_es llf_est innovation_est sigma_est summary_est SigmaForecast MeanForecast SigmaTotal MeanRMSE
end

% Ex ante optimal strategy
bond=(us_1y(prev:4:last-4,1));
ret_stock=NaN(rows(us_p),1);
ret_stock(prev+4:4:last,1)=(us_ret_1(prev+1:4:last-3,1)+us_ret_1(prev+2:4:last-2,1)+us_ret_1(prev+3:4:last-1,1)+us_ret_1(prev+4:4:last,1))/4;
stock=ret_stock(prev+4:4:last);
index=(forecast_ar>bond);
index1=(stock>bond);
port_rf(1,1)=1;
port_bh(1,1)=1;
port_exante(1,1)=1;
port_expost(1,1)=1;
for i=2:14
    port_rf(i,1)=port_rf(i-1,1)*(1+bond(i-1,1));
    port_bh(i,1)=port_bh(i-1,1)*exp(stock(i-1,1));
    % Continuous compounding if investing in stock, annual compounding if
    % investing in 1y US Government bond
    port_exante(i,1)=port_exante(i-1,1)*(index(i-1,1)*exp(stock(i-1,1))+(1-index(i-1,1))*(1+bond(i-1,1)));
    port_expost(i,1)=port_expost(i-1,1)*(index1(i-1,1)*exp(stock(i-1,1))+(1-index1(i-1,1))*(1+bond(i-1,1)));
end

year=(1996:2009);
figure;
plot(year',port_rf,'g')
hold on
plot(year', port_bh,'b','linewidth',2);
hold on
plot(year',port_exante,'r','linestyle',':','linewidth',2);
hold on
plot(year',port_expost,'k'); 
title('Comparison among investment strategies ','fontname','times','fontangle','italic','fontsize',9);
set(gca,'fontname','times','fontangle','italic','fontsize',8,'gridlinestyle',':');
set(gca,'xlim',[1996 2009]);
grid;
set(gcf,'color','w');
legend('Risk free','Buy & hold (stock)','Optimal ex ante','Optimal ex post',0);
hold off