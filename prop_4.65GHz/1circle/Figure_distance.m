clear;

num_users = 3;
distance = [50,100,150,200];
num_start = 0;
num_end = 499;
num_file = num_end-num_start+1;
a=1;
num_scheduling_users = 1;
num_cell = 7;
con_start = 21;         %21～カウント
num_sub_flame = 60;
num_rb = 100;

%右軸距離，縦軸スループット

for u = 1:numel(distance)
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
    FI4 = zeros(1, num_file);
    Throughput_PF_temp4 = zeros(1, num_file);
    sum_square4 = zeros(1, num_file);
    square_sum4 = zeros(1, num_file);

    for rng = num_start:num_end
        load(['./result/proposed_p1_th4_28GHz/',num2str(num_users),'user/result_d',num2str(distance(u)),'_rng',num2str(rng),'.mat'],'cumulative_throughput')
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
    if u == 1
        plot(Fairness_Index_PF, Throughput_PF,'.b','MarkerSize',30)
    elseif u == 2
        plot(Fairness_Index_PF, Throughput_PF,'.r','MarkerSize',30)
    elseif u == 3
        plot(Fairness_Index_PF, Throughput_PF,'.k','MarkerSize',30)
    elseif u == 4
        plot(Fairness_Index_PF, Throughput_PF,'.g','MarkerSize',30)
    end
    hold off



    % proposed_p2
    for rng = num_start:num_end
        load(['./result/conventional_28GHz/',num2str(num_users),'user/result_d',num2str(distance(u)),'_rng',num2str(rng),'.mat'],'cumulative_throughput')
        square_sum_temp2 = zeros(num_cell, num_users);
        for macro_cell = 1:num_cell
            for user = 1:num_users
                for sub_flame = con_start:num_sub_flame
                    sum_square2(rng + 1) = squeeze(sum_square2(rng + 1)) + squeeze(cumulative_throughput(macro_cell, user, sub_flame))/(num_sub_flame - con_start + 1)/num_rb;
                    Throughput_PF_temp2(rng + 1) = squeeze(Throughput_PF_temp2(rng + 1)) + squeeze(cumulative_throughput(macro_cell, user, sub_flame))/(num_sub_flame - con_start + 1)/7/num_rb;
                end
            end
        end
        sum_square2(rng + 1) = sum_square2(rng + 1).^2;
        for macro_cell = 1:num_cell
            for user = 1:num_users
                for sub_flame = con_start:num_sub_flame
                    square_sum_temp2(macro_cell, user) = squeeze(square_sum_temp2(macro_cell, user)) + squeeze(cumulative_throughput(macro_cell, user, sub_flame))/(num_sub_flame - con_start + 1)/num_rb;
                end
                square_sum_temp2(macro_cell, user) = square_sum_temp2(macro_cell, user).^2;
            end
        end
        square_sum2(rng + 1) = num_users * num_cell * sum(sum(square_sum_temp2));
        FI2(rng + 1) = sum_square2(rng + 1) ./ square_sum2(rng + 1);    
     end
    Fairness_Index_PF2 = sum(FI2(:)) / num_file;
    Throughput_PF2 = sum(Throughput_PF_temp2(:)) / num_file / num_cell;

    figure(a)
    hold on
    if u == 1
        plot(Fairness_Index_PF2, Throughput_PF2,'pb','MarkerSize',10)
    elseif u == 2
        plot(Fairness_Index_PF2, Throughput_PF2,'pr','MarkerSize',10)
    elseif u == 3
        plot(Fairness_Index_PF2, Throughput_PF2,'pk','MarkerSize',10)
    elseif u == 4
        plot(Fairness_Index_PF2, Throughput_PF2,'pg','MarkerSize',10)
    end
    hold off

    % % proposed_p3
    % for rng = num_start:num_end
    %     load(['./result/proposed_p3_th4/',num2str(num_users(u)),'user/result_d',num2str(distance),'_rng',num2str(rng),'.mat'],'cumulative_throughput')
    %     square_sum_temp3 = zeros(num_cell, num_users(u));
    %     for macro_cell = 1:num_cell
    %         for user = 1:num_users(u)
    %             for sub_flame = con_start:num_sub_flame
    %                 sum_square3(rng + 1) = squeeze(sum_square3(rng + 1)) + squeeze(cumulative_throughput(macro_cell, user, sub_flame))/(num_sub_flame - con_start + 1)/num_rb;
    %                 Throughput_PF_temp3(rng + 1) = squeeze(Throughput_PF_temp3(rng + 1)) + squeeze(cumulative_throughput(macro_cell, user, sub_flame))/(num_sub_flame - con_start + 1)/7/num_rb;
    %             end
    %         end
    %     end
    %     sum_square3(rng + 1) = sum_square3(rng + 1).^2;
    %     for macro_cell = 1:num_cell
    %         for user = 1:num_users(u)
    %             for sub_flame = con_start:num_sub_flame
    %                 square_sum_temp3(macro_cell, user) = squeeze(square_sum_temp3(macro_cell, user)) + squeeze(cumulative_throughput(macro_cell, user, sub_flame))/(num_sub_flame - con_start + 1)/num_rb;
    %             end
    %             square_sum_temp3(macro_cell, user) = square_sum_temp3(macro_cell, user).^2;
    %         end
    %     end
    %     square_sum3(rng + 1) = num_users(u) * num_cell * sum(sum(square_sum_temp3));
    %     FI3(rng + 1) = sum_square3(rng + 1) ./ square_sum3(rng + 1);    
    %  end
    % Fairness_Index_PF3 = sum(FI3(:)) / num_file;
    % Throughput_PF3 = sum(Throughput_PF_temp3(:)) / num_file / num_cell;
    % 
    % figure(a)
    % hold on
    % if u == 1
    %     plot(Fairness_Index_PF3, Throughput_PF3,'+b','MarkerSize',10)
    % elseif u == 2
    %     plot(Fairness_Index_PF3, Throughput_PF3,'+r','MarkerSize',10)
    % elseif u == 3
    %     plot(Fairness_Index_PF3, Throughput_PF3,'+k','MarkerSize',10)
    % elseif u == 4
    %     plot(Fairness_Index_PF3, Throughput_PF3,'+g','MarkerSize',10)
    % end
    % hold off

    % conventional
    % for rng = num_start:num_end
    %     load(['./result/conventional_28GHz/',num2str(num_users(u)),'user/result_d',num2str(distance),'_rng',num2str(rng),'.mat'],'cumulative_throughput')
    %     square_sum_temp4 = zeros(num_cell, num_users(u));
    %     for macro_cell = 1:num_cell
    %         for user = 1:num_users(u)
    %             for sub_flame = con_start:num_sub_flame
    %                 sum_square4(rng + 1) = squeeze(sum_square4(rng + 1)) + squeeze(cumulative_throughput(macro_cell, user, sub_flame))/(num_sub_flame - con_start + 1)/num_rb;
    %                 Throughput_PF_temp4(rng + 1) = squeeze(Throughput_PF_temp4(rng + 1)) + squeeze(cumulative_throughput(macro_cell, user, sub_flame))/(num_sub_flame - con_start + 1)/7/num_rb;
    %             end
    %         end
    %     end
    %     sum_square4(rng + 1) = sum_square4(rng + 1).^2;
    %     for macro_cell = 1:num_cell
    %         for user = 1:num_users(u)
    %             for sub_flame = con_start:num_sub_flame
    %                 square_sum_temp4(macro_cell, user) = squeeze(square_sum_temp4(macro_cell, user)) + squeeze(cumulative_throughput(macro_cell, user, sub_flame))/(num_sub_flame - con_start + 1)/num_rb;
    %             end
    %             square_sum_temp4(macro_cell, user) = square_sum_temp4(macro_cell, user).^2;
    %         end
    %     end
    %     square_sum4(rng + 1) = num_users(u) * num_cell * sum(sum(square_sum_temp4));
    %     FI4(rng + 1) = sum_square4(rng + 1) ./ square_sum4(rng + 1);    
    %  end
    % Fairness_Index_PF4 = sum(FI4(:)) / num_file;
    % Throughput_PF4 = sum(Throughput_PF_temp4(:)) / num_file / num_cell;
    % 
    % figure(a)
    % hold on
    % if u == 1
    %     plot(Fairness_Index_PF4, Throughput_PF4,'*b','MarkerSize',10)
    % elseif u == 2
    %     plot(Fairness_Index_PF4, Throughput_PF4,'*r','MarkerSize',10)
    % elseif u == 3
    %     plot(Fairness_Index_PF4, Throughput_PF4,'*k','MarkerSize',10)
    % elseif u == 4
    %     plot(Fairness_Index_PF4, Throughput_PF4,'*g','MarkerSize',10)
    % end
    % hold off

end


xlim([0.1 0.9])
ylim([0 3])
box on
xlabel('Fairness Index','FontSize',10,'FontName','Arial')
ylabel('Throughput (bps/Hz/cell)','FontSize',10,'FontName','Arial')
%legend({'conventional'},'Location','southeast','Fontsize',10)
%legend({'proposed 1','proposed 2','proposed 3','conventional'},'Location','southeast','Fontsize',10)
% str = {'Nu=5,15,20'};
% text(0.332,0.44,str)
saveas(gcf,"result\fig\Figure_distance\28GHz\" + num_users + "user.fig")