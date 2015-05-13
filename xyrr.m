function r = xyrr(p, divs, df)
%XYRR Modified rate of return of a dividend paying stock.
%
%   R = XYRR(P, DIVS, DF)
%
%   Inputs:
%
%        P - A vector or matrix of stock prices.
%            EACH COLUMN of P represents the prices of a different stock.
%
%     DIVS - A vector or matrix of dividends the same size as P.
%            EACH COLUM of DIVS represents the dividend cash flow of a stock.
%
%       DF - A vector of serial date numbers, or a cell array of date
%            stringsthe the same length as P.
%
%   Outputs:
%
%        R - Vector of the annualized internal rate of return of each cash
%            flow stream. A NaN indicates that a solution was not found.
%
%
%
%   See also IRR, MIRR, XIRR, FVVAR.
%
%   Copyright 2011-(end of the time) Michel Mustapha Raggio





if nargin ~= 3
   error('finance:xirr:tooFewInputs', 'Specify prices, dividends, dates.')
end

if ~isnumeric(p)
   error('finance:xirr:invalidInputArg','Invalid P input.')
end

if ~isnumeric(divs)
   error('finance:xirr:invalidInputArg','Invalid DIVS input.')
end


[rowp, colp]     = size(p);
[rowdivs, coldivs] = size(divs);

if rowp ~= rowdivs || colp ~= coldivs
   error('finance:xirr:invalidDims', ...
         'P0 and P1 must be of the same dimensions.')
end

if rowp == 1            % If inputs are row vectors,
   p = p(:);            % flip them.
   divs = divs(:);
   [rowp, colp] = size(p);
end



% destring DF
if ischar(df) || iscell(df)
   if iscell(df) && (size(df, 2) > 1)
      % Convert cell array of dates to char string so datenum can process.
      df = char(df);
   end

   df = datenum(df);

   try
      df = reshape(df, rowdivs, 1);
   catch
      error('finance:xirr:insufficientNumberOfDates', ...
            'Number of cash flows is inconsistent with number of dates.')
   end
end




df(isfinite(df)==0)=df(end,1);      % replace missing date (i.e. when the company still didn't exist) with the last date, so that there is no compounding
divs(isfinite(divs)==0)=0;          % replace missing dividend with a zero

p(1,:) = -p(1,:);                   % change sign to p0 for it to be an initial investment
divs(1,:) = 0;              % set the first dividend to zero because it belongs to the previous period.


if colp>1
    
    % transform DF from a vector to a matrix, if necessary
    df=df*ones(1,colp);

end




% create the cashflow vector, consisting of initial price and final
% price+future val. of dividends that have been reinvested buying the stock
cf = [p(1,:); zeros(rowp-2 , colp); p(end,:) + sum((ones(rowp,1)*p(end,:)).*divs./p,1) ];



% FIND MY YIELD
r = xirr(cf,df);

end
