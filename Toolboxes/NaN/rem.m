function [z,e] = rem(x,y)
% REM calculates remainder of X / Y  
%
%     z = x - y * fix(x/y);
%     e = eps * fix(x/y);
%
%    [z,e] = REM(X,Y)
%	z is the remainder of X / Y
%	e is the error tolerance, for checking the accuracy
%		z(e > abs(y)) is not defined 
%
% 	z has always the same sign than x	
% 
% see also: MOD

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

%       $Revision: 3442 $
%       $Id: rem.m 3442 2007-03-23 16:14:46Z adb014 $
%	Copyright (C) 2004 by Alois Schloegl <a.schloegl@ieee.org>	
%       This function is part of the NaN-toolbox
%       http://www.dpmi.tu-graz.ac.at/~schloegl/matlab/NaN/



%s = warning;
%warning('off');

if all(size(x)==1)
        x = repmat(x,size(y));
end;
if all(size(y)==1)
        y = repmat(y,size(x));
end;
if any(size(x)~=size(y)),
        fprintf(2,'Error REM: size if input arguments do not fit.\n');
	return;
end;

t = fix(x./y);
z = x - y.*t;

z(~t) = x(~t);		% remainder is x if y = inf
z(~y) = 0;		% remainder must be 0 if y==0

%warning(s);		% reset warning status

if nargout > 1,
        e = (abs(t)*eps);	% error interval 
        %z(e > abs(y)) = NaN;	% uncertainty of rounding error to large
end;



