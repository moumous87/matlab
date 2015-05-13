function copulafitnew(PRICES)
% derivation of the empirical compula for a bivariate sample of log returns
% illustration of a method for choosing amongst different copulas 

[nr, nc]=size(PRICES);
logret=log(PRICES(2:nr,:))-log(PRICES(1:(nr-1),:));                 % daily log-returns calculation
logret1=logret(:,1);                                                % log-returns first asset
logret2=logret(:,2);                                                % log-returns second asset
T=length(logret1);
orderlogret1=sort(logret1);                                         % order statistics for log-returns (in ascending order)
orderlogret2=sort(logret2);

% empirical copula
for i=1:T
    for j=1:T
        countcop=0;
        for k=1:T
            if (logret1(k)<=orderlogret1(i)) & (logret2(k)<=orderlogret2(j)) 
                countcop=countcop+1;
            end
        end
        Cemp(i,j)=countcop/(T+1);                                       % empirical bivariate distribution function (empirical copula)
    end
    
end

[X,Y] = meshgrid((1/T):1/T:1);                                      % plot of the empirical copula
mesh(X,Y,Cemp)

% Selection of the right copula using the empirical copula
empcorrmatrix=corrcoef(logret1, logret2);
empcorr=empcorrmatrix(1,2);                                         % empirical correlation coefficient
df1=4;
df2=7;
for i=1:T
    for j=1:T
            Cga(i,j)=copulacdf('Gaussian',[X(i) Y(j)], empcorr);
            Ctdf1(i,j)=copulacdf('t',[X(i) Y(j)], empcorr, df1);
            Ctdf2(i,j)=copulacdf('t',[X(i) Y(j)], empcorr, df2);
    end
    
end

% discrete L^2 norm to measure distance of parametric copulas from the empirical copula
dGa=sqrt(sum(sum((Cemp-Cga).^2)))
dt1=sqrt(sum(sum((Cemp-Ctdf1).^2)))
dt2=sqrt(sum(sum((Cemp-Ctdf2).^2)))

