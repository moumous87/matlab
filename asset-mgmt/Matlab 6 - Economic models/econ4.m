clear all


%We upload Factors and Industry Indices Returns
fa=xlsread('Econ Data.xls','Factors','B2:k120');
db=xlsread('Econ Data.xls','Indices','B2:AW120');

%Number of factors and indices
nf=size(fa,2);
ni=size(db,2);

%We choose the factor we want to maximize
mf=6;


%We chose the tolerance level for the betas of the "Other Factors"
to=0.05;




%We start a loop for the industry indices
for i=1:size(db,2)
    
    %We estimate the multifactor model
    [b,de,st]=glmfit(fa,db(:,i));    
    be(:,i)=b(2:end);
end


%We consider an equally weigthed Benchmark
ben=mean(db,2);
[bb,bde,bst]=glmfit(fa,ben);  
bbe=bb(2:end);




%We create a matrix with the "Other Factors" that we want to constrain
of=[be(1:mf-1,:);be(mf+1:end,:)];
ob=[bbe(1:mf-1,:);bbe(mf+1:end,:)];


%We calculate the tolerance level for the "Other Factors"
tl=to*abs(ob);


%we define the function to be minimized
f=-1.*be(mf,:);

%We build the constraint matrices
A=[of;-1*of];
B=[ob+tl;-1*(ob-tl)];


%We impose sum of the weights equal to one
aeq=ones(1,ni);
beq=1;


%We apply upper and lower bounds for the assets
lb=zeros(ni,1);
ub=ones(ni,1).*0.20;


%We include an equally weighted initial portfolio
x0=ones(ni,1)./ni;


%We find the optimal composition
x=linprog(f,A,B,aeq,beq,lb,ub,x0);


%We calculate the portfolio returns
por=db*x;



%We claculatethe diagnostics for the portfolio (see econ3.m)
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
xlswrite('Econ Data.xls',ris,'OptVar','B2')
xlswrite('Econ Data.xls',100.*[be sqrt(diag(fv)) sens] ,'OptVar','B18')


