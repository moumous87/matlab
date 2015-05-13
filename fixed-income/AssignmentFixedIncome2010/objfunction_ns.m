function y=objfunction_ns(parameters,date,spot_rate)

%Recall initial parameters
b0=parameters(1);
b1=parameters(2);
b2=parameters(3);
k=parameters(4);
N=size(spot_rate,1);

% Compute the NS interopolation
ns=b0+(b1+b2/k)*((1-exp(-k*date))./(k*date))-(b2/k)*(exp(-k*date));

y=sum((spot_rate-ns).^2);