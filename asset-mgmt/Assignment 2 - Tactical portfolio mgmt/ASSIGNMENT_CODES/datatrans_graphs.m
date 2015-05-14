%% PLOT THE BENCHMARK

figure
plot(datex, benchprice)
hold on
plot(datex, points,'k o')
title('Benchmark price')
dateaxis('x',12)
xlim([datex(1) datex(end)])
grid on;


figure
plot(datex, pricexasset)
hold on
plot(datex, benchprice,'k :','linewidth',2)
title('Industries & Benchmark (black bold line)')
dateaxis('x',12)
xlim([datex(1) datex(end)])
grid on;


%% SOME GRAPHS TO GET A VISUAL OF THE ACTUAL BEHAVIOUR OF THE INDUSTRIES

for i=1:4:48
figure

subplot(2,2,1)
plot(datex,pricexasset(:,i))
hold on
plot(datex, benchprice,'k -.')
title(strcat(industries_(i), ' industry portfolio'))
dateaxis('x',12)
xlim([datex(1) datex(end)])
grid on;

subplot(2,2,2)
plot(datex,pricexasset(:,i+1))
hold on
plot(datex, benchprice,'k -.')
title(strcat(industries_(i+1), ' industry portfolio'))
dateaxis('x',12)
xlim([datex(1) datex(end)])
grid on;

subplot(2,2,3)
plot(datex,pricexasset(:,i+2))
hold on
plot(datex, benchprice,'k -.')
title(strcat(industries_(i+2), ' industry portfolio'))
dateaxis('x',12)
xlim([datex(1) datex(end)])
grid on;

subplot(2,2,4)
plot(datex,pricexasset(:,i+3))
hold on
plot(datex, benchprice,'k -.')
title(strcat(industries_(i+3), ' industry portfolio'))
dateaxis('x',12)
xlim([datex(1) datex(end)])
grid on;

end;



% Intuitively we can say that the benchmark might affect the signals

