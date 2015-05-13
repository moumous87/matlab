function y = objfunction(lambda,y)

ret=y;
R=rows(ret);
C=cols(ret);
conditional_var=NaN(R,C);
conditional_var(1,1)=var(ret);
for i=2:R
conditional_var(i,1)=(1-lambda)*ret(i-1,1).^2+lambda*conditional_var(i-1,1);
end
z=ret./sqrt(conditional_var);

y=-sum(-0.5*log(2*pi)-0.5*log(conditional_var)-0.5*(z.^2));