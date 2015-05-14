clear all

db=dlmread('dbfunds.txt','\t');

%We extrapolate the fund codes
nam=db(:,1);
names=unique(nam);

%We extrapolate the dates
dat=datenum(db(:,2:4));
dates=unique(dat);

%We preallocate the result matrices
bet=zeros(size(names,1),4);
pme=zeros(size(names,1),4);

%We start a cycle for the number of funds in the sample
for i=1:size(names,1)
    
    %We isolate the data for the relevant fund
    db2=db(db(:,1)==names(i),:);
    
    %We estimate the models and save the risk exposures of the multifacotr
    %model
    [b,dev,st]=glmfit(db2(:,8:11),db2(:,5)-db2(:,12));
    [b2,dev2,st2]=glmfit(db2(:,8),db2(:,5)-db2(:,12));
    
    bet(i,:)=[b(2:end)'];
    
    %We calculate four classic performance measures (annualized): 1-Excess
    %return, 2-Singe Index Alpha, 3-Sharpe Ratio, 4-Treynor Ratio    
    pme(i,1)=12*mean(db2(:,5)-db2(:,12));
    pme(i,2)=12*b2(1);
    pme(i,3)=12*mean(db2(:,5)-db2(:,12))/(sqrt(12)*std(db2(:,5)-db2(:,12)));
    pme(i,4)=12*mean(db2(:,5)-db2(:,12))/b2(2);
end


%We perform the cross sectiona lregression in order to quatify the risk
%premiums associated with the exposures at the four risk factors
for i=1:4
    [b,dev,st]=glmfit(bet,pme(:,i));
    
    coe(:,i)=b;
    sig(:,i)=st.p;
    rsq(:,i)=1-(nanvar(st.resid)/nanvar(pme(:,i)));
end


%We prepare the final table wit hthe p-values below the coefficients
for i=1:size(coe,1)
    ris(2*i-1,:)=coe(i,:);
    ris(2*i,:)=sig(i,:);
end


%We Save the results
ris=[ris;rsq];

ris2=[mean(pme);std(pme);max(pme);min(pme)];

xlswrite('Analysis.xls',ris,'Measures','B2')
xlswrite('Analysis.xls',ris2,'Descriptive','B2')



%We Plot the Performance Measures
figure
subplot(2,2,1)
hist(pme(:,1),20)
grid on
title('Annualized Excess Return')

subplot(2,2,2)
hist(pme(:,2),20)
grid on
title('Annualized Single Index Alpha')

subplot(2,2,3)
hist(pme(:,3),20)
grid on
title('Annualized Sharpe Ratio')

subplot(2,2,4)
hist(pme(:,4),20)
grid on
title('Annualized Treynor Ratio')
    