clear all


eto=xlsread('Diagnostics.xls','Top');
ebo=xlsread('Diagnostics.xls','Bottom');
ebe=xlsread('Diagnostics.xls','Bench');
cto=xlsread('Diagnostics.xls','CTop');
cbo=xlsread('Diagnostics.xls','CBottom');
    
%We start by calculating mean returns
eri(1,:)=mean(eto);
eri(2,:)=mean(ebo);
eri(3,:)=mean(ebe);

%We calculate standard deviations
eri(4,:)=std(eto);
eri(5,:)=std(ebo);
eri(6,:)=std(ebe);

%We can now calculate the risk reward ratios
eri(7,:)=mean(eto)./std(eto);
eri(8,:)=mean(ebo)./std(ebo);
eri(9,:)=mean(ebe)./std(ebe);

%We calculate the diagnostics for the spread portfolio
eri(10,:)=mean(eto-ebo);
eri(11,:)=std(eto-ebo);
eri(12,:)=mean(eto-ebo)./std(eto-ebo);

%We calculate the diagnostics for the active top portfolio
eri(13,:)=mean(eto-ebe);
eri(14,:)=std(eto-ebe);
eri(15,:)=mean(eto-ebe)./std(eto-ebe);

%We can now move to a non parametric approach

%We calculate the worst returns   
eri(16,:)=min(eto);
eri(17,:)=min(eto-ebo);
eri(18,:)=min(eto-ebe);

%We calculate the percentage of positive returns
eri(19,:)=sum(sign(max(0,eto)))./size(eto,1);
eri(20,:)=sum(sign(max(0,eto-ebo)))./size(eto,1);
eri(21,:)=sum(sign(max(0,eto-ebe)))./size(eto,1);

%We calculate the mean consistency
eri(22,:)=mean(cto);
eri(23,:)=mean(cbo);
    
xlswrite('Diagnostics.xls',eri,'Diagnostics','B2')


%We calculate the correlations among the top portfolio returns
eco1=corrcoef(eto);
eco2=corrcoef(eto-ebo);

xlswrite('Diagnostics.xls',eco1,'TopCorr','B2')
xlswrite('Diagnostics.xls',eco2,'SprCorr','B2')
