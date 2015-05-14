clear, clc, close all

%% CONVERT THE FILE FORMAT FROM XLSX TO XLS AND UPLOAD DATASET

%[data,txt1,~]=xlsread('Industry Data.xls','Database');
%[~,txt2,~]=xlsread('Industry Data.xls','Industries','B2:C49');

%save dataxlsread <== We save the data derived from the above xlsread in a file .mat
%(this is to avoid problems with xlsread on McOSX)

%clear all
%%
load dataxlsread

%% FIRST DATA TRANSFORMATIONS

data(data==-999)=NaN;

journal=datenum(data(:,1:3));
time=data(:,4);
id=data(:,5);

mcap=data(:,6);

dates=unique(journal);
ti=unique(time);
assets=unique(id);

nd=size(ti,1); % # of date=228
na=size(assets,1); % =48

signames=txt1(:,7:22)';

industries=txt2(:,1);
industries_=txt2(:,2);


db=[data(:,7:end) mcap]; %data(:,7:22) are the signals, then are the returns and last the mcap
% column 1:16=signals
% column 17:28=returns
% column 29=mcap

nv=16; % # of signals


%% DATA FOR EACH INDUSTRY

dbxasset(nd,29,na)=0;
% column 1:16=signals
% column 17:28=returns
% column 29=mcap

for i=1:na
    dbxasset(:,:,i)=data(id==i,[7:end 6]);
end;

pricexasset(nd+1,na)=0;

for i=1:na
    pricexasset(:,i)=ret2tick(dbxasset(:,nv+1,i));
end;


datex=[datenum([1989 12 31]); dates(1:nd)]; %vector dates modified for time series of prices


%% HISTORICAL DATABASE THAT WE WILL USE IN THE STRATEGY IMPLEMENTATION

hi(:,2:na+1)=dbxasset(:,nv+1,1:na);
hi(:,1)=ti;

% SAVE "hi" IN -MAT FILE
save('hi.mat','hi');

%%

clear data txt1 txt2;


%% THE BENCHMARK

% dbxasset(:,:,i)=[data(id==i,[7:end 6])];
% column 1:16=signals
% column 17:28=returns
% column 29=mcap


wb(nd,1,na)=0;

for i=1:nd
    
    wb(i,1,:)=dbxasset(i,end,:)/sum(dbxasset(i,end,:)); %mkt weights of each asset through time
    
end;



wbr(nd,12,na)=0;

for j=1:na

    for i=nv+1:nv+12

        wbr(:,i-nv,j)=wb(:,1,j).*dbxasset(:,i,j); % weighted benchmark returns
        %(for each asset, i.e. outer loop) we multiply the weights by the returns (from r1 to r12, i.e. dbxasset(:,nv+1:nv+12,j)

    end

end

clear wb;


benchmark(:,:)=sum(wbr(:,1,:),3);
benchprice=ret2tick(benchmark);


%% find the 'local' max & min

maxbench1=max(benchprice(datex<datenum(2001,04,01)));
peak1=find(benchprice==maxbench1);

maxbench2=max(benchprice(datex>datenum(2006,11,01)));
peak2=find(benchprice==maxbench2);

minbench=min(benchprice(datex>datenum(2001,05,01) & datex<datenum(2004,02,01)));
bottom=find(benchprice==minbench);

year(datex(peak1))  %=year 2000
year(datex(peak2))  %=year 2007
year(datex(bottom)) %=year 2002


points=NaN(size(benchprice,1),1);
points(peak1)=maxbench1;
points(peak2)=maxbench2;
points(bottom)=minbench;


clear maxbench1;
clear maxbench2;
clear minbench;

%% 3-MONTH RETURNS

ret=prod(1+db(:,nv+1:nv+3),2)-1;
db=[db ret];

% db:
% column 1:16  =signals
% column 17:28 =returns
% column 29    =mcap
% column 30    =3m returns

%saving the database
save('database.mat','db','ret','benchmark','journal','time','dates','signames','id','mcap');

%% DIVIDING THE DATABASE INTO IN-SAMPLE AND OUT-OF-SAMPLE
% WE STOP THE IN-SAMPLE DATA IN BETWEEN THE FIRST PEAK (2000) IN THE
% BENCHMARK AND THE SUCCESSIVE DIP (2002) ==> 2001

indb=db(year(journal)<=2001,:);

% indb:
% column 1:16  =signals
% column 17:28 =returns
% column 29    =mcap
% column 30    =3m returns


indates=unique(journal(year(journal)<=2001));
intime=time(year(journal)<=2001);
inti=unique(intime);
innd=size(inti,1);


