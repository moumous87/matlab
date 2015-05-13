function th=title2(string)
%TITLE2  Titles for 2-D and 3-D plots.
%       TITLE2('text') adds a second title above the default title 
%
%       returns a handle to the second title

% This is provided as an example of how to use handle grapics and
% comes with no warranties.

pos = get(gca,'pos');
set(gca,'pos',[pos(1:3) .9*pos(4)])
x = .5;
y=pos(1)+pos(4)/.825;
th=text(x,y,string,'Units','Normalized','HorizontalAlignment','Center');
ax = gca;

%Over-ride text objects default font attributes with
%the Axes' default font attributes.
set(th, 'FontAngle',  get(ax, 'FontAngle'), ...
        'FontName',   get(ax, 'FontName'), ...
        'FontSize',   get(ax, 'FontSize'), ...
        'FontWeight', get(ax, 'FontWeight'), ...
        'string',     string);

return
