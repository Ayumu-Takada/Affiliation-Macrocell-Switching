clear;

num_users = 5;
distance = 50;
num_start = 0;
num_end = 500;
num_file = num_end-num_start+1;
a=1;
num_scheduling_users = 1;
num_cell = 7;
con_start = 21;         %21Å`ÉJÉEÉìÉg
num_sub_flame = 60;
num_rb = 100;
FI = zeros(1, num_file);
Throughput_PF_temp = zeros(1, num_file);
sum_square = zeros(1, num_file);
square_sum = zeros(1, num_file);
FI2 = zeros(1, num_file);
Throughput_PF_temp2 = zeros(1, num_file);
sum_square2 = zeros(1, num_file);
square_sum2 = zeros(1, num_file);
FI3 = zeros(1, num_file);
Throughput_PF_temp3 = zeros(1, num_file);
sum_square3 = zeros(1, num_file);
square_sum3 = zeros(1, num_file);


% proposed
for rng = num_start:num_end
    load(['./result/proposed_p1_th4/',num2str(num_users),'user/result_d',num2str(distance),'_rng',num2str(rng),'.mat'],'cumulative_throughput')
    square_sum_temp = zeros(num_cell, num_users);
    for macro_cell = 1:num_cell
        for user = 1:num_users
            for sub_flame = con_start:num_sub_flame
                sum_square(rng + 1) = squeeze(sum_square(rng + 1)) + squeeze(cumulative_throughput(macro_cell, user, sub_flame))/(num_sub_flame - con_start + 1)/num_rb;
                Throughput_PF_temp(rng + 1) = squeeze(Throughput_PF_temp(rng + 1)) + squeeze(cumulative_throughput(macro_cell, user, sub_flame))/(num_sub_flame - con_start + 1)/7/num_rb;
            end
        end
    end
    sum_square(rng + 1) = sum_square(rng + 1).^2;
    for macro_cell = 1:num_cell
        for user = 1:num_users
            for sub_flame = con_start:num_sub_flame
                square_sum_temp(macro_cell, user) = squeeze(square_sum_temp(macro_cell, user)) + squeeze(cumulative_throughput(macro_cell, user, sub_flame))/(num_sub_flame - con_start + 1)/num_rb;
            end
            square_sum_temp(macro_cell, user) = square_sum_temp(macro_cell, user).^2;
        end
    end
    square_sum(rng + 1) = num_users * num_cell * sum(sum(square_sum_temp));
    FI(rng + 1) = sum_square(rng + 1) ./ square_sum(rng + 1);    
 end
Fairness_Index_PF = sum(FI(:)) / num_file;
Throughput_PF = sum(Throughput_PF_temp(:)) / num_file / num_cell;

figure(a)
hold on
plot(Fairness_Index_PF, Throughput_PF,'.b','MarkerSize',30)
hold off




% conventional
for rng = num_start:num_end
    load(['./result/conventional/',num2str(num_users),'user/result_d',num2str(distance),'_rng',num2str(rng),'.mat'],'cumulative_throughput')
    square_sum_temp3 = zeros(num_cell, num_users);
    for macro_cell = 1:num_cell
        for user = 1:num_users
            for sub_flame = con_start:num_sub_flame
                sum_square3(rng + 1) = squeeze(sum_square3(rng + 1)) + squeeze(cumulative_throughput(macro_cell, user, sub_flame))/(num_sub_flame - con_start + 1)/num_rb;
                Throughput_PF_temp3(rng + 1) = squeeze(Throughput_PF_temp3(rng + 1)) + squeeze(cumulative_throughput(macro_cell, user, sub_flame))/(num_sub_flame - con_start + 1)/7/num_rb;
            end
        end
    end
    sum_square3(rng + 1) = sum_square3(rng + 1).^2;
    for macro_cell = 1:num_cell
        for user = 1:num_users
            for sub_flame = con_start:num_sub_flame
                square_sum_temp3(macro_cell, user) = squeeze(square_sum_temp3(macro_cell, user)) + squeeze(cumulative_throughput(macro_cell, user, sub_flame))/(num_sub_flame - con_start + 1)/num_rb;
            end
            square_sum_temp3(macro_cell, user) = square_sum_temp3(macro_cell, user).^2;
        end
    end
    square_sum3(rng + 1) = num_users * num_cell * sum(sum(square_sum_temp3));
    FI3(rng + 1) = sum_square3(rng + 1) ./ square_sum3(rng + 1);    
 end
Fairness_Index_PF3 = sum(FI3(:)) / num_file;
Throughput_PF3 = sum(Throughput_PF_temp3(:)) / num_file / num_cell;

figure(a)
hold on
plot(Fairness_Index_PF3, Throughput_PF3,'pk','MarkerSize',10)
hold off



xlabel('Fairness Index','FontSize',10,'FontName','Arial')
ylabel('Throughput (bps/Hz/cell)','FontSize',10,'FontName','Arial')
legend({'Proposed','Conventional'},'Location','southeast','Fontsize',10)
% legend({'proposed','conventional'},'Location','northeast','Fontsize',10)
% legend({'proposed(sum)','proposed(each)','conventional'},'Location','southwest','Fontsize',10)


