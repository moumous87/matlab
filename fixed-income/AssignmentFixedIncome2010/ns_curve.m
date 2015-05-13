function [ns_spot,ns_df]=ns_curve(parameters,ttm)

beta0=parameters(1);
beta1=parameters(2);
beta2=parameters(3);
kappa=parameters(4);
ns_spot=beta0+(beta1+beta2/kappa)*(1-exp(-kappa.*ttm))./(kappa.*ttm)-beta2*exp(-kappa.*ttm)/kappa;
ns_df=exp(-ns_spot.*ttm);