function tloglik=logL2(par,y)
ret=y;
d=par(5,1);
R=rows(ret);
cond_var=NaN(R,1);
cond_var(1,1)=var(ret);
for i=2:R
    cond_var(i,1)=par(1,1)+par(2,1)*(ret(i-1,1)-par(3,1)*sqrt(cond_var(i-1,1)))^2+par(4,1)*cond_var(i-1,1);

end

logL=gammaln((d+1)/2)-gammaln(d/2)-0.5*log(pi)-0.5*log(d-2)-0.5*(1+d)*log(1+(y./sqrt(cond_var)).^2./(d-2));

tloglik=-sum(logL-0.5*log(cond_var));
