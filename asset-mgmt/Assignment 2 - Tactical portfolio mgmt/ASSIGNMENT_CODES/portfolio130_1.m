clear all
%%
load fore
load hi
run loopy

%%

% market impact: assuming that you can buy and sell with no effect on the price is false
%We indicate the lenght of the investment period
le=3;

%We indicate the lenght of historical var-cov matrix estimation
ve=60;

%Yearly Target Tracking Error
yte=0.01;

%We choose the type of constraint for the weigths in the optimization
% 0=relative constraint (as a percentage of the actual benchmark weight),
% 1=Absolute constraint (percentage points above or below the benchmark)


%We introduce our hypothesis on the one-way transaction costs in basis
%points (remember: round-trip tc vs. one-way tc)
ttc=50; %= %tc*turnover

%We split the database into its components
names=fo(:,1);
dat=fo(:,2);
time=fo(:,3);
mcap=fo(:,4);
er=fo(:,5);
fr=fo(:,6:end);

ti=unique(time);
datesp=unique(dat);
na=unique(names);

nd=size(ti,1);
ns=size(na,1);
clear fo

innd=size(datesp(year(datesp)<=2001),1);
np1=floor(innd/le);


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
sizecheck=po1; %Check the size of the "neutral strategy" excceding the
               %benchmark, i.e. checking if we are building a 130/30 or a
               %120/20 (which is acceptable) or a  175/75 or a 190/90 (which
               %is NOT acceptable)
dr=zeros(np,1);
tc=ttc/10000;


%%


for j=1:np1
    
    if j==1
        char({'incipit'})
    end
    
    t=(j-1)*le+1;
    
    
    %We extract the required portion of the historical data fore the
    %var-cov matrix estimation
    
    hist=hi(hi(:,1)<=ti(t) & hi(:,1)>ti(t)-ve,2:end);
    
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
    
    
    A=[-fr(time==ti(t),1)']; % portfolio able to cover the costs
        % assets whose weights will exceed those of the benchmark...
    
    b=[-wb'*fr(time==ti(t),1)];
    
    % EXPLANATION:
    % I want: gross portfolio-cost > benchmark
    
    % ==> Weights*fr(time==ti(t),1) - sum(abs(pw1-ow1'))*tc > wb'*fr(time==ti(t),1)
    % dim  1x48        48x1                     1x1                   1x1
    
    % ==> Weights*fr(time==ti(t),1) - cost > wb'*fr(time==ti(t),1)
    
    % recall that the 'Custom' constraint must be expressed as A*PortWeights <= b
    % so I need to transpose the left-hand part of the inequality and then
    % change sign to the inequality
    
    % ==> fr(time==ti(t),1)'*Weights' - cost > wb'*fr(time==ti(t),1)
    % dim      1x48          48x1       1x1           1x1
    
    % ==> fr(time==ti(t),1)'*Weights' > wb'*fr(time==ti(t),1) + cost
    
    % ==>  - fr(time==ti(t),1)'*Weights' < - wb'*fr(time==ti(t),1) - cost
    % i.e.          A        *PortWeights  <           b
    
    % [below you see that the returns are expressed as fr(time==ti(t),k),
    % but k=1 for us because it's only when k=1 that we incur in
    % transaction costs]
    % we didn't include any estimate of the cost in the vector b for 2
    % reasons:
    % 1st- without specifying any estimate of the cost we saw (ex post) that
    % the above condition was sufficient to have the net portfolio above
    % the benchmark
    % 2nd- the cost itself is a function of the weights (i.e. the output)
    % so the solution would have been a more complicated
    % optimization/minimization function. Any constraint or if condition
    % simply asking to minimize the turnover would have led to a turnover=0
    % (and therefore cost=0), i.e. a buy&hold portfolio=benchmark
    
    const=portcons('PortValue',1,ns,'AssetLims',0,wb'*1.3,'Custom',A,b);
    
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
            dr(j,1)=datesp(t);
            
            %The net portfolio return is equal to the gross portfolio less
            %the transaction cost
            pon1((j-1)*le+k,1)=po1((j-1)*le+k,1)-cost(j,1);
            pon2((j-1)*le+k,1)=po2((j-1)*le+k,1)-cost(j,2);
            
            %We update the portfolio composition given the return of the
            %assets 
            pw1=((1+fr(time==ti(t),k)).*ow1')./sum((1+fr(time==ti(t),k)).*ow1');
            pw2=((1+fr(time==ti(t),k)).*ow2')./sum((1+fr(time==ti(t),k)).*ow2');
            pwb=((1+fr(time==ti(t),k)).*wb)./sum((1+fr(time==ti(t),k)).*wb);
            
            %Check the size of the "neutral strategy" excceding the
            %benchmark, i.e. checking if we are building a 130/30 or a
            %120/20 (which is acceptable) or a  175/75 or a 190/90 (which
            %is NOT acceptable)
            z=pw1-wb;
            z=pw1-wb;
            z(z<0)=0;
            sizecheck((j-1)*le+k,1)=sum(z);
            
            
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
            
            %Check the size of the "neutral strategy" excceding the
            %benchmark, i.e. checking if we are building a 130/30 or a
            %120/20 (which is acceptable) or a  175/75 or a 190/90 (which
            %is NOT acceptable)
            z=pw1-wb;
            z(z<0)=0;
            sizecheck((j-1)*le+k,1)=sum(z);
            
        end
    end
    
    
    np-j 
    char(loopcheck(j))
    
end

clc

char({'BOOM !!!'})



%% OUT-OF-SAMPLE RESULTS (BACKTESTING)


for j=np1+1:np
    
    if j==1
        char({'incipit'})
    end
    
    t=(j-1)*le+1;
    
    
    %We extract the required portion of the historical data fore the
    %var-cov matrix estimation
    
    hist=hi(hi(:,1)<=ti(t) & hi(:,1)>ti(t)-ve,2:end);
    
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
    
    
    A=[-fr(time==ti(t),1)']; % portfolio able to cover the costs
        % assets whose weights will exceed those of the benchmark...
    
    b=[-wb'*fr(time==ti(t),1)]; %==> portfolio able to cover the costs (rough estimation of transaction costs)
        %==> assets whose weights will exceed those of the benchmark... 
                           %==> ...must not account for more than 0.3 of the PortValue
                           % What exceeds the benchmark accounts for (max) 0.3,
                           % meaning that the rest (benchmark + 'short leg' of the 130/30 strategy)
                           % accounts for 0.7 (min) (since we impose PortValue=1),
                           % i.e. bechmark (=1) - 0.3 (max) of something
                           %==> the condition for the part exceeding the
                           % benchmark suffices also as condition for the
                           % part going below the benchamrk!!! 
    
    const=portcons('PortValue',1,ns,'AssetLims',0,wb'*1.3,'Custom',A,b);
    
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
            dr(j,1)=datesp(t);
            
            %The net portfolio return is equal to the gross portfolio less
            %the transaction cost
            pon1((j-1)*le+k,1)=po1((j-1)*le+k,1)-cost(j,1);
            pon2((j-1)*le+k,1)=po2((j-1)*le+k,1)-cost(j,2);
            
            %We update the portfolio composition given the return of the
            %assets 
            pw1=((1+fr(time==ti(t),k)).*ow1')./sum((1+fr(time==ti(t),k)).*ow1');
            pw2=((1+fr(time==ti(t),k)).*ow2')./sum((1+fr(time==ti(t),k)).*ow2');
            pwb=((1+fr(time==ti(t),k)).*wb)./sum((1+fr(time==ti(t),k)).*wb);
            
            %Check the size of the "neutral strategy" excceding the
            %benchmark (i.e. checking if we are building a 130/30, a 120/20
            %a 185/85 and so on)
            z=pw1-wb;
            z(z<0)=0;
            sizecheck((j-1)*le+k,1)=sum(z);
            
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
            
            %Check the size of the "neutral strategy" excceding the
            %benchmark (i.e. checking if we are building a 130/30, a 120/20
            %a 185/85 and so on)
            z=pw1-wb;
            z(z<0)=0;
            sizecheck((j-1)*le+k,1)=sum(z);
            
            
            
        end
    end
    
    
    np-j 
    char(loopcheck(j))
    
end


clc

char({'BOOM !!!'})



%% We create the price series, plot and calculate the diagnostics    
port1=ret2tick(po1);
port2=ret2tick(po2);
portn1=ret2tick(pon1);
portn2=ret2tick(pon2);
bench=ret2tick(ben);

%% plot

% PRICE PATTERN OF GROSS PORTFOLIO, NET PORTFOLIO AND BENCHMARK
figure
subplot(2,1,1)
plot(datesp(1:size(port1,1)),[port1 portn1 bench])
legend('Gross','Net','Benchmark','location','northwest')
grid on
dateaxis('x',12)
title('Absolute Portfolio')

subplot(2,1,2)
plot(datesp(1:size(port2,1)),[port2 portn2 bench])
legend('Gross','Net','Benchmark','location','northwest')
grid on
dateaxis('x',12)
title('Relative Portfolio')

% PRICE PATTERN OF NET PORTFOLIO AND BENCHMARK
figure
subplot(2,1,1)
plot(datesp(1:size(port1,1)),[portn1 bench])
legend('Net','Benchmark','location','northwest')
grid on
dateaxis('x',12)
title('Absolute Portfolio')

subplot(2,1,2)
plot(datesp(1:size(port2,1)),[portn2 bench])
legend('Net','Benchmark','location','northwest')
grid on
dateaxis('x',12)
title('Relative Portfolio')

% plot turnover and cost
figure
subplot(2,1,1)
plot(dr,turn)
grid on
dateaxis('x',12)
title('Turnover')
legend('Absolute','Relative')

subplot(2,1,2)
plot(dr,cost.*10000)
grid on
dateaxis('x',12)
title('Transaction Costs')
legend('Absolute','Relative')
ylabel('Basis Points')



%%  FOCUS ON IN-SAMPLE

% PRICE PATTERN OF GROSS PORTFOLIO, NET PORTFOLIO AND BENCHMARK
figure
plot(datesp(1:innd),[port1(1:innd) portn1(1:innd) bench(1:innd)])
grid on
dateaxis('x',12)
title('Absolute Portfolio')
legend('Gross','Net','Benchmark','location','southeast')
ylim([0,6])
xlim([datesp(1) datesp(innd)])


figure
plot(datesp(1:innd),[port2(1:innd) portn2(1:innd) bench(1:innd)])
grid on
dateaxis('x',12)
title('Relative Portfolio')
legend('Gross','Net','Benchmark','location','southeast')
ylim([0,6])
xlim([datesp(1) datesp(innd)])


% plot turnover and cost
figure
plot(dr(1:np1),turn(1:np1,1:2))
grid on
dateaxis('x',12)
title('Turnover')
ylim([0,1.5])
xlim([dr(1) dr(np1)])


figure
plot(dr(1:np1),cost(1:np1,1:2).*10000)
grid on
dateaxis('x',12)
title('Transaction Costs')
ylabel('Basis Points')
ylim([0,60])
xlim([dr(1) dr(np1)])


%%
clc

round(sizecheck*100) % you'll see displayed in the Command Window that our
                     % portfolio is more or less a "120/20"
                     % ==> acceptable/credible financial product
          

%% diagnostics

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


%xlswrite('Diagnostics.xls',dia,'model','B2')
%xlswrite('Diagnostics.xls',[datesp(1:size(po1,1)) po1 pon1 po2 pon2
%ben],'portfolios','A2')

% WE DIDN'T USE XLSWRITE FOR PROBLEMS OF INCOMPATIBILITY WITH OUR OPERATING
% SYSTEMS... SO WE JUST COPIED AND PASTED THE RESULTS JUST OPENING THE
% VARIABLES IN THE WORKSPACE
    

