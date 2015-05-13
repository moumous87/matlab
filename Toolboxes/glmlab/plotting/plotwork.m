function plotwork(pflag)
%PLOTWORK  Does all the plotting and work attached to  glmplot

%Copyright 1996--1999 Peter Dunn
%12 July 1999

global COLS

GLMLAB_INFO_=get(findobj('tag','glmlab_main'),'UserData');

%GET INFO TO PLACE ON PLOTS:
%distribution:
titledis=[upper(GLMLAB_INFO_{1}(1)),GLMLAB_INFO_{1}(2:length(GLMLAB_INFO_{1}))];

if strcmp(titledis,'Inv_gsn')
   titledis='Inv Gaussian'; %using inv_gsn subscripts g but still want TeX style
elseif strcmp(titledis,'Binoml')
   titledis='Binomial';
end;

%residual type:
typer=[upper(GLMLAB_INFO_{4}(1)),GLMLAB_INFO_{4}(2:length(GLMLAB_INFO_{4}))];
if strcmp(typer,'Quantile')
   if strcmp(GLMLAB_INFO_{1},'binomial')|strcmp(GLMLAB_INFO_{1},'poisson'),
      typer='Randomised Quantile';
   end;
end;

%Replication (if needed):
trn=' '; 
REPS=size(GLMLAB_INFO_{18},2);

if REPS>1, 
   trn=': (rep: 1)';
   for II=2:REPS, 
      trn=str2mat(trn,[': (rep: ',num2str(II),')']);
   end;
end;

%do something:
if pflag==1, %res vs y

   if size(GLMLAB_INFO_{14},2)==2, %binomial
      pyvar=GLMLAB_INFO_{14}(:,1)./GLMLAB_INFO_{14}(:,2); %the ratio
   else
      pyvar=GLMLAB_INFO_{14};
   end;

   for II=1:REPS,
      hf=figure;
      hplot=plot(pyvar,GLMLAB_INFO_{18}(:,II),'b+');
      titletext=[typer,' Residuals vs Response (y)',trn(II,:)];
      ht1=title(titletext);
      ht2=title2(' ');
      if size(GLMLAB_INFO_{14},2)==2,
         xlabtext='Ratio of Observed Counts to Sample Size';
      else
         if isempty(GLMLAB_INFO_{9}),
            xlabtext='Response Variable (y)';
         else
            xlabtext=['Response Variable (y): ',GLMLAB_INFO_{9}];
         end;
      end;
      hxl=xlabel(xlabtext);
      ylabtext=[typer,' Residuals'];
      hyl=ylabel(ylabtext);
      axis([min(pyvar)-1 max(pyvar)+1,...
            min(GLMLAB_INFO_{18}(:,II))-1 max(GLMLAB_INFO_{18}(:,II))+1]);
      UD(1)=hplot;
      UD(2)=ht2;
      UD(3)=hf;
      set(hf,'UserData',UD);
      addpmenu
   end;

elseif pflag==2, %res vs cov

   for JJ=find(COLS==1), %which covar

     for II=1:REPS, %rep
        hf=figure;
        hplot=plot(GLMLAB_INFO_{15}(:,JJ),GLMLAB_INFO_{18}(:,II),'b+');
        titletext=[typer,' Residuals vs Covariate ',...
             num2str(JJ),trn(II,:)];
        ht1=title(titletext);
        ht2=title2(' ');
        ylabtext=[typer,' Residuals'];
        hyl=ylabel(ylabtext);
        if ~isempty(GLMLAB_INFO_{13}),
           xlabtext=['Covariate ',num2str(JJ),' [',...
                    deblank(GLMLAB_INFO_{13}(JJ,:)),']'];
        else
           xlabtext=['Covariate ',num2str(JJ)];
        end;
        hxl=xlabel(xlabtext);
        axis([min(GLMLAB_INFO_{15}(:,JJ))-1 max(GLMLAB_INFO_{15}(:,JJ))+1,...
             min(GLMLAB_INFO_{18}(:,II))-1 max(GLMLAB_INFO_{18}(:,II))+1]);
        UD(1)=hplot;
        UD(2)=ht2;
        UD(3)=hf;
        set(hf,'UserData',UD);
        addpmenu

      end;

   end;

elseif pflag==3, %npplot

   for II=1:REPS,
      hf=figure;
      if findstr(GLMLAB_INFO_{4},'quantile'),
         hplot=npplot(GLMLAB_INFO_{18}(:,II),1); 
      else
         hplot=npplot(GLMLAB_INFO_{18}(:,II),0);
      end;
      ht2=title2('Normal Probability Plot');
      titletext=[typer,' Residuals (',titledis,') ',trn(II,:)];
      ht1=title(titletext);

      if ~isempty(GLMLAB_INFO_{9}),
         ylabtext=['Data ',GLMLAB_INFO_{9}];
         hyl=ylabel(ylabtext);
      end;

      hxl=xlabel('Standard Normal Deviate');
      hyl=ylabel('Residuals');
      UD(1)=hplot(1);
      UD(2)=ht2;
      UD(3)=hf;
      set(hf,'UserData',UD);
      addpmenu

   end;

elseif pflag==4,

   for II=1:REPS,

      hf=figure;
      hplot=plot(GLMLAB_INFO_{19},GLMLAB_INFO_{18}(:,II),'b+');
      hxl=xlabel('Fitted Values');
      ylabtext=[typer,' Residuals']; hyl=ylabel(ylabtext);
      title2text=[typer,' Residuals (',titledis,') vs '];
      ht2=title2(title2text);
      set(gcf,'UserData',ht2);
      titletext=['Fitted Values',trn(II,:)];
      ht1=title(titletext);
      axis([min(GLMLAB_INFO_{19})-1 max(GLMLAB_INFO_{19})+1,...
            min(GLMLAB_INFO_{18}(:,II))-1 max(GLMLAB_INFO_{18}(:,II))+1]);
      UD(1)=hplot;
      UD(2)=ht2;
      set(gcf,'UserData',UD);
      addpmenu

   end;

elseif pflag==5,  %See McCullagh and Nelder p~398--Constant information scales used

   if strcmp(GLMLAB_INFO_{1},'poisson'),
      XAXIS=2*sqrt(GLMLAB_INFO_{19});xlabtext='2 sqrt(Fitted Values)';
   elseif strcmp(GLMLAB_INFO_{1},'binoml'),
      XAXIS=2*asin(sqrt(GLMLAB_INFO_{19}./GLMLAB_INFO_{14}(:,2)));
      xlabtext='2 asin( sqrt(Fitted Ratio) )';
   elseif strcmp(GLMLAB_INFO_{1},'gamma'),
      XAXIS=2*log(GLMLAB_INFO_{19}); xlabtext='2 log( Fitted Values )';
   elseif strcmp(GLMLAB_INFO_{1},'inv_gsn'),
      XAXIS=2/sqrt(GLMLAB_INFO_{19});
      xlabtext='2/sqrt(Fitted Values)';
   else %normal and user-defined
      XAXIS=GLMLAB_INFO_{19};xlabtext='Fitted Values';
   end;   

   for II=1:REPS,
      hf=figure;
      hplot=plot(XAXIS,GLMLAB_INFO_{18}(:,II),'b+');
      hxl=xlabel(xlabtext);
      ylabtext=[typer,' Residuals'];
      hyl=ylabel(ylabtext);
      title2text=[typer,' Residuals (',titledis,') vs '];
      ht2=title2(title2text);
      set(gcf,'UserData',ht2);
      titletext=[xlabtext,trn(II,:)];
      ht1=title(titletext);
      axis([min(XAXIS)-1 max(XAXIS)+1,...
            min(GLMLAB_INFO_{18}(:,II))-1 max(GLMLAB_INFO_{18}(:,II))+1]);
      UD(1)=hplot;
      UD(2)=ht2;
      UD(3)=hf;
      set(gcf,'UserData',UD);
      addpmenu
   end;

elseif pflag==6, %fv vs qe

   for II=1:REPS,
      hf=figure('menubar','none');
      hplot=plot(cdfnorm(GLMLAB_INFO_{18}(:,II)),GLMLAB_INFO_{19},'b+');
      hxl=xlabel('Quantile Equivalents');
      hyl=ylabel('Fitted Values');
      title2text=['Fitted Values vs Quantile Equivalents for'];
      ht2=title2(title2text);
      set(gcf,'UserData',ht2);
      titletext=[typer,' Residuals (',titledis,') ',trn(II,:)];
      ht1=title(titletext);
      axis([min(cdfnorm(GLMLAB_INFO_{18}(:,1)))-1 max(cdfnorm(GLMLAB_INFO_{18}(:,II)))+1,...
            min(GLMLAB_INFO_{19})-1 max(GLMLAB_INFO_{19})+1]);
      UD(1)=hplot;
      UD(2)=ht2;
      UD(3)=hf;
      set(hf,'UserData',UD);
      addpmenu

   end;

elseif pflag==7,

   for II=1:min(40,size(GLMLAB_INFO_{13},1)),
      COLS(II)=get(findobj('tag',num2str(II)),'value');
   end;
   delete(findobj('tag','cvwindow'));

end;
