clear;

timeslot = 70;
timeslot_PF = 420;
num_users = 20;
distance = 150;
num_cell = 7;
a = 5;

num_RB = 100;
con_start = 20;
count_start = 7;
num_scheduling_users = 1;


num_file = 100;
rng_value = (0:num_file - 1);
Throughput_PF_best = zeros(num_cell, num_file);
Throughput_PF_worst = zeros(num_cell, num_file);
Throughput_PF_best2 = zeros(num_cell, num_file);
Throughput_PF_worst2 = zeros(num_cell, num_file);
cumulative_all = zeros(num_cell,num_users, num_file);
throughput_PF_sort = zeros(num_cell,num_users);
throughput_PF_sortx = zeros(num_cell,num_users);
throughput_PF_sort2 = zeros(num_cell,num_users);
throughput_PF_sortx2 = zeros(num_cell,num_users);

for rng = 0:numel(rng_value)-1
    load(['./result/proposed/',num2str(num_users),'user/result_d',num2str(distance),'_rng',num2str(rng),'.mat'],'cumulative_throughput')
    for i = 1:num_cell
        for j = 1:num_users
            throughput_PF_sort(i,j) = sum(cumulative_throughput(i,j,21:60))/(60-21+1)/7;
            cumulative_all(i,j,rng+1) = sum(cumulative_throughput(i,j,21:60));
        end
        throughput_PF_sortx(i,:) = sort(throughput_PF_sort(i,:),2); 
    end
    Throughput_PF_worst(:, rng + 1) = throughput_PF_sortx(:,1);
    Throughput_PF_best(:, rng + 1) = throughput_PF_sortx(:,end);
end
x_PF_best = reshape(Throughput_PF_best,[1,numel(Throughput_PF_best)]);
x_PF_worst = reshape(Throughput_PF_worst,[1,numel(Throughput_PF_worst)]);

for rng = 0:numel(rng_value)-1
    load(['./result/conventional/',num2str(num_users),'user/result_d',num2str(distance),'_rng',num2str(rng),'.mat'],'cumulative_throughput')
    for i = 1:num_cell
        for j = 1:num_users
            throughput_PF_sort2(i,j) = sum(cumulative_throughput(i,j,21:60))/(60-21+1)/7;
        end
        throughput_PF_sortx2(i,:) = sort(throughput_PF_sort2(i,:),2); 
    end
    Throughput_PF_worst2(:, rng + 1) = throughput_PF_sortx2(:,1);
    Throughput_PF_best2(:, rng + 1) = throughput_PF_sortx2(:,end);
end
x_PF_best2 = reshape(Throughput_PF_best2,[1,numel(Throughput_PF_best2)]);
x_PF_worst2 = reshape(Throughput_PF_worst2,[1,numel(Throughput_PF_worst2)]);

%%
figure(a)
hold on
PF_worst = cdfplot(x_PF_worst);
PF_best = cdfplot(x_PF_best);
PF_worst2 = cdfplot(x_PF_worst2);
PF_worst2.LineStyle = '--';
PF_best2 = cdfplot(x_PF_best2);
PF_best2.LineStyle = '--';
hold off


set(gca,'FontSize',10,'FontName','Arial')
xlabel('Throughput (bits/user/timeslot)','FontSize',10,'FontName','Arial')
ylabel('Probability','FontSize',10,'FontName','Arial')
legend({'Worst user (Proposed)','Best user (Proposed)','Worst user (Conventional)','Best user (Conventional)'},'Location','southeast','FontSize',10,'FontName','Arial')