%% PANEL ON THE DYNAMIC MODEL 10 (ONLY BULLISH MKT)


np=floor((innd-60)/3);

pan10=zeros(11,nv);
ris=zeros(np,3);
betas10=zeros(np,nv);



for i=1:nv
    
    
    for j=2:np % we start at 2 because for the first 3 times we have NaN
        
        t=(j-1)*3+12+1; % first t=16 t-12=4
        
        dbt=indbuz10((intime>inti(t-12) & intime<=inti(t)),:); % ti(t-12)<time<=ti(t)
        tim=intime((intime>inti(t-12) & intime<=inti(t)),:); % ti(t-12)<time<=ti(t)
        
        [b de st]=panel(dbt(:,i),dbt(:,end),tim);
        
        ris(j,:)=[b(2) st.p(2) 1-(nanvar(st.resid)/nanvar(dbt(:,end)))];
        %         beta stats                  R2
        
    end
    
    betas10(:,i)=ris(:,1);
    
    [h p]=ttest(ris(:,1));
    
    pan10(1,i)=size(ris(ris(:,1)>0),1)/np; % Positive beta
    pan10(2,i)=size(ris(ris(:,1)<0),1)/np; % Negative beta
    pan10(3,i)=size(ris(ris(:,2)<0.1),1)/np; % Significant beta
    pan10(4,i)=size(ris(ris(:,1)>0 & ris(:,2)<0.1),1)/np; % Pos & Sig
    pan10(5,i)=size(ris(ris(:,1)<0 & ris(:,2)<0.1),1)/np; % Neg & Sig
    pan10(6,i)=mean(ris(:,3)); %- Mean R-Squared
    pan10(7,i)=p; %- P-Value
    pan10(8,i)=mean(ris(:,1))*100; %- Mean Coeff. X 100
    pan10(9:11,i)=quantile(ris(:,1),[.50 .25 .75])*100; %  median, 1st quartile, 3rd quartile x 100
    

end


% plot

for i=1:2:nv-1
    
figure

subplot(2,1,1)
plot(dateb, betas10(:,i))
hold on
plot(dateb, redline,'r')
hold on
plot(dateb,pan(8,i)*ones(np,1)/100,'k -.') % ==> mean
hold on
plot(dateb,pan(10,i)*ones(np,1)/100,'k :','LineWidth',2) % ==> 1st quartile
hold on
plot(dateb,pan(11,i)*ones(np,1)/100,'k :','LineWidth',2) % ==> 3rd quartile
hold on
plot(dateb,cyclepoint,'r *','LineWidth',2)
title(strcat(signames(i)))
dateaxis('x',12)
xlim([dateb(1) dateb(end)])
grid on

subplot(2,1,2)
plot(dateb, betas10(:,i+1))
hold on
plot(dateb, redline,'r')
hold on
plot(dateb,pan(8,i+1)*ones(np,1)/100,'k -.') % ==> mean
hold on
plot(dateb,pan(10,i+1)*ones(np,1)/100,'k :','LineWidth',2) % ==> 1st quartile
hold on
plot(dateb,pan(11,i+1)*ones(np,1)/100,'k :','LineWidth',2) % ==> 3rd quartile
hold on
plot(dateb,cyclepoint,'r *','LineWidth',2)
title(strcat(signames(i+1)))
dateaxis('x',12)
xlim([dateb(1) dateb(end)])
grid on

end;



%% PANEL ON indbuz01



np=floor((innd-60)/3);

pan01=zeros(11,nv);
ris=zeros(np,3);
betas01=zeros(np,nv);



for i=1:nv
        
    for j=2:np % we start at 2 because for the first 3 times we have NaN
        
        t=(j-1)*3+12+1; % first t=16 t-12=4
        
        dbt=indbuz01((intime>inti(t-12) & intime<=inti(t)),:); % ti(t-12)<time<=ti(t)
        tim=intime((intime>inti(t-12) & intime<=inti(t)),:); % ti(t-12)<time<=ti(t)
        
        [b de st]=panel(dbt(:,i),dbt(:,end),tim);
        
        ris(j,:)=[b(2) st.p(2) 1-(nanvar(st.resid)/nanvar(dbt(:,end)))];
        %         beta stats                  R2
        
    end
    
    betas01(:,i)=ris(:,1);
    
    [h p]=ttest(ris(:,1));
    
    pan01(1,i)=size(ris(ris(:,1)>0),1)/np; % Positive beta
    pan01(2,i)=size(ris(ris(:,1)<0),1)/np; % Negative beta
    pan01(3,i)=size(ris(ris(:,2)<0.1),1)/np; % Significant beta
    pan01(4,i)=size(ris(ris(:,1)>0 & ris(:,2)<0.1),1)/np; % Pos & Sig
    pan01(5,i)=size(ris(ris(:,1)<0 & ris(:,2)<0.1),1)/np; % Neg & Sig
    pan01(6,i)=mean(ris(:,3)); %- Mean R-Squared
    pan01(7,i)=p; %- P-Value
    pan01(8,i)=mean(ris(:,1))*100; %- Mean Coeff. X 100
    pan01(9:11,i)=quantile(ris(:,1),[.50 .25 .75])*100; %  median, 1st quartile, 3rd quartile x 100
    

end


char({'BOOM !!!'})



% plot

for i=1:2:nv-1
    
figure

subplot(2,1,1)
plot(dateb, betas01(:,i))
hold on
plot(dateb, redline,'r')
hold on
plot(dateb,pan(8,i)*ones(np,1)/100,'k -.') % ==> mean
hold on
plot(dateb,pan(10,i)*ones(np,1)/100,'k :','LineWidth',2) % ==> 1st quartile
hold on
plot(dateb,pan(11,i)*ones(np,1)/100,'k :','LineWidth',2) % ==> 3rd quartile
hold on
plot(dateb,cyclepoint,'r *','LineWidth',2)
title(strcat(signames(i)))
dateaxis('x',12)
xlim([dateb(1) dateb(end)])
grid on

subplot(2,1,2)
plot(dateb, betas01(:,i+1))
hold on
plot(dateb, redline,'r')
hold on
plot(dateb,pan(8,i+1)*ones(np,1)/100,'k -.') % ==> mean
hold on
plot(dateb,pan(10,i+1)*ones(np,1)/100,'k :','LineWidth',2) % ==> 1st quartile
hold on
plot(dateb,pan(11,i+1)*ones(np,1)/100,'k :','LineWidth',2) % ==> 3rd quartile
hold on
plot(dateb,cyclepoint,'r *','LineWidth',2)
title(strcat(signames(i+1)))
dateaxis('x',12)
xlim([dateb(1) dateb(end)])
grid on

end;



%%
clear dbt

