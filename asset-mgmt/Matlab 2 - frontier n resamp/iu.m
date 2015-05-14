er=[0.1 0.05];
sd=[0.2 0.1];
rho=0.8;

cova=corr2cov(sd,[1 rho;rho 1]);

n=10000;

r=mvnrnd(er,cova,n);

figure
scatterhist(r(:,1), r(:,2), [50 500])