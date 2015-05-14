clear all


%We upload Factors and Industry Indices Returns
fa=xlsread('Econ Data.xls','Factors','B2:k120');
db=xlsread('Econ Data.xls','Indices','B2:AW120');

%We Initialize the empty matrices for the results
ris=zeros(2*size(fa,2)+1,size(db,2));
res=zeros(size(db));


%We start a loop for the industry indices
for i=1:size(db,2)
    
    %We estimate the multifactor model
    [b,de,st]=glmfit(fa,db(:,i));
    
    for j=1:size(fa,2)
        ris(2*j-1,i)=b(j+1);
        ris(2*j,i)=st.p(j+1);
    end
    
    ris(2*size(fa,2)+1,i)=1-(var(st.resid)/var(db(:,i)));
    res(:,i)=st.resid;
end


%We plot the distribution of the R-Squared
figure
hist(ris(end,:))
title('R-Squared Didstribution')
grid on


%We claculatethe correlation among the residuals
rescor=corrcoef(res);


%We save the results
xlswrite('Econ Data.xls',ris,'Betas','B3')
xlswrite('Econ Data.xls',res,'Residuals','B2')
xlswrite('Econ Data.xls',rescor,'ResCorr','B2')