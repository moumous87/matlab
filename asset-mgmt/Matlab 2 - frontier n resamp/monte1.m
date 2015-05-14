
%We efine the moments of our distribution
er=0.1;
sd=0.2;
t=20;

%We choose the number of random iterations
n=10000;


%We simulate the random sample of returns
r=normrnd(er,sd,t,n);

%We Create the price series
p=ret2tick(r);


%We plot the results
subplot(2,2,1)
plot(p)
grid on
title('Random Paths')

subplot(2,2,2)
hist(p(2,:),50)
grid on
title('Prices distribution at t=1')

subplot(2,2,3)
hist(p(12,:),50)
grid on
title('Prices distribution at t=10')

subplot(2,2,4)
hist(p(end,:),50)
grid on
title('Prices distribution at t=20')
