%We want to test two possible rebalancing strategies for our portfolio.
%Specifically we want to see if the choice of constant mix vs buy and hold
%produce a significantly diferent return pattern.


%We consider two asset (one high risk, the other low risk)


mr=[0.02 0.003];
sd=[0.1 0.01];
co=0.2;



cm=[1 co;co 1];
covar=corr2cov(sd,cm);

%We use a montecarlo approach to run this simulation considering k random
%iterations

k=10000;
t=36;

%We assume that the assets are jointly normally dsitributed and in each
%random iteration we generate a random series of 12 montly returns
ris=zeros(k,2);
for i=1:k
    %We run a multivariate normal random number generation
    r=mvnrnd(mr,covar,t);
    
    %We initialize the intial portfolio composition of the BH portfolio
    pbh=[0.5 0.5];
    
    %We initialize the portfolio returns vectors
    rcm=zeros(t,1);
    rbh=zeros(t,1);
    
    %We initialize the portfolio value vectors
    cm=[1;zeros(t,1)];
    bh=[1;zeros(t,1)];
    
    
    %We start a second loop where we simulate the portoflio evolution after
    %each montly return
    
    for j=1:t
        
        %We calculate the monthly return of the two portfolios
        rcm(j,1)=mean(r(j,:));
        rbh(j,1)=(pbh*r(j,:)')/sum(pbh);
        
        %We update the composition of the buy and hold portfolio
        pbh=pbh.*(1+r(j,:));
        
        %We calculate the portfolio value at the end of the month
        cm(j+1,1)=cm(j,1)*(1+rcm(j,1));
        bh(j+1,1)=bh(j,1)*(1+rbh(j,1));
    end
    
    
    %we save the terminal portfolio values
    ris(i,1)=cm(t);
    ris(i,2)=bh(t);
    
end

figure

subplot(2,2,1)
hist(ris(:,1),50)
title('Constant Mix')
grid on

subplot(2,2,2)
hist(ris(:,2),50)
title('Buy and Hold')
grid on

subplot (2,2,3)
plot(ris(:,1),ris(:,2),'b.')
xlabel('Constant Mix')
ylabel('Buy and Hold')
grid on
        
