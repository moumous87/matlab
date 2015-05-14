clear all


%We upload Factors and Industry Indices Returns
fa=xlsread('Econ Data.xls','Factors','B2:k120');
db=xlsread('Econ Data.xls','Indices','B2:AW120');

%We consider an equally weigthed Benchmark
ben=mean(db,2);

%We consider an Initial Portfolio that is equally weighted in the first 5
%industries
por=mean(db(:,1:5),2);

%Number of factors and indices
nf=size(fa,2);
ni=size(db,2);


%We estimate the model for Benchmark and Portfolio
[bb,bde,bst]=glmfit(fa,ben);    

[pb,pde,pst]=glmfit(fa,por); 


%We calculate the Tracking Portfolio
tb=pb-bb;

be=[pb(2:end) bb(2:end) tb(2:end)];

res=[pst.resid bst.resid pst.resid-bst.resid];

ts=[por ben por-ben];

ris=zeros(nf+3,3);
sens=zeros(nf,3);
fv=cov(fa);

for i=1:3
    
    ris(1:nf,i)=(be(:,i).^2).*diag(fv);
    ris(nf+1,i)=be(:,i)'*fv*be(:,i)-sum(ris(1:nf,i));
    ris(nf+2,i)=be(:,i)'*fv*be(:,i);
    ris(nf+3,i)=var(res(:,i));
    ris(:,i)=ris(:,i)./var(ts(:,i));
    sens(:,i)=be(:,i).*sqrt(diag(fv));
end



%We save the results
xlswrite('Econ Data.xls',ris,'PortVar','B2')
xlswrite('Econ Data.xls',100.*[be sqrt(diag(fv)) sens] ,'PortVar','B18')
