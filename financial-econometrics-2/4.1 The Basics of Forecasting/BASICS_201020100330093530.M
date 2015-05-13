    %UPLOAD DATASET 
    [filename,pathname]=uigetfile('*.xls');
    [data,textdata,raw] = xlsread(filename,1);
    %--------------------------------------------------------------------------
    %data trasformation
    %US VARIABLES
    us_d=data(:,3).*data(:,1);
    us_p=data(:,1);
    us_cpi=data(:,14);
    us_div=NaN(size(us_p));
    us_ldiv=NaN(size(us_p));
    us_divgr=NaN(size(us_p));
    us_divgrr=NaN(size(us_p));
    us_ldp=NaN(size(us_p));
    us_infl_1=NaN(size(us_p));
    us_ret_1=NaN(size(us_p));
    us_ret_1r=NaN(size(us_p));
    us_ret_4=NaN(size(us_p));
    us_ret_4r=NaN(size(us_p));
    us_ret_8=NaN(size(us_p));
    us_ret_8r=NaN(size(us_p));
    us_ret_12=NaN(size(us_p));
    us_ret_12r=NaN(size(us_p));
    us_div(4:end,:)=0.25*(us_d(4:end,:)+us_d(3:end-1,:)+us_d(2:end-2,:)+us_d(1:end-3,:));
    us_ldiv(4:end,:)=log(us_div(4:end,:));
    us_lp=log(us_p);
    us_ldp(4:end,:)=us_ldiv(4:end,:)-us_lp(4:end,:);
    us_infl_1(2:end,:)=4*(log(us_cpi(2:end,:))-log(us_cpi(1:end-1,:)));
    us_divgr(5:end,:)=4*(us_ldiv(5:end,:)-us_ldiv(4:end-1,:));
    us_divgrr(5:end,:)=us_divgr(5:end,:)-us_infl_1(5:end,:);
    us_ret_1(2:end,:)=4*(log(data(2:end,2))-log(data(1:end-1,2)));
    us_ret_1r(2:end,:)=us_ret_1(2:end,:)-us_infl_1(2:end,:);
    us_ret_4(5:end,:)=(us_ret_1(5:end,:)+us_ret_1(4:end-1,:)+us_ret_1(3:end-2,:)+us_ret_1(2:end-3,:));
    us_ret_4r(5:end,:)=us_ret_4(5:end,:)-(log(us_cpi(5:end,:))-log(us_cpi(1:end-4,:)));
    us_ret_8(9:end,:)=0.5*(us_ret_4(9:end,:)+us_ret_4(5:end-4,:));
    us_ret_8r(9:end,:)=us_ret_8(9:end,:)-0.5*(log(us_cpi(9:end,:))-log(us_cpi(1:end-8,:)));
    us_ret_12(13:end,:)=(1/3)*(us_ret_4(13:end,:)+us_ret_4(9:end-4,:)+us_ret_4(5:end-8,:));
    us_ret_12r(13:end,:)=us_ret_12(13:end,:)-(1/3)*(log(us_cpi(13:end,:))-log(us_cpi(1:end-12,:)));
    
%--------------------------------------------------------------------------
    % Defining the parameters
    alpha_1q=mean(us_ret_1r(2:end));
    alpha_12q=mean(us_ret_12r(13:end));
    beta_1q=var(us_ret_1r(2:end));
    beta_12q=var(us_ret_12r(13:end));
    alpha_ldp=mean(us_ldp(4:end));
    beta_ldp=var(us_ldp(4:end));
    % Simulate artificial series
    Num=size(us_ret_1r);
    Wn_1q=alpha_1q+sqrt(beta_1q)*normrnd(0,1,Num,1);
    Wn_12q=alpha_12q+sqrt(beta_12q)*normrnd(0,1,Num,1);
    Wn_ldp=alpha_ldp+sqrt(beta_ldp)*normrnd(0,1,Num,1);
    % Plot the result
    % 1Q
    t=1:rows(us_p);
    figure
    h1=plot(t',us_ret_1r,t',Wn_1q,'-','LineWidth',2);
    title(' (log) SM Returns 1-quarter','fontname','garamond','fontsize',16);
     set(gca,'fontname','garamond','fontsize',12);
     set(gca,'xtick',[1:8:rows(t')]); 
     set(gca,'xlim',[1 rows(t')]);
    set(gca,'xticklabel','1973|1975|1977|1979|1981|1983|1985|1987|1989|1991|1993|1995|1997|1999|2001|2003|2005|2007|2009');
    grid;
    set(gcf,'color','w');
    h1=legend('Actual','Simulated WN',0);
    % 12Q
    figure
    h2=plot(t',us_ret_12r,t',Wn_12q,'-','LineWidth',2);
    title(' (log) SM Returns 12-quarter','fontname','garamond','fontsize',16);
    set(gca,'fontname','garamond','fontsize',12);
    set(gca,'xtick',[1:8:rows(t')]); 
    set(gca,'xlim',[1 rows(t')]);
    set(gca,'xticklabel','1973|1975|1977|1979|1981|1983|1985|1987|1989|1991|1993|1995|1997|1999|2001|2003|2005|2007|2009');
    grid;
    set(gcf,'color','w');
    h2=legend('Actual','Simulated WN',0);
 %-------------------------------------------------------------------------
    % Generate artificial AR series
    % Defining the parameters
    rho=0.5;
    % Simulate AR series
    AR_1q=NaN(size(us_p));
    AR_12q=NaN(size(us_p));
    AR_1q(2,1)=us_ret_1r(2,1);
    ind=rows(us_p);
    for i=3:ind
    AR_1q(i,:)=rho*AR_1q(i-1)+alpha_1q*(1-rho)+normrnd(0,1,1)*sqrt((1-rho^2)*beta_1q);
    end
    AR_12q(13,1)=us_ret_12r(13,1);
    for i=14:ind
    AR_12q(i,:)=0.5*AR_12q(i-1)+alpha_12q*(1-rho)+normrnd(0,1,1)*sqrt((1-rho^2)*beta_12q);
    end
    %----------------------------------------------------------------------
    % Estimate ARMA model 
    % ARMA(1,1) estimation
    ind1=104;
    spec=garchset('VarianceModel','Constant','R',1,'M',1);
    [coeff,errors,llf,innovation,sigma,summary]=garchfit(spec,us_ret_1r(2:ind1));
    garchdisp(coeff,errors);
    %ARMA forecast
    horz=36;
    [SigmaForecast,MeanForecast] = garchpred(coeff,us_ret_1r(2:ind1),horz);
    Forecast_arma=MeanForecast;
    us_ret_1r_for_arma=NaN(size(us_p));
    us_ret_1r_for_arma(2:ind1,1)=us_ret_1r(2:ind1,1);
    us_ret_1r_for_arma(ind1+1:(ind1+horz),1)=Forecast_arma(1:horz,1);
    % AR(1) estimation
    spec=garchset('VarianceModel','Constant','R',1);
    [coeff,errors,llf,innovation,sigma,summary]=garchfit(spec,us_ret_1r(2:ind1));
    garchdisp(coeff,errors);
    % AR forecast
    %spec_pred=garchset('VarianceModel','Constant','C',coeff.C,'R',1,'AR',coeff.AR,'K',coeff.K);
    [SigmaForecast,MeanForecast] = garchpred(coeff,us_ret_1r(2:ind1),horz);
    Forecast_ar=MeanForecast;
    us_ret_1r_for_ar=NaN(size(us_p));
    us_ret_1r_for_ar(2:ind1,1)=us_ret_1r(2:ind1);
    us_ret_1r_for_ar(ind1+1:(ind1+horz),1)=Forecast_ar(1:horz,1);
    % Forecast unconditional mean
    Forecast_unc=ones(48,1)*mean(us_ret_1r(2:ind1));
    us_ret_1r_for_unc=NaN(size(us_p));
    us_ret_1r_for_unc(2:ind1)=us_ret_1r(2:ind1);
    us_ret_1r_for_unc(ind1+1:(ind1+horz),1)=Forecast_unc(1:horz,1);
    %----------------------------------------------------------------------
    % Generate artificial trend series
    Trend_det=NaN(size(us_p));
    Trend=NaN(size(us_p));
    Trend_st1=NaN(size(us_p));
    Trend_st2=NaN(size(us_p));
    Trend(1,1)=0;
    Trend_det(1,1)=0;
    Trend_st1(1,1)=0;
    Trend_st2(1,1)=0;
    ind=rows(Trend_st1);
    for i=2:ind
    Trend(i,:)=Trend(i-1,:)+1;
    Trend_det(i,:)=0.1*Trend(i,:)+normrnd(0,1,1);
    Trend_st1(i,:)=0.1+Trend_st1(i-1,:)+normrnd(0,1,1);
    Trend_st2(i,:)=0.1+Trend_st2(i-1,:)+normrnd(0,1,1);
    end
    % Plot trend series
    figure
    h3=plot(t',Trend_det,t',Trend_st1,t',Trend_st2,'-','LineWidth',2);
    title('Trends','fontname','garamond','fontsize',16);
    set(gca,'fontname','garamond','fontsize',10);
    set(gca,'xtick',[1:8:rows(t')]); 
    set(gca,'xlim',[1 rows(t')]);
    set(gca,'xticklabel','1973|1975|1977|1979|1981|1983|1985|1987|1989|1991|1993|1995|1997|1999|2001|2003|2005|2007|2009');
    grid;
    set(gcf,'color','w');
    h3=legend('Det Trend','ST TREND 1', 'ST TREND 2',2);
   