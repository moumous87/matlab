function [sumloglik,z,cond_var] = ngarch(par,y)

ret=y;
R=rows(ret);
cond_var=NaN(R,1);
cond_var(1,1)=var(ret);
for i=2:R
    cond_var(i,1)=par(1,1)+par(2,1)*(ret(i-1,1)-par(3,1)*sqrt(cond_var(i-1,1)))^2+par(4,1)*cond_var(i-1,1);
end
z=ret./sqrt(cond_var);

sumloglik=-sum(-0.5*log(2*pi)-0.5*log(cond_var)-0.5*(z.^2));
