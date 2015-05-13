function [parameters nsfit]=nelson_siegel(Frac,DF)

% This function computes and plots the term structure of the spot and forward
% Euro rates. 
%INPUT:     date= a vector (Nx1) that includes the date which the discount
%                 factors have been computed in. The first 16 date will
%                 have the ACT/360 basis, while the remaining date the
%                 30/360 basis.
%           DF=   a vector of Discount Factor referred to the date in the vector date.
%
%OUTPUT:    NS_interp= a vector (Nx1) of the Nelson.Siegel spot curve
%                      interpolation.
%           parameters= the estimated parameters in the following order: 

%Compute the Year Fraction
% Fra1 = yearfrac(date(1,1)*ones(16,1), date(1:16,1), 2);
% Fra2 = yearfrac(date(1,1)*ones(size(date,1)-16,1), date(17:end,1), 1);   
% Frac=[Fra1;Fra2];

%Compute the Spot rate
spot_rate=-log(DF(2:end))./Frac(2:end);

%Inizialise the parameters
parameters0=[spot_rate(end);spot_rate(1)-spot_rate(end);0.0001;0.1];
options=optimset('LargeScale','off');
[x,fval,exitflag,output,grad]   = fminunc(@objfunction_ns,parameters0,options,Frac(2:end),spot_rate);
parameters=x;

%Construct the NS Curve
b0=parameters(1);
b1=parameters(2);
b2=parameters(3);
k=parameters(4);
N=size(spot_rate,1);

% Compute the NS interopolation
nsfit=ns(parameters,Frac(2:end));

%Plot the two curves
figure
plot(Frac(2:end), [spot_rate nsfit],'--d','MarkerSize',5);
title('Nelson-Siegel term structure interpolation');
h=legend('Spot rates','Nelson-Siegel rates',2);