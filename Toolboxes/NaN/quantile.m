function Q=quantile(Y,q,DIM)
% QUANTILE calculates the quantiles of histograms and sample arrays.  
%
%  Q = quantile(Y,q)
%  Q = quantile(Y,q,DIM)
%     returns the q-th quantile along dimension DIM of sample array Y.
%     size(Q) is equal size(Y) except for dimension DIM which is size(Q,DIM)=length(Q)
%
%  Q = quantile(HIS,q)
%     returns the q-th quantile from the histogram HIS. 
%     HIS must be a HISTOGRAM struct as defined in HISTO2 or HISTO3.
%     If q is a vector, the each row of Q returns the q(i)-th quantile 
%
% see also: HISTO2, HISTO3, PERCENTILE


%	$Id: quantile.m 3936 2007-08-28 10:15:32Z schloegl $
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

if nargin<3,
        DIM = [];
end;
if isempty(DIM),
        DIM = min(find(size(Y)>1));
        if isempty(DIM), DIM = 1; end;
end;


if nargin<2,
	help quantile
        
else
        SW = isstruct(Y);
        if SW, SW = isfield(Y,'datatype'); end;
        if SW, SW = strcmp(Y.datatype,'HISTOGRAM'); end;
        if SW,                 
                [yr,yc]=size(Y.H);
                Q = repmat(nan,length(q),yc);
                if ~isfield(Y,'N');
                        Y.N = sum(Y.H,1);
                end;
                
                for k1 = 1:yc,
                        tmp = Y.H(:,k1)>0;
                        h = full(Y.H(tmp,k1));
                        t = Y.X(tmp,min(size(Y.X,2),k1));

			N = Y.N(k1);  
			t2(1:2:2*length(t)) = t;
			t2(2:2:2*length(t)) = t;
			x2 = cumsum(h); 
			x(1)=0; 
			x(2:2:2*length(t)) = x2;
			x(3:2:2*length(t)) = x2(1:end-1);
                        for k2 = 1:length(q),
				if (q(k2)<0) | (q(k2)>1) 	
					Q(k2,k1) = NaN;  
				elseif 	q(k2)==0,
					Q(k2,k1) = t2(1);  	
				elseif 	q(k2)==1,
					Q(k2,k1) = t2(end);  	
				else 	
					n=1;
					while (q(k2)*N > x(n)), 
						n=n+1; 
					end; 			

					if q(k2)*N==x(n)
						% mean of upper and lower bound 
						Q(k2,k1) = (t2(n)+t2(n+1))/2;
					else
						Q(k2,k1) = t2(n);
					end; 
                                end; 
                        end
                end;


        elseif isnumeric(Y),
		sz = size(Y);
		if DIM>length(sz),
		        sz = [sz,ones(1,DIM-length(sz))];
		end;

		D1 = prod(sz(1:DIM-1));
		D3 = prod(sz(DIM+1:length(sz)));
		Q  = repmat(nan,[sz(1:DIM-1),length(q),sz(DIM+1:length(sz))]);
		for k = 0:D1-1,
		for l = 0:D3-1,
		        xi = k + l * D1*sz(DIM) + 1 ;
			xo = k + l * D1*length(q) + 1;
		        t  = Y(xi:D1:xi+D1*sz(DIM)-1);
		        t  = sort(t(~isnan(t)));
		        N  = length(t); 
			
			t2(1:2:2*length(t)) = t; 
			t2(2:2:2*length(t)) = t;
			x=floor([1:2*length(t)]/2);
			for k2=1:length(q)
				if (q(k2)<0) | (q(k2)>1) 	
					f(k2) = NaN;  
				elseif 	q(k2)==0	
					f(k2) = t2(1);  	
				elseif 	q(k2)==1,
					f(k2) = t2(end);  	
				else 	
					n=1;
					while (q(k2)*N > x(n)),
						n = n+1;
					end;

					if q(k2)*N==x(n)
						% mean of upper and lower bound 
						f(k2) = (t2(n) + t2(n+1))/2;   
					else
						f(k2) = t2(n);
					end; 
				end; 		
			end;
			Q(xo:D1:xo + D1*length(q) - 1) = f;
		end;
		end;

        else
                fprintf(2,'Error QUANTILES: invalid input argument\n');
                return;
        end;
        
end;



