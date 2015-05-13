function nll=tnegloglik2(param, uemp, trho)
% returns -loglikelihood function of BIVARIATE Student's t copula density (to be minimized)
v=param;                %number of degrees of freedom to be optimized

x1=tinv(uemp(:,1),v);
x2=tinv(uemp(:,2),v);
k2=(0.5*(gamma(v/2)/gamma(0.5+v/2))^2*v)*(1-trho^2)^(-0.5);
k1=k2*((1+(x1.^2)./v).*(1+(x2.^2)./v)).^((v+1)/2).*(1+(x1.^2-2*trho*x1.*x2+x2.^2)./((1-trho^2)*v)).^(-1-v/2);
nll=-sum(log(k1));