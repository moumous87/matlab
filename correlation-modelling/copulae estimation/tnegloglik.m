function nll=tnegloglik(param, data)
% returns -loglikelihood function of Student's t (to be minimized)
mu=param(1);                % location
sigma=param(2);             % scale
v=param(3);                 % degrees of freedom
nu=length(data);
nll=-nu*(log(gamma((v+1)/2)))+nu*log(sigma*sqrt(pi*v))+nu*log(gamma(v/2))+((v+1)/2)*sum(log(v+((data-mu)./sigma).^2))-nu*((v+1)/2)*log(v);