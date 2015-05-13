function y=var(x,opt,DIM)
% VAR calculates the variance.
% 
% y = var(x [, opt[, DIM]])
%   calculates the variance in dimension DIM
%   the default DIM is the first non-single dimension
%
% opt   0: normalizes with N-1 [default}
%	1: normalizes with N 
% DIM	dimension
%	1: VAR of columns
%	2: VAR of rows
% 	N: VAR of  N-th dimension 
%	default or []: first DIMENSION, with more than 1 element
%
% features:
% - can deal with NaN's (missing values)
% - dimension argument 
% - compatible to Matlab and Octave
%
% see also: MEANSQ, SUMSQ, SUMSKIPNAN, MEAN, RMS, STD,

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
%	$Id: var.m 3442 2007-03-23 16:14:46Z adb014 $
%	Copyright (C) 2000-2003,2006 by Alois Schloegl <a.schloegl@ieee.org>

if nargin>1,
        if ~isempty(opt) & opt~=0, 
                fprintf(2,'Warning STD: OPTION not supported.\n');
        end;
else 
        opt = 0; 
end;

if nargin<3,
	DIM = []; 
end;
if isempty(DIM), 
        DIM=min(find(size(x)>1));
        if isempty(DIM), DIM=1; end;
end;

[y,n] = sumskipnan(center(x,DIM).^2,DIM);

if (opt~=1)
    	n = max(n-1,0);			% in case of n=0 and n=1, the (biased) variance, STD and STE are INF
end;
y = y./n;	% normalize

