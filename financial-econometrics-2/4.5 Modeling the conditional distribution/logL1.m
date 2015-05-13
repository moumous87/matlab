function [sumloglik] = logL1(df,ret,sigma)
d=df;
y=ret;
s=sigma;

R=rows(y);
logL=NaN(R,1);
logL=gammaln((d+1)/2)-gammaln(d/2)-0.5*log(pi)-0.5*log(d-2)-0.5*(1+d)*log(1+(y./s).^2./(d-2));

sumloglik=-sum(logL);



    