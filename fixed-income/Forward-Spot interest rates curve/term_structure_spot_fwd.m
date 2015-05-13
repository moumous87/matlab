function [spot_rate fwd_rate]=term_structure_spot_fwd(date,DF)

% This function computes and plots the term structure of the spot and forward
% Euro rates. 
%INPUT:     date= a vector (Nx1) that includes the date which the discount
%                 factors have been computed in. The first 16 date will
%                 have the ACT/360 basis, while the remaining date the
%                 30/360 basis.
%           DF=   a vector of Discount Factor referred to the date in the vector date.
%
%OUTPUT:    spot_rate= a vector (Nx1) of related spot rates
%           fwd_rate = a vector (Nx1) of related forward rates



%Compute the Year Fraction
Fra1 = yearfrac(date(1,1)*ones(16,1), date(1:16,1), 2);
Fra2 = yearfrac(date(1,1)*ones(size(date,1)-16,1), date(17:end,1), 1);   
Frac=[Fra1;Fra2];

%Compute the Spot and fwd rate
spot_rate=-log(DF)./Frac;
fwd_rate=-365*(log(DF(3:end)./DF(2:end-1))./(date(3:end)-date(2:end-1)));

%Plot the curves
figure
plot([spot_rate(2:end-1) fwd_rate],'--d','MarkerSize',5)
title('Spot and Forward rates');
h=legend('Spot rates','Forward rates',2);

