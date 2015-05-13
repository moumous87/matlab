% Black & Litterman

% Upload dataset
market_val=xlsread('data1.xls');
data=xlsread('data2.xls');
rf=0.00038615;
lam=3;

% Compute returns
returns=(data(2:end,:)-data(1:end-1,:))./data(1:end-1,:);
[R,C]=size(returns);

% Compute VarCov matrix
VarCov=cov(returns);

% Compute expected returns
hist_exp_ret=mean(returns);
hist_excess_ret=hist_exp_ret-rf;

% Compute market weights for the tangency portfolio, taking the last date
market_w=market_val(end,:)./sum(market_val(end,:));

% Compute the implied market expected and excess returns with the BL formula
mark_exp_ret=lam*VarCov*market_w'+rf;
mark_excess_ret=lam*VarCov*market_w';

% Compute the implied market expected returns with an optimization approach
market_fit_w0=1./ones(1,C);
fun=@minESS;
options=optimset('LargeScale','off');
Aeq=ones(1,C);
beq=1;
market_w_fitted=fmincon(fun,market_fit_w0,[],[],Aeq,beq,[],[],[],options,mark_exp_ret',market_w,VarCov,C,rf);

% Compute Makowitz weights 
denominator1=ones(C,1)'*inv(VarCov)*ones(C,1);
denominator2=hist_exp_ret*inv(VarCov)*ones(C,1);
lamb=denominator2-rf*denominator1;
markow_w=hist_excess_ret*inv(VarCov)*(1/lamb);

% Plot market expected returns vs historical expected returns
figure
bar([mark_exp_ret hist_exp_ret']);
title('Market expected returns vs Historical expected returns');
h=legend('Market returns','Historical returns',2);
axis([1 C -0.005 0.01]);

% Plot market weights vs Markowitz weights
figure
bar([markow_w' market_w']);
title('Markowitz vs market weights');
h=legend('Markowitz weights','Market weights',2);
axis([1 C -1 1]);

% Espress views
Number_views=3;
P=zeros(C,Number_views);
    % Alleanza > Generali
    P(1,1)=1; P(12,1)=-1;
    % BNL > Fideuram
    P(3,2)=1; P(4,2)=-1;
    % Unicredit > San Paolo IMI
    P(18,3)=-1; P(21,3)=1;

% Expected value of the views
V=zeros(Number_views,1);

% Standard deviation of the views
tau=0.3;
Error=diag(ones(Number_views,1)*0.0001);

%Combining alltogheter
[Mu_BL]=calcolobl(P',VarCov,Error,V,mark_exp_ret,tau)

% Computing BL weights
bl_w=(Mu_BL'-rf)*inv(VarCov)*(1/lam);

% Plot market, Markowitz and BL weights
figure
bar([markow_w' market_w' bl_w']);
title('Markowitz, market and Black and Litterman weights');
h=legend('Markowitz weights','Market weights','BL weights',4);
axis([1 C -1 0.8]);

% Plot market weights vs BL weights
figure
bar([market_w' bl_w']);
title('Market and Black and Litterman weights');
h=legend('Market weights','BL weights',2);
axis([1 C -0.2 0.3]);


