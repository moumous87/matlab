function [y,z,I,Itr] = dd_crossval(x,I)
%DD_CROSSVAL Create cross-validation sets.
%
%   [Y,Z,I] = DD_CROSSVAL(X,I/NRBAGS)
% 
% Create cross-validation sets. When called for the first time:
%   [Y,Z,I] = DD_CROSSVAL(X,NRBAGS)
% Here I gives the number of folds and the permutated object indices.  Y
% and Z give the new training set (containing (NRBAGS-1) pieces) and the
% new testing set (containing just 1 fold). The folds may be of unequal
% size, but class sizes are taken into account. After gettting Y and Z
% the index variable I is updated. This is needed for the next call to
% dd_crossval.
%
% A 5-fold crossvalidation is implemented as:
% I = 5;
% for i=1:5
%   [Y,Z,I] = DD_CROSSVAL(X,I);
%   W = LDC(Y);
%   E(i) = Z*W*TESTC;
% end
%
% Note that you have to update the I each time, else you will get the
% same training and test set.
%
% See also: dd_error, dd_auc

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

if (nargin<2)
	error('I or nrfolds should be given!');
end
if length(I)==1
	nrfolds = I; I = [];
end

% Check if the coding vector I is already defined
if ~isempty(I) % is already defined, go for the next fold.
	if (I(5)~=170673)
		error('Sorry, I has not the right format');
	end
	I(2) = I(2) + 1; % goto next fold
	if (I(2)>I(1))
		warning('dd_tools:IllegalFoldNr','Maximal number of folds is extracted');
	end
	% Extract the class priors for Y and Z, but without warning:
	pr = getprior(x,0);
else % Create a vector I to code for the folds
	[nrx,dim,c] = getsize(x);
	% Consider each class separately, to force that all classes are
	% represented as best as possible (stratified crossvalidation)
	% Setup the variables:
	lab = getnlab(x);
	n = zeros(1,c);
	for i=1:c
		Iset{i} = find(lab==i);
		n(i) = length(Iset{i});
		if (n(i)<nrfolds)
			warning('dd_tools:InsufficientObjectsPerClass',...
				'Not enough samples per class, some folds lack objects from class %d.',i)
		end
	end
	% Now fill the fold sets (use the trick by Cor Veenman):
	cur = ones(1,c);
	for i=1:nrfolds
		Ifold{i} = [];
		% take objects from each of the sets:
		for j=1:c
			% compute the # of objects to select
			nr = floor(n(j)/(nrfolds-i+1));
			% select the j-th fold
			Ifold{i} = [Ifold{i};
			           Iset{j}(cur(j):cur(j)+nr-1)];
			% move the cur-pointer to the next set
			cur(j) = cur(j)+nr;
			% and update the remaining class sizes
			n(j) = n(j)-nr;
		end
	end
	% now fill the indices:
	I = zeros(nrx,1);
	for i=1:nrfolds
		I(Ifold{i}) = i;
	end
		
	% Encode the rest:
	I = [zeros(5,1); I];
	I(5) = 170673;  %Magic code;-)
	I(1) = nrfolds;
	I(2) = 1;      % number of active fold

	% Extract the class priors from X for Y and Z
	% This is the first time, so when the priors are not well-defined in
	% X, give a warning.
	pr = getprior(x);
end

% Extract the correct data given the I:
J = I(6:end);
Itr = find(J~=I(2));
y = x(Itr,:);
z = x((J==I(2)),:);

% One security check:
if nargout<3
	warning('dd_tools:XvalIndexLost',...
		'You probably want to use the index vector I for the next time!');
end

% Useful for inspection purposes, and to avoid too many complains about
% missing priors:
if isdataset(y)
	y = setname(y,[getname(y),' (Xval trn)']);
	z = setname(z,[getname(z),' (Xval tst)']);
	y = setprior(y,pr);
	z = setprior(z,pr);
end


return
