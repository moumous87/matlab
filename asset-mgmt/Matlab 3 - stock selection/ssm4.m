clear all

%We load the database
db=dlmread('zdatabase.txt','\t');

%We save the number of information signals in our file
nv=28;

%We indicate the variables that we want to use and the number of stocks
%that we want to include in the portfolios
var=[2 5 7 15];

num=100;

%We indicate the pre-filtering size
minc=200;

%We indicate the lenght of the investment period
le=3;

%We indicate the lenght model optimization process
de=24;


%We convert all the -999 in the database into missing values
db(db==-999)=NaN;

%We load a file with the strings of the names of the Information Variables
run signals

%We split the database into its components
dat=datenum(db(:,1:3));
time=db(:,4);
names=db(:,5);
mcap=db(:,6);
dbx=[db(:,7:end) db(:,6)];

clear db


%We estract the list of the stocks, periods and dates
ti=unique(time);
na=unique(names);
dates=unique(dat);

%We define the number of stocks, the number of dates and the number of
%investment periods
ns=size(na,1);
nd=size(ti,1);
np=floor((nd-1)/le);

%We initialize vectors for portfolio returns and consistencies
etop=zeros(np*le,size(var,2));
ebot=etop;
eben=etop;
ctop=etop;
cbot=etop;






%We run a first outer loop on the base of the number of information signals
%chosen for the task
for i=1:size(var,2)
    
   
        
    %An inner loop will serve to repeat the ranking and invesmtment
    %decision each month
    for j=1:np
        
        %We individuate the time indicator of the observation
            t=(j-1)*le+1;
        
        %We extract the sub-database with the observations that we
        %will use in this particular iteration
        dbx2=dbx((time==ti(t) & mcap>=minc),:);
        
        %We extract the sub-database where the value of the signal is
        %non-missing
        dbm=dbx2(isfinite(dbx2(:,var(i))),:);
        
        %We sort the rows of our sample on the base of he specific
        %information signal
        [dbs ind]=sortrows(dbm,-1*var(i));
        num2=min(num,0.5*size(dbs,1));
        
        for k=1:le
        
            %We save the equally weighted returns of the portfolios
            etop((j-1)*le+k,i)=mean(dbs(1:num2,nv+k));
            ebot((j-1)*le+k,i)=mean(dbs(end-num2:end,nv+k));
            eben((j-1)*le+k,i)=mean(dbs(1:end,nv+k));
            
            %We calculate the consistency
            ctop((j-1)*le+k,i)=size(find(dbs(1:num2,nv+k)>eben((j-1)*le+k,i)),1)/num2;
            cbot((j-1)*le+k,i)=size(find(dbs(end-num2:end,nv+k)<eben((j-1)*le+k,i)),1)/num2;
        end
    end
    
    %We save the name of the signal
    sn(1,i)=signal(var(i));
    
end    

%At this point we create the dynamic Model

%We load the model switching variable
bul=dlmread('bull.txt','\t');

%We create the dates relative to this file
bdat=datenum(bul(:,1:3));

%We create a matrix of regime indicators compatible with the database file
%(observation by observation)
bun=zeros(size(dbx,1),1);

for i=1:size(bdat,1)
    bun(dat==bdat(i),1)=bul(i,4);
end

%We create a matrix of regime indicators compatible with the portfolio file
%(date by date)
bux=zeros(size(etop,1),1);

for i=1:size(etop,1)
    bux(i,1)=bul(bdat==dates(i),4);
end


%We create syntetic portfolios multiplying the top portfolios by the regime
%indicator
dspr=zeros(size(etop));

for i=1:size(var,2)
    dspr(:,i)=(etop(:,i)-ebot(:,i)).*bux;
end


[mr1 cv1]=ewstats(etop-ebot);
[mr2 cv2]=ewstats([etop-ebot dspr]);

%We calculate the efficient frontier for the top portfolios
[ri1 re1 w1]=frontcon(mr1,cv1,20);
[ri2 re2 w2]=frontcon(mr2,cv2,20);

rr1=re1./ri1;
rr2=re2./ri2;

ow1=w1(rr1==max(rr1),:);
ow2=w2(rr2==max(rr2),:);

%We create syntetic signals multiplying the old signals by the regime
%indicator
for i=1:size(var,2)
    dbn(:,i)=dbx(:,var(i)).*bun;
end

%We create the two models
mod=[dbx(:,var)*ow1' [dbx(:,var) dbn]*ow2'];

%We create an adaptive model


dmo=zeros(size(dbx,1),1);

%We create a loop where we calculate the optimal composition of the model
%using a certain number of past observations
for i=1:size(etop,1)-de
    [mr1 cv1]=ewstats(etop(i:i+de-1,:)-ebot(i:i+de-1,:));
    
    [ri1 re1 w1]=frontcon(mr1,cv1,20);

    rr1=re1./ri1;
    
    
    %We save the weights and the relevant date

    aw(i,:)=w1(rr1==max(rr1),:);
    dw(i,1)=dates(i+de-1,1);
    
    %We calculate the model for the subset of observations with the given
    %date
    dmo(dat==dw(i,1),:)=dbx(dat==dw(i,1),var)*aw(i,:)' ;
end

dbz=[mod dmo dbx];
dbz=dbz(dat>=dw(1,1),:);
time=time(dat>=dw(1,1),:);
mcap=mcap(dat>=dw(1,1),:);
etop=etop(de+1:end,:);
ebot=ebot(de+1:end,:);
eben=eben(de+1:end,:);
etop=etop(de+1:end,:);
ebot=ebot(de+1:end,:);
ti=ti(de+1:end,:);
dates=dates(de+1:end,:);

nd=size(ti,1);
np=floor((nd-1)/le);
nv=nv+3;

for i=1:3
          
    %An inner loop will serve to repeat the ranking and invesmtment
    %decision each month
    for j=1:np
        
        %We individuate the time indicator of the observation
            t=(j-1)*le+1;
        
        %We extract the sub-database with the observations that we
        %will use in this particular iteration
        dbx2=dbz((time==ti(t) & mcap>=minc),:);
        
        %We extract the sub-database where the value of the signal is
        %non-missing
        dbm=dbx2(isfinite(dbx2(:,i)),:);
        
        %We sort the rows of our sample on the base of he specific
        %information signal
        [dbs ind]=sortrows(dbm,-1*i);
        num2=min(num,0.5*size(dbs,1));
        for k=1:le
        
            %We save the equally weighted returns of the portfolios
            etop((j-1)*le+k,size(var,2)+i)=mean(dbs(1:num2,nv+k));
            ebot((j-1)*le+k,size(var,2)+i)=mean(dbs(end-num2:end,nv+k));
            eben((j-1)*le+k,size(var,2)+i)=mean(dbs(1:end,nv+k));
            
            %We calculate the consistency
            ctop((j-1)*le+k,size(var,2)+i)=size(find(dbs(1:num2,nv+k)>eben((j-1)*le+k,size(var,2)+i)),1)/num2;
            cbot((j-1)*le+k,size(var,2)+i)=size(find(dbs(end-num2:end,nv+k)<eben((j-1)*le+k,size(var,2)+i)),1)/num2;
        end
    end
end    


sn2=[sn 'Static' 'Dynamic' 'Adaptive'];


%We start by calculating mean returns
eri(1,:)=mean(etop);
eri(2,:)=mean(ebot);
eri(3,:)=mean(eben);

%We calculate standard deviations
eri(4,:)=std(etop);
eri(5,:)=std(ebot);
eri(6,:)=std(eben);

%We can now calculate the risk reward ratios
eri(7,:)=mean(etop)./std(etop);
eri(8,:)=mean(ebot)./std(ebot);
eri(9,:)=mean(eben)./std(eben);

%We calculate the diagnostics for the spread portfolio
eri(10,:)=mean(etop-ebot);
eri(11,:)=std(etop-ebot);
eri(12,:)=mean(etop-ebot)./std(etop-ebot);

%We calculate the diagnostics for the active top portfolio
eri(13,:)=mean(etop-eben);
eri(14,:)=std(etop-eben);
eri(15,:)=mean(etop-eben)./std(etop-eben);

%We can now move to a non parametric approach

%We calculate the worst returns   
eri(16,:)=min(etop);
eri(17,:)=min(etop-ebot);
eri(18,:)=min(etop-eben);

%We calculate the percentage of positive returns
eri(19,:)=sum(sign(max(0,etop)))./size(etop,1);
eri(20,:)=sum(sign(max(0,etop-ebot)))./size(etop,1);
eri(21,:)=sum(sign(max(0,etop-eben)))./size(etop,1);

%We calculate the mean consistency
eri(22,:)=mean(ctop);
eri(23,:)=mean(cbot);
    
   
%We save the results in an excel file       

xlswrite('Diagnostics.xls',sn2,'ADModel','B1')
xlswrite('Diagnostics.xls',eri,'ADModel','B2')


%We transform the returns into prices
ptop=ret2tick(etop);
pbot=ret2tick(ebot);
pben=ret2tick(eben);
pspr=ret2tick(etop-ebot);
pact=ret2tick(etop-eben);


%And plot them
datex=dates(1:size(ptop,1));

figure
subplot(2,1,1)
plot(datex,ptop(:,end-2:end))
legend('Static Model', 'Dynamic Model', 'Adaptive Model','Location','NorthWest')
grid on
dateaxis('x',12)
title('Top Portfolios')

subplot(2,1,2)
plot(datex,pspr(:,end-2:end))
legend('Static Model', 'Dynamic Model', 'Adaptive Model','Location','NorthWest')
grid on
dateaxis('x',12)
title('Spread portfolios')

figure
area(dw,aw)
legend(sn)
dateaxis('x',12)
grid on
title('Dynamic Model Composition')

