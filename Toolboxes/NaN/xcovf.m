function [C,N,LAGS] = xcovf(X,Y,MAXLAG,SCALEOPT);
% XCOVF generates cross-covariance function. 
% XCOVF is the same as XCORR except 
%   X and Y can contain missing values encoded with NaN.
%   NaN's are skipped, NaN do not result in a NaN output. 
%   The output gives NaN only if there are insufficient input data
%
% [C,N,LAGS] = xcovf(X,MAXLAG,SCALEOPT);
%      calculates the (auto-)correlation function of X
% [C,N,LAGS] = xcovf(X,Y,MAXLAG,SCALEOPT);
%      calculates the crosscorrelation function between X and Y
%
% see also: COVM, XCORR

%	$Revision: 3442 $
%	$Id: xcovf.m 3442 2007-03-23 16:14:46Z adb014 $
%	Copyright (C) 2005 by Alois Schloegl <a.schloegl@ieee.org>	

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
        Y = [];
        MAXLAG = [];
        SCALEOPT = 'none';
elseif ischar(Y),
        SCALEOPT=Y;
        Y=[];
        MAXLAG = [];
elseif all(size(Y)==1),
        if nargin<3
                SCALEOPT = 'none';
        else
                SCALEOPT = MAXLAG;
        end;
        MAXLAG = Y; 
        Y = [];
end;

if 0,
        
elseif isempty(Y) & isempty(MAXLAG)
        NX = isnan(X);
        X(NX) = 0;
        [C,LAGS] = xcorr(X,'none');
        [N,LAGS] = xcorr(1-NX,'none');
elseif ~isempty(Y) & isempty(MAXLAG)
        NX = isnan(X);
        NY = isnan(Y);
        X(NX) = 0;
        Y(NY) = 0;
        [C,LAGS] = xcorr(X,Y,'none');
        [N,LAGS] = xcorr(1-NX,1-NY,'none');
elseif isempty(Y) & ~isempty(MAXLAG)
        NX = isnan(X);
        X(NX) = 0;
        [C,LAGS] = xcorr(X,MAXLAG,'none');
        [N,LAGS] = xcorr(1-NX,MAXLAG,'none');
elseif ~isempty(Y) & ~isempty(MAXLAG)
        NX = isnan(X);
        NY = isnan(Y);
        X(NX) = 0;
        Y(NY) = 0;
        [C,LAGS] = xcorr(X,Y,MAXLAG,'none');
        [N,LAGS] = xcorr(1-NX,1-NY,MAXLAG,'none');
end;        



if 0,

elseif strcmp(SCALEOPT,'none')
	% done

elseif strcmp(SCALEOPT,'coeff')
	ix = find(LAGS==0);
	c  = repmat(C(ix,1:size(C,2)+1:end));
	v  = sqrt(1./c);
	v  = v'*v; 
	C  = C.*repmat(v(:).',size(C,1),1);	

elseif strcmp(SCALEOPT,'biased')
	C = C./repmat(max(N),size(C,1),1);
	
elseif strcmp(SCALEOPT,'unbiased')
	C = C./(repmat(max(N),size(C,1),1)-repmat(LAGS,1,size(C,2)));

else
        warning('invalid SCALEOPT - not supported');    
end;
