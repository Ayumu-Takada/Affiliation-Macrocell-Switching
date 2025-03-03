clear;
tic
num_users = 3;
distance = 150;
num_start = 0;
num_end = 99;
num_file = num_end-num_start+1;
x=3;
num_scheduling_users = 1;
num_cell = 7;
con_start = 21;         %21～カウント
num_sub_flame = 60;
num_rb = 100;
band_per_rb = 60*12*10^3;             % frequency band range for each rb (Hz)
band = band_per_rb * num_rb;        % total frequency band
rnd = -174;             % Reciever Noise Density
N_f = 9;                % Noise Figure (dB)
noise_power = rnd + 10*log10( band ) + N_f;
noise = 10^( noise_power / 10 );
SINR_before_per_line1 = zeros(1,12);
SINR_before_per_line2 = zeros(1,12);
SINR_after_per_line1 = zeros(1,12);
SINR_after_per_line2 = zeros(1,12);
i=1;

% proposed 正しい提案法
for rng = num_start:num_end
    load(['./result/proposed/',num2str(num_users),'user/result_d',num2str(distance),'_rng',num2str(rng),'.mat'],'active_proposed')
    load(['./result/proposed/',num2str(num_users),'user/result_d',num2str(distance),'_rng',num2str(rng),'.mat'],'active_line')
    for line = 1:numel(active_line(:,1))
       if active_line(line,2) >= con_start
%            if active_line(line,3) < 8
               a = find(active_proposed(line,:,1)~=0);
               target_signal_before1 = active_proposed(line,a,1) ;
               target_signal_after1 = active_proposed(line,a,3) ;
               interference_before1 = active_proposed(line,a,5) ;
               interference_after1 = active_proposed(line,a,7) ;
               for sc = 1:12
                   SINR_before_per_line1(sc) = target_signal_before1(sc) / (interference_before1(sc) + 10^( noise_power / 10 )) ;
                   SINR_after_per_line1(sc) = target_signal_after1(sc) / (interference_after1(sc) + 10^( noise_power / 10 )) ;
               end
               SINR_before1(12*(i-1)+1:12*i) = SINR_before_per_line1;
               SINR_after1(12*(i-1)+1:12*i) = SINR_after_per_line1;
               i = i + 1;
%            end
%            if active_line(line,4) < 8
               a = find(active_proposed(line,:,1)~=0);
               target_signal_before2 = active_proposed(line,a,2) ;
               target_signal_after2 = active_proposed(line,a,4) ;
               interference_before2 = active_proposed(line,a,6) ;
               interference_after2 = active_proposed(line,a,8) ;
               for sc = 1:12
                   SINR_before_per_line2(sc) = target_signal_before2(sc) / (interference_before2(sc) + 10^( noise_power / 10 )) ;
                   SINR_after_per_line2(sc) = target_signal_after2(sc) / (interference_after2(sc) + 10^( noise_power / 10 )) ;
               end
               SINR_before1(12*(i-1)+1:12*i) = SINR_before_per_line2;
               SINR_after1(12*(i-1)+1:12*i) = SINR_after_per_line2;
               i = i + 1;
%            end
       end
    end
end

SINR_before1 = 10*log10(SINR_before1);
SINR_after1 = 10*log10(SINR_after1);
 
figure(x)
hold on
Before = cdfplot(SINR_before1);
After = cdfplot(SINR_after1);
hold off
xlabel('SINR (dB)','FontSize',10,'FontName','Arial')
ylabel('Probability','FontSize',10,'FontName','Arial')
legend({'Without Switching','With Switching'},'Location','southeast','Fontsize',10)
toc
% legend({'proposed(sum)','proposed(each)','conventional'},'Location','southwest','Fontsize',10)