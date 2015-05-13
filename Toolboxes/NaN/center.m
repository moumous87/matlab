function [i,S] = center(i,DIM)
% CENTER removes the mean 
%
% [z,mu] = center(x,DIM)
%   removes mean x along dimension DIM
%
% DIM	dimension
%	default or []: first DIMENSION, with more than 1 element
%
% features:
% - can deal with NaN's (missing values)
% - dimension argument 
% - compatible to Matlab and Octave
%
% see also: SUMSKIPNAN, MEAN, STD, DETREND, ZSCORE
%
% REFERENCE(S):

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
%    along with this program; If not, see <http://www.gnu.org/licenses/>.


%	$Id: center.m 4585 2008-02-04 13:47:45Z adb014 $
%	Copyright (C) 2000-2003,2005 by Alois Schloegl <a.schloegl@ieee.org>
%    	This is part of the NaN-toolbox. For more details see
%    	   http://www.dpmi.tu-graz.ac.at/~schloegl/matlab/NaN/
	

if any(size(i)==0); return; end;

if nargin>1,
        [S,N] = sumskipnan(i,DIM);
else
        [S,N] = sumskipnan(i);
end;

S     = S./N;
szi = size(i);
szs = size(S);
if length(szs)<length(szi);
        szs(length(szs)+1:length(szi)) = 1;
end;
i = i - repmat(S,szi./szs);		% remove mean
