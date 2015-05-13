
[dataEuriborSwap,txtEuriborSwap,~]=xlsread('Assignment_MarketData copia.xls');
[dataVcub,~,~]=xlsread('Assignment_MarketData copia 3.xls');
[dataCDS,~,~]=xlsread('Assignment_MarketData copia 2.xls');


%%
EuriborSwap(33,6)=0;
Vcub(13,16)=0;
CDS(8,4)=0;
%%


EuriborSwap(:,2)=datenum(txtEuriborSwap(2:end,2),'mm/dd/yyyy');

date=EuriborSwap(:,2);
busday=isbusday(EuriborSwap(:,2)); % the dates provided are all business days, so no need of adjustment


start=datenum(2005,06,26);

EuriborSwap(1:13,1)=yearfrac(start*ones(13,1),date(1:13,:),2);
EuriborSwap(14:end,1)=[(1:1:12)';(15:5:50)'];

EuriborSwap(:,3:end-1)=dataEuriborSwap(2:end,:);

EuriborSwap(1:13,end)=0; %0=cash rate
EuriborSwap(14:end,end)=1; %1=swap rate

clear dataEuriborSwap txtEuriborSwap

%%

Vcub(:,1)=[1;2;3;4;5;6;7;8;9;10;12;15;20];

Vcub(:,2:end)=dataVcub(2:end,:);

clear dataVcub

%%

CDS(:,1)=[10;7;5;4;3;2;1;0.5];
CDS(:,2:end)=dataCDS;

clear dataCDS

%%

save('Assignment_MarketData.mat','EuriborSwap','Vcub','CDS');


%%













