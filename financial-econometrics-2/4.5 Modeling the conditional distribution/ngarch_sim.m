function [r_s,sigma_s] = ngarch_sim(par,sig2_0,innov)

% Inputs:
%   par: NGARCH 4x1 parameter vector (omega; alpha; theta; beta)
%   sig2_0: initial variance
%   innov: vector of innovations

% Outputs:
%   r_s: vector with simulated returns (size=size of innovation vector)
%   sigma_s: vector of simulated conditional standard deviations

R=rows(innov);
sigma_sq=NaN(R,1);
r_s=NaN(R,1);
sigma_sq(1,1)=sig2_0;

for i=2:R
    sigma_sq(i,1)=par(1,1)+par(2,1)*sigma_sq(i-1,1)*(innov(i-1,1)-par(3,1))^2+par(4,1)*sigma_sq(i-1,1);
    sigma_s(i,1)=sqrt(sigma_sq(i,1));
    r_s(i,1)=sigma_s(i,1).*innov(i,1);
end

