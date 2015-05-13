function p = tpdf(x,n);
% TPDF returns student probability density 
%
% pdf = tpdf(x,DF);
%
% Computes the PDF of a the student distribution 
%    with DF degreas of freedom
% x,DF must be matrices of same size, or any one can be a scalar. 
%
% see also: TINV, TCDF, NORMPDF, NORMCDF, NORMINV 

% Reference(s):

%	$Revision: 4510 $
%	$Id: tpdf.m 4510 2008-01-17 13:17:59Z schloegl $
%	Copyright (C) 2000-2003,2008 by Alois Schloegl <a.schloegl@ieee.org>	

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

% allocate memory and check size of arguments
p = x+n;	  % if this line causes an error, size of input arguments do not fit. 
ix = (n>0) & (n~=inf) & ~isnan(x); 

% make size of x and n equal
n = x+n-x;
x = x+n-n;

% workaround for invalid arguments in BETA
if any(ix)
p(ix) = (exp (-(n(ix)+1).*log(1+x(ix).^2./n(ix))/2) ./ (sqrt(n(ix)).* beta(n(ix)/2, 1/2)));
end; 
p(~ix)= NaN;

% shape output
p = reshape(p,size(x));
