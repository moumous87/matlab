function p = tcdf(x,n);
% TCDF returns student cumulative distribtion function
%
% cdf = tcdf(x,DF);
%
% Computes the CDF of the students distribution 
%    with DF degrees of freedom 
% x,DF must be matrices of same size, or any one can be a scalar. 
%
% see also: NORMCDF, TPDF, TINV 

% Reference(s):

%	$Id: tcdf.m 5301 2008-09-17 07:26:18Z schloegl $
%	Copyright (C) 2000-2003 by Alois Schloegl <a.schloegl@ieee.org>	
%    	This is part of the NaN-toolbox. For more details see
%    	   http://www.dpmi.tu-graz.ac.at/~schloegl/matlab/NaN/

%    This program is free software; you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation; either version 3 of the License, or
%    (at your option) any later version.
%
%    This program is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with this program; If not, see <http://www.gnu.org/licenses/>.


% check size of arguments
n = x+n-x;	  % if this line causes an error, size of input arguments do not fit. 
z = n ./ (n + x.^2);

% allocate memory
p = z;
p(x==Inf) = 1;

% workaround for invalid arguments in BETAINC
tmp   = isnan(z) | ~(n>0);
p(tmp)= NaN;
ix    = (~tmp);
p(ix) = betainc (z(ix), n(ix)/2, 1/2) / 2;

ix    = find(x>0);
p(ix) = 1 - p(ix);

% shape output
p = reshape(p,size(z));


