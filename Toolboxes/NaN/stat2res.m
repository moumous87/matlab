function [o] = stat2res(i1,i2)
% STAT2RES calculates the signal-to-noise-ration, entropy difference 
%
% see also: SUMSKIPNAN, STAT2
%
% REFERENCES: 

%   Version 1.26  Date: 21 Aug 2002   
%   Copyright (C) 1999-2002 by Alois Schloegl <a.schloegl@ieee.org>	

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
%    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

%    Copyright (C) 2000-2002 by  Alois Schloegl <a.schloegl@ieee.org>	


if strcmp(i1.datatype,'STAT2') & strcmp(i2.datatype,'STAT2');
        o.MEAN1=i1.SUM./i1.N;
        v1=i1.SSQ-i1.SUM.*o.MEAN1;
        o.SD1=sqrt(v1./i1.N);
        
        o.MEAN2=i2.SUM./i2.N;
        v2=i2.SSQ-i2.SUM.*o.MEAN2;
        o.SD2=sqrt(v2./i2.N);
        
        %o.SNR=(i1.N+i2.N).*(o.MEAN2-o.MEAN1).^2./(i1.N.*v1+i2.N.*v2);
        %o.I  =1/2*log2((i1.N+i2.N).*(o.MEAN2-o.MEAN1).^2./(i1.N.*v1+i2.N.*v2)+1);
        o.SNR=(i1.N+i2.N).*(o.MEAN2-o.MEAN1).^2./(v1+v2);
        o.I  =1/2*log2((i1.N+i2.N).*(o.MEAN2-o.MEAN1).^2./(v1+v2)+1);
	o.datatype='SNR';   
else
        
end;


