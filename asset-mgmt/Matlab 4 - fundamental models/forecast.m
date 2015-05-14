clear all

%We load the database
db=dlmread('zidatabase.txt','\t');

%We save the number of information signals in our file
nv=16;

%We indicate the variables that we want to use and the number of stocks
%that we want to include in the portfolios
vr=[3 5 7 9];


%We indicate the lenght of the investment period
le=3;

%We indicate the lenght of the evaluation period
ep=60;


%We convert all the -999 in the database into missing values
db(db==-999)=NaN;

%We load a file with the strings of the names of the Information Variables
run isignals

%We split the database into its components
dat=datenum(db(:,1:3));
time=db(:,4);
names=db(:,5);
mcap=db(:,6);
dbx=db(:,7:end);

clear db


%We estract the list of the stocks, periods and dates
ti=unique(time);
na=unique(names);
dates=unique(dat);

%We define the number of stocks, the number of dates and the number of
%investment periods
ns=size(na,1);
nd=size(ti,1);
np=nd-ep;

%We initialize vectors for portfolio returns and consistencies
fam=zeros(8,size(vr,2));
pan=zeros(7,size(vr,2));

%We create the investment period return

ret=prod(1+dbx(:,nv+1:nv+1+le),2)-1;

%We Isolate the variables that we want to use

mod=zeros(size(dbx,1),size(vr,2));

for i=1:size(vr,2)
    sn(1,i)=signal(vr(i));
    mod(:,i)=dbx(:,vr(i));
end

dbx=[mod dbx(:,nv+1:end) ret];




%We now run a Panel Regression Model with time fixed effects


risu=[];

ris=zeros(np,2*size(vr,2)+1);
coef=zeros(np,size(vr,2)+1);
for j=1:np

    %We individuate the time indicator of the observation
    t=(j-1)+ep+1;

    %We extract the sub-database with the observations that we
    %will use in this particular iteration
    dbm=dbx((time<=ti(t) & time>ti(t-ep)),:);  
    tim=time((time<=ti(t) &time>ti(t-ep)),:);

    %We run the univariate panel regression
    [b de st]=panel(dbm(:,1:size(vr,2)), dbm(:,end), tim);
    
    dbm=dbx(time==ti(t),:);
    nm=names(time==ti(t),:);
    si=mcap(time==ti(t),:);
    
    ris=[nm ones(size(nm)).*m2xdate(dates(t)) ones(size(nm)).*ti(t) si b(1)+dbm(:,1:size(vr,2))*b(2:size(vr,2)+1) dbm(:,size(vr,2)+1:end-1)];
    
    risu=[risu;ris];
    
    coef(j,:)=[dates(t) b(2:size(vr,2)+1)'];

end

xlswrite('FDiagnostics.xls',risu,'Forecasts','A2')

dlmwrite('forecasts.txt',risu,'Delimiter','\t')


figure
plot(coef(:,1),coef(:,2:end));
grid on
legend(sn)
dateaxis('x',12)
title('Coefficienti')
