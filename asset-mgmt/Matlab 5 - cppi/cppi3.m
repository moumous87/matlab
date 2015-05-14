clear all

sdy=0.25; %Yearly Standard Deviation
mry=0.08; %Yearly mean return
rfy=0.03; %Risk free

le=5; %Lenght of the Strategy in Years


k=1000; %Number of Iterations

%Weekly moments
sd=sdy/(52^0.5);
mr=mry/52;
rf=rfy/52;


%Number of periods
t=52*le;

%Multiples to Test
mu=[4 5 6 7 8];

for j=1:size(mu,2)

    sm=100;
    p=100;
    f=100/(1+rf)^t;
    c=p-f;
    m=mu(j);
    %s=m*c;
    s=min(p,m*c);
    b=p-s;
    def=zeros(k,1);


    for x=1:k
        for i=2:t
            r=normrnd(mr,sd,1,1);
            p(i,1)=s(i-1,1)*(1+r)+b(i-1,1)*(1+rf);
            f(i,1)=100/(1+rf)^(t-i+1);
            c(i,1)=p(i,1)-f(i,1);
            %s(i,1)=max(0,m*c(i,1));
            s(i,1)=max(0,min(p(i,1),m*c(i,1)));  
            b(i,1)=p(i,1)-s(i,1);
            sm(i,1)=sm(i-1,1)*(1+r);
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
subplot(1,2,1)
plot(mu,def_perc,'r-o')
xlabel('Multiple')
ylabel('Default rate')
grid on

subplot(1,2,2)
plot(mu,prate,'r-o')
xlabel('Multiple')
ylabel('Relative Performance')
grid on

