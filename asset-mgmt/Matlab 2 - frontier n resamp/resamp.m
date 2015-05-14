db=csvread('data.csv');

ret=db(:,2);
cova=corr2cov(db(:,1),db(:,3:end));


nport=50;	%number of portfolios on the frontier
nit=100;	%number of iterations
t=36;		%lenght of the simulated sample

na=size(ret,1);

we=zeros(nport,size(ret,1));

%Unconstrainded Frontier%
[ri,re,wt]=frontcon(ret,cova,nport);

%Resampling%

for i=1:nit
   r=mvnrnd(ret,cova,t);
   ret2=mean(r);
   cova2=cov(r);
   [ri2,re2,wt2]=frontcon(ret2,cova2,nport);
   we=we+wt2;
end

nwe=we./nit;

for i=1:size(nwe,1)
   nrisk(i,1)=(nwe(i,:)*cova*nwe(i,:)')^0.5;
   nret(i,1)=nwe(i,:)*ret;
end

csvwrite('frontier.csv',[nwe nrisk nret]);

figure
subplot (2,2,1)
area(wt)
title('Unconstrained Frontier');

subplot (2,2,2)
area(nwe)
title('Resampled Frontier');

subplot(2,2,3)
plot(ri,re,'b-',nrisk,nret,'r-')
title('Frontiers');
xlabel('Standard Deviation');
ylabel('Expected Return');
legend('Unconstrained','Resampled')
grid on



%Sensitivity Analysis



herf=(sum(wt.^2,2)-(1/na))/(1-1/na);
herf2=(sum(nwe.^2,2)-(1/na))/(1-1/na);

figure
plot(nrisk,herf2,'rd-',ri,herf,'bo-')
title('Portfolio Concentration');
xlabel('Standard Deviation');
ylabel('Herfindahl');
legend('Resampled','Unconstrained')
grid on
    