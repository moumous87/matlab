function figwork(option,handle,ht2,ht1,hxl,hyl)
%FIGWORK   The menu for adding labels to plots
%USE:  labelmnu(handle,ht2,ht1,hxl,hyl,t1,t2,xl,yl)
%where  h*  are the handles of the figure and labels.

%Copyright 1996--1999 Peter Dunn
%05 February 1999

if option==1, %LABELS AND TITLES
   %Get info
   UD=get(gcf,'UserData');
   t2=get(UD(2),'String');

   ht1=get(gca,'title');
   t1=get(ht1,'String');

   hxl=get(gca,'xlabel');
   xl=get(hxl,'String');

   hyl=get(gca,'ylabel');
   yl=get(hyl,'String');

   %Dialog box for info
   ltexts=inputdlg({'Title (first line)','Title (second line)',...
                   'x-axis Label','y-axis Label'},...
                   'Labelling Plots',...
                   [1,1,1,1],{t2,t1,xl,yl});

   %Relabel
   if ~isempty(ltexts),
      set(UD(2),'String',ltexts{1});
      title(ltexts{2});
      xlabel(ltexts{3});
      ylabel(ltexts{4});
   end

elseif option==2 %GRID LINES

   if ht2==1,
      if strcmp( get(gca,'XGrid'), 'on')
         set(gca,'XGrid','off');
      else
         set(gca,'XGrid','on');
      end;
   else
      if strcmp( get(gca,'YGrid'), 'on') 
         set(gca,'YGrid','off');
      else
         set(gca,'YGrid','on');
      end;
   end

elseif option==3, %AXIS LIMITS

   al=axis;
   prompts = {'Lower x-limit','Upper x-limit','Lower y-limit','Upper y-limit'};
   title = 'Axis Limits';
   lines = [1 1 1 1];
   defaults = {num2str(al(1)),num2str(al(2)),num2str(al(3)),num2str(al(4))};

   raxis = inputdlg( prompts,title,lines,defaults );
%   raxis=inputdlg(...
%         {'Lower x-limit','Upper x-limit','Lower y-limit','Upper y-limit'},...
%         'Axis Limits',[1 1 1 1],...
%         {num2str(al(1)),num2str(al(2)),num2str(al(3)),num2str(al(4))});
   if ~isempty(raxis),
      eval(['axis([',raxis{1},',',raxis{2},',',...
             raxis{3},',',raxis{4},']);'],...
           'errordlg(''Lower limits must be less than upper limits!'')');
   end

elseif option==4, %marker style

   UD=get(gcf,'UserData');
   set(UD(1),'Marker',handle);

elseif option==5, %marker edge color

   UD=get(gcf,'UserData');
   set(UD(1),'MarkerEdgeColor',handle);

elseif option==6 %marker face color

   UD=get(gcf,'UserData');
   set(UD(1),'MarkerFaceColor',handle);

elseif option==7, %marker size

   UD=get(gcf,'UserData');
   set(UD(1),'MarkerSize',handle);

end
