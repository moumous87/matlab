
% FIRST RUN ass1_datatran.m and ass1_frontcon.m

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%	                          w	    st.dev   E(r)
%Money Market	                     0,15%  2,56%
%Bond Euro		                     3,34%	3,33%
%Bond US$		                     9,20%  4,43%
%Bond Corporate Europe HY           16,16%	8,23%

%Equity Italy	            2,23%	24,30%	8,20%
%Equity Europe ex Italy	   27,70%	22,40%	8,75%
%Equity America	           52,22%	19,80%	9,20%
%Equity Japan	           10,11%	20,81% 10,80%
%Equity Pacific ex Japan	2,94%	21,70%	9,85%
%Equity Emerging Market	    4,80%	24,80%	9,90%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
% PARAMETRIC VaR

% THE VaR OF EACH ASSET TAKEN ALONE

VaR99=sd.*norminv(0.99);

% LET'S COMPUTE THE VaR FOR THE TARGET PORTFOLIO FROM THE EFFICIENT FRONTIER

VaR_1=pori1_tgt*norminv(0.99);


% THE LONG (AND USELESS) WAY TO ARRIVE AT THE SAME RESULT:
%VaR weighted of each asset
VaRw1=VaR99.*pow1_tgt';

%Computing the overall VaR of the portfolio
%Thre is no correlation matrix for FX, so we assume that we have already
%adopted some hedging strategy against FX risk

VaR_2=0;

for i=1:10
    for j=1:10
        VaRi2=VaRw1(i,1)*VaRw1(j,1)*corre(i,j);
        VaR_2=VaR_2+VaRi2;
    end
end;

%here is the VaR of the portfolio
VaR_1=sqrt(VaR_2); % =   0.355549072370950

%here is the RAROC
RAROC_1=target1(1,1)/VaR_1; % = 27.84%


clear VaR_2 VaRi2;

%LET'S COMPUTE THE VaR FOR THE TARGET PORTFOLIO FROM THE RESAMPLED FRONTIER

%VaR weighted of each asset
VaRwR=VaR99.*nw_tgt(1,:)';

%Computing the overall VaR of the portfolio
%Thre is no correlation matrix for FX, so we assume that we have already
%adopted some hedging strategy against FX risk

VaR_2=0;

for i=1:10
    for j=1:10
        VaRi2=VaRwR(i,1)*VaRwR(j,1)*corre(i,j);
        VaR_2=VaR_2+VaRi2;
    end
end;

%here is the VaR of the portfolio
VaR_R=sqrt(VaR_2); % =   0.361134609986436

%here is the RAROC
RAROC_R=targetR(1,1)/VaR_R; % = 27.40%


clear VaR_2 VaRi2;

%%
% SIMULATED VaR
% We simulate 1000 possible future paths on which we estimate the VaR
% The methodology is that of the historical smulation... but instead of
% sorting returns from a time series, we sort simulated returns

%%
% LET'S SEE THE EFFICIENT FRONTIER PORTFOLIO WITH E(R) OF 9,9%

nit=10000;

for i=1:nit
    r=mvnrnd(ret,cova,5);
    p=ret2tick(r);
    rpf(:,i)=r*pow1_tgt';
    ppf(:,i)=p*pow1_tgt';
end;

i_one=ones(6,1);

%here are the 10000 possible future paths of the portfolio

figure
plot(ppf)
hold on
plot(i_one,'w :','linewidth', 2)
grid on
title('1000 Random Paths: Portfolio #');

%here we focus on the losses we might incur

losses=1-ppf; %profit or loss
losses(losses>0)=0; %only losses

meanloss=mean(losses');
medianloss=median(losses');

figure
plot(losses,'-')
hold on
plot(meanloss,'w :','linewidth', 2)
hold on
plot(medianloss,'y :','linewidth', 2)
grid on
title('LOSSES: SIMPLE FRONTIER');

%here is the VaR

sorted=sort(rpf,2);

VaRsim_1=-sorted(:,101);

%here is the RAROC

RAROCsim_1=mean(rpf')./VaRsim_1';


clear r p;

%%
% LET'S SEE THE RESAMPLED PORTFOLIO CLOSE TO OUR TARGET E(R) OF 9,9%

for i=1:nit
    r=mvnrnd(ret,cova,5);
    p=ret2tick(r);
    rpf_R(:,i)=r*nw_tgt(1,:)';
    ppf_R(:,i)=p*nw_tgt(1,:)';
end;

i_one=ones(6,1);

%here are the 10000 possible future paths of the portfolio
figure
plot(ppf_R)
hold on
plot(i_one,'w :', 'linewidth', 2)
grid on
title('LOSSES: RESAMPLED FRONTIER');

%here we focus on the losses we might incur

losses_R=1-ppf_R; %profit or loss
losses_R(losses_R>0)=0; %only losses

meanloss_R=mean(losses_R');
medianloss_R=median(losses_R');

figure
plot(losses_R, '-')
hold on
plot(meanloss_R,'w :', 'linewidth', 2)
hold on
plot(medianloss_R,'y :', 'linewidth', 2)
grid on
title('losses');

%here is the VaR

sorted_R=sort(rpf_R,2);

VaRsim_R=-sorted_R(:,101);

%here is the RAROC

RAROCsim_R=mean(rpf_R')./VaRsim_R';


clear r p;

%%
% COMPARING VaR AND RAROC

VaRcompared=[VaRsim_1,VaRsim_R];

RAROCcompared=[RAROCsim_1',RAROCsim_R'];


figure

subplot(2,1,1)
plot(VaRcompared)
title('COMPARING VaR');
xlabel('years')
ylabel('returns')
legend('simple frontier','resampled frontier','Location','best')
grid on;

subplot(2,1,2)
plot(RAROCcompared)
title('COMPARING RAROC');
xlabel('years')
ylabel('returns')
legend('simple frontier','resampled frontier','Location','best')
grid on;

%%
%