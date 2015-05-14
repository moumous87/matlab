
% FIRST RUN ass1ignment_part1.m and assignment_part2.m

%%
% IN THIS CODE WE QUANTIFY THE RISK

%%
% PARAMETRIC VaR


% THE VaR OF EACH ASSET TAKEN ALONE

VaR99=sd.*norminv(0.99);

% LET'S COMPUTE THE VaR FOR THE TARGET PORTFOLIO FROM THE M-V OPTIMIZATION

VaR_1=pori1_tgt*norminv(0.99); % =   0.355549072370950

RAROC_1=target1(1,1)/VaR_1; % = 27.84%



% LET'S COMPUTE THE VaR FOR THE TARGET PORTFOLIO FROM THE RESAMPLED FRONTIER

VaR_R=targetR(1,2)*norminv(0.99); % = 0.376168179223627

RAROC_R=targetR(1,1)/VaR_R; % = 26.30%

%%
% SIMULATED VaR
% We simulate 10000 possible future paths on which we estimate the VaR
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


figure
plot(ppf)
hold on
plot(i_one,'w :','linewidth', 2)
grid on
title('1000 Random Paths: Portfolio #');

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



sorted=sort(rpf,2);

% HERE IS THE VaR

VaRsim_1=-sorted(:,101);

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


figure
plot(ppf_R)
hold on
plot(i_one,'w :', 'linewidth', 2)
grid on
title('LOSSES: RESAMPLED FRONTIER');

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


sorted_R=sort(rpf_R,2);

% HERE IS THE VaR

VaRsim_R=-sorted_R(:,101);

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
% THE MAJOR PROBLEM OF THE M-V METHODOLOGY IS THAT IT IS TOO POWERFUL
% GIVEN THE SIGNIFICANCE OF THE DATA, i.e EVEN A 1 B.P. CHANGE IN A VERY...
% 'VOLATILE' PARAMETER SUCH AS ST.DEV MAKES A HUGE DIFFERENCE.
% WHILE WE NOW THAT, FIRST, PARAMETERS AND EXPECTATIONS CHANGE AND, SECOND,
% SMALL DIFFERENCES BETWEEN PARAMETERS SHOULD BE IRRELEVANT.
% IT IS FROM THIS VERY SIMPLE IDEA THAT WE BUILD A KIND OF SENSISTIVITY
% ANALYSIS...

% ...SUPPOSE THAT THAT OUR RISK FACTOR IS JAPAN'S VOLATILITY...

% We increase Japan's volatility by 1%
sd01=sd+[0;0;0;0;0;0;0;0.01;0;0];
cova01=corr2cov(sd01,corre);

%%
% GIVEN THE NEW VOLATILITIES AND THE NEW VARCOV MATRIX, ALSO THE RISK OF
% OUR TARGET PORTFOLIO HAS CHANGED

% The expected return of the old portfolio hasn't changed since the weights
% are the same and the E(r) are as well the same

% ... but the VOLATILITY has changed
pori_old=sqrt(pow1_tgt*cova01*pow1_tgt'); % = 0.158274739946021 vs the former 0.152835728627879

% ... as well as the VaR
VaR_old=pori_old*norminv(0.99);

RAROC_old=target1(1,1)/VaR_old; % = 26.89% vs previous 27.84%

% VaR CHANGE
VaRchange=VaR_old-VaR_1; % = 0.012653032416842
RAROCchange=RAROC_old-RAROC_1; % = -0.009568503027522

%%
% SAME AS BEFORE FOR THE TARGET RESAMPLED PORTFOLIO

% The new VOLATILITY
pori_oldR=sqrt(nw_tgt(1,:)*cova01*nw_tgt(1,:)'); % = 0.165829338712438 vs. previous 0.161699023358113

% And the new VaR
VaR_oldR=pori_oldR*norminv(0.99); % = 0.385776729567280 vs. previous 0.376168179223627

RAROC_oldR=targetR(1,1)/VaR_oldR; % = 25.64% vs. previous 26.30%

% VaR CHANGE
VaRchangeR=VaR_oldR-VaR_R; % = 0.009608550343653

%%
% SAME AS BEFORE FOR THE TARGET PORTFOLIO AFTER BLACK & LITTERMAN (1st one)

% The new VOLATILITY
pori_oldBL=sqrt(powBL_tgt*cova01*powBL_tgt'); % = 0.237567340993432 vs. previous 0.237492552976313

% The VaR has changed...
% ...from
VaR_BL=poriBL_tgt*norminv(0.99); % = 0.552490295716978
% ...to
VaR_oldBL=pori_oldBL*norminv(0.99); % = 0.552664278661607

% VaR CHANGE
VaRchangeBL=VaR_oldBL-VaR_BL; % = 0.0001739829446296692

%%
% SAME AS BEFORE FOR THE TARGET PORTFOLIO AFTER BLACK & LITTERMAN (2nd one)

pori_oldBL2=sqrt(powBL_tgt2*cova01*powBL_tgt2');
VaR_BL2=poriBL_tgt2*norminv(0.99);
VaR_oldBL2=pori_oldBL2*norminv(0.99);
VaRchangeBL2=VaR_oldBL2-VaR_BL2;

%%
%