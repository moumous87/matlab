% Linear regression

%Upload the dataset
data=xlsread('data.xls',1);
fund_ret=data(:,end-2); %Vanguard 500
exp_ret=data(:,1:end-3); %TBills IntBds LngBds CrpBds ValStx MedVal MedGth SmlStx ForBds EurStx JpnStx
[R]=size(exp_ret);

%Regression with intercept of the Vanguard 500 over the explainatory variables 
[b_V500,bint,r_V500,rint,stats_V500] = regress(fund_ret,[ones(R(1),1) exp_ret]);

%Residual analysis
r2_V500=r_V500.^2;
SS_res=sum(r2_V500);
predict_V500=[ones(R,1) exp_ret]*b_V500;
fitted_r2=(predict_V500-mean(predict_V500)).^2;
SS_reg=sum(fitted_r2);
SS_tot=sum((fund_ret-mean(fund_ret)).^2);

%Regression without intercept of the Vanguard 500 over the explainatory variables 
[b_V500_2,bint,r_V500_2,rint,stats_V500_2] = regress(fund_ret,exp_ret);

%Residual analysis
r2_V500_2=r_V500_2.^2;
SS_res_2=sum(r2_V500_2);
predict_V500_2=exp_ret*b_V500_2;
fitted_r2_2=(predict_V500_2).^2;
SS_reg_2=sum(fitted_r2_2);
R2_2=SS_reg_2/SS_tot;

%Regression with intercept of the Vanguard 500 over a subset of explainatory variables 
[b_red,bint,r_red,rint,stats_red] = regress(fund_ret,[ones(R(1),1) exp_ret(:,2) exp_ret(:,5:7)]);

%Residual analysis
r2_red=r_red.^2;
SS_red=sum(r2_red);
predict_red=[ones(R(1),1) exp_ret(:,2) exp_ret(:,5:7)]*b_red;
fitted_r2_red=(predict_red-mean(predict_red)).^2;
SS_reg_red=sum(fitted_r2_red);
