function f= objfunction(param0,returns)

p1=param0(1);
std1=param0(2);
std2=param0(3);

M=mean(returns);
Lik1=normpdf(returns,M,std1);
Lik2=normpdf(returns,M,std2);
Mix=p1*Lik1+(1-p1)*Lik2;

f=-sum(log(Mix));

