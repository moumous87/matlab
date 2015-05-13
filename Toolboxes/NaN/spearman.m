function r = spearman(x,y)
% SPEARMAN Spearman's rank correlation coefficient.
% This function is replaced by CORRCOEF. 
% Significance test and confidence intervals can be obtained from CORRCOEF. 
%
% [R,p,ci1,ci2] = CORRCOEF(x, [y, ] 'Rank');
%
% For some (unknown) reason, in previous versions Spearman's rank correlation  
%   r = corrcoef(ranks(x)). 
% But according to [1], Spearman's correlation is defined as 
%   r = 1-6*sum((ranks(x)-ranks(y)).^2)/(N*(N*N-1))
% The results are different. Here, the later version is implemented. 
%
% see also: CORRCOEF, RANKCORR
%
% REFERENCES:
% [1] http://mathworld.wolfram.com/SpearmanRankCorrelationCoefficient.html
% [2] http://mathworld.wolfram.com/CorrelationCoefficient.html

%    Version 1.27  Date: 12 Aug 2002
%    Copyright (C) 2000-2002 by Alois Schloegl <a.schloegl@ieee.org>	

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


% warning('SPEARMAN might become obsolete; use CORRCOEF(...,''Spearman'') instead');

if nargin < 2
   r = corrcoef(x,'Spearman');
else
   r = corrcoef(x,y,'Spearman');
end
