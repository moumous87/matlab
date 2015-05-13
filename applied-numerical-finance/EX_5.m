% Conceptualizing the Lognaormal Distribution

%*************Simulation of Stock Price Path******************************

% This script uses the SDE fornulation
% Declare the initial values
N=250;
Mean=0.15;
Sigma=0.30;
Delta_t=1/N;
S0=35;

% Stock Path for 250 observations (days)
normal_shocks=normrnd(0,1,N-1,1);
S(1,1)=S0;
for i=1:N-1
    S(i+1,1)=S(i)*exp(Mean*Delta_t+normal_shocks(i)*Sigma*sqrt(Delta_t));
end

% Plot the Stock Price Path

figure
plot(S)
title('Simulated Stock Price Path');
xlabel('Day');
ylabel('Stock Price ($)');
%**************************************************************************
%*************************Lognormal Histogram******************************

% Declare the initial values
N=1000;
Mean=0.15;
Sigma=0.30;
Delta_t=1;

% Normally distributed errors
X=normrnd(0,1,N,1);

% Lognormal probability density function
Y=exp(Mean*Delta_t+X*Sigma*sqrt(Delta_t));

% Plot the histogram
step=0.05;
mini=min(Y);
maxi=max(Y);
hist(Y,[mini:step:maxi])
title('Lognormal Frequency Distribution');
ylabel('Frequency');
%**************************************************************************
%****************Simulation of Stock Price Path****************************

% This script uses the Euler approximation
% Declare the initial values
N=250;
Mean=0.15;
Sigma=0.30;
Delta_t=1/N;
S0=35;

% Stock Path for 250 observations (days) with the same shocks of the SDE
% example
S_eu(1,1)=S0;
for i=1:N-1
    S_eu(i+1,1)=S(i)*(1+Mean*Delta_t+normal_shocks(i)*Sigma*sqrt(Delta_t));
end

% Plot the Stock Price Path
figure
plot([S S_eu])
title('Comparison of simulated Stock Price Path with SDE and Euler formula');
xlabel('Day');
ylabel('Stock Price ($)');
h=legend('Price with SDE','Price with Euler',2);









