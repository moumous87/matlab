
% FIRST RUN ass1ignment_part1.m

%%
% IN THIS CODE WE ARE USING THE BLACK & LITERMAN METHODOLOGY

%%
% FIRST STEP: FIND THE NEUTRAL RETURNS
% i.e. the actual mkt eq. returns

lambda=2; % We set lambda, the risk aversion coefficient, equal to 2 (a common value in quadratic utility functions)
EqReturns=lambda*covaE*wmkt;
%  =
%   0.075095916014262
%   0.077244709095017
%   0.071215151731526
%   0.044094702426329
%   0.063009650326455
%   0.071872091982165

% We stick to the utility function of the quadratic form because it is the
% base-form of utility function used in most financial theory, therefore we
% are not going to challenge it

% LET'S  SEE HOW THE EFFICIENT FRONTIER WITH THIS RETURNS WOULD BE

[pori3,pore3,pow3]=frontcon(EqReturns,covaE,30);

profile3=[pore3, pori3];

figure
plot(pori3,pore3,'k *')
xlabel('standard deviation')
ylabel('eq. return')
title('FRONTCON ON EQUILIBRIUM RETURNS')
grid on

figure
area(pow3)
xlabel('eq. return')
title('FRONTCON ON EQUILIBRIUM RETURNS')
set(gca,'ylim',[0 1])
legend('Italy','Europe','America','Japan','Pacific','Emerging Mkts','Location','EastOutside')
grid on;

% COMPARING EFFICIENT FRONTIERS: EQ. RETURNS VS EXPECTATIONS

figure
plot(pori2,pore2,'k *', pori3,pore3,'r *')
xlabel('standard deviation')
ylabel('expected return')
title('COMPARING EFFICIENT FRONTIER: EQ. RETURNS VS EXPECTATIONS')
legend('expectations','equilibrium','Location','SouthEast','Orientation','horizontal')
grid on

figure

subplot(1,2,1)
area(pow2)
xlabel('expected return')
title('FRONTCON ON EXPECTATIONS')
set(gca,'ylim',[0 1])
legend('It','Eu','Am','Jp','Pa','E.M.','Location','best')
grid on;

subplot(1,2,2)
area(pow3)
xlabel('eq. return')
title('FRONTCON ON EQUILIBRIUM RETURNS')
set(gca,'ylim',[0 1])
legend('It','Eu','Am','Jp','Pa','E.M.','Location','best')
grid on;


% RECAPITULATING

%                           std   expectations     eq. ret.
%Equity Italy	           24,30%     8,20%    7.5095916014262%
%Equity Europe ex Italy	   22,40%     8,75%    7.7244709095017%
%Equity America	           19,80%     9,20%    7.1215151731526%
%Equity Japan	           20,81%    10,80%    4.4094702426329% <== the Japan neutral return is really low!!!
%Equity Pacific ex Japan   21,70%     9,85%    6.3009650326455%
%Equity Emerging Market	   24,80%     9,90%    7.1872091982165%


%%
% THE EXPECTATIONS GIVEN BY THE BOSS ARE VIEWS, SO WE WILL 'BLEND' THEM
% WITH THE EQUIIBRIUM RETURNS (WE CONSIDER ONLY THE EQUITY)

% Here are the views, i.e. our analysts' expectations
vBL=ret(5:10,:);

% Here is the view-weights matrix
pBL=eye(6);

myconf1=0.70; %my confidence on view #1
s1=0.01/norminv((1+myconf1)/2); %sigma estimated the Drobetz way

myconf2=0.70; %my confidence on view #2
s2=0.01/norminv((1+myconf2)/2); %sigma estimated the Drobetz way

myconf3=0.70; %my confidence
s3=0.01/norminv((1+myconf3)/2); %sigma estimated the Drobetz way

myconf4=0.70; %my confidence
s4=0.01/norminv((1+myconf4)/2); %sigma estimated the Drobetz way

myconf5=0.70; %my confidence
s5=0.01/norminv((1+myconf5)/2); %sigma estimated the Drobetz way

myconf6=0.70; %my confidence
s6=0.01/norminv((1+myconf6)/2); %sigma estimated the Drobetz way

sdBL=diag([s1 s2 s3 s4 s5 s6]);

tau=1/sqrt(5);

%%
% BLACK & LITTERMAN

mBL=inv(inv(tau*covaE)+pBL'*inv(sdBL)*pBL)*(inv(tau*covaE)*EqReturns+pBL'*inv(sdBL)*vBL);

%          mBL          st.dev
%   0.090350093961469   24,30%
%   0.090350623346117   22,40%
%   0.088468622543346   19,80%
%   0.086622743767085   20,81%
%   0.089483111611938   21,70%
%   0.100077637033051   24,80%


% these results are economically acceptable... higher return for higher
% volatility... higher return for emerging markets... Japan not jumping
% from an equilibrium of 4% to a 10.28%... and so on

%%
% BUILDING AN EFFICIENT FRONTIER WITH THE B&L EXPECTED RETURNS

retBL=[ret(1:4,1);mBL];

[poriBL,poreBL,powBL]=frontcon(retBL,cova,21);

profileBL=[poreBL, poriBL]; % column1=E(r), column2=St.Dev

figure
plot(poriBL,poreBL,'k *')
xlabel('standard deviation')
ylabel('expected return')
title('FRONTCON ON B&L')
grid on;

figure
area(powBL)
title('FRONTCON ON B&L')
set(gca,'ylim',[0 1])
legend('M.M.','B. Euro','B. US','B. Euro HY','E. Italy','E. Europe','E. America','E. Japan','E. Pacific','E. Emerging','Location','EastOutside')
grid on;

% PORTFOLIO WITH TARGET E(r) OF 9.9%

[poriBL_tgt,poreBL_tgt,powBL_tgt]=frontcon(retBL,cova,[],0.099);

targetBL=[poreBL_tgt,poriBL_tgt]; % column1=E(r), column2=St.Dev

%%
% RESAMPLING THE B&L EXPECTED RETURNS

nit=1000;
w=zeros(201,na);

for i=1:nit
    r=mvnrnd(retBL,cova,100);
    retSIM=mean(r);
    covaSIM=cov(r);
    [poriBLR,poreBLR,powBLR]=frontcon(retSIM,covaSIM,201);
    w=w+powBLR;
end;


clear r retSIM covaSIM;


nwBL=w./nit;

for i=1:size(nwBL,1)
    riskBLR(i,1)=(nwBL(i,:)*cova*nwBL(i,:)')^0.5;
    retBLR(i,1)=nwBL(i,:)*retBL;
end;


clear w;


profileBLR=[retBLR, riskBLR]; % column1=E(r), column2=St.Dev

% Here we save the portfolios (and the respective weights) with E(r) close to 9.9%

targetBLR=profileBLR(find(profileBLR(:,1)>0.0989),:);
nwBL_tgt=nw(find(profileBLR(:,1)>0.0989),:);

% Here I reduce the efficient frontier portfolios from 201 to 21
nwBL=nwBL(1:10:201,:);
retBLR=retBLR(1:10:201,:);
riskBLR=riskBLR(1:10:201,:);
profileBLR=profileBLR(1:10:201,:);


figure
plot(riskBLR,retBLR,'k *')
xlabel('Standard Deviation')
ylabel('Expected Return')
title('RESAMPLING B&L')
grid on;

figure
area(nwBL)
title('RESAMPLING B&L')
set(gca,'ylim',[0 1])
legend('M.M.','B. Euro','B. US','B. Euro HY','E. Italy','E. Europe','E. America','E. Japan','E. Pacific','E. Emerging','Location','EastOutside')
grid on;


%profileBLR=
%          E(r)                std
%   0.025836978398532   0.001403280195711
%   0.029601620343778   0.006156321868756
%   0.033386599311921   0.011947224749722
%   0.037172018970953   0.017791054606619
%   0.040950058186363   0.023640005635016
%   0.044589335434866   0.029380310855031
%   0.047992045338085   0.035373769488202
%   0.051329883122429   0.042414148154393
%   0.054692738976817   0.050446348584375
%   0.058085021461240   0.059091057222683
%   0.061489210039625   0.068096759126650
%   0.064903255943457   0.077347024411543
%   0.068341351862992   0.086829141971205
%   0.071803628401661   0.096516735317622
%   0.075278707354633   0.106391322602368
%   0.078706689336841   0.116441764416208
%   0.081955926427421   0.126619790861907
%   0.084791183164977   0.136907797003720
%   0.087233096700240   0.148388444521786
%   0.089565153335703   0.163123129672209
%   0.092600809677251   0.186910699141265

% We do not reach the desired 9.9% so we will not take any target portfolio
% from this effient frontier


%%
% NOW WE WILL USE B&L IN ANOTHER WAY:
% WE WILL DEFINE VIEWS TRYING TO 'REPLICATE' THE EXPECTATIONS OF OUR
% ANALYSTS

%%
% OUR VIEWS:

% VIEW #1
% Absolute view of Japan performing at 12.80%

% VIEW #2
% Japan outperforms Europe and America by 2%: this view should lead to
% results more in line with the assignment ones. We won't impose anything
% on the Pacific area because it should follow Japan on the wave of the
% positive view.
vw1=wmkt(1,1)/sum(wmkt(1:3,1)); %view weight for Italy
vw2=wmkt(2,1)/sum(wmkt(1:3,1)); %view weight for Europe ex Italy
vw3=wmkt(3,1)/sum(wmkt(1:3,1)); %view weight for America

%VIEW #3
% Just an exercise: Emerging markets outperforming the world by 1%... the
% eq. returns for Emerging Mkts is lower than Italy, Europe and America,
% which pretty goes against the definition of 'Emerging mkt'...
vw4=1-wmkt(6,1);

% Here are our views
vBL_=[0.128; 0.02; 0.01];

% Here is the view-weights matrix
pBL_=[0 0 0 1 0 0 ; -vw1 -vw2 -vw3 1 0 0; -wmkt(1,1) -wmkt(2,1) -wmkt(3,1) -wmkt(4,1) -wmkt(5,1) vw4];

myconf_1=0.68; %my confidence on view #1
sdBL_1=0.01/norminv((1+myconf_1)/2); %sigma estimated the Drobetz way

myconf_2=0.85; %my confidence on view #2
sdBL_2=0.01/norminv((1+myconf_2)/2); %sigma estimated the Drobetz way

myconf_3=0.85; %my confidence on view #3
sdBL_3=0.01/norminv((1+myconf_3)/2); %sigma estimated the Drobetz way

sdBL_=diag([sdBL_1 sdBL_2 sdBL_3]);

tau=1/sqrt(5);

%%
% BLACK & LITTERMAN

mBL_=inv(inv(tau*covaE)+pBL_'*inv(sdBL_)*pBL_)*(inv(tau*covaE)*EqReturns+pBL_'*inv(sdBL_)*vBL_);

%  =
%   0.091870296060609
%   0.087404017820811
%   0.080280678915677
%   0.096227324117330
%   0.082668680404077
%   0.095832897639782

%%
% M-V OPTIMIZATION AND RESAMPLING

% SIMPLE FRONTIER

retBL_=[ret(1:4,1);mBL_];

[poriBL_,poreBL_,powBL_]=frontcon(retBL_,cova,30); %I guess that the covariance matrix remains the original one

profileBL_=[poreBL_, poriBL_];

figure
plot(poriBL_,poreBL_,'k *')
xlabel('standard deviation')
ylabel('expected return')
title('FRONTCON ON VIEWS')
grid on;

figure
area(powBL_)
title('FRONTCON ON VIEWS')
set(gca,'ylim',[0 1])
legend('M.M.','B. Euro','B. US','B. Euro HY','E. Italy','E. Europe','E. America','E. Japan','E. Pacific','E. Emerging','Location','EastOutside')
grid on;

% PORTFOLIO WITH TARGET RETURN OF 9.9%

[poriBL_tgt2,poreBL_tgt2,powBL_tgt2]=frontcon(retBL_,cova,[],0.099);
targetBL_=[poreBL_tgt2,poriBL_tgt2];

% RESAMPLING
nit=1000;
w=zeros(21,na);

for i=1:nit
    r=mvnrnd(retBL_,cova,100);
    retSIM=mean(r);
    covaSIM=cov(r);
    [poriBL_R,poreBL_R,powBL_R]=frontcon(retSIM,covaSIM,21);
    w=w+powBL_R;
end;


clear r retSIM covaSIM;


nwb_=w./nit;

for i=1:size(nwb_,1)
    riskBL_R(i,1)=(nwb_(i,:)*cova*nwb_(i,:)')^0.5;
    retBL_R(i,1)=nwb_(i,:)*retBL_;
end;


clear w;


figure
plot(riskBL_R,retBL_R,'k *')
xlabel('Standard Deviation')
ylabel('Expected Return')
title('Resampled View')
grid on;

figure
area(nwb_)
title('Resampled View')
set(gca,'ylim',[0 1])
legend('M.M.','B. Euro','B. US','B. Euro HY','E. Italy','E. Europe','E. America','E. Japan','E. Pacific','E. Emerging','Location','EastOutside')
grid on;

profileBL_R=[retBL_R, riskBL_R];

%%
%