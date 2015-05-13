% Monte carlo Methods

%*****************General Exercice**************************************** 
Num_sim=[10;100;500;1000;5000];

for i=1:size(Num_sim,1)
    Y = rand(Num_sim(i),1);
    average=mean(Y);
    int_up=average+1.96*std(Y)/sqrt(Num_sim(i));
    int_down=average-1.96*var(Y)/sqrt(Num_sim(i));
    eval(['Mean_' num2str(Num_sim(i)) '=average;']);
    eval(['Intup_' num2str(Num_sim(i)) '=int_up;']);
    eval(['Intdown_' num2str(Num_sim(i)) '=int_down;']);
    Mean(i)=average;
    INTUP(i)=int_up;
    INTDW(i)=int_down;
end

% Plot the results
figure
plot(Num_sim,[Mean' INTUP' INTDW'])
title('Integration');
xlabel('Number of Simulations');
ylabel('Integral Value');
h=legend('Mean','CI lower bound','CI upper bound',2);
%************************************************************************* 
%***************** General Exercice with Box-Muller transformation ******** 

for i=1:size(Num_sim,1)
    Y1 = rand(Num_sim(i),1);
    Y2 = rand(Num_sim(i),1);
    N1=sqrt(-2*log(Y1)).*cos(2*Y2*pi);
    N2=sqrt(-2*log(Y1)).*sin(2*Y2*pi);
    average=mean(N1.^2+N2.^2)/2;
    int_up=average+1.96*std(N1.^2+N2.^2)/sqrt(2*Num_sim(i));
    int_down=average-1.96*std(N1.^2+N2.^2)/sqrt(2*Num_sim(i));
%     eval(['Mean_' num2str(Num_sim(i)) '=average;']);
%     eval(['Intup_' num2str(Num_sim(i)) '=int_up;']);
%     eval(['Intdown_' num2str(Num_sim(i)) '=int_down;']);
    Mean_BM(i)=average;
    INTUP_BM(i)=int_up;
    INTDW_BM(i)=int_down;
end

% Plot the results
figure
plot(Num_sim,[Mean_BM' INTUP_BM' INTDW_BM'])
title('Integration with Box-Muller trasformation');
xlabel('Number of Simulations');
ylabel('Integral Value');
h=legend('Mean','CI lower bound','CI upper bound',2);
%*************************************************************************



