function y = objfunction(x1, port_returns)

ret=port_returns;
R=size(ret,1);
C=size(ret,2);
conditional_var=NaN(R,C);
conditional_var(1,1)=var(ret);
for i=2:R
conditional_var(i,1)=(1-x1)*ret(i-1,1).^2+x1*conditional_var(i-1,1);
end
z=ret./sqrt(conditional_var);

y=-sum(-0.5*log(pi)-0.5*log(conditional_var)-0.5*(ret./conditional_var));