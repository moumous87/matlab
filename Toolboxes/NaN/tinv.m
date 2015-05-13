function y = tinv(x,n);
% TINV returns inverse cumulative function of the student distribution
%
% x = tinv(p,v);
%
% Computes the quantile (inverse of the CDF) of a the student
%    cumulative distribution with mean m and standard deviation s
% p,v must be matrices of same size, or any one can be a scalar. 
%
% see also: TPDF, TCDF, NORMPDF, NORMCDF, NORMINV 

% Reference(s):

%	$Revision: 3442 $
%	$Id: tinv.m 3442 2007-03-23 16:14:46Z adb014 $
%	Version 1.28   Date: 13 Mar 2003
%	Copyright (C) 2000-2003 by Alois Schloegl <a.schloegl@ieee.org>	

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


% allocate output memory and check size of arguments
y = x+n-n;	% if this line causes an error, size of input arguments do not fit.
n = n+x-x;

y = norminv(x); % do special cases, like x<=0, x>=1, isnan(x), n > 10000;
y(~(n>0)) = NaN; 

ix = find(~isnan(x) & (n>0) & (n<10000));
if ~isempty(ix)
        y(ix) = (sign(x(ix) - 1/2).*sqrt(n(ix)./betainv(2*min(x(ix), 1-x(ix)), n(ix)/2, 1/2) - n(ix)));
end;

y = reshape(y,size(x));

