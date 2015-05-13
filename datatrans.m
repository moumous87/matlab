%%

load myDATA
load TREAS


% it's already sorted, but you're never too sure

myDATA(myDATA==-999) = NaN;
myDATA = sortrows(myDATA,[1,2]);
TREAS = sortrows(TREAS,1);


gvkey = unique(myDATA(:,1));
dates = unique(myDATA(:,2));
ggroup = unique(myDATA(:,20));
gind = unique(myDATA(:,21));
gsector = unique(myDATA(:,22));

%% BAPTIZM

names = {'GVKEY';
         'datadate';
         'datadate lag 1';
         'datadate lag 2';
         'datadate lag 3';
         'datadate lag 4';
         'datadate lag 5';
         'datadate lag 6';
         'datadate lag 7';
         'datadate lag 8';
         'datadate lag 9';
         'datadate lag 10';
         'datadate lag 11';
         'datadate lag 12';
         
         'unique obs. identifier';
         'Fundamentals Available';
         'Research Company Deletion Date';
         'Research Co Reason for Deletion';
         'Status Alert';
         'GIC Groups';
         'GIC Industries';
         'GIC Sectors';
         
         'Price - Close';
         'Price - lag 1';
         'Price - lag 2';
         'Price - lag 3';
         'Price - lag 4';
         'Price - lag 5';
         'Price - lag 6';
         'Price - lag 7';
         'Price - lag 8';
         'Price - lag 9';
         'Price - lag 10';
         'Price - lag 11';
         'Price - lag 12';
         
         'Cash Equivalent Distributions';
         'Cash Equivalent Distributions - lag 1';
         'Cash Equivalent Distributions - lag 2';
         'Cash Equivalent Distributions - lag 3';
         'Cash Equivalent Distributions - lag 4';
         'Cash Equivalent Distributions - lag 5';
         'Cash Equivalent Distributions - lag 6';
         'Cash Equivalent Distributions - lag 7';
         'Cash Equivalent Distributions - lag 8';
         'Cash Equivalent Distributions - lag 9';
         'Cash Equivalent Distributions - lag 10';
         'Cash Equivalent Distributions - lag 11';
         'Cash Equivalent Distributions - lag 12';
         
         'Dividends per Share';
         'Dividends per Share - lag 1';
         'Dividends per Share - lag 2';
         'Dividends per Share - lag 3';
         'Dividends per Share - lag 4';
         'Dividends per Share - lag 5';
         'Dividends per Share - lag 6';
         'Dividends per Share - lag 7';
         'Dividends per Share - lag 8';
         'Dividends per Share - lag 9';
         'Dividends per Share - lag 10';
         'Dividends per Share - lag 11';
         'Dividends per Share - lag 12';
         
         'Dividend Rate';
         'Dividend Yield';
         
         '3-Month Momentum';
         '6-Month Momentum';
         '1-Year Momentum';
         
         'Trading Volume';
         'Common Shares';
         'Mkt Cap';
         
         'Inverse of Mkt Cap';
         'Eps';
         'Cash Eps';
         'E/P';
         'B/P';
         'CF/P';
         'Ebitda/P';
         'Sales/P';
         'PEG';
         'Sales Growth';
         'Earnings Growth';
         'Assets Growth';
         'PPE Growth';
         'Equity Growth';
         'Gross Profit Margin';
         'Mark-up';
         'Ebit Margin';
         'Cash Flow Margin';
         'Pretax Profit Margin';
         'Net Income Margin';
         'Operating Income Impact';
         'ROE - Excluding Extr. Items';
         'ROA';
         'ROS';
         'ROIC';
         'ROIC simplified - tax=40%';
         'Cash Return on Assets';
         'Cash Return on Invested Capital';
         'Change in Gross Profit Margin';
         'Change in Mark-up';
         'Change in Ebit Margin';
         'Change in Cash Flow Margin';
         'Change in Pretax Profit Margin';
         'Change in Net Income Margin';
         'Change in Operating Income Impact';
         'Change in ROE';
         'Change in ROA';
         'Change in ROS';
         'Change in ROIC';
         'Change in ROIC simplified - tax=40%';
         'Change in Cash Return on Assets';
         'Change in Cash Return on Invested Capital';
         'Asset Turnover';
         'Equity Turnover';
         'Working Capital Turnover';
         'Days Sales Outstanting';
         'Days Payable Outstanding';
         'Stock Turnover';
         'Cash Conversion Cycle';
         'D/E';
         'Debt Ratio';
         'Total Liabilities/Total Assets';
         'Assets Coverage Ratio';
         'Current Ratio';
         'Quick Ratio';
         'Cash Ratio';
         'Interest Coverage Ratio';
         'Debt Service Coverage Ratio';
         'Cash Interest Coverage Ratio';
         'Cash Flow Liquidity Ratio';
         'Cash Flow To Debt Ratio';
         'Extraordinary Items Impact';
         'R&D to Sales';
         'M&A % of Operating Expenses'};
         
         'Monthly Return';
         'Capital Gain / 1-Month Momentum';



%% GENERATE QUARTERLY TOTAL RETURN


day1=find(dates(1)==TREAS(:,1));
rrate = reshape(TREAS(day1:end,4)*ones(1,size(gvkey,1)) , size(myDATA,1) , 1);

% COMPUTE THE FUTURE VALUE OF DIVIDENDS (+CASSH EQUIVALENT DISTRIBUTIONS)
% USING AS INVESTMENT RATE THE 90 Day Bill Returns

fvd=NaN(size(myDATA,1),3);

for i = 1:3
    
    fvd(:,i) = (myDATA(:,52-i)+myDATA(:,39-i)).*(1+rrate).^(myDATA(:,2)-myDATA(:,5-i))/365 ;
    
end



fvd = sum(fvd,2);


%myDATA column 229 = QUARTERLY TOTAL RETURN
myDATA(:,end+1) = 100*((myDATA(:,23)+fvd)./myDATA(:,26) -1);

names(end+1) = {'Quarterly Total Return'};



clear fvd rrate



%% GENERATE QUARTERLY CAPITAL GAIN

%myDATA column 230 = QUARTERLY PRICE RETURN (i.e. CAPITAL GAIN)
myDATA(:,end+1) = 100*(myDATA(:,23)./myDATA(:,26) -1);

names(end+1) = {'Quarterly Capital Gain'};


%% RECESSION DATES

% 31dec1969 -- 30nov1970
% 30nov1973 -- 31mar1975
% 31jan1980 -- 31jul1980
% 31jul1981 -- 30nov1982
% 31jul1990 -- 31mar1991
% 31mar2001 -- 30nov2001
% 31dec2007 -- 30jun2009


datenum('31dec1969','ddmmmyyyy');
datenum('30nov1970','ddmmmyyyy')

datenum('30nov1973','ddmmmyyyy');
datenum('31mar1975','ddmmmyyyy');

datenum('31jan1980','ddmmmyyyy');
datenum('31jul1980','ddmmmyyyy');

datenum('31jul1981','ddmmmyyyy');
datenum('30nov1982','ddmmmyyyy');

datenum('31jul1990','ddmmmyyyy');
datenum('31mar1991','ddmmmyyyy');

datenum('31mar2001','ddmmmyyyy');
datenum('30nov2001','ddmmmyyyy');

datenum('31dec2007','ddmmmyyyy');
datenum('30jun2009','ddmmmyyyy');





%%
scatter(myDATA(myDATA(:,1)==1045,229),myDATA(myDATA(:,1)==1045,174))


%%



% Do Fama-McBeth on co. of the same industry (gind.... which I... don't
% know why... deleted)

% Then do 





























































