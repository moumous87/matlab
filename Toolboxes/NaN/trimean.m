function y=trimean(x,DIM)
% TRIMEAN evaluates basic statistics of a data series
%    m = TRIMEAN(y).
%
% The trimean is  m = (Q1+2*MED+Q3)/4
%    with quartile Q1 and Q3 and median MED   
%
% N-dimensional data is supported
% 
% REFERENCES:
% [1] http://mathworld.wolfram.com/Trimean.html


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
%	$Id: trimean.m 3442 2007-03-23 16:14:46Z adb014 $
%	Copyright (C) 1996-2003 by Alois Schloegl <a.schloegl@ieee.org>	


% check dimension
sz=size(x);

% find the dimension
if nargin==1,
        DIM=min(find(sz>1));
        if isempty(DIM), DIM=1; end;
end;

if DIM>length(sz),
        sz = [sz,ones(1,DIM-length(sz))];
end;

D1 = prod(sz(1:DIM-1));
%D2 = sz(DIM);
D3 = prod(sz(DIM+1:length(sz)));
D0 = [sz(1:DIM-1),1,sz(DIM+1:length(sz))];
y  = repmat(nan,D0);
q  = repmat(nan,3,1);
for k = 0:D1-1,
for l = 0:D3-1,
        xi = k + l * D1*sz(DIM) + 1 ;
        xo = k + l * D1 + 1;
        t = x(xi+(0:sz(DIM)-1)*D1);
        t = sort(t(~isnan(t)));
        t = t(:);
	n = length(t); 
	
        
        % q = flix(t,x); 	% The following find the quartiles and median.
        			% INTERP1 is not an alternative since it fails for n<2;
        x  = n*[0.25;0.50;0.75] + [0.75;0.50;0.25]; 
	k  = x - floor(x);	% distance to next sample	 

        t  = t(:);
	ix = ~logical(k);     	% find integer indices
	q(ix) = t(x(ix)); 	% put integer indices
	ix = ~ix;	     	% find non-integer indices
	q(ix) = t(floor(x(ix))).*(1-k(ix)) + t(ceil(x(ix))).*k(ix);  
        
        y(xo) = (q(1) + 2*q(2) + q(3))/4;
end;
end;

