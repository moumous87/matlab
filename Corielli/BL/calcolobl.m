
function [Mu_BL]=calcolobl(P,expvariance,Error,v,expret,tau)
omega=Error;
V=expvariance;
Q=v;
eqretvec=expret;
% Mu_BL=expret'+expvariance*P'*inv(P*expvariance*P'+Omega)*(v-P*expret');
% Sigma_BL=expvariance-expvariance*P'*inv(P*expvariance*P'+Omega)*P*expvariance;

Mu_BL=inv(inv(tau*V)+P'*inv(omega)*P)*(inv(tau*V)*eqretvec+P'*inv(omega)*Q);
