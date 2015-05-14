clear all

sdy=[0.20 0.21]; %Yearly Standard Deviation
mry=[0.08 0.11]; %Yearly mean return
cor=0.5; %Correlation Coefficient between equity and rf changes
rfy=0.03; %Risk free at t=0

le=5; %Lenght of the Strategy in Years

%Weekly moments
sd=sdy./(52^0.5);
mr=mry./52;
rf=0.03/52;

cova=[sd(1)^2 sd(1)*sd(2)*cor; sd(1)*sd(2)*cor sd(2)^2];


%Number of periods
t=52*le;




sm=100;
p=100;
f=100/(1+rf)^t;
c=p-f;
m=50/c;
s=m*c;
%s=min(p,m*c);
b=p-s;

for i=2:t
    r=mvnrnd(mr,cova,1);
    rf(i,1)=rf(i-1,1)*(1+r(2));
    p(i,1)=s(i-1,1)*(1+r(1))+b(i-1,1)*(1+rf(i,1));
    f(i,1)=100/(1+rf(i,1))^(t-i+1);
    c(i,1)=p(i,1)-f(i,1);
    s(i,1)=max(0,m*c(i,1));
    %s(i,1)=max(0,min(p(i,1),m*c(i,1)));   
    b(i,1)=p(i,1)-s(i,1);
    sm(i,1)=sm(i-1,1)*(1+r(1));
end

pt=linspace(1,t,t);

figure
subplot (2,2,1)
plot(pt,p,'r-',pt,f,'b-')
title('Product')
grid on

subplot (2,2,2)
plot(pt,sm,'r-')
title('Stock Market')
grid on

subplot (2,2,3)
plot(pt,s./p,'r-')
title('Percentage in stocks')
grid on

subplot (2,2,4)
plot(pt,rf*52,'r-')
title('Risk Free')
grid on

