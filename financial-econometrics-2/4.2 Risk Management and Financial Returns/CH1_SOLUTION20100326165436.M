clc, clear, close all

% CHAPTER 1 - Christoffersen

% Note: Slight differences in the results are due to the starting date. In the following 5day Returns are computed from Monday to Monday. 

% UPLOAD THE DATASET

[filename,pathname]=uigetfile('*.xls');
[prices, textdata, raw]=xlsread(filename,1);

%-----------------------------------------------
% QUESTION 1

ret=100*log(prices(2:end,1)./ prices(1:end-1,1));

date=datenum(textdata(3:end,1),'dd/mm/yyyy');
f1=['02/01/1997';'02/01/1998';'04/01/1999';'03/01/2000';'02/01/2001';'31/12/2001'];
date_find=datenum(f1,'dd/mm/yyyy');
index=datefind(date_find,date);

% Plot Closing Prices

t=1:rows(prices);
figure;
plot(t',prices)
title('Closing Prices','fontname','garamond','fontsize',14,'Color',[.3 .3 .3]);
set(gca,'fontname','garamond','fontsize',10);
set(gca,'xtick',index);
set(gca,'xticklabel','Jan1997|Jan1998|Jan1999|Jan2000|Jan2001|Dec2001'),
set(gca,'xlim',[1 rows(t')]);
grid;
ylabel('Prices');
xlabel('Date');
set(gcf,'color','w');
set(gca,'Box', 'off', 'TickDir', 'out', 'TickLength', [.02 .02],'XMinorTick', 'off','YMinorTick', 'off','XColor', [.3 .3 .3],'YColor',[.3 .3 .3],'LineWidth', 1, 'FontName', 'Times');

% Plot Returns
figure;
plot(ret)
title('Returns','fontname','garamond','fontsize',14,'Color',[.3 .3 .3]);
set(gca,'fontname','garamond','fontsize',10);
set(gca,'xtick',index);
set(gca,'xticklabel','Jan1997|Jan1998|Jan1999|Jan2000|Jan2001|Dec2001'),
set(gca,'xlim',[1 rows(t')]);
grid;
ylabel('Returns');
xlabel('Date');
set(gcf,'color','w');
set(gca,'Box', 'off', 'TickDir', 'out', 'TickLength', [.02 .02],'XMinorTick', 'off','YMinorTick', 'off','XColor', [.3 .3 .3],'YColor',[.3 .3 .3],'LineWidth', 1, 'FontName', 'Times');
%--------------------------------------------------------------------------
% QUESTION 2

% Descriptive statistics:
mean_ret=mean(ret);
std_ret=std(ret);
skewness_ret=skewness(ret);
kurtosis_ret=kurtosis(ret);

excess_kurtosis_ret=kurtosis_ret-3;

% Histogram of returns:
figure;
hist(ret,100);
title('Histogram of Returns','fontname','garamond','fontsize',14,'Color',[.3 .3 .3]);
set(gcf,'color','w');
h = findobj(gca,'Type','patch');
set(h, 'facecolor','b')
set(gca,'Box', 'off', 'TickDir', 'out', 'TickLength', [.02 .02],'XMinorTick', 'off','YMinorTick', 'off','XColor', [.3 .3 .3],'YColor',[.3 .3 .3],'LineWidth', 1, 'FontName', 'Times');
xlabel('Returns');
ylabel('Number of Observations');

% Normal distribution:
x=sort(ret);
y=normpdf(x,mean_ret,std_ret);
figure;
plot(x,y,'r','Linewidth',2.5);
title('Normal Distribution','fontname','garamond','fontsize',14,'Color',[.3 .3 .3]);
set(gcf,'color','w');
set(gca,'Box', 'off', 'TickDir', 'out', 'TickLength', [.02 .02],'XMinorTick', 'off','YMinorTick', 'off','XColor', [.3 .3 .3],'YColor',[.3 .3 .3],'LineWidth', 1, 'FontName', 'Times');
xlabel('Returns');
ylabel('Frequency');

% Histogram+Normal Distribution:
[h x1] = ecdf(ret);
figure;
ecdfhist(h,x1,100);
p = findobj(gca,'Type','patch');
set(p, 'facecolor', 'b');
hold on;
plot(x,y,'r','Linewidth',2.5);
title('Empirical Distribution of Returns','fontname','garamond','fontsize',14);
set(gcf,'color','w');
set(gca,'Box', 'off', 'TickDir', 'out', 'TickLength', [.02 .02],'XMinorTick', 'off','YMinorTick', 'off','XColor', [.3 .3 .3],'YColor',[.3 .3 .3],'LineWidth', 1, 'FontName', 'Times');
xlabel('Returns');
ylabel('Frequency');
%-----------------------------------------------
% QUESTION 3

% ACF:
figure;
autocorr(ret,100,[],2);
title('ACF:Returns');
set(gcf,'color','w');

% Figure 1.1:

[ACF, Lags] = autocorr(ret, 100);
figure;
plot(Lags(2:end,:),ACF(2:end,:),'b','Linewidth',2.5);
set(gca,'ylim',[-0.10 0.20]);
title('ACF: Returns','fontname','garamond','fontsize',14,'Color',[.3 .3 .3]);
set(gcf,'color','w');
set(gcf,'color','w');
xlabel('Lag Order');
ylabel('Autocorrelation');
set(gca,'Box', 'off', 'TickDir', 'out', 'TickLength', [.02 .02],'XMinorTick', 'off','YMinorTick', 'off','XColor', [.3 .3 .3],'YColor',[.3 .3 .3],'LineWidth', 1, 'FontName', 'Times');
hold on
l=zeros(rows(Lags),1);
plot(Lags,l,'b');
%-----------------------------------------------
% QUESTION 4

% ACF:
figure;
autocorr(ret.^2,100,[],2);
title('ACF:Squared Returns');
set(gcf,'color','w');

% Figure 1.3:
[ACF, Lags] = autocorr(ret.^2, 100);
figure;
plot(Lags(2:end,:),ACF(2:end,:),'b','Linewidth',2.5);
set(gca,'ylim',[-0.10 0.20]);
title('ACF:Squared Returns','fontname','garamond','fontsize',14,'Color',[.3 .3 .3]);
set(gcf,'color','w');
set(gcf,'color','w');
xlabel('Lag Order');
ylabel('Autocorrelation');
set(gca,'Box', 'off', 'TickDir', 'out', 'TickLength', [.02 .02],'XMinorTick', 'off','YMinorTick', 'off','XColor', [.3 .3 .3],'YColor',[.3 .3 .3],'LineWidth', 1, 'FontName', 'Times');
hold on
l=zeros(rows(Lags),1);
plot(Lags,l,'b');
%-----------------------------------------------
% QUESTION 5

% Compute the conditional variance/standard deviation:
init=var(ret);
cond_var=NaN(rows(ret),1);
cond_var(1)=init;
for i=1:rows(ret)-1
cond_var(i+1)=0.94*cond_var(i)+0.06*ret(i).^2;
end

cond_std=sqrt(cond_var);

% Plot the results:
figure;
plot(cond_std,'b','Linewidth',2);
title('Volatility','fontname','garamond','fontsize',14,'Color',[.3 .3 .3]);
set(gca,'xtick',index);
set(gca,'xticklabel','Jan1997|Jan1998|Jan1999|Jan2000|Jan2001|Dec2001'),
set(gca,'ylim',[0 3]);
set(gcf,'color','w');
set(gcf,'color','w');
xlabel('Date');
ylabel('Standard Deviation');
set(gca,'Box', 'off', 'TickDir', 'out', 'TickLength', [.02 .02],'XMinorTick', 'off','YMinorTick', 'off','XColor', [.3 .3 .3],'YColor',[.3 .3 .3],'LineWidth', 1, 'FontName', 'Times');
%-----------------------------------------------
% QUESTION 6

% Standardized Returns:
zt=ret./cond_std;

mean_stdret=mean(zt);
std_stdret=std(zt);
skewness_stdret=skewness(zt);
kurtosis_stdret=kurtosis(zt);
excess_kurtosis_stdret=kurtosis_stdret-3;

% Returns and descriptive statistics at different frequencies:
ret_5d=NaN(rows(ret),1);
ret_5d(6:5:end)=100*log(prices(6:5:end,:)./prices(1:5:end-5,:));
ret_10d=NaN(rows(ret),1);
ret_10d(11:10:end)=100*log(prices(11:10:end,:)./prices(1:10:end-10,:));
ret_15d=NaN(rows(ret),1);
ret_15d(16:15:end)=100*log(prices(16:15:end,:)./prices(1:15:end-15,:));

RET=NaN(rows(ret),1);
RET(:,1)=ret;
RET(:,2)=ret_5d;
RET(:,3)=ret_10d;
RET(:,4)=ret_15d;

suffix=strvcat('5d','10d','15d');

for i=1:3
mean=nanmean(RET(:,i+1));
stdev=nanstd(RET(:,i+1));
var1=strcat('mean_',suffix(i,:));
assignin('base',var1,mean);
var2=strcat('Stdev_',suffix(i,:));
assignin('base',var2,stdev);
end

skewness_ret5d=skewness(ret_5d);
kurtosis_ret5d=kurtosis(ret_5d);
skewness_ret10d=skewness(ret_10d);
kurtosis_ret10d=kurtosis(ret_10d);
skewness_ret15d=skewness(ret_15d);
kurtosis_ret15d=kurtosis(ret_15d);

Kurt=NaN(1,3);
Kurt(:,1)=kurtosis_ret5d;
Kurt(:,2)=kurtosis_ret10d;
Kurt(:,3)=kurtosis_ret15d;

for i=1:3
Excess_kurtosis=Kurt(:,i)-3;
var3=strcat('ExcessKurtosis_',suffix(i,:));
assignin('base',var3,Excess_kurtosis);
end

% Remove Nans and look at the histograms:

ret_5d_1= ret_5d(~isnan(ret_5d));
ret_10d_1=ret_10d(~isnan(ret_10d));
ret_15d_1=ret_15d(~isnan(ret_15d));

v=sort(ret_5d_1);
q=normpdf(v,mean_5d,Stdev_5d);

figure;
subplot(2,2,1)
[h x1] = ecdf(ret);
ecdfhist(h,x1,100);
p = findobj(gca,'Type','patch');
set(p, 'facecolor', 'b');
title('Daily Returns','fontname','garamond','fontsize',10,'Color',[.3 .3 .3]);
set(gcf,'color','w');
xlabel('Date');
ylabel('Returns');
set(gca,'Box', 'off', 'TickDir', 'out', 'TickLength', [.02 .02],'XMinorTick', 'off','YMinorTick', 'off','XColor', [.3 .3 .3],'YColor',[.3 .3 .3],'LineWidth', 1, 'FontName', 'Times');
hold on;
plot(x,y,'r','Linewidth',2.5);

subplot(2,2,2)
[h5 x5] = ecdf(ret_5d_1);
ecdfhist(h5,x5,20);
p = findobj(gca,'Type','patch');
set(p, 'facecolor', 'b');
title('5Day Returns','fontname','garamond','fontsize',10,'Color',[.3 .3 .3]);
set(gcf,'color','w');
xlabel('Date');
ylabel('Returns');
set(gca,'Box', 'off', 'TickDir', 'out', 'TickLength', [.02 .02],'XMinorTick', 'off','YMinorTick', 'off','XColor', [.3 .3 .3],'YColor',[.3 .3 .3],'LineWidth', 1, 'FontName', 'Times');
hold on;
plot(v,q,'r','Linewidth',2.5);

r=sort(ret_10d_1);
s=normpdf(r,mean_10d,Stdev_10d);

subplot(2,2,3)
[h10 x10] = ecdf(ret_10d_1);
ecdfhist(h10,x10,20);
p = findobj(gca,'Type','patch');
set(p, 'facecolor', 'b');
title('10Day Returns','fontname','garamond','fontsize',10,'Color',[.3 .3 .3]);
set(gcf,'color','w');
xlabel('Returns');
ylabel('Frequency');
set(gca,'Box', 'off', 'TickDir', 'out', 'TickLength', [.02 .02],'XMinorTick', 'off','YMinorTick', 'off','XColor', [.3 .3 .3],'YColor',[.3 .3 .3],'LineWidth', 1, 'FontName', 'Times');
hold on;
plot(r,s,'r','Linewidth',2.5);

k=sort(ret_15d_1);
g=normpdf(k,mean_15d,Stdev_15d);

subplot(2,2,4)
[h15 x15] = ecdf(ret_15d_1);
ecdfhist(h15,x15,20);
p = findobj(gca,'Type','patch');
set(p, 'facecolor', 'b');
title('15Day Returns','fontname','garamond','fontsize',10,'Color',[.3 .3 .3]);
set(gcf,'color','w');
xlabel('Returns');
ylabel('Frequency');
set(gca,'Box', 'off', 'TickDir', 'out', 'TickLength', [.02 .02],'XMinorTick', 'off','YMinorTick', 'off','XColor', [.3 .3 .3],'YColor',[.3 .3 .3],'LineWidth', 1, 'FontName', 'Times');
hold on;
plot(k,g,'r','Linewidth',2.5);

