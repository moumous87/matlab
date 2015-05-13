


function [mysigma]=mycalibrating(Tj,t,sigma,x0)


banana=@(x)(sum((sqrt(int(([x(1)*(Tj-t)+x(4)]*exp(-x(2)*(Tj-t))+x(3))^2,t,0,Tj))-sqrt(Tj)*sigma)^2))


mysigma=fminsearch(banana,x0)















