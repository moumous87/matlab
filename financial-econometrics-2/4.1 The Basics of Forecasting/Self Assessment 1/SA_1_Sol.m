% SELF ASSESSMENT

%This solution programme is to be run after data_tran 
% Exercise 2

date=datenum(textdata(2:end,1),'dd/mm/yyyy');
f1=['31/03/1974'];
f2=['31/12/1999'];
date_find1=datenum(f1,'dd/mm/yyyy');
date_find2=datenum(f2,'dd/mm/yyyy');
first=datefind(date_find1,date);
last=datefind(date_find2,date);

t=1:rows(us_p);

DY=NaN(rows(us_p),3);
DY(:,1)=us_ldp;
DY(:,2)=uk_ldp;
DY(:,3)=ger_ldp;

X1=NaN(rows(us_p),3);
X1(:,2)=uk_ldp(:,1);
X1(:,1)=us_ldp(:,1);
X1(:,3)=ger_ldp(:,1);

country=strvcat('US','UK','GER');

for i=1:3

X=NaN(rows(us_p),2);
X(:,1)=ones;
X(:,2)=X1(:,i);
result=ols(DY(first+1:last,i), X(first:last-1,:));
beta=result.beta;
tstat=result.tstat;
R2=result.rsqr;

var1=strcat('beta',country(i,:));
assignin('base',var1,beta);
var2=strcat('tstat',country(i,:));
assignin('base',var2,tstat);
var3=strcat('R2',(country(i,:)));
assignin('base',var3,R2);

clear result beta tstat var1 var2 var3

end

% b
horz=1;
forsmpl=40;
ldp_mean=NaN(size(us_p));
ldp_upp=NaN(size(us_p));
ldp_low=NaN(size(us_p));
    
for i=1:3 
for j=1:forsmpl
    %AR(1) estimation
    spec=garchset('VarianceModel','Constant','R',1);
    [coeff,errors,llf,innovation,sigma,summary]=garchfit(spec,DY(first:last,i));
    garchdisp(coeff,errors);
    
    %AR(1) forecast
   
    spec_pred=garchset('VarianceModel','Constant','C',coeff.C,'R',1,'AR',coeff.AR,'K',coeff.K);
    [SigmaForecast,MeanForecast,SigmaTotal,MeanRMSE] = garchpred(spec_pred,DY(first:last+j-1,i),horz);
    forecast_ar=MeanForecast;
    forecast_upp=MeanForecast+2*MeanRMSE;
    forecast_low=MeanForecast-2*MeanRMSE;
    ldp_mean(last+j:last+j,1)=forecast_ar;
    ldp_upp(last+j:last+j,1)=forecast_upp;
    ldp_low(last+j:last+j,1)=forecast_low;
    end

figure
h2=plot(t',DY(:,i),t',ldp_mean,'-',t',ldp_upp,'--',t',ldp_low,'--','LineWidth',2);
tit=strcat('Forecasting DY - ', country(i,:)); 
title(tit,'fontname','garamond','fontsize',14);
set(gca,'fontname','garamond','fontsize',10,'gridlinestyle',':');
set(gca,'xtick',[1:8:rows(t')]); 
set(gca,'xlim',[0 rows(t')]);
set(gca,'xticklabel','1973|1975|1977|1979|1981|1983|1985|1987|1989|1991|1993|1995|1997|1999|2001|2003|2005|2007|2009');
grid;
set(gcf,'color','w');
h3=legend('Realized DY','Simulated DY','Upper Bound','Lower Bound',3);

RMSE=sqrt(sum((ldp_mean(last+1:last+forsmpl)-DY(last+1:last+forsmpl,i)).^2));

var1=strcat('For_',country(i,:));
assignin('base',var1,ldp_mean);
var2=strcat('UpperBound_',country(i,:));
assignin('base',var2,ldp_upp);
var3=strcat('LowBound_',country(i,:));
assignin('base',var3,ldp_low);
var4=strcat('RMSE_',(country(i,:)));
assignin('base',var4,RMSE);

clear var1 var2 var3 var4       
    
end;

%--------------------------------------------------------------------------
% c)
% Look at beta
% Look at RMSE

% EXERCISE 3

f3=['31/03/1985'];
f4=['31/12/2009'];
date_find3=datenum(f3,'dd/mm/yyyy');
date_find4=datenum(f4,'dd/mm/yyyy');
first=datefind(date_find3,date);
last=datefind(date_find4,date);

RET=NaN(rows(us_p),12);
RET(:,1)=us_ret_1r;
RET(:,2)=us_ret_4r;
RET(:,3)=us_ret_8r;
RET(:,4)=us_ret_12r;
RET(:,5)=uk_ret_1r;
RET(:,6)=uk_ret_4r;
RET(:,7)=uk_ret_8r;
RET(:,8)=uk_ret_12r;
RET(:,9)=ger_ret_1r;
RET(:,10)=ger_ret_4r;
RET(:,11)=ger_ret_8r;
RET(:,12)=ger_ret_12r;

DY=NaN(rows(us_p),3);
DY(:,1)=us_ldp(:,1);
DY(:,2)=uk_ldp(:,1);
DY(:,3)=ger_ldp(:,1);

horizon=strvcat('1Q','4Q','8Q','12Q');

for j=1:3
X=NaN(rows(us_p),2);
X(:,1)=ones;
X(:,2)=DY(:,j);

result1Q=ols(RET(first+1:last,(j-1)*4 + 1),X(first:last-1,:));
r2_1Q=result1Q.rsqr;
var1=strcat('result',country(j,:),'1Q');
assignin('base',var1,result1Q);
var2=strcat('R2',country(j,:),'1Q');
assignin('base',var2,r2_1Q);
clear var1
for i=1:3
    result=ols(RET(first+1:last,(j-1)*4 + i + 1),X(first+1-i*4:last-i*4,:));
    r2_q=result.rsqr;
    var3=strcat('result',country(j,:),(horizon(i+1,:)));
    assignin('base',var3,result);
    var4=strcat('R2',country(j,:),horizon(i+1,:));
    assignin('base',var4,r2_q);
    clear var1 
end;
clear X;

end

% Plot R2: Within country

R2_US=[resultUS1Q.rsqr;resultUS4Q.rsqr;resultUS8Q.rsqr;resultUS12Q.rsqr];
R2_UK=[resultUK1Q.rsqr;resultUK4Q.rsqr;resultUK8Q.rsqr;resultUK12Q.rsqr];
R2_GER=[resultGER1Q.rsqr;resultGER4Q.rsqr;resultGER8Q.rsqr;resultGER12Q.rsqr];
x=[1;2;3;4];

figure;
plot(x,R2_US,'g',x,R2_UK,'b',x,R2_GER,'r');
title('Predictive regressions R2 ','fontname','Garamond','fontsize',14);
%set(gca,'fontname','garamond','fontsize',10,'gridlinestyle',':');
set(gca,'xtick',[1:4]);   
set(gca,'xlim',[1 4]);
set(gca,'xticklabel','1Q|4Q|8Q|12Q');
set(gcf,'color','w');
h5=legend('US','UK','GER',2);
set(gca,'Box', 'off', 'TickDir', 'out', 'TickLength', [.02 .02],'XMinorTick', 'off','YMinorTick', 'off','XColor', [.3 .3 .3],'YColor',[.3 .3 .3],'LineWidth', 1, 'FontName', 'Times');
hold off

% Plot R2: Across countries

R2_dy=[R2_US'; R2_UK';R2_GER'];

for j=1:4
    
x=[1;2;3];

figure;
bar(x,R2_dy(:,j),0.3,'m');
tit=strcat('Predictive Regressions R2 - ', horizon(j,:)); 
title(tit,'fontname','garamond','fontsize',14);
set(gca,'xtick',[1:3]);   
set(gca,'xlim',[0 4]);
set(gca,'xticklabel','US|UK|GER');
set(gcf,'color','w');
set(gca,'Box', 'off', 'TickDir', 'out', 'TickLength', [.02 .02],'XMinorTick', 'off','YMinorTick', 'off','XColor', [.3 .3 .3],'YColor',[.3 .3 .3],'LineWidth', 1, 'FontName', 'Times');
hold off

end


