clear all


%We upload Factors and Industry Indices Returns
fa=xlsread('Econ Data.xls','Factors','B2:k120');
db=xlsread('Econ Data.xls','Indices','B2:AW120');

%Number of factors and indices
nf=size(fa,2);
ni=size(db,2);

%We Initialize the empty matrices for the results
be=zeros(nf,ni);
res=zeros(size(db));

ris=zeros(nf+3,ni);

fv=cov(fa);

%We start a loop for the industry indices
for i=1:size(db,2)
    
    %We estimate the multifactor model
    [b,de,st]=glmfit(fa,db(:,i));    
    be(:,i)=b(2:end);
    res(:,i)=st.resid;
    
    ris(1:nf,i)=(be(:,i).^2).*diag(fv);
    ris(nf+1,i)=be(:,i)'*fv*be(:,i)-sum(ris(1:nf,i));
    ris(nf+2,i)=be(:,i)'*fv*be(:,i);
    ris(nf+3,i)=var(res(:,i));
    
    ris(:,i)=ris(:,i)./var(db(:,i));
end





%We save the results
xlswrite('Econ Data.xls',ris,'Variance','B2')
