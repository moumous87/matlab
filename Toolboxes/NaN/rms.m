function o=rms(i,DIM)
% RMS calculates the root mean square
%   can deal with complex data. 
%
% y = rms(x,DIM)
%
% DIM	dimension
%	1 STD of columns
%	2 STD of rows
% 	N STD of  N-th dimension 
%	default or []: first DIMENSION, with more than 1 element
%
% features:
% - can deal with NaN's (missing values)
% - dimension argument also in Octave
% - compatible to Matlab and Octave
%
% see also: SUMSKIPNAN, MEAN


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
%	$Id: rms.m 3442 2007-03-23 16:14:46Z adb014 $


i = real(i).^2 + imag(i).^2;

if nargin<2,
	[o,N] = sumskipnan(i);
else
	[o,N] = sumskipnan(i,DIM);
end;

o = sqrt(o./N);
   
   