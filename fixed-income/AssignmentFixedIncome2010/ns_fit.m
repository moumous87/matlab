function [ns_error]=ns_fit(parameters, mktdata)
%mkdata array containing market time to maturity and spot rats

ttm=mktdata(:,1);
mkt_spot=mktdata(:,2);
ns_spot=ns_curve(parameters,ttm);

ns_error=ns_spot-mkt_spot;
