er=0.1;
sd=0.2;

t=20;

n=10000;

%random sample generation;
r=normrnd(er,sd,t,n);

p=ret2tick(r);


figure
subplot(2,2,1)
plot(p)
grid on
title('random paths')

subplot(2,2,2)
hist(p(2,:),50)
grid on
title('prices at t=1')


subplot(2,2,3)
hist(p(11,:),50)
grid on
title('prices at t=10')


subplot(2,2,4)
hist(p(end,:),50)
grid on
title('prices at t=1')


%the graph becomes lognormal!!!!!!!!!!!

