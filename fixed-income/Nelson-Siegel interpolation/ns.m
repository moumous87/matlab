function res=ns(parameters,date)

%Recall initial parameters
b0=parameters(1);
b1=parameters(2);
b2=parameters(3);
k=parameters(4);

% Compute the NS interopolation
res=b0+(b1+b2/k)*((1-exp(-k*date))./(k*date))-(b2/k)*(exp(-k*date));

