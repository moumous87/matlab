function cv=coefficient_of_variation(i,DIM)
% COEFFICIENT_OF_VARIATION returns STD(X)/MEAN(X)
% 
% cv=coefficient_of_variation(x [,DIM])
%  cv=std(x)/mean(x) 
%
% see also: SUMSKIPNAN, MEAN, STD
%
%   REFERENCE(S):
%   http://mathworld.wolfram.com/VariationCoefficient.html

%	$Revision: 3442 $
%	$Id: coefficient_of_variation.m 3442 2007-03-23 16:14:46Z adb014 $
%	Version 1.28   Date: 13 Mar 2003
%	Copyright (C) 1997-2003 by Alois Schloegl <a.schloegl@ieee.org>	

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


if nargin<2,
        DIM=min(find(size(i)>1));
        if isempty(DIM), DIM=1; end;
end;

[S,N,SSQ] = sumskipnan(i,DIM);

% sqrt((SSQ-S.*S./N)./max(N-1,0))/(S./N);    % = std(i)/mean(i)

cv = sqrt(SSQ.*N./(S.*S)-1);

%if flag_implicit_unbiased_estim,
	cv = cv.*sqrt(N./max(N-1,0));
%end;
