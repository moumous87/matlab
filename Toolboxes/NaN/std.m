function [o,v]=std(x,opt,DIM)
% STD calculates the standard deviation.
% 
% [y,v] = std(x [, opt[, DIM]])
% 
% opt   option 
%	0:  normalizes with N-1 [default]
%		provides the square root of best unbiased estimator of the variance
%	1:  normalizes with N, 
%		this provides the square root of the second moment around the mean
% 	otherwise: 
%               best unbiased estimator of the standard deviation (see [1])      
%
% DIM	dimension
% 	N STD of  N-th dimension 
%	default or []: first DIMENSION, with more than 1 element
%
% y	estimated standard deviation
%
% features:
% - provides an unbiased estimation of the S.D. 
% - can deal with NaN's (missing values)
% - dimension argument also in Octave
% - compatible to Matlab and Octave
%
% see also: RMS, SUMSKIPNAN, MEAN, VAR, MEANSQ,
%
%
% References(s):
% [1] http://mathworld.wolfram.com/StandardDeviationDistribution.html


%    This program is free software; you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation; either version 2 of the License, or
%    (at your option) any later version.
%
%    This program is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with this program; if not, write to the Free Software
%    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

%	$Revision: 3442 $
%	$Id: std.m 3442 2007-03-23 16:14:46Z adb014 $
%	Copyright (C) 2000-2003, 2006 by Alois Schloegl <a.schloegl@ieee.org>	
%       This is part of the NaN-toolbox for Octave and Matlab 
%       see also: http://hci.tugraz.at/schloegl/matlab/NaN/       

if nargin<3,
	DIM = []; 
end;
if isempty(DIM), 
        DIM=min(find(size(x)>1));
        if isempty(DIM), DIM=1; end;
end;

[y,n] = sumskipnan(center(x,DIM).^2,DIM);

if nargin<2,
        opt = 0;
end;

if opt==0, 
        % square root if the best unbiased estimator of the variance 
        ib = inf;
        o  = sqrt(y./max(n-1,0));	% normalize
        
elseif opt==1, 
	ib = NaN;        
        o  = sqrt(y./n);

else
        % best unbiased estimator of the mean
        if exist('unique')==2, 
		% usually only a few n's differ
                [N,tmp,tix] = unique(n(:));	% compress n and calculate ib(n)
        	ib = sqrt(N/2).*gamma((N-1)./2)./gamma(N./2);	%inverse b(n) [1]
	        ib = ib(reshape(tix,size(y)));	% expand ib to correct size
                
        elseif exist('histo3')==2, 
		% usually only a few n's differ
                [N,tix] = histo3(n(:)); N = N.X;
                ib = sqrt(N/2).*gamma((N-1)./2)./gamma(N./2);	%inverse b(n) [1]
	        ib = ib(reshape(tix,size(y)));	% expand ib to correct size
                
        else	% gamma is called prod(size(n)) times 
                ib = sqrt(n/2).*gamma((n-1)./2)./gamma(n./2);	%inverse b(n) [1]
        end;	
        o  = sqrt(y./n).*ib;
end;

if nargout>1,
	v = y.*((max(n-1,0)./(n.*n))-1./(n.*ib.*ib)); % variance of the estimated S.D. ??? needs further checks
end;


