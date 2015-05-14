%This function is a home-made panel regression model. The actual regression
%is based on the GLMFIT function (see the appropriate help). The syntax of
%the function is 
%
%           [b dev st]=panel(x,y,t)
%
%Where: b is the vector of the coefficients, dev is the deviance of the fit at
%the solution vector and stats is a structure with the fields as in GLMFIT.
%The requred inputs are x, the matrix of the independent variables, y, the
%vector of the dependent variable and t, the vector of the time indicators.

function [b dev st]=panel(x,y,t)

g=unique(t);

du=zeros(size(x,1),size(g,1)-1);

for i=1:size(du,2)
    du(t==g(i),i)=1;
end

[b dev st]=glmfit([x du], y);