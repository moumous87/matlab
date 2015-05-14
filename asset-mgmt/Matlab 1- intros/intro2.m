dat=csvread('data.csv');

ni=size(dat,2);
nd=size(dat,1);


ret=tick2ret(dat);


%We calculate mean retuns and the var-cov frontier from our historical
%sample. We will assume that these are the inputs that we want to use in
%our mean-variance optimization.

covar=cov(ret);
mr=mean(ret);

%Again in the finance toolbox there is a built-in functio toperform this
%task

%[mr covar]=ewstats(ret);


%We can now calculate 20 portfolios on the efficinet frontier
%This function is hihgly customizable. Here we consider the basic
%uncostrained specification

[porisk, poret, pow] = frontcon(mr, covar, 20);


%We can plot the result
plot(porisk,poret,'b-o');


%Let's assume that now we want to estimate a more realistic frontier with
%minimum and maximum weight constrains for each asset

%We have to create two row vectors for lower and upper bounds for each
%asset
lb=zeros(1,ni);
ub=ones(1,ni).*0.3;


%We can now calculate the efficient frontier using upper and lower bounds

[porisk2, poret2, pow2] = frontcon(mr, covar, 20, [], [lb;ub]);


%We can now plot the two frontiers together. We also want to get more
%control on the output and, specifically, on the color and the type of the
%two lines

plot(porisk,poret,'b-o',porisk2,poret2,'r-d');
title('Efficient Frontiers');
xlabel('Risk');
ylabel('Expected Return');
legend('Uncontrained','Constrained');
grid on


%We also want to get a visula look at the composition of the two frontiers.
%With the area command what we get is a visula picture of the composition
%of the 20 portfolios on the frontier.

%This line will tell matlab to open a new figure instead of writing over
%the previous plot

figure

%The subplot command allows us to nest more than one graph inside the same
%figure window

subplot(1,2,1)
area(pow)
title('Unconstrained Frontier')

subplot(1,2,2)
area(pow2)
title('Constrained Frontier')
