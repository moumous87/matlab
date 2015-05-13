%UPLOAD DATASET 
[filename,pathname]=uigetfile('*.xls');
[data,textdata,raw] = xlsread(filename,1);

%--------------------------------------------------------------------------
%data trasformation
%US VARIABLES
us_d=data(:,3).*(data(:,1)/100);
us_p=data(:,1);
us_cpi=data(:,14);
us_dy=log(data(:,3)/100);
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
us_1y=NaN(size(us_p));
us_10y=NaN(size(us_p));
us_div(4:end,:)=0.25*(us_d(4:end,:)+us_d(3:end-1,:)+us_d(2:end-2,:)+us_d(1:end-3,:));
us_ldiv(4:end,:)=log(us_div(4:end,:));
us_lp=log(us_p);
us_ldp(4:end,:)=us_ldiv(4:end,:)-us_lp(4:end,:);
us_infl_1(2:end,:)=4*(log(us_cpi(2:end,:))-log(us_cpi(1:end-1,:)));
us_1y(2:end,:)=data(2:end,17)/100; 
us_10y(2:end,:)=data(2:end,18)/100;
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

%UK VARIABLES
uk_d=data(:,7).*data(:,5)/100;
uk_p=data(:,5);
uk_cpi=data(:,15);
uk_dy=log(data(:,7)/100);
uk_div=NaN(size(us_p));
uk_ldiv=NaN(size(us_p));
uk_divgr=NaN(size(us_p));
uk_divgrr=NaN(size(us_p));
uk_ldp=NaN(size(us_p));
uk_infl_1=NaN(size(us_p));
uk_ret_1=NaN(size(us_p));
uk_ret_1r=NaN(size(us_p));
uk_ret_4=NaN(size(us_p));
uk_ret_4r=NaN(size(us_p));
uk_ret_8=NaN(size(us_p));
uk_ret_8r=NaN(size(us_p));
uk_ret_12=NaN(size(us_p));
uk_ret_12r=NaN(size(us_p));
uk_div(4:end,:)=0.25*(uk_d(4:end,:)+uk_d(3:end-1,:)+uk_d(2:end-2,:)+uk_d(1:end-3,:));
uk_ldiv(4:end,:)=log(uk_div(4:end,:));
uk_lp=log(uk_p);
uk_ldp(4:end,:)=uk_ldiv(4:end,:)-uk_lp(4:end,:);
uk_infl_1(2:end,:)=4*(log(uk_cpi(2:end,:))-log(uk_cpi(1:end-1,:)));
uk_divgr(5:end,:)=4*(uk_ldiv(5:end,:)-uk_ldiv(4:end-1,:));
uk_divgrr(5:end,:)=uk_divgr(5:end,:)-uk_infl_1(5:end,:);
uk_ret_1(2:end,:)=4*(log(data(2:end,6))-log(data(1:end-1,6)));
uk_ret_1r(2:end,:)=uk_ret_1(2:end,:)-uk_infl_1(2:end,:);
uk_ret_4(5:end,:)=(uk_ret_1(5:end,:)+uk_ret_1(4:end-1,:)+uk_ret_1(3:end-2,:)+uk_ret_1(2:end-3,:));
uk_ret_4r(5:end,:)=uk_ret_4(5:end,:)-(log(uk_cpi(5:end,:))-log(uk_cpi(1:end-4,:)));
uk_ret_8(9:end,:)=0.5*(uk_ret_4(9:end,:)+uk_ret_4(5:end-4,:));
uk_ret_8r(9:end,:)=uk_ret_8(9:end,:)-0.5*(log(uk_cpi(9:end,:))-log(uk_cpi(1:end-8,:)));
uk_ret_12(13:end,:)=(1/3)*(uk_ret_4(13:end,:)+uk_ret_4(9:end-4,:)+uk_ret_4(5:end-8,:));
uk_ret_12r(13:end,:)=uk_ret_12(13:end,:)-(1/3)*(log(uk_cpi(13:end,:))-log(uk_cpi(1:end-12,:)));

%GER VARIABLES
ger_d=data(:,11).*data(:,9)/100;
ger_p=data(:,9);
ger_cpi=data(:,16);
ger_dy=log(data(:,11)/100);
ger_div=NaN(size(us_p));
ger_ldiv=NaN(size(us_p));
ger_divgr=NaN(size(us_p));
ger_divgrr=NaN(size(us_p));
ger_ldp=NaN(size(us_p));
ger_infl_1=NaN(size(us_p));
ger_ret_1=NaN(size(us_p));
ger_ret_1r=NaN(size(us_p));
ger_ret_4=NaN(size(us_p));
ger_ret_4r=NaN(size(us_p));
ger_ret_8=NaN(size(us_p));
ger_ret_8r=NaN(size(us_p));
ger_ret_12=NaN(size(us_p));
ger_ret_12r=NaN(size(us_p));
ger_div(4:end,:)=0.25*(ger_d(4:end,:)+ger_d(3:end-1,:)+ger_d(2:end-2,:)+ger_d(1:end-3,:));
ger_ldiv(4:end,:)=log(ger_div(4:end,:));
ger_lp=log(ger_p);
ger_ldp(4:end,:)=ger_ldiv(4:end,:)-ger_lp(4:end,:);
ger_infl_1(2:end,:)=4*(log(ger_cpi(2:end,:))-log(ger_cpi(1:end-1,:)));
ger_divgr(5:end,:)=4*(ger_ldiv(5:end,:)-ger_ldiv(4:end-1,:));
ger_divgrr(5:end,:)=ger_divgr(5:end,:)-ger_infl_1(5:end,:);
ger_ret_1(2:end,:)=4*(log(data(2:end,10))-log(data(1:end-1,10)));
ger_ret_1r(2:end,:)=ger_ret_1(2:end,:)-ger_infl_1(2:end,:);
ger_ret_4(5:end,:)=(ger_ret_1(5:end,:)+ger_ret_1(4:end-1,:)+ger_ret_1(3:end-2,:)+ger_ret_1(2:end-3,:));
ger_ret_4r(5:end,:)=ger_ret_4(5:end,:)-(log(ger_cpi(5:end,:))-log(ger_cpi(1:end-4,:)));
ger_ret_8(9:end,:)=0.5*(ger_ret_4(9:end,:)+ger_ret_4(5:end-4,:));
ger_ret_8r(9:end,:)=ger_ret_8(9:end,:)-0.5*(log(ger_cpi(9:end,:))-log(ger_cpi(1:end-8,:)));
ger_ret_12(13:end,:)=(1/3)*(ger_ret_4(13:end,:)+ger_ret_4(9:end-4,:)+ger_ret_4(5:end-8,:));
ger_ret_12r(13:end,:)=ger_ret_12(13:end,:)-(1/3)*(log(ger_cpi(13:end,:))-log(ger_cpi(1:end-12,:)));
%--------------------------------------------------------------------------
%Plot US returns at different frequency
ret_US=NaN(rows(us_p),4);
ret_US(:,4)=us_ret_12r;
ret_US(:,3)=us_ret_8r;
ret_US(:,2)=us_ret_4r;
ret_US(:,1)=us_ret_1r;
names=strvcat('1-quarter','4-quarter','8-quarter','12-quarter');
t=1:rows(us_p);
figure
for i=1:3
      subplot(3,1,i), h1=plot(t', ret_US(:,i));
   title(['US Stock Market Returns: ',num2str(names(i,:))],'fontname','times','fontangle','italic','fontsize',9);
   set(gca,'fontname','times','fontangle','italic','fontsize',8,'gridlinestyle',':');
   set(gca,'xtick',[1:8:rows(t')]);   
   set(gca,'xlim',[0 rows(t')]);
set(gca,'xticklabel','1973|1975|1977|1979|1981|1983|1985|1987|1989|1991|1993|1995|1997|1999|2001|2003|2005|2007|2009');
grid;
set(gcf,'color','w');
end;
%--------------------------------------------------------------------------
%Same plot as above, but all in one Figure
figure
h1=plot(t',us_ret_1r,t',us_ret_4r,'-',t',us_ret_8r,'--',t',us_ret_12r,':','LineWidth',2);
title(' US Stock Market Returns ','fontname','times','fontangle','italic','fontsize',18);
   set(gca,'fontname','times','fontangle','italic','fontsize',12,'gridlinestyle',':');
   set(gca,'xtick',[1:8:rows(t')]);   
   set(gca,'xlim',[0 rows(t')]);
set(gca,'xticklabel','1973|1975|1977|1979|1981|1983|1985|1987|1989|1991|1993|1995|1997|1999|2001|2003|2005|2007|2009');
grid;
set(gcf,'color','w');
h=legend('1-Quarter','4-Quarter','8-Quarter','12-Quarter',1);
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%International Comparisons, dividend-yields
figure
h1=plot(t',us_ldp,t',uk_ldp,'-',t',ger_ldp,'--','LineWidth',2);
title(' (log) Dividend-Yields ','fontname','times','fontangle','italic','fontsize',18);
   set(gca,'fontname','times','fontangle','italic','fontsize',12,'gridlinestyle',':');
   set(gca,'xtick',[1:8:rows(t')]);   
   set(gca,'xlim',[0 rows(t')]);
set(gca,'xticklabel','1973|1975|1977|1979|1981|1983|1985|1987|1989|1991|1993|1995|1997|1999|2001|2003|2005|2007|2009');
grid;
set(gcf,'color','w');
h=legend('US','UK','Germany',1);
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%International Comparisons, returns 1-q
figure
h1=plot(t',us_ret_1r,t',uk_ret_1r,'-',t',ger_ret_1r,'--','LineWidth',2);
title(' (log) SM Returns 1-quarter','fontname','times','fontangle','italic','fontsize',18);
   set(gca,'fontname','times','fontangle','italic','fontsize',12,'gridlinestyle',':');
   set(gca,'xtick',[1:8:rows(t')]);   
   set(gca,'xlim',[0 rows(t')]);
set(gca,'xticklabel','1973|1975|1977|1979|1981|1983|1985|1987|1989|1991|1993|1995|1997|1999|2001|2003|2005|2007|2009');
grid;
set(gcf,'color','w');
h=legend('US','UK','Germany',1);
%--------------------------------------------------------------------------
%International Comparisons, returns 12-q
figure
h1=plot(t',us_ret_12r,t',uk_ret_12r,'-',t',ger_ret_12r,'--','LineWidth',2);
title(' (log) SM Returns 12-quarter','fontname','times','fontangle','italic','fontsize',18);
   set(gca,'fontname','times','fontangle','italic','fontsize',12,'gridlinestyle',':');
   set(gca,'xtick',[1:8:rows(t')]);   
   set(gca,'xlim',[0 rows(t')]);
set(gca,'xticklabel','1973|1975|1977|1979|1981|1983|1985|1987|1989|1991|1993|1995|1997|1999|2001|2003|2005|2007|2009');
grid;
set(gcf,'color','w');
h=legend('US','UK','Germany',1);