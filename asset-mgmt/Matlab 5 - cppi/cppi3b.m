clear all

sdy=[0.20 0.21]; %Yearly Standard Deviation
mry=[0.08 0.11]; %Yearly mean return
rfy=0.03; %Risk free at t=0

le=5; %Lenght of the Strategy in Years

k=1000; %Number of Iterations

%Weekly moments
sd=sdy./(52^0.5);
mr=mry./52;
rf=0.03/52;




%Number of periods
t=52*le;


%Correlation Coefficients to test
cor=[-0.9 -0.45 0 0.45 0.9];

for j=1:size(cor,2)
    cova=[sd(1)^2 sd(1)*sd(2)*cor(j); sd(1)*sd(2)*cor(j) sd(2)^2];
   
    rf=0.03/52;
    sm=100;
    p=100;
    f=100/(1+rf)^t;
    c=p-f;
    m=50/c;
    s=m*c;
    %s=min(p,m*c);
    b=p-s;
    def=zeros(k,1);
    
    for x=1:k
        for i=2:t
            r=mvnrnd(mr,cova,1);
            rf(i,1)=rf(i-1,1)*(1+r(2));
            p(i,1)=s(i-1,1)*(1+r(1))+b(i-1,1)*(1+rf(i,1));
            f(i,1)=100/(1+rf(i,1))^(t-i+1);
            c(i,1)=p(i,1)-f(i,1);
            s(i,1)=max(0,m*c(i,1));
            %s(i,1)=max(0,min(p(i,1),m*c(i,1)));   
            b(i,1)=p(i,1)-s(i,1);
            sm(i,1)=sm(i-1,1)*(1+r(1));
        end
        
        if min(c)<0
            def(x,1)=1;
        end
        part(x,1)=(p(t,1)-sm(t,1));
    end
    
    defaults(1,j)=sum(def);
    def_perc(1,j)=sum(def)/k;
    prate(1,j)=mean(part);
end



figure
plot(cor,def_perc,'r-o')
xlabel('Correlation')
ylabel('Default rate')
grid on


