clear all

db=dlmread('dbfunds.txt','\t');


%We extrapolate the fund codes
nam=db(:,1);
names=unique(nam);

%We extrapolate the dates
dat=datenum(db(:,2:4));
dates=unique(dat);

%We preallocate the result matrices
ris=zeros(size(names,1),3);
ris2=zeros(size(names,1),6);

%We start a cycle for the number of funds in the sample
for i=1:size(names,1)
    
    %We isolate the data for the relevant fund
    db2=db(db(:,1)==names(i),:);
    
    %We estimate the models
    [b,dev,st]=glmfit(db2(:,8),db2(:,5)-db2(:,12));
    [b2,dev2,st2]=glmfit(db2(:,8:11),db2(:,5)-db2(:,12));
    
    %We can set equal to zero the insignificant coefficients
    %b(st.p>0.1)=0;
    %b2(st2.p>0.1)=0;
    
    %We can save the estimated coefficients and the R-Squared
    ris(i,:)=[b' 1-(nanvar(st.resid)/nanvar(db2(:,5)-db2(:,12)))];
    ris2(i,:)=[b2' 1-(nanvar(st2.resid)/nanvar(db2(:,5)-db2(:,12)))];
end
        

%We plot the results
figure
subplot(2,2,1)
hist(12*ris(:,1),20)
title('Annualized Single Index Alpha')
grid on

subplot(2,2,2)
hist(12*ris2(:,1),20)
title('Annualized Multi Index Alpha')
grid on

subplot(2,2,3)
plot(12*ris(:,1),12*ris2(:,1),'b.')
title('Correlation among Alphas')
xlabel('Single Index Alpha')
ylabel('Multi Iddex Alpha')
grid on


figure
subplot(2,2,1)
hist(ris(:,3),20)
title('Single Index R-Squared')
grid on

subplot(2,2,2)
hist(ris2(:,6),20)
title('Multi Index R-Squared')
grid on

subplot(2,2,3)
plot(ris(:,3),ris2(:,6),'b.')
title('Correlation among Alphas')
xlabel('Single Index R-Squared')
ylabel('Multi Iddex R-Squared')
grid on


figure
subplot(2,2,1)
hist(ris2(:,2),20)
title('Market')
grid on
 
subplot(2,2,2)
hist(ris2(:,3),20)
title('Small - Big')
grid on
 
subplot(2,2,3)
hist(ris2(:,4),20)
title('High - Low')
grid on
 
subplot(2,2,4)
hist(ris2(:,5),20)
title('Winner - Losers')
grid on


figure
plot(ris2(:,3),ris2(:,4),'b.')
xlabel('Small - Big')
ylabel('High - Low')
grid on

figure
plot3(ris2(:,3),ris2(:,4),ris2(:,5),'b.')
xlabel('Small - Big')
ylabel('High - Low')
zlabel('Winner - Losers')
grid on
 