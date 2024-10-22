function Q=percentile(Y,q,DIM)
% PERCENTILE calculates the percentiles of histograms and sample arrays.  
%
%  Q = percentile(Y,q)      
%  Q = percentile(Y,q,DIM)      
%     returns the q-th percentile along dimension DIM of sample array Y.
%     size(Q) is equal size(Y) except for dimension DIM which is size(Q,DIM)=length(Q)
%
%  Q = percentile(HIS,q)
%     returns the q-th percentile from the histogram HIS. 
%     HIS must be a HISTOGRAM struct as defined in HISTO2 or HISTO3.
%     If q is a vector, the each row of Q returns the q(i)-th percentile 
%
% see also: HISTO2, HISTO3, QUANTILE

%	$Id: percentile.m 3937 2007-08-28 10:16:07Z schloegl $
%	Copyright (C) 1996-2003,2005,2006,2007 by Alois Schloegl <a.schloegl@ieee.org>	
%       This function is part of the NaN-toolbox
%       http://www.dpmi.tu-graz.ac.at/~schloegl/matlab/NaN/

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


if nargin==2,
	Q = quantile(Y,q/100); 

elseif nargin==3,
	Q = quantile(Y,q/100,DIM); 

else
	help percentile

end;



