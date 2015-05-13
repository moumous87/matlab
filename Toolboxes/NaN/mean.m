function [y]=mean(x,DIM,opt)
% MEAN calculates the mean of data elements. 
% 
%  y = mean(x [,DIM] [,opt])
%
% DIM	dimension
%	1 MEAN of columns
%	2 MEAN of rows
% 	N MEAN of  N-th dimension 
%	default or []: first DIMENSION, with more than 1 element
%
% opt	options 
%	'A' arithmetic mean
%	'G' geometric mean
%	'H' harmonic mean
%
% Any combination between opt and DIM is possible. e.g. 
%   y = mean(x,2,'G')
%   calculates the geometric mean of each row in x. 
%
% features:
% - can deal with NaN's (missing values)
% - dimension argument also in Octave
% - compatible to Matlab and Octave
%
% see also: SUMSKIPNAN, MEAN, GEOMEAN, HARMMEAN
%

%	$Id: mean.m 5301 2008-09-17 07:26:18Z schloegl $
%	Copyright (C) 2000-2004,2008 by Alois Schloegl <a.schloegl@ieee.org>	
%    	This is part of the NaN-toolbox. For more details see
%    	   http://www.dpmi.tu-graz.ac.at/~schloegl/matlab/NaN/
%
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

if nargin<2
        DIM=[]; 
        opt='a';
end
if (nargin<3)
        %if ~isnumeric(DIM), %>=65;%abs('A'), 
        if (DIM>64) %abs('A'), 
                opt=DIM;
                DIM=[]; 
        else
                opt='a';
        end;	
else 
        %if ~isnumeric(DIM), %>=65;%abs('A'), 
        if (DIM>64) %abs('A'), 
                tmp=opt;
                opt=DIM;
                DIM=tmp;
        end;
end;	

opt = upper(opt); % eliminate old version 

if  (opt == 'A')
	[y, n] = sumskipnan(x,DIM);
        y = y./n;
elseif (opt == 'G')
	[y, n] = sumskipnan(log(x),DIM);
    	y = exp (y./n);
elseif (opt == 'H')
	[y, n] = sumskipnan(1./x,DIM);
    	y = n./y;
else
    	fprintf (2,'mean:  option `%s` not recognized', opt);
end 

