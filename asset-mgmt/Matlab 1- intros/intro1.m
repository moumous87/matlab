%We read sata from a csv file created with a spreadsheet
dat=csvread('data.csv');

%We have different alternatives
%dat=dlmread('data.txt','\t');
%dat=xlsread('data.xls','Sheet1','B2:L62');


%We capture some informations from the data
ni=size(dat,2); %Number of indices
nd=size(dat,1); %Number of datapoints for each index


%We create a double loop. The outer one moves across indices
%The inner loop moves across datapoints for each index

for j=1:ni
    for i=1:nd-1
        ret(i,j)=(dat(i+1,j)-dat(i,j))/dat(i,j);
    end
end



%When we want to speed up our code we have to remember that
%each time there is asign =, that is each time Matlab has to repeat
%an operation a certain amount of time is used. We can optimize the
%code by finding ways to reduce the number of times we repeat each 
%operation. One way, here, is to use a single loop across indices
%and operate with vectors instead that using single numbers (scalars)

for j=1:ni
    ret2=(dat(2:nd,j)-dat(1:nd-1,j))./dat(1:nd-1,j);
end


%We can further optimize the code by operating with matrices
%In this way we can calculate the full range of returns for 
%our indices with a single calculation (a single =)

ret3=(dat(2:nd,:)-dat(1:nd-1,:))./dat(1:nd-1,:);


%Many times, when there is a mundane task, we will see that Matlab
%has built-in function to perform it automatically. In this case
%the function tick2ret transform a time series of prices into a time 
%series of returns

ret4=tick2ret(dat);


