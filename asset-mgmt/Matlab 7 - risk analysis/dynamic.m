clear all

db=dlmread('dbfunds.txt','\t');


%We extrapolate the fund codes
nam=db(:,1);
names=unique(nam);

%We choose the lenght of the rolling period
t=60;


%We choose the funds we want to analyze
fu=[99999];


%fu=[3258 3528 4197 4629]; 
%fu=[6384 6471]; 
 
%We load the names of the funds
run fundnam

%We extrapolate the dates
dat=datenum(db(:,2:4));
dates=unique(dat);

%We preallocate the result matrices
alp=zeros(size(dates,1)-t,size(fu,2));
mkt=alp;
smb=alp;
hml=alp;
umd=alp;
rsq=alp;


%We start a cycle for the number of funds that we want to analyze
for j=1:size(fu,2);
    
    %We isolate the data relevant for the given fund
    db2=db(db(:,1)==fu(j),:);
    
    %We start an inner cycle for the number of rolling periods on which we
    %estimate the model
    for i=1:size(dates,1)-t
        
        %We estimate the muktifactor model and save the results
        [b,dev,st]=glmfit(db2(i:i+t-1,8:11),db2(i:i+t-1,5)-db2(i:i+t-1,12));
        
        alp(i,j)=b(1);
        mkt(i,j)=b(2);
        smb(i,j)=b(3);
        hml(i,j)=b(4);
        umd(i,j)=b(5);
        rsq(i,j)=1-(nanvar(st.resid)/nanvar(db2(:,5)-db2(:,12)));
        fun(j,1)=funds(names==fu(j));
        
    end
    
    %We can plot the results
    figure
    subplot(2,1,1)
    plot(dates(t+1:end),12*alp(:,j),'b-')
    dateaxis('x',12)
    grid on
    legend('Annualized Alpha')
    title(fun(j,1));
    
    subplot(2,1,2)
    plot(dates(t+1:end),rsq(:,j),'r-')
    dateaxis('x',12)
    grid on
    legend('R-Squared')
    
    figure

    subplot(2,1,1)
    plot(dates(t+1:end),mkt(:,j),'b-')
    dateaxis('x',12)
    grid on
    legend('Market Exposure')
    title(fun(j,1));

    subplot(2,1,2)
    plot(dates(t+1:end),smb(:,j),'b-',dates(t+1:end),hml(:,j),'r-',dates(t+1:end),umd(:,j),'g-')
    dateaxis('x',12)
    grid on
    legend('smb','hml','umd')

    
    
end




