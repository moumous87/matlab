%% %% %% ERRATA CORRIGE

% 1) Open the mfile Ex3_solution.m

% 2) LINES 162:170 ARE WRONG!

es_pred_d=NaN(ind(3)-ind(2),1);
es_pred_w=NaN(ind(3)-ind(2),1);
es_pred_d(1,1)=lambda*cond_var_es(ind(2)-1)+(1-lambda)*port_ret(ind(2))^2;
es_pred_w(1,1)=5*es_pred_d(1,1);

for i=1:(ind(3)-ind(2)-1)
es_pred_d(i+1)=lambda*cond_var_es(i)+(1-lambda)*port_ret(ind(2))^2;
es_pred_w(i+1)=5*cond_var_es(i+1,1);
end

% 3) Replace those lines (162:170) as follows:

es_pred_d = NaN(ind(3)-ind(2),1);
es_pred_w = NaN(ind(3)-ind(2),1);
es_pred_d(1,1) = var(port_ret(ind(1):ind(2)));
es_pred_w(1,1) = 5*es_pred_d(1,1);

for i=1:(ind(3)-ind(2)-1)
es_pred_d(i+1)=lambda*es_pred_d(i)+(1-lambda)*port_ret(ind(2)+i)^2;
es_pred_w(i+1)=5*es_pred_d(i+1,1);
end

% 4) Run the mfile