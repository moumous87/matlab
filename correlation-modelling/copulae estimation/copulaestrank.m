function copulaestrank(PRICES)
% function to estimate bivariate gaussian, student's t, clayton and gumbel copulae from market data 
% PRICES: input matrix of time series of prices of financial assets (bivariate case: nx2)

[nr, nc]=size(PRICES);
logret=log(PRICES(2:nr,:))-log(PRICES(1:(nr-1),:));                 % daily log-returns calculation
logret1=logret(:,1);                                                %log returns first asset
logret2=logret(:,2);                                                %log returns second asset

%estimate of copula parameters using rank correlation measures:
ktau=corr(logret,'type','Kendall');                 %empirical estimation Kendall's tau
srho=corr(logret,'type','Spearman');                %empirical estimation Spearman's rho

claytoncoeff=(2*ktau(1,2))/(1-ktau(1,2));           %estimation coeff Clayton's bivariate copula
%claytoncoeff=copulaparam('Clayton',ktau(1,2));     %alternative estimation

gumbelcoeff=1/(1-ktau(1,2));                        %estimation coeff Gumbel's bivariate copula
%gumbelcoeff=copulaparam('Gumbel',ktau(1,2));       %alternative estimation

gaussianrho=srho(1,2);                                   %estimation correlation coefficient for bivariate Gaussian copula
%gaussianrho=copulaparam('Gaussian',ktau(1,2));      %alternative estimation

trho=sin((pi/2)*ktau(1,2));                         %estimation correlation coefficient for bivariate t copula

for i=1:(nr-1)                                      % empirical cumulative distr. functions for the marginals
    uemp(i,1)=length(logret1(logret1<=logret1(i)))/(nr);
    uemp(i,2)=length(logret2(logret2<=logret2(i)))/(nr);
end
% estimation of degrees of freedom for Student's t copula via maximum likelihood
lowerbound=[0.5];                                         
upperbound=[50];
parEst0=[2];                                        %initial guess for parameters
options=optimset('LargeScale','off','MaxFunEval',50000,'MaxIter',50000);        % set options for optimization routine
dfreed=fmincon(@tnegloglik2,parEst0,[],[],[],[],lowerbound,upperbound,[], options,uemp,trho)  


%plots of the pdf of the estimated copulae
u1 = linspace(1e-3,1-1e-3,50);
u2 = linspace(1e-3,1-1e-3,50);

subplot(2,2,1);
[U1,U2] = meshgrid(u1,u2);
Rho = [1 gaussianrho; gaussianrho 1];
f = copulapdf('Gaussian',[U1(:) U2(:)],Rho);
f = reshape(f,size(U1));
surf(u1,u2,log(f),'FaceColor','interp','EdgeColor','none');
view([-15,20]);
xlabel('U1'); ylabel('U2'); zlabel('Probability Density');
title('Gaussian Copula');

subplot(2,2,2);
Rho = [1 gaussianrho; gaussianrho 1];
f = copulapdf('t',[U1(:) U2(:)],Rho,dfreed);
f = reshape(f,size(U1));
surf(u1,u2,log(f),'FaceColor','interp','EdgeColor','none');
view([-15,20]);
xlabel('U1'); ylabel('U2'); zlabel('Probability Density');
title('t Copula');

subplot(2,2,3);
alpha=claytoncoeff;
f = copulapdf('Clayton',[U1(:) U2(:)],alpha);
f = reshape(f,size(U1));
surf(u1,u2,log(f),'FaceColor','interp','EdgeColor','none');
view([-15,20]);
xlabel('U1'); ylabel('U2'); zlabel('Probability Density');
title('Clayton Copula');

subplot(2,2,4);
alpha=gumbelcoeff;
f = copulapdf('Gumbel',[U1(:) U2(:)],alpha);
f = reshape(f,size(U1));
surf(u1,u2,log(f),'FaceColor','interp','EdgeColor','none');
view([-15,20]);
xlabel('U1'); ylabel('U2'); zlabel('Probability Density');
title('Gumbel Copula');