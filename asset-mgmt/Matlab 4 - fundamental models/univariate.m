clear all

%We load the database
db=dlmread('zidatabase.txt','\t');

%We save the number of information signals in our file
nv=16;

%We indicate the variables that we want to use 
vr=linspace(1,nv,nv);

%We indicate the lenght of the investment period
le=3;

%We indicate the lenght of the evaluation period
ep=12;


%We convert all the -999 in the database into missing values
db(db==-999)=NaN;

%We load a file with the strings of the names of the Information Variables
run isignals

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
fam=zeros(8,size(vr,2));
pan=zeros(7,size(vr,2));

%We create the investment period return

ret=prod(1+dbx(:,nv+1:nv+le),2)-1;
dbx=[dbx ret];

%We run first a Fama-McBeth single period model

%We run a first outer loop on the base of the number of information signals
%chosen for the task
for i=1:size(vr,2)
    sn(1,i)=signal(vr(i));
     ris=zeros(np,3);
    %An inner loop will serve to repeat the ranking and invesmtment
    %decision each month
    for j=1:np
        
        %We individuate the time indicator of the observation
        t=(j-1)*le+1;
        
        %We extract the sub-database with the observations that we
        %will use in this particular iteration
        dbm=dbx(time==ti(t),:);
        
        %We run the univariate regression
        [b de st]=glmfit(dbm(:,i), dbm(:,end));
        ris(j,:)=[b(2) st.p(2) 1-(nanvar(st.resid)/nanvar(dbm(:,end)))];
    end
    
    [h p]=ttest(ris(:,1));
    
    fam(1,vr(i))=size(ris(ris(:,1)>0),1)/np;
    fam(2,vr(i))=size(ris(ris(:,1)<0),1)/np;
    fam(3,vr(i))=size(ris(ris(:,2)<0.1),1)/np;
    fam(4,vr(i))=size(ris(ris(:,1)>0 & ris(:,2)<0.1 ),1)/np;
    fam(5,vr(i))=size(ris(ris(:,1)<0 & ris(:,2)<0.1 ),1)/np;
    fam(6,vr(i))=mean(ris(:,3));
    fam(7,vr(i))=p;
    fam(8,vr(i))=mean(ris(:,1))*1000;
    
    
end


%We now run a Panel Regression Model with time fixed effects

np=floor((nd-1-ep)/le);




for i=1:size(vr,2)
    ris=zeros(np,3);
    for j=1:np
        
        %We individuate the time indicator of the observation
        t=(j-1)*le+ep+1;
       
        %We extract the sub-database with the observations that we
        %will use in this particular iteration
        dbm=dbx((time<=ti(t) & time>ti(t-ep)),:);  
        tim=time((time<=ti(t) &time>ti(t-ep)),:);
        
        %We run the univariate panel regression
        [b de st]=panel(dbm(:,i), dbm(:,end), tim);
     
        ris(j,:)=[b(2) st.p(2) 1-(nanvar(st.resid)/nanvar(dbm(:,end)))];
    end
    
    [h p]=ttest(ris(:,1));
    
    pan(1,vr(i))=size(ris(ris(:,1)>0),1)/np;
    pan(2,vr(i))=size(ris(ris(:,1)<0),1)/np;
    pan(3,vr(i))=size(ris(ris(:,2)<0.1),1)/np;
    pan(4,vr(i))=size(ris(ris(:,1)>0 & ris(:,2)<0.1 ),1)/np;
    pan(5,vr(i))=size(ris(ris(:,1)<0 & ris(:,2)<0.1 ),1)/np;
    pan(6,vr(i))=mean(ris(:,3));
    pan(7,vr(i))=mean(ris(:,1))*1000;
end


%We save the returns and consistencies to a xls file in an area prepared and formatted        

xlswrite('FDiagnostics.xls',sn,'Univariate','B1')
xlswrite('FDiagnostics.xls',fam,'Univariate','B2')
xlswrite('FDiagnostics.xls',pan,'Univariate','B11')