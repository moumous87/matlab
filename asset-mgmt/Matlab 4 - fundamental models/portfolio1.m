fo=dlmread('forecasts.txt','\t');
hi=dlmread('historical.txt','\t');


%We indicate the lenght of the investment period
le=3;

%We indicate the lenght of historical var-cov matrix estimation
ve=60;

%Yearly Target Tracking Error
yte=0.02;

%Maximum Active Weight (in percentage of the benchmark weigth)
aw=0.5;


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

po1=zeros(np*le,1);
po2=po1;
ben=po1;


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
    
    const=portcons('PortValue',1,ns,'AssetLims',(1-aw).*wb',(1+aw).*wb');
    
    %We run the mean-variance optimization
    [ri,re,w]=portopt(mr,cova,100,[],const);
    
    %We look for the portfolio with the volatility closest to the benchmark
    %volatility
    de=abs(ri-bvol);
    ow1=w(de==min(de),:);
    
    %We now run the active return - tracking error optimization
    aconst=abs2active(const,wb);
    
    [ri2,re2,w2]=portopt(mr,cova,100,[],aconst);
    
    %We look for the portfolio with the tracking error closest to the
    %target
    de=abs(ri2-(yte/sqrt(12)));
    ow2=(w2(de==min(de),:)+wb');
    
    %We calculate the protfolio returns
    for k=1:le
        po1((j-1)*le+k,1)=ow1*fr(time==ti(t),k);
        po2((j-1)*le+k,1)=ow2*fr(time==ti(t),k);
        ben((j-1)*le+k,1)=wb'*fr(time==ti(t),k);
    end
end

%We create the price series, plot and calculate the diagnostics    
port1=ret2tick(po1);
port2=ret2tick(po2);
bench=ret2tick(ben);

plot(dates(1:size(port1,1)),[port1 port2 bench])
legend('Absolute','Relative','Benchmark')
grid on
dateaxis('x',12)


dia=zeros(6,3);
    
dia(1,:)=mean([po1 po2 ben]).*12;
dia(2,:)=std([po1 po2 ben]).*sqrt(12);
dia(3,1:2)=mean([po1-ben po2-ben]).*12;
dia(4,1:2)=std([po1-ben po2-ben]).*sqrt(12);
dia(5,1)=sum(sign(max(0,po1)))./size(po1,1);
dia(5,2)=sum(sign(max(0,po2)))./size(po2,1);
dia(5,3)=sum(sign(max(0,ben)))./size(ben,1);
dia(6,1)=sum(sign(max(0,po1-ben)))./size(po1,1);
dia(6,2)=sum(sign(max(0,po2-ben)))./size(po2,1);


xlswrite('FDiagnostics.xls',dia,'Model','B2')
xlswrite('FDiagnostics.xls',[m2xdate(dates(1:size(po1,1))) po1 po2 ben],'Portfolios','A2')
    
    
    
    
    
    


