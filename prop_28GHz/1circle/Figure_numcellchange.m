clear;

num_users = [3,5,10,15,20];
distance =200;
num_start = 0;
num_end = 499;
num_file = num_end-num_start+1;
a=1;
num_scheduling_users = 1;
num_cell = 7;
con_start = 21;         %21～カウント
num_sub_flame = 60;
num_rb = 100;

%rbごとのピコセル帰属切り替えの総数

% proposed_p1
for u = 1:numel(num_users)
    sum_square = zeros(1, num_file);

    for rng = num_start:num_end
        load(['./result/proposed_p1_th4_28GHz/',num2str(num_users(u)),'user/result_d',num2str(distance),'_rng',num2str(rng),'.mat'],'change_count')
        square_sum_temp = zeros(num_cell, num_users(u));

        for sub_flame = 1:num_sub_flame
            for rb = 1:num_rb
                sum_square(rng + 1) = squeeze(sum_square(rng + 1)) + squeeze(change_count(rb, sub_flame));
            end
        end        
    end
    
    change_count = sum(sum_square(:))/num_rb/num_sub_flame/num_file;
    change_count = change_count/19;

    figure(a)
    

    hold on
    if u == 1
        plot(3, change_count,'.b','MarkerSize',30)
    elseif u == 2
        plot(5, change_count,'.r','MarkerSize',30)
    elseif u == 3
        plot(10, change_count,'.k','MarkerSize',30)
    elseif u == 4
        plot(15, change_count,'.g','MarkerSize',30)
    else
        plot(20, change_count,'.c','MarkerSize',30)
    end
    hold off

end

box on
%xlim([0.8 1])
ylim([0 1])
xlabel('No. of Users','FontSize',10,'FontName','Arial')
ylabel('帰属セル切り替えピコセル数/フレーム/セル','FontSize',10)
saveas(gcf,"result\figfile\Figure_numcellchange\28GHz\" + distance + "m.fig")