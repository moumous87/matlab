% Matrix Algebra

% Basic Exercises
A=[4,2,3;2,4,2;3,2,8];
[X,latent] = pcacov(A);
Lambdas=diag(latent);
I=X*X';
Lambdas_1=X*A*X';

% Upload data
data=xlsread('data.xls');

% Covariance matrix
VarCov=cov(data);

%Spectral decomposition
[Eigenvector,Eigenvalue] = pcacov(VarCov);

%Construction of PC
P=data*Eigenvector;

%Covariance matrix of PC
VarCov_pc=cov(P);

