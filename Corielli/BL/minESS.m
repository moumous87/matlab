function f=minESS(y,exp_ret,m_w,sigma,C,rf)

denominator1=ones(C,1)'*inv(sigma)*ones(C,1);
denominator2=exp_ret*inv(sigma)*ones(C,1);
lamb=denominator2-rf*denominator1;

m_e_r=exp_ret'-rf;

y=m_e_r'*inv(sigma)*(1/lamb);

f=sum(y - m_w).^2*1000000;