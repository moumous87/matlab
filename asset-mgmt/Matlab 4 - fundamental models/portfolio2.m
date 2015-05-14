fo=dlmread('forecasts.txt','\t');
hi=dlmread('historical.txt','\t');


%We indicate the lenght of the investment period
le=3;

%We indicate the lenght of historical var-cov matrix estimation
ve=60;

%Yearly Target Tracking Error
yte=0.04;

%We choose the type of constraint for the weigths in the optimization
% 0=relative constraint (as a percentage of the actual benchmark weight),
% 1=Absolute constraint (percentage points above or below the benchmark)
type=1;

%Maximum Active Weight (in percentage of the benchmark weigth)
rw=0.50;

%Maximum Active Weight (in absolute term)
aw=0.02;


%We introduce our hypothesis on the one-way transaction costs in basis
%points
ttc=25;

%We split the database into its components
names=fo(:,1);
dat=x2mdate(fo(:,2));
time=fo(:,3);
mcap=fo(:,4);
er=fo(:,5);
fr=fo(:,6:end);

ti=unique(time);
dates=unique(dat);
na=unique(names);

nd=size(ti,1);
ns=size(na,1);
clear fo

np=floor((nd-1)/le);

cost=zeros(np,2);
turn=zeros(np,2);
pw1=zeros(ns,1);
pw2=zeros(ns,1);
pwb=zeros(ns,1);
po1=zeros(np*le,1);
po2=po1;
pon1=po1;
pon2=po1;
ben=po1;
dr=zeros(np,1);
tc=ttc/10000;

for j=1:np
    np-j
    t=(j-1)*le+1;
    
    
    %We extract the required portion of the historical data fore the
    %var-cov matrix estimation
    
    hist=hi(hi(:,4)<=ti(t) & hi(:,4)>ti(t)-ve,5:end);
    
    %We estimate the var-cov matrix
    cova=cov(hist);
    
    %We take the appropriate mean returns from the forecast file
    mr=er(time==ti(t),1);
    
    %We calculate the benchmark composition at time t by dividing the
    %individual weigths at time t for the sume of the weigths in the same
    %period
    wb=mcap(time==ti(t),1)./sum(mcap(time==ti(t),1));
    
    %We calculate the expected benchmark volatility
    bvol=sqrt(wb'*cova*wb);
    
    
    %We now proceed to the portfolio optimization by using a more
    %sofisticated function (portopt) that requires the previous definition
    %of a constrains set
    if type==0
        const=portcons('PortValue',1,ns,'AssetLims',(1-rw).*wb',(1+rw).*wb');
    else
        const=portcons('PortValue',1,ns,'AssetLims',min(0,wb'-aw),wb'+aw);
    end
    
    %We run the mean-variance optimization
    [ri,re,w]=portopt(mr,cova,100,[],const);
    
    %We look for the portfolio with the volatility closest to the benchmark
    %volatility
    de=abs(ri-bvol);
    x=find(de==min(de));
    ow1=w(x,:);
    
    %We now run the active return - tracking error optimization
    aconst=abs2active(const,wb);
    
    [ri2,re2,w2]=portopt(mr,cova,100,[],aconst);
    
    %We look for the portfolio with the tracking error closest to the
    %target
    de=abs(ri2-(yte/sqrt(12)));
    x2=find(de==min(de));
    ow2=(w2(x2,:)+wb');
    
    %We calculate the protfolio returns
    for k=1:le
        
        %We separate the portfolio return calculation between rebalancing
        %and non-rebalancing month. If k=1 it means that we are in a
        %rebalancing month
        if k==1
            
            %The gross portfolio return is calculated as usual
            po1((j-1)*le+k,1)=ow1*fr(time==ti(t),k);
            po2((j-1)*le+k,1)=ow2*fr(time==ti(t),k);
            ben((j-1)*le+k,1)=wb'*fr(time==ti(t),k);
            
            %The turnover is calculated summing up the differences between
            %the current optimal weight and the previous period weights
            turn(j,1)=sum(abs(pw1-ow1'));
            turn(j,2)=sum(abs(pw2-ow2'));
            
            %Transaction cost is turnover time the unit cost
            cost(j,1)=turn(j,1)*tc;
            cost(j,2)=turn(j,2)*tc;
            dr(j,1)=dates(t);
            
            %The net portfolio return is equal to the gross portfolio less
            %the transaction cost
            pon1((j-1)*le+k,1)=po1((j-1)*le+k,1)-cost(j,1);
            pon2((j-1)*le+k,1)=po2((j-1)*le+k,1)-cost(j,2);
            
            %We update the portfolio composition given the return of the
            %assets 
            pw1=((1+fr(time==ti(t),k)).*ow1')./sum((1+fr(time==ti(t),k)).*ow1');
            pw2=((1+fr(time==ti(t),k)).*ow2')./sum((1+fr(time==ti(t),k)).*ow2');
            pwb=((1+fr(time==ti(t),k)).*wb)./sum((1+fr(time==ti(t),k)).*wb);
        else
            
            %If we are not in a rebalancing period the net portfolio
            %returns is equal to the gross portfolio return
            po1((j-1)*le+k,1)=pw1'*fr(time==ti(t),k);
            po2((j-1)*le+k,1)=pw2'*fr(time==ti(t),k);
            pon1((j-1)*le+k,1)=po1((j-1)*le+k,1);
            pon2((j-1)*le+k,1)=po2((j-1)*le+k,1);
            ben((j-1)*le+k,1)=pwb'*fr(time==ti(t),k);
            
            %We update the portfolio composition given the return of the
            %assets 
            pw1=((1+fr(time==ti(t),k)).*pw1)./sum((1+fr(time==ti(t),k)).*pw1);
            pw2=((1+fr(time==ti(t),k)).*pw2)./sum((1+fr(time==ti(t),k)).*pw2);
            pwb=((1+fr(time==ti(t),k)).*pwb)./sum((1+fr(time==ti(t),k)).*pwb);
        end
    end
end

%We create the price series, plot and calculate the diagnostics    
port1=ret2tick(po1);
port2=ret2tick(po2);
portn1=ret2tick(pon1);
portn2=ret2tick(pon2);
bench=ret2tick(ben);


figure
subplot(2,2,1)
plot(dates(1:size(port1,1)),[port1 portn1 bench])
legend('Gross','Net','Benchmark')
grid on
dateaxis('x',12)
title('Absolute Portfolio')

subplot(2,2,2)
plot(dates(1:size(port2,1)),[port2 portn2 bench])
legend('Gross','Net','Benchmark')
grid on
dateaxis('x',12)
title('Relative Portfolio')

subplot(2,2,3)
plot(dr,turn)
grid on
dateaxis('x',12)
title('Turnover')
legend('Absolute','Relative')

subplot(2,2,4)
plot(dr,cost.*10000)
grid on
dateaxis('x',12)
title('Transaction Costs')
legend('Absolute','Relative')
ylabel('Basis Points')


dia=zeros(9,5);
    
dia(1,:)=mean([po1 pon1 po2 pon2 ben]).*12;
dia(2,:)=std([po1 pon1 po2 pon2 ben]).*sqrt(12);
dia(3,1:4)=mean([po1-ben pon1-ben po2-ben pon2-ben]).*12;
dia(4,1:4)=std([po1-ben pon1-ben po2-ben pon2-ben]).*sqrt(12);
dia(5,1:4)=dia(3,1:4)./dia(4,1:4);
dia(6,1)=sum(sign(max(0,po1)))./size(po1,1);
dia(6,2)=sum(sign(max(0,po2)))./size(po2,1);
dia(6,3)=sum(sign(max(0,pon1)))./size(pon1,1);
dia(6,4)=sum(sign(max(0,pon2)))./size(pon2,1);
dia(6,5)=sum(sign(max(0,ben)))./size(ben,1);
dia(7,1)=sum(sign(max(0,po1-ben)))./size(po1,1);
dia(7,2)=sum(sign(max(0,po2-ben)))./size(po2,1);
dia(7,3)=sum(sign(max(0,pon1-ben)))./size(pon1,1);
dia(7,4)=sum(sign(max(0,pon2-ben)))./size(pon2,1);
dia(8,2)=mean(turn(:,1)).*(12/le).*0.5;
dia(8,4)=mean(turn(:,2)).*(12/le).*0.5;
dia(9,2)=mean(cost(:,1)).*(12/le);
dia(9,4)=mean(cost(:,2)).*(12/le);


xlswrite('FDiagnostics.xls',dia,'TCModel','B2')
xlswrite('FDiagnostics.xls',[m2xdate(dates(1:size(po1,1))) po1 pon1 po2 pon2 ben],'TCPortfolios','A2')
    
    
    
    
    
    


