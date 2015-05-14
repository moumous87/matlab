clc

%%

load database


%%

vr=[1 2 6 8 15];
sn=signames(vr)';


ti=unique(time);
nd=size(ti,1);

%Take only the out-of-sample portion
bkdb=db(year(journal)>1996,:);

bkdates=unique(journal(year(journal)>1996));
bktime=time(year(journal)>1996);
bkti=unique(bktime);
bknd=size(bkti,1);
bkmcap=mcap(year(journal)>1996,:);
bkret=ret(year(journal)>1996,:);

nv=16;

%We indicate the lenght of the evaluation period
ep=60;

bknp=bknd-ep;


%We Isolate the variables that we want to use
mod=bkdb(:,vr);

dbx=[mod bkdb(:,nv+1:end) bkret];




%We now run a Panel Regression Model with time fixed effects


foback=[];

ris=zeros(bknp,2*size(vr,2)+1);
coef=zeros(bknp,size(vr,2)+1);

for j=1:bknp
    
    bknp-j

    %We individuate the time indicator of the observation
    t=(j-1)+ep+1;

    %We extract the sub-database with the observations that we
    %will use in this particular iteration
    dbxm=dbx((bktime<=bkti(t) & bktime>bkti(t-ep)),:);  
    tim=bktime((bktime<=bkti(t) & bktime>bkti(t-ep)),:);

    %We run the multivariate panel regression
    [b de st]=panel(dbxm(:,1:size(vr,2)), dbxm(:,end), tim);
    
    dbxm=dbx(bktime==bkti(t),:);
    nm=id(bktime==bkti(t),:);
    si=bkmcap(bktime==bkti(t),:);
    
    ris=[nm ones(size(nm)).*bkdates(t) ones(size(nm)).*ti(t) si b(1)+dbxm(:,1:size(vr,2))*b(2:size(vr,2)+1) dbxm(:,size(vr,2)+1:end-1)];
    
    foback=[foback;ris];
    
    coef(j,:)=[dates(t) b(2:size(vr,2)+1)'];

end

clc

save('foreback.mat','foback');


save everything % in case we need to go back, we don't need to run again the cods, just load everything.mat

figure
plot(coef(:,1),coef(:,2:end));
grid on
legend(sn,'location','northwest')
dateaxis('x',12)
title('Coefficienti')



