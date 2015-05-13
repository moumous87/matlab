function r = ranks(X,DIM,Mode);
% RANKS gives the rank of each element in a vector.
% This program uses an advanced algorithm with averge effort O(m.n.log(n)) 
% NaN in the input yields NaN in the output.
% 
% r = ranks(X[,DIM])
%   if X is a vector, return the vector of ranks of X adjusted for ties.
%   if X is matrix, the rank is calculated along dimension DIM. 
%   if DIM is zero or empty, the lowest dimension with more then 1 element is used. 
% r = ranks(X,DIM,'traditional')
%   implements the traditional algorithm with O(n^2) computational 
%   and O(n^2) memory effort
% r = ranks(X,DIM,'mtraditional')
%   implements the traditional algorithm with O(n^2) computational 
%   and O(n) memory effort
% r = ranks(X,DIM,'advanced   ')
%   implements an advanced algorithm with O(n*log(n)) computational 
%   and O(n.log(n)) memory effort
%
% see also: CORRCOEF, SPEARMAN, RANKCORR
%
% REFERENCES:
% --


%    $Id: ranks.m 3442 2007-03-23 16:14:46Z adb014 $
%    Copyright (C) 2000-2002,2005 by Alois Schloegl <a.schloegl@ieee.org>	
%    This script is part of the NaN-toolbox
%    http://www.dpmi.tu-graz.ac.at/~schloegl/matlab/NaN/

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

% Features:
% + is fast, uses an efficient algorithm for the rank correlation
% + computational effort is O(n.log(n)) instead of O(n^2)
% + memory effort is O(n.log(n)), instead of O(n^2). 
%     Now, the ranks of 8000 elements can be easily calculated
% + NaN's in the input yield NaN in the output 
% + compatible with Octave and Matlab
% + traditional method is also implemented for comparison. 


if nargin<2, DIM = 0; end;
if ischar(DIM),
	Mode= DIM; 
	DIM = 0; 
elseif (nargin<3), 
	Mode = '';
end; 
if isempty(Mode),
	Mode='advanced   '; 
end;

sz = size(X);
if (~DIM)
	 [tmp,DIM] = min(find(sz>1));
end;	 
[N,M] = size(X);
if (DIM==2),
        X = X';
	[N,M] = size(X);
end; 

if strcmp(Mode(1:min(11,length(Mode))),'traditional'), % traditional, needs O(m.n^2)
% this method was originally implemented by: KH <Kurt.Hornik@ci.tuwien.ac.at>
% Comment of KH: This code is rather ugly, but is there an easy way to get the ranks adjusted for ties from sort?

r = zeros(size(X));
        for i = 1:M;
                p = X(:, i(ones(1,N)));
                r(:,i) = [(sum (p < p') + (sum (p == p') + 1) / 2)'];
        end;
        % r(r<1)=NaN;
        
elseif strcmp(Mode(1:min(12,length(Mode))),'mtraditional'), % advanced
        % + memory effort is lower
        
	r = zeros(size(X));
        for k = 1:N;
        for i = 1:M;
                r(k,i) = [(sum (X(:,i) < X(k,i)) + (sum (X(:,i)  == X(k,i)) + 1) / 2)];
        end;
        end;
        % r(r<1)=NaN;
        
elseif strcmp(Mode(1:min(11,length(Mode))),'advanced   '), % advanced
        % + uses sorting, hence needs only O(m.n.log(n)) computations         
        
        % [tmp,ix] = sort([X,Y]);     
        % [tmp,r] = sort(ix);     % r yields rank. 
        % but because sort does not work accordingly for cell arrays, 
        % and DIM argument not supported by Octave 
        % and DIM argument does not work for cell-arrays in Matlab
        % we sort each column separately:
        
        r = zeros(size(X));
        n = N;
        for k = 1:M,
                [sX,ix] = sort(X(:,k)); 
                [tmp,r(:,k)] = sort(ix);	    % r yields the rank of each element 	
                
                % identify multiple occurences (not sure if this important, but implemented to be compatible with traditional version)
                if isnumeric(X)
                        n=sum(~isnan(X(:,k)));
                end;
                x = [0;find(sX~=[sX(2:N);n])];    % for this reason, cells are not implemented yet.   
                d = find(diff(x)>1);
                
                % correct rank of multiple occurring elements
                for l = 1:length(d),
                        t = (x(d(l))+1:x(d(l)+1))';
                        r(ix(t),k) = mean(t);
                end;
        end;
        tmp = version;
	if str2num(tmp(1))*1000+str2num(tmp(3))*100+str2num(tmp(5))*10<2020,
                for k1=1:size(X,1),
                        for k2=1:size(X,2),	% needed for 2.0.17 
                                if isnan(X(k1,k2)), 
                                        r(k1,k2) = nan;
                                end;
                        end;
                end;
        else
                r(isnan(X)) = nan;
        end;
        
elseif strcmp(Mode,'=='), 
% the results of both algorithms are compared for testing.    
%
% if the Mode-argument is omitted, both methods are applied and 
% the results are compared. Once the advanced algorithm is confirmed, 
% it will become the default Mode. 

        r  = ranks(X,'advanced   ');
        r(isnan(r)) = 1/2;
        
        if N>100,
	        r1 = ranks(X,'mtraditional');  % Memory effort is lower 
        else
                r1 = ranks(X,'traditional');
        end;
        if ~all(all(r==r1)),
                fprintf(2,'WARNING RANKS: advanced algorithm does not agree with traditional one\n Please report to <a.schloegl@ieee.org>\n');
                r = r1;
        end;
        r(isnan(X)) = nan;
end;

if (DIM==2)
	r=r';
end;	
