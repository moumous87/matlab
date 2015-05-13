function [y]=median(x,DIM)
% MEDIAN data elements, 
% [y]=median(x [,DIM])
%
% DIM	dimension
%	1: median of columns
%	2: median of rows
% 	N: median of  N-th dimension 
%	default or []: first DIMENSION, with more than 1 element
%
% features:
% - can deal with NaN's (missing values)
% - accepts dimension argument like in Matlab in Octave, too. 
% - compatible to Matlab and Octave 
%
% see also: SUMSKIPNAN
 
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
%	$Id: median.m 3442 2007-03-23 16:14:46Z adb014 $
%	Copyright (C) 2000-2003 by Alois Schloegl <a.schloegl@ieee.org>	

% check dimension of x
sz=size(x);

% find the dimension for median
if nargin<2,
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
for k = 0:D1-1,
for l = 0:D3-1,
        xi = k + l * D1*sz(DIM) + 1 ;
        xo = k + l * D1 + 1;
        t = x(xi+(0:sz(DIM)-1)*D1);
        t = sort(t(~isnan(t)));
        n = length(t); 
        
        if n==0,
                y(xo) = nan;
        elseif ~rem(n,2),
                y(xo) = (t(n/2) + t(n/2+1)) / 2;
        elseif rem(n,2),
                y(xo) = t((n+1)/2);
        end;
end;
end;
