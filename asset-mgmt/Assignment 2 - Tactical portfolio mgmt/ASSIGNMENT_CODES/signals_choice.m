%% FIRST-ROUND CHOICE

% Building up our "Dynamic models" we end up having 16x4 "signals", i.e. 16
% signals plus another three derivations for each.
% We choose our signals first confronting the diagnostics "% Pos & Sig" and
% "% Neg & Sig", picking those with a rather big difference and looking at
% whether the direction of the inequality was respected in the diagnostics
% "% Pos" vs. "% Neg".

% This choice can be implemented rather easily through an algorythm...


% Example for choosing signals that should have a positive beta:

% xx=pan([1 8 10],:,:);
% xx(:,pan(4,:,:)<2*pan(5,:,:))=0;
% sigplus(nv,4,na)=0;
% for i=1:na
%    sigplus(:,:,i)=sortrows([linspace(1,16,16)' xx(:,:,i)'],-2);
% end;

% The first-round choice should be:

% imv ==> 10 01
% ep ==> vanilla
% mom1 ==> vanilla
% mom3 ==> 10
% mom12 ==> vanilla
% [roa ==> 10 01]
% roe ==> 10 01
% ass_tur ==> 11 (WITH BETA NEGATIVE)
% eq_tur ==> vanilla
% rev_ratio ==> vanilla
% FY1_3mch  ==> vanilla


% We are definitely happy with these results as, for instance, we see that
% actually imv is actually a risk factor as described in the Fam-French
% model: imv performs very well with a positive beta if we only look at the
% upward trend of the market , and performs very well also in downward
% slopes, but with a negative beta!!!

% Howevere we see also some disturbing features such as the asset_turnover
% changing sign from "good times" to "bad times", but with a negative
% beta... meaning that in "good time" an increasing asset turnover will
% translate into decreasing returns... In this case we want to be prudent,
% so we simply drop the asset turnover from the rose of the signals to use.

% In other cases we see a signal having a good performance in more models,
% specifically mom1, mom12, eq_tur, re_ratio and FY1_3mch all have good
% diagnostics in both the straigt model and in the 10 model. In such cases
% we just went for the simplest, so we picked the signal in the vanilla
% model.


%% PERFORMING AN OPTIMIZATION TO AVOID THE MULTI-CO-LINEARITY PROBLEM

% We know that some signals are highly correlated with each other and we
% can see it also from the plot of the betas. For instant we see that roa
% and roe show pretty much the same pattern. To solve this problem, we
% build top-bottom portfolios using our "first-round signals" and then see
% what's the behaviour of the weights

% The variables for which we suspect co-linearity
vr=[1 2 4 6 7 8 13 14 15];

np=floor(innd/3);

etop=zeros(np*3,size(vr,2));
ebot=etop;
eben=etop;
ctop=etop;
cbot=etop;


%We run a first outer loop on the base of the number of information signals
%chosen for the task
for i=1:size(vr,2)
      
    %An inner loop will serve to repeat the ranking and invesmtment
    %decision each month
    for j=1:np
        
        %We individuate the time indicator of the observation
            t=(j-1)*3+1;
        
        %We extract the sub-database with the observations that we
        %will use in this particular iteration
        dbt=indb(time==ti(t),:);
        
        %We extract the sub-database where the value of the signal is
        %non-missing
        dbm=dbt(isfinite(dbt(:,vr(i))),:);
        
        %We sort the rows of our sample on the base of he specific
        %information signal
        dbs=sortrows(dbm,-1*vr(i));
        num2=min(100,0.5*size(dbs,1));
        
        for k=1:3
        
            %We save the equally weighted returns of the portfolios
            etop((j-1)*3+k,i)=mean(dbs(1:num2,nv+k));
            ebot((j-1)*3+k,i)=mean(dbs(end-num2:end,nv+k));
            eben((j-1)*3+k,i)=mean(dbs(1:end,nv+k));
            
            %We calculate the consistency
            ctop((j-1)*3+k,i)=size(find(dbs(1:num2,nv+k)>eben((j-1)*3+k,i)),1)/num2;
            cbot((j-1)*3+k,i)=size(find(dbs(end-num2:end,nv+k)<eben((j-1)*3+k,i)),1)/num2;
            
            clc % ==> Warning: Integer operands are required for colon operator when used as index
        end
    end
    
end    

[mr2 cv2]=ewstats(etop-ebot);

% We calculate the efficient frontier for the top-bottom portfolios
[ri2 re2 w2]=frontcon(mr2,cv2,20);




%%
clear etop ebot eben ctop cbot dbt dbm dbs num2 mr2 cv2 ri2 re2 w2

%% MULTI-VARIATES TO TEST THE GOODNESS OF THE DYNAMIC MODEL


%% VANILLA 

vr=[1 2 6 8 13 15];


%We Isolate the variables that we want to use

sn=signames(vr)';
mod=db(:,vr);

dbx=[mod ret];

%We now run a Panel Regression Model with time fixed effects

np=floor((innd-60)/3);

panmulti1=zeros(11,size(vr,2));
ris=zeros(np,2*size(vr,2)+1);
coef1=zeros(np,size(vr,2));


for j=1:np

    %We individuate the time indicator of the observation
    t=(j-1)*3+12+1;

    %We extract the sub-database with the observations that we
    %will use in this particular iteration
    dbm=dbx((intime<=inti(t) & intime>inti(t-12)),:);  
    tim=time((intime<=inti(t) &intime>inti(t-12)),:);

    %We run the univariate panel regression
    [b de st]=panel(dbm(:,1:size(vr,2)), dbm(:,end), tim);

    ris(j,:)=[b(2:size(vr,2)+1)' st.p(2:size(vr,2)+1)' 1-(nanvar(st.resid)/nanvar(dbm(:,end)))];
    
    coef1(j,:)=b(2:size(vr,2)+1)';

end


for i=1:size(vr,2)

    
    [h p]=ttest(ris(:,i));
    
    panmulti1(1,i)=size(ris(ris(:,i)>0),1)/np; % Positive beta
    panmulti1(2,i)=size(ris(ris(:,i)<0),1)/np; % Negative beta
    panmulti1(3,i)=size(ris(ris(:,size(vr,2)+i)<0.1),1)/np; % Significant beta
    panmulti1(4,i)=size(ris(ris(:,i)>0 & ris(:,size(vr,2)+i)<0.1 ),1)/np; % Pos & Sig
    panmulti1(5,i)=size(ris(ris(:,i)<0 & ris(:,size(vr,2)+i)<0.1 ),1)/np; % Neg & Sig
    panmulti1(6,i)=mean(ris(:,2*size(vr,2)+1)); %- Mean R-Squared
    panmulti1(7,i)=p; %- P-Value
    panmulti1(8,i)=mean(ris(:,i))*100; %- Mean Coeff. X 100
    panmulti1(9:11,i)=quantile(ris(:,i),[.50 .25 .75])*100; %  median, 1st quartile, 3rd quartile x 100
    
end

figure
plot(dateb,coef1);
grid on
legend(sn,'location','northwest')
dateaxis('x',12)
title('Coefficienti')
xlim([dateb(1) dateb(end)])
grid on


%% VANILLA

vr=[1 2 6 8 15];


%We Isolate the variables that we want to use

sn=signames(vr)';
mod=db(:,vr);

dbx=[mod ret];

%We now run a Panel Regression Model with time fixed effects

np=floor((innd-60)/3);

panmulti2=zeros(11,size(vr,2));
ris=zeros(np,2*size(vr,2)+1);
coef2=zeros(np,size(vr,2));


for j=1:np

    %We individuate the time indicator of the observation
    t=(j-1)*3+12+1;

    %We extract the sub-database with the observations that we
    %will use in this particular iteration
    dbm=dbx((intime<=inti(t) & intime>inti(t-12)),:);  
    tim=time((intime<=inti(t) &intime>inti(t-12)),:);

    %We run the univariate panel regression
    [b de st]=panel(dbm(:,1:size(vr,2)), dbm(:,end), tim);

    ris(j,:)=[b(2:size(vr,2)+1)' st.p(2:size(vr,2)+1)' 1-(nanvar(st.resid)/nanvar(dbm(:,end)))];
    
    coef2(j,:)=b(2:size(vr,2)+1)';

end


for i=1:size(vr,2)

    
    [h p]=ttest(ris(:,i));
    
    panmulti2(1,i)=size(ris(ris(:,i)>0),1)/np; % Positive beta
    panmulti2(2,i)=size(ris(ris(:,i)<0),1)/np; % Negative beta
    panmulti2(3,i)=size(ris(ris(:,size(vr,2)+i)<0.1),1)/np; % Significant beta
    panmulti2(4,i)=size(ris(ris(:,i)>0 & ris(:,size(vr,2)+i)<0.1 ),1)/np; % Pos & Sig
    panmulti2(5,i)=size(ris(ris(:,i)<0 & ris(:,size(vr,2)+i)<0.1 ),1)/np; % Neg & Sig
    panmulti2(6,i)=mean(ris(:,2*size(vr,2)+1)); %- Mean R-Squared
    panmulti2(7,i)=p; %- P-Value
    panmulti2(8,i)=mean(ris(:,i))*100; %- Mean Coeff. X 100
    panmulti2(9:11,i)=quantile(ris(:,i),[.50 .25 .75])*100; %  median, 1st quartile, 3rd quartile x 100
    
end

figure
plot(dateb,coef2);
grid on
legend(sn,'location','northwest')
dateaxis('x',12)
title('Coefficienti')
xlim([dateb(1) dateb(end)])
grid on




%% VANILLA

vr=[1 2 6 15];


%We Isolate the variables that we want to use

sn=signames(vr)';
mod=db(:,vr);

dbx=[mod ret];

%We now run a Panel Regression Model with time fixed effects

np=floor((innd-60)/3);

panmulti3=zeros(11,size(vr,2));
ris=zeros(np,2*size(vr,2)+1);
coef3=zeros(np,size(vr,2));


for j=1:np

    %We individuate the time indicator of the observation
    t=(j-1)*3+12+1;

    %We extract the sub-database with the observations that we
    %will use in this particular iteration
    dbm=dbx((intime<=inti(t) & intime>inti(t-12)),:);  
    tim=time((intime<=inti(t) &intime>inti(t-12)),:);

    %We run the univariate panel regression
    [b de st]=panel(dbm(:,1:size(vr,2)), dbm(:,end), tim);

    ris(j,:)=[b(2:size(vr,2)+1)' st.p(2:size(vr,2)+1)' 1-(nanvar(st.resid)/nanvar(dbm(:,end)))];
    
    coef3(j,:)=b(2:size(vr,2)+1)';

end


for i=1:size(vr,2)

    
    [h p]=ttest(ris(:,i));
    
    panmulti3(1,i)=size(ris(ris(:,i)>0),1)/np; % Positive beta
    panmulti3(2,i)=size(ris(ris(:,i)<0),1)/np; % Negative beta
    panmulti3(3,i)=size(ris(ris(:,size(vr,2)+i)<0.1),1)/np; % Significant beta
    panmulti3(4,i)=size(ris(ris(:,i)>0 & ris(:,size(vr,2)+i)<0.1 ),1)/np; % Pos & Sig
    panmulti3(5,i)=size(ris(ris(:,i)<0 & ris(:,size(vr,2)+i)<0.1 ),1)/np; % Neg & Sig
    panmulti3(6,i)=mean(ris(:,2*size(vr,2)+1)); %- Mean R-Squared
    panmulti3(7,i)=p; %- P-Value
    panmulti3(8,i)=mean(ris(:,i))*100; %- Mean Coeff. X 100
    panmulti3(9:11,i)=quantile(ris(:,i),[.50 .25 .75])*100; %  median, 1st quartile, 3rd quartile x 100
    
end

figure
plot(dateb,coef3);
grid on
legend(sn,'location','northwest')
dateaxis('x',12)
title('Coefficienti')
xlim([dateb(1) dateb(end)])
grid on






%%

%xlswrite('pan.xls',pan,'straight','B2')
%xlswrite('pan.xls',pan10,'10','B2')
%xlswrite('pan.xls',pan01,'01','B2')
%xlswrite('pan.xls',panmulti1,'multi1','B2')
%xlswrite('pan.xls',panmulti2,'multi_final','B2')
%xlswrite('pan.xls',panmulti3,'multi3','B2')

% WE DIDN'T USE XLSWRITE FOR PROBLEMS OF INCOMPATIBILITY WITH OUR OPERATING
% SYSTEMS... SO WE JUST COPIED AND PASTED THE RESULTS OPENING THE VARIABLES
% IN THE WORKSPACE



%% FINAL CHOICE: SECOND MULTIVARIATE PANEL

vr=[1 2 6 8 15];
sn=signames(vr)';

%imv
%ep
%mom12
%roe
%FY1_3mch

