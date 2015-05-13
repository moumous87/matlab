%Finds the covariates to use when plotting covariates vs Residuals

%Copyright 1997-1998 Peter Dunn
%17 August 1998

global COLS

GLMLAB_INFO_=get(findobj('tag','glmlab_main'),'UserData');
COLS=zeros(1,min(40,size(GLMLAB_INFO_{13},1)));

if size(GLMLAB_INFO_{13},1)==1,
   COLS(1)=1;
else

   if floor(size(GLMLAB_INFO_{13},1)/20)>1
      bell;
      HW=warndlg('I can''t display all co-variates, just the first 30.');
      set(HW,'WindowStyle','modal');
   end;

   figure('Name','Residual vs Covariate Plot','tag','cvwindow');
   watchon;
   uicontrol(findobj('tag','cvwindow'),'Style','frame',...
     'Units','normalized','Position',[.15 .9 .7 .1]);
   uicontrol(findobj('tag','cvwindow'),'Style','frame',...
     'Units','normalized','Position',[0.03 0.1 0.94 0.8]);

   uicontrol(findobj('tag','cvwindow'),'Style','text',...
     'Units','normalized','Position',[.2 .92 .6 .05],...
     'String','Please select the co-variates against which to plot:');

   for UIL=1:min(30,size(GLMLAB_INFO_{13},1)),
      CVCOLS=( (UIL>15) +1);
      uicontrol(findobj('tag','cvwindow'),'Style','checkbox',...
         'tag',num2str(UIL),...
         'String',GLMLAB_INFO_{13}(UIL,:),'Units','normalized',...
         'Position',[0.05+(CVCOLS-1)*0.5, 0.85-0.04*(UIL-(CVCOLS-1)*15), ...
                     0.4, 0.05]);
   end;
   uicontrol(findobj('tag','cvwindow'),'Style','pushbutton','tag','finished',...
      'String','PLOT','Units','normalized',...
      'Position',[.2 .01 .2 .08],'Callback',['plotwork(7);plotwork(2);']);
   uicontrol(findobj('tag','cvwindow'),'Style','pushbutton','tag','finished',...
      'String','Cancel','Units','normalized',...
      'Position',[.6 .01 .2 .08],...
      'Callback','delete(findobj(''tag'',''cvwindow'')); return;');
end;

if exist('HW')==1, 
   figure(HW); 
end;

clear CVCOLS UIL GLMLAB_INFO_
watchoff;
