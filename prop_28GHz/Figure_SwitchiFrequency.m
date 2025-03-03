clear;

num_users = [5,10,15,20];
distance = [50,100,150];
num_start = 0;
num_end = 500;
num_file = num_end-num_start+1;
x=1;
num_scheduling_users = 1;
num_cell = 7;
con_start = 21;         %21`ƒJƒEƒ“ƒg
num_sub_flame = 60;
num_rb = 100;
active_for_plot = zeros(numel(num_users),numel(distance));

for j = 1:numel(distance)
    for i = 1:numel(num_users)
        for rng = num_start:num_end
            load(['./result/proposed_p1_th4/',num2str(num_users(i)),'user/result_d',num2str(distance(j)),'_rng',num2str(rng),'.mat'],'active_line')
            for k = 1:numel(active_line(:,1))
                if active_line(k,2) > 20
                    if active_line(k,3) < 8 || active_line(k,4) < 8
                        active_for_plot(i,j) = active_for_plot(i,j) + 1/(num_sub_flame - con_start)/num_file;
                    end
                end
            end
        end
    end
    figure(x)
    hold on
    plot(active_for_plot(:,j),'o-')
    hold off
end

xlabel('No. of UEs','FontSize',10,'FontName','Arial')
ylabel('Switch Frequency (/subframe)','FontSize',10,'FontName','Arial')
legend({'50m','100m','150m'},'Location','southeast','Fontsize',10)