% Principal Component Analisys

% This script examines the PCA of a set of stocks.

%************************** PART 1 ****************************************
%Upload the dataset
data=xlsread('data_pc.xls');

%Compute the returns
returns=(data(2:end,:)-data(1:end-1,:))./data(1:end-1,:);

%Compute the PCA
X=cov(returns);
[pc,latent,explained] = pcacov(X);
variance_explanation=cumsum(explained);

%Estimation of the VarCov matrix using the first 4 principal components
X_new=pc(:,1:4)*diag(latent(1:4))*pc(:,1:4)';
error_X=(X_new-X)./X;

%Plot the first PC and the return series
Index_equally_w=mean(returns,2);
Tot=sum(pc,1);
First_pc=returns*(pc(:,1)./Tot(1,1));
for i=1:size(returns,2)
    cumret(:,i)=cumprod(1+returns(:,i));
end
figure
plot([cumret, cumprod(1+First_pc)]);
title('Returns vs First Principal Componet');
h = legend('3M', 'ALCOA' ,'ALTRIA GROUP','AMER.EXPRESS','AMER.INT.GROUP','BOING','FIRST PC',2);
figure
plot([cumprod(1+Index_equally_w), cumprod(1+First_pc)]);
title('Equally Weighted Index vs First Principal Componet');
h = legend('Equally Weighted Index','FIRST PC',2);

%************************** END PART 1 ************************************

%************************** PART 2 ****************************************

%Upload the dataset
data2a=xlsread('data_pc2a.xls');
data2b=xlsread('data_pc2b.xls');

data2=[data2a data2b];

clear data2a data2b;

%Compute the returns
returns2=(data2(2:end,:)-data2(1:end-1,:))./data2(1:end-1,:);
[N,C]=size(returns2);

%Compute the PCA
X2=cov(returns2);
[pc2,latent2,explained2] = pcacov(X2);
variance_explanation2=cumsum(explained2);

figure
plot(latent2)
title('Lambda')

%Centered returns
for i=1:C
    cent_returns2(:,i)=returns2(:,i)-mean(returns2(:,i));
end

%Principal Componet on Centered returns
PC_cent=cent_returns2*pc2;

%We try to explain the returns of each stock using the first 19 PC.
exp=PC_cent(:,1:19)*pc2(:,1:19)';
for i=1:C
    explained_returns2(:,i)=exp(:,i)+mean(returns2(:,i));
end
name= {'ABN AMRO HOLDING' 'AEGON' 'AHOLD KON.' 'AIR LIQUIDE' 'ALCATEL' 'ALLIANZ' 'ALLIED IRISH BANKS' 'GENERALI' 'AXA' 'BASF' 'BAYER' 'BBV ARGENTARIA' 'BNC.SANTANDER' 'BNP PARIBAS' 'CARREFOUR' 'DAIMLERCHRYSLER' 'DEUTSCHE BANK' 'DEUTSCHE TELEKOM' 'E ON' 'ENDESA' 'ENEL' 'ENI' 'FORTIS' 'FRANCE TELECOM' 'DANONE' 'SOCIETE GENERALE' 'IBERDROLA' 'ING GROEP CERTS.' 'LOREAL' 'LAFARGE ' 'LVMH' 'MUNCH.RUCK.' 'NOKIA' 'PHILIPS ELTN.KON' 'RENAULT' 'REPSOL YPF' 'RWE' 'SAINT GOBAIN' 'SAN PAOLO IMI' 'SANOFI-AVENTIS' 'SAP' 'SIEMENS' 'SUEZ' 'TELECOM ITALIA' 'TELEFONICA' 'TOTAL' 'UNICREDITO ITALIANO' 'UNILEVER' 'VIVENDI UNIVERSAL'};

%Plot the explained returns vs the raw ones.
cumret_exp=cumprod(1+explained_returns2);
cumret2=cumprod(1+returns2);
figure
for i=1:16
    subplot(4,4,i)
    plot([cumret_exp(:,i),cumret2(:,i)])
    eval(strcat('title(''',char(name(i)),''')'));
end
figure
for i=1:16
    subplot(4,4,i)
    plot([cumret_exp(:,i+16),cumret2(:,i+16)])
    eval(strcat('title(''',char(name(i+16)),''')'));
end
figure
for i=1:16
    subplot(4,4,i)
    plot([cumret_exp(:,i+32),cumret2(:,i+32)])
    eval(strcat('title(''',char(name(i+32)),''')'));
end
%************************** END PART 2*****************************************



