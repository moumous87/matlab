clear all

sdy=0.25; %Yearly Standard Deviation
mry=0.08; %Yearly mean return
rfy=0.03; %Risk free

le=5; %Lenght of the Strategy in Years


k=10000; %Number of Iterations

%Weekly moments
sd=sdy/(52^0.5);
mr=mry/52;
rf=rfy/52;


%Number of periods
t=52*le;




sm=100;
p=100;
f=100/(1+rf)^t;
c=p-f;
m=100/c;
s=m*c;
%s=min(p,m*c);
b=p-s;

def=zeros(k,1);

for x=1:k
    for i=2:t
        r=normrnd(mr,sd,1,1);
        p(i,1)=s(i-1,1)*(1+r)+b(i-1,1)*(1+rf);
        f(i,1)=100/(1+rf)^(t-i+1);
        c(i,1)=p(i,1)-f(i,1);
        s(i,1)=max(0,m*c(i,1));
        %s(i,1)=max(0,min(p(i,1),m*c(i,1)));   
        b(i,1)=p(i,1)-s(i,1);
        sm(i,1)=sm(i-1,1)*(1+r);
    end

    if min(c)<0
       def(x,1)=1;
    end
end

defaults=sum(def)
def_perc=sum(def)/k
