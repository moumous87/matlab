function [handles,nd,sy]=npplot(y,s);
%NPPLOT Plots a normal probability plot of  y.
%USE: [handles,nd,sy]=npplot(y,s)  plots a normal probability plot of  y.
%   where  y  is the data;
%          s  takes on the value 1 if the normal prob plot is
%             to contain a line indicating the standard normal distribution.
%             It takes on the value 0 to plot a line corresponding to
%             a normal distribution with the same mean and variance as the data.
%             BY DEFAULT, s=0 (a line with same mean and variance).
%           handle  is the handle for the points;
%           nd  is the normal quantiles;
%           sy  is the data quantiles.

%Copyright 1996, 1997 Peter Dunn
%13 August 1997
if nargin==1, s=0; end;

sy = sort(y);
nd = invnorm( (1:length(y))/(length(y)+1) );
handle1 = plot(nd,sy,'+');

xlabel('Standard Normal Deviate');
ylabel('Data');
title('Normal Probability Plot');

%add N(0,1) line
zx=[-3.5 0 3.5]; %fixed x-points
if s==1,
   hold on; 
   cfplot=plot(zx,zx,'r--');
   hold off;
   [ lhand ] = legend(cfplot,'Standard Normal',4);
else
   hold on; 
   cfplot=plot(zx,mean(y)+zx*std(y),'r--'); 
   hold off;
   [ lhand ] = legend(cfplot,...
                      'Normal Distribution (same mean, variance)',4);
end;
nd=nd(:);
sy=sy(:);

handles = [handle1, lhand];
