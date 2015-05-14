%% Demo for Calculating Portfolio Weights For a Target Risk Level
% Oren Rosen
% The MathWorks
% 2/23/09
%
% The Financial Toolbox function allows the user to specify a target return
% but not a target risk. This is due to the implementation of the
% optimization algorithms at work in the underlying code base. However, by
% using the core MATLAB function "fzero" we can optimize for a target risk
% indirectly.
%
% Note: In practice this is not the most efficient way of calculating the
% desired portfolio. This method is clean, demonstrates the use of function
% handles and "nested" optimization. This demo should be used for
% illustrative purposes only without further investigation by the end user.


% Load a vector of expected returns and a covariance matrix for 30 stocks
load StockStats;

%% Call portopt just to get a visual of the efficient frontier.
% Note the min/max values for portfolio risk and return
portopt(expRet,expCov);

%% Call portopt with inputs/outputs to capture 10 specific portfolios
[pRisk,pRet,pWts] = portopt(expRet,expCov,10);

% Note that the first and last portfolios define the min/max risk/return
minRisk = pRisk(1);
maxRisk = pRisk(end);
minRet = pRet(1);
maxRet = pRet(end);

%% We can also call portopt with a target return
% Set target return to be mid point between min and max return
targetRet = 0.5*(minRet + maxRet);
[tRisk,tRet,tWts] = portopt(expRet,expCov,[],targetRet);

%% Use "fzero" and above to find portfolio with target risk
% Through trial and error, we could certainly use the above technique with
% different values of target return to find a desired risk portfolio.
% However, we can do this more rigorously using "fzero". This is a core ML
% optimization function that can find zeros of a given function.

% First, set a target risk (will use midpoint for this example)
lambda = 0.5;
targetRisk = minRisk*(1-lambda) + maxRisk*(lambda);

% Next, define a function that takes target return as input and returns the
% difference of the resulting risk and our target risk. This function will
% equal zero when we input the "correct" target return
objfun = @(x) portopt(expRet,expCov,[],x) - targetRisk;

% Pass this objective to "fzero".
% Note: we need to input bounds for potential target return values. If not,
% "fzero" will likely generate target returns that are not possible to
% achieve with the given stats. This will cause "portopt" to error. We can
% use the min/max returns generated above for this purpose.
matchingRet = fzero(objfun,[minRet maxRet]);

% Find the portfolio data that corresponds to our desired portfolio
[tRisk,tRet,tWts] = portopt(expRet,expCov,[],matchingRet);

% Note that the resulting risk is what we were looking for
targetRisk
tRisk

% Visualize on efficient frontier
plot(pRisk,pRet,'k-',tRisk,tRet,'r*');
title('Target portfolio with risk equal to midpoint');
xlabel('Portfolio Risk');
ylabel('Portfolio Return');
grid on;




