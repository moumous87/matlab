% Style Analysis

%Upload the dataset
data=xlsread('data.xls',1);

%Dividind the sample into in-sample and out-of-sample period.
ret_in=data(1:40,:);
ret_out=data(41:end,:);

%Distinguishing explainatory variables from the three funds
[R,C]=size(ret_in);
exp_in=ret_in(:,1:end-3);
exp_out=ret_out(:,1:end-3);
fund_in=ret_in(:,end-2:end);
fund_out=ret_out(:,end-2:end);

%Compute the regression for the Fund Vanguard 500 over the explainatory variables
[b_V500,bint,r,rint,stats_V500] = regress(fund_in(:,1),[ones(R,1) exp_in]);

%Compute the regression for the Fund Vanguard WIND over the explainatory variables
[b_VW,bint,r,rint,stats_VW] = regress(fund_in(:,2),[ones(R,1) exp_in]);

%Compute the regression for the Fund Fidelity over the explainatory variables
[b_F,bint,r,rint,stats_F] = regress(fund_in(:,3),[ones(R,1) exp_in]);

%Compute the unexpected returns for the three Funds
unexp_V500=fund_out(:,1)-exp_out*b_V500(2:end)-b_V500(1);
unexp_VW=fund_out(:,2)-exp_out*b_VW(2:end)-b_VW(1);
unexp_F=fund_out(:,3)-exp_out*b_F(2:end)-b_F(1);

%Compute Mean, Standard deviation and IF for the unexpected returns
Mean_unexp=mean([unexp_V500 unexp_VW unexp_F]);
Std_unexp=std([unexp_V500 unexp_VW unexp_F]);
IF_unexp=Mean_unexp./Std_unexp;

%Compute the Upper and Lower bands @95% confidence level
for i=1:size(ret_out,1)
    upper(i,:)=Mean_unexp*i+2*Std_unexp*sqrt(i);
    lower(i,:)=Mean_unexp*i-2*Std_unexp*sqrt(i);
end

%Plot the unexpected returns
figure
plot([unexp_V500 unexp_VW unexp_F]);
title('Unexpected Returns');
legend('Vanguard 500','Vanguard Wind','Fidelity',2);

figure
plot([cumprod(1+unexp_V500) cumprod(1+unexp_VW) cumprod(1+unexp_F)]);
title('Cumulative Unexpected Returns');
legend('Vanguard 500','Vanguard Wind','Fidelity',2);

figure
plot([unexp_V500 unexp_VW unexp_F upper lower]);
title('Unexpected Returns with approximate 95% confidence bands');
legend('Vanguard 500','Vanguard Wind','Fidelity','UpV500','UpVW','UpF','LowV500','LowVW','LowF',2);





