% to be run after datatran_int

% EXERCISE 1

% a)

date=datenum(textdata(2:end,1),'dd/mm/yyyy');
f1=['31/12/1974'];
f2=['31/12/1999'];
date_find1=datenum(f1,'dd/mm/yyyy');
date_find2=datenum(f2,'dd/mm/yyyy');
first=datefind(date_find1,date);
last=datefind(date_find2,date);

X=NaN(size(us_p),2);
X(:,1)=ones;
X(:,2)=uk_ldp;

result=ols(uk_ret_4r(first:last,:), X(first-4:last-4,:));
R2_uk=result.rsqr;
beta_uk=result.beta;
tstat_uk=result.tstat;

% b)

f3=['31/12/1999'];
f4=['31/12/2009'];
date_find3=datenum(f3,'dd/mm/yyyy');
date_find4=datenum(f4,'dd/mm/yyyy');
prev=datefind(date_find3,date);
last2=datefind(date_find4,date);

% ECONOMETRIC MODEL:

ret_prev=NaN(10,1);

% forecasted returns:

ret_prev(1,1)=beta_uk(1,1)+beta_uk(2,1)*uk_ldp(prev,1);
for i=1:9;
ret_prev(i+1,1)=beta_uk(1,1)+beta_uk(2,1)*uk_ldp(prev+4*i,1);    
end

% Strategy: buy stocks only if ret_prev>1.5%.

ret_real=NaN(10,1);
ret_real=uk_ret_4r(prev+4:4:last2);
index=(ret_prev>0.015);
port(1,1)=1;
for i=2:11
port(i,1)=port(i-1,1)*(index(i-1,1)*exp(ret_real(i-1,1))+(1-index(i-1,1))*(1+0.015));
end

% UNCONDITIONAL MEAN STRATEGY:

%uncond_mean=mean(uk_ret_4r(first:last,1));
uncond_mean=mean(uk_ret_4r(first:4:last,1));

a(1:10,1)=ones;
index2=(uncond_mean*a>0.015);

port_um(1,1)=1;
for i=2:11
port_um(i,1)= port_um(i-1,1)*(index2(i-1,1)*exp(ret_real(i-1,1))+(1-index2(i-1,1))*(1+0.015));
end

% COMPARISON: ECONOMETRIC MODEL VS UNCONDITIONAL MEAN
figure;
t=(2000:2010);
plot(t',port,t',port_um);
title('Econometric model vs Unconditional Mean ','fontname','Garamond','fontsize',14);
set(gca,'fontname','garamond','fontsize',10);
set(gca,'xlim',[2000 2010]);
grid;
set(gcf,'color','w');
legend('Econometric Model','Unconditional Mean',0);

% c) optimal portfolio allocation chose alfa to maximize
% alfa*(E(Rt+4,t))+(1-alfa)*Rsafet+4,t - (1/2)*gamma*(alfa^2)* Var(Rt+4,t)
% the econometric model should deliver the mean and the variance of the
% risky asset.
% example: gamma=0 implies alfa =1 if Ert+4 > 1.5 % 
%          gamma=1 imples alfa= 0.5 if  Ert+4 = 3 %   

%optimal allocation given gamma
gamma=1;
alfa=(ret_prev-0.015)/(result.sige*gamma);
alfa_rs=NaN(10,1);
for j=1:10
if alfa(j,1)<0
    alfa_rs(j,1)=0;
elseif alfa(j,1)>1
    alfa_rs(j,1)=1;
        
else
    alfa_rs(j,1)=alfa(j,1);
end   
end
    port_opt(1,1)=1;
for i=2:11
port_opt(i,1)=port_opt(i-1,1)*(alfa_rs(i-1,1)*exp(ret_real(i-1,1))+(1-alfa_rs(i-1,1))*(1+0.015));
end 

% d)

% EX-POST STRATEGY/INFLATION INDEXED BILL ONLY/SHARES ONLY

index1=(ret_real>0.015);

port_expost(1,1)=1;
port_bill(1,1)=1;
port_stock(1,1)=1;

for i=2:11
port_bill(i,1)=port_bill(i-1,1)*(1+0.015);
port_stock(i,1)=port_stock(i-1,1)*exp(ret_real(i-1,1));
port_expost(i,1)=port_expost(i-1,1)*(index1(i-1,1)*exp(ret_real(i-1,1))+(1-index1(i-1,1))*(1+0.015));
end

% COMPARISON AMONG ALTERNATIVE STRATEGIES:

figure;
t=(2000:2010);
plot(t',port_bill, t',port_stock,t',port, t',port_expost);
title('Comparison among investment strategies ','fontname','Garamond','fontsize',14);
set(gca,'fontname','garamond','fontsize',10);
set(gca,'xlim',[2000 2010]);
grid;
set(gcf,'color','w');
legend('Inflation indexed bill','Shares only = Unconditional Mean','Econometric model based','Optimal ex post',0);

