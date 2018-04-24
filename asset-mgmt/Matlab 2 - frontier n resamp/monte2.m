%We define the moments of our multivariate distribution
er=[0.1 0.05];
sd=[0.2 0.01];

rho=0.8;
cova=corr2cov(sd,[1 rho;rho,1]);

%We choose the number of random iterations
n=10000;



%We simulate the random sample of returns
r=mvnrnd(er,cova,n);

%We plot the results
figure
scatterhist(r(:,1),r(:,2),[50 50])




    
