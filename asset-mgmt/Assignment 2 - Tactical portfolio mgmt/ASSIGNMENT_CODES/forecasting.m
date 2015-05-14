%% FINAL CHOICE: SECOND MULTIVARIATE PANEL

vr=[1 2 6 8 15];
sn=signames(vr)';

%%


%We indicate the lenght of the evaluation period
ep=60;

np=nd-ep;


%We Isolate the variables that we want to use
mod=db(:,vr);

dbx=[mod db(:,nv+1:end) ret];




%We now run a Panel Regression Model with time fixed effects


fo=[];

ris=zeros(np,2*size(vr,2)+1);
coef=zeros(np,size(vr,2)+1);

for j=1:np
    
    np-j

    %We individuate the time indicator of the observation
    t=(j-1)+ep+1;

    %We extract the sub-database with the observations that we
    %will use in this particular iteration
    dbxm=dbx((time<=ti(t) & time>ti(t-ep)),:);  
    tim=time((time<=ti(t) & time>ti(t-ep)),:);

    %We run the multivariate panel regression
    [b de st]=panel(dbxm(:,1:size(vr,2)), dbxm(:,end), tim);
    
    dbxm=dbx(time==ti(t),:);
    nm=id(time==ti(t),:);
    si=mcap(time==ti(t),:);
    
    ris=[nm ones(size(nm)).*dates(t) ones(size(nm)).*ti(t) si b(1)+dbxm(:,1:size(vr,2))*b(2:size(vr,2)+1) dbxm(:,size(vr,2)+1:end-1)];
    
    fo=[fo;ris];
    
    coef(j,:)=[dates(t) b(2:size(vr,2)+1)'];

end

clc

save('fore.mat','fo');


save everything % in case we need to go back, we don't need to run again the cods, just load everything.mat

figure
plot(coef(:,1),coef(:,2:end));
grid on
legend(sn,'location','northwest')
dateaxis('x',12)
title('Coefficienti')



