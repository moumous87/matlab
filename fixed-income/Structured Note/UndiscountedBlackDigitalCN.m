function [und_value]=UndiscountedBlackDigitalCN(phi,Fwdrate,Caprate,Vol,OptionMat,tenor)

% The Black formula for pricing asset or nothing digitals
%CAUTION: NEED TO DISCOUNT AND MULTIPLY BY NOMINAL TO GET DIGITAL PRICE
% INPUT:
%       Phi: logical value: phi=1 for call (F>K) and phi=-1 for put (F<K)
%       Fwdrate: a vector of annual forward rates;
%       Caprate: a value of the Stike Price (annual rate);
%       Vol:     a vector vith volatility values;
%       OptionMat:  a vector of time fractions;
%       tenor:   a vector with the tenor values;
%OUTPUT:
%       und_value: a vector with undiscounted value of Cash or Nothing digital option.


% Adjust the volatility for the maturity
volsqrt=Vol.*sqrt(OptionMat);

% Compute D1 and D2
D1=(log(Fwdrate/Caprate)+(Vol.^2).*OptionMat/2)./volsqrt;
D2=D1-volsqrt;

%Undiscounted value
und_value=Caprate*normcdf(phi*D2,0,1).*tenor;






