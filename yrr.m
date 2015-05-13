function r = yrr(p0, p1, divs, df, rrate)
%YRR Modified rate of return of a dividend paying stock.
%
%   R = YRR(P0, P1, DIVS, DF, RRATE)
%
%   Inputs:
%
%       P0 - A scalar or (row) vector of the initial price of the stock(s).
%
%       P1 - A scalar or (row) vector of the final price of the stock(s).
%
%     DIVS - A vector or matrix of dividends the same size as DF.
%            EACH COLUMN of DIVS represents the dividend cash flow of a stock.
%
%       DF - A vector of serial date numbers, or a cell array of date
%            strings, the same size as DIVS
%
%    RRATE - Scalar or vector of the reinvestment rate for dividends.
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





if nargin < 3
   error('finance:xirr:tooFewInputs', 'Specify at least 3 inputs: initial price, final price and dates.')
end

if ~isnumeric(p0)
   error('finance:xirr:invalidInputArg','Invalid P0 input.')
end

if ~isnumeric(p1)
   error('finance:xirr:invalidInputArg','Invalid P1 input.')
end

if isempty(divs)
   divs=zeros(size(p0,1),size(p0,2));
end

if ~isnumeric(divs)
   error('finance:xirr:invalidInputArg','Invalid DIVS input.')
end

if isempty(rrate)
   rrate=0;
end

if ~isnumeric(rrate)
   error('finance:xirr:invalidInputArg','Invalid RRATE input.')
end





[rowp0, colp0]     = size(p0);
[rowp1, colp1]     = size(p1);
[rowdivs, coldivs] = size(divs);

if rowp0 ~= rowp1 || colp0 ~= colp1
   error('finance:xirr:invalidDims', ...
         'P0 and P1 must be of the same dimensions.')
end

if colp0 == 1           % If inputs are column vectors,
   p0 = p0(:)';         % flip them.
   p1 = p1(:)';
%   rowp0=1;
%   rowp1=1;
   [~, colp0] = size(p0);
end

if colp0 ~= coldivs
   error('finance:xirr:invalidDims', ...
         '# of initial prices P0 and # of columns of DIVS must be of the same.')
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




df(isnan(df)==1)=df(end,1);      % replace missing date (i.e. when the company still didn't exist) with the last date, so that there is no compounding
divs(isnan(divs)==1)=0;          % replace missing dividend with a zero

p0 = -p0;                   % change sign to p0 for it to be an initial investment.
divs(1,:) = 0;              % set the first dividends to zero because it belongs to the previous period.


fvdivs=zeros(1,colp0);
if colp0>1
    
    
    % compute the future value of dividends
    for i=1:colp0
    fvdivs(1,i)=fvvar(divs(:,i),rrate,df);
    end
    
    % transform DF from a vector to a matrix, if necessary
    df=df*ones(1,colp0);

end


% create the cashflow vector, consisting of initial price and final
% price+future val. of dividends
cf = [p0; zeros(rowdivs-2 , colp0); p1+fvdivs ];



% FIND MY YIELD
r = xirr(cf,df);

end
