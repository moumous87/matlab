dat=csvread('data.csv');


ni=size(dat,2);
nd=size(dat,1);

ret=tick2ret(dat);

mr=mean(ret);
covar=cov(ret);

[porisk,poret,pow]=frontcon(mr,covar,20);

plot(porisk,poret,'k:o');

%lb=zeros(1,ni);
%ub=ones(1,ni).*0.3;

%bound=[lb;ub];

bound=[zeros(1,ni);ones(1,ni).*0.3];

[porisk2, poret2, pow2]=frontcon(mr, covar, 20, [], bound);

figure
plot(porisk,poret,'k:o',porisk2,poret2,'r:x');
title('efficient frontier');
xlabel('risk');
ylabel('expected return');
legend('unconstrained','constrained',2);
grid on;

figure
subplot(1,2,1);
area(pow);
title('unconstrained frontier');
subplot(1,2,2);
area(pow2);
title('constrained');





















