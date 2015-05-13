function [SE,M]=sem(x,DIM)
% SEM calculates the standard error of the mean
% 
% [SE,M] = SEM(x [, DIM])
%   calculates the standard error (SE) in dimension DIM
%   the default DIM is the first non-single dimension
%   M returns the mean. 
%   Can deal with complex data, too. 
%
% DIM	dimension
%	1: SEM of columns
%	2: SEM of rows
% 	N: SEM of  N-th dimension 
%	default or []: first DIMENSION, with more than 1 element
%
% features:
% - can deal with NaN's (missing values)
% - dimension argument 
% - compatible to Matlab and Octave
%
% see also: SUMSKIPNAN, MEAN, VAR, STD

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

%	Copyright (C) 2000-2003 by Alois Schloegl <a.schloegl@ieee.org>	
%	$Revision: 3442 $
%	$Id: sem.m 3442 2007-03-23 16:14:46Z adb014 $


if nargin>1,
	[S,N,SSQ] = sumskipnan(x,DIM);
else    
	[S,N,SSQ] = sumskipnan(x);
end

M  = S./N;
SE = (SSQ.*N - real(S).^2 - imag(S).^2)./(N.*N.*(N-1)); 
SE(SE<=0) = 0; 	% prevent negative value caused by round-off error  
SE = sqrt(real(SE));

