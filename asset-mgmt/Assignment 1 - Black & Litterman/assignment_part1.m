
clear, clc, close all;

%%
% UPLOAD DATASET

[data,txt,raw]=xlsread('Assignement_1_data.xls',1);

% VARIABLES

ret=data(:,3); % 5y expected returns
sd=data(:,2); %standard deviation
corre=data(:,4:end); %correlation matrix
cova=corr2cov(sd,corre); %covariance matrix = sd*sd'.*corre
na=size(ret,1);

% E(R) AND ST.DEV OF THE EXPECTED MKT PORTFOLIO

retE=ret(5:end,:); %equity returns
wmkt=data(5:end,1); %mkt weights
covaE=cova(5:end,5:end); %covariance matrix - only equity
mkt_r=sum(retE.*wmkt); %mkt portfolio ret=0.092673954842504
mkt_sd=sqrt(wmkt'*covaE*wmkt); %mkt portfolio st.dev=0.187112109604992
ne=size(retE,1); %#of equity assets


clear data;


%%
% M-V OPTIMIZATION WITH ALL ASSETS

[pori1,pore1,pow1]=frontcon(ret,cova,21);

profile1=[pore1, pori1]; % column1=E(r), column2=St.Dev

figure
plot(pori1,pore1,'k *')
title('FRONTCON - ALL ASSETS')
xlabel('standard deviation')
ylabel('expected return')
grid on;


figure
area(pow1)
title('FRONTCON - ALL ASSETS')
set(gca,'ylim',[0 1])
xlabel('expected return/risk')
legend('M.M.','B. Euro','B. US','B. Euro HY','E. Italy','E. Europe','E. America','E. Japan','E. Pacific','E. Emerging','Location','EastOutside')
grid on;

% PORTFOLIO WITH TARGET E(r) OF 9.9%
% The volatility of the resulting portfolio is of 15.2835728627879%
% we decided to target the E(r) - and not the standard deviation - in order
% to compare the volatility of other portfolios that have equal (or pretty
% similar)E(r)

[pori1_tgt,pore1_tgt,pow1_tgt]=frontcon(ret,cova,[],0.099);

target1=[pore1_tgt,pori1_tgt]; % column1=E(r), column2=St.Dev







%%
% M-V OPTIMIZATION WITH ONLY EQUITY

[pori2,pore2,pow2]=frontcon(retE,covaE,21);

profile2=[pore2, pori2]; % column1=E(r), column2=St.Dev

figure
plot(pori2,pore2,'k *')
title('FRONTCON - ONLY EQUITY')
xlabel('standard deviation')
ylabel('expected return')
grid on

figure
area(pow2)
title('FRONTCON - ONLY EQUITY')
set(gca,'ylim',[0 1])
xlabel('expected return/risk')
legend('Italy','Europe','America','Japan','Pacific','Emerging Mkts','Location','EastOutside')
grid on;

% Here we can better see how Japan weights a lot in our m-v optimized
% portfolios

%% 
% RESAMPLING ALL ASSETS

nit=1000;
w=zeros(201,na);

run loopy;


for i=1:nit
    char(loopcheck(i))
    
    r=mvnrnd(ret,cova,100); % When simulating a time series of returns, the
    % 3rd input is actually the length of the investment horizon, BUT in
    % this case it is not really the length of the investment horizon since
    % we take the mean value of them (see next code-line). In the end it is
    % just a number of successive simulations, so it is not a statistical
    % mistake to freely set a number as we did (putting 100).
    
    % In particular, we NEEDED to put a high number because with only a few
    % data, the VarCov matrix results as non-psd (you need at least n+1
    % observations where n is the dimension of the VarCov matrix).
    
    % Switching from yearly returns to monthly returns could have been a
    % way to avoid this intellectual/statistical puzzle since we would have
    % set the third argument equal to 60 (i.e 60 months), a number high
    % enough to end up for sure with a psd VarCov matrix, but scaling
    % standard deviations to the monthly investment horizon using the
    % periodic compounding rule would have been a nightmare (if not
    % impossible) since the 1-over-square-root-of-n rule is valid only for
    % log-returns.
    
    % Switching to log-returns would have been quite complex as well since
    % we would have had to change the standard deviations (st.dev of
    % periodically compounded returns is different from st.dev of
    % log-returns), and this would have been a nightmare (if not impossible).
    
    % Finally, we decided to adopt our heuristic and statistically
    % acceptable solution: 3rd argument=100
    
    retSIM=mean(r);
    covaSIM=cov(r);
    
    [poriR,poreR,powR]=frontcon(retSIM,covaSIM,201); % In the resampling
    % methodology we cannot explicitely request an expected return (better,
    % a very high or very low return) since in the course of the iterations
    % it happens that the randomly generated returns do not allow the
    % efficient frontier to reach such return, so Matlab stops running the
    % loop. That is why we are building so many portfolios. The more
    % portfolios we build, the more easily we can find a portfolio with an
    % E(r) as close a possible to the 9.9% target.
    
    w=w+powR;
end;


clear r retSIM covaSIM;


nw=w/nit;

%for i=1:size(nw,1)
%    riskR(i,1)=(nw(i,:)*cova*nw(i,:)')^0.5;
%    retR(i,1)=nw(i,:)*ret;
%end;
%THIS WAS A USELESS LOOP
%HERE A BETTER, FASTER WAY, MORE EFFICIENT WAY JUST USING MATRIX OPERATIONS

retR=nw*ret;
riskR=sqrt(sum(nw*cova.*nw,2));



clear w;


profileR=[retR, riskR]; % column1=E(r), column2=St.Dev

% Here we save the portfolios (and the respective weights) with E(r) close to 9.9%

targetR=profileR(find(profileR(:,1)>0.0989),:); % column1=E(r), column2=St.Dev
nw_tgt=nw(find(profileR(:,1)>0.0989),:);

% the way we find the portfolio with a target 9.9% E(r) is pretty rough,
% lacks of swiss precision... but it's the easiest and fastest way.


% Here we reduce the efficient frontier portfolios from 201 to 21
nw=nw(1:10:201,:);
retR=retR(1:10:201,:);
riskR=riskR(1:10:201,:);
profileR=profileR(1:10:201,:);


figure
plot(riskR,retR,'k *')
title('RESAMPLED FRONTIER')
xlabel('Standard Deviation')
ylabel('Expected Return')
grid on;

figure
area(nw)
title('RESAMPLED FRONTIER')
set(gca,'ylim',[0 1])
xlabel('expected return/risk')
legend('M.M.','B. Euro','B. US','B. Euro HY','E. Italy','E. Europe','E. America','E. Japan','E. Pacific','E. Emerging','Location','EastOutside')
grid on;

%targetR=
%          E(r)                std
%   0.098954834831017   0.161354421275857 <== I'll take this portfolio as the closest to our target
%   0.099213079867808   0.162874471649493
%   0.099462987196140   0.164412449142449
%   0.099705719280793   0.165975951751696
%   0.099940285632967   0.167557178851052

%%
% COMPARING THE SIMPLE FRONTIER AND THE RESAMPLED ONE

figure
plot(pori1,pore1,'k : *', riskR,retR,'r : *')
xlabel('standard deviation')
ylabel('expected return')
title('COMPARING EFFICIENT FRONTIER: SIMPLE M-V vs. RESAMPLING')
legend('markowitz','resampling','Location','SouthEast','Orientation','horizontal')
grid on
%%
%