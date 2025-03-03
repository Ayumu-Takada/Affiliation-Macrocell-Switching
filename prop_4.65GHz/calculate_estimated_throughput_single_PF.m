function [ throughput_est_sc ] = calculate_estimated_throughput_single_PF( signal_power_new, macro_cell_of_user, noise, outer_cell_index, attribute, rb, UE_combinations, sub_flame)

throughput_est_sc = zeros(1,12);
UE_comb = UE_combinations(macro_cell_of_user, :);

    for sc = 1:12
        power_macro = 0;
        desired_signal_amplitude = 0;
        SINR = 0;
        N_A = 0;

        %自セル内信号振幅の和計算
        for cell_index = 1:19
            for antenna_index = 1:7
                if attribute(cell_index, antenna_index, rb) == macro_cell_of_user
                    desired_signal_amplitude = desired_signal_amplitude + sqrt(signal_power_new(macro_cell_of_user, UE_comb(sub_flame), cell_index, antenna_index, (rb-1) * 12 + sc));
                    N_A = N_A + 1;
                end
            end
        end

        %干渉計算
        if (sub_flame-1) ~= 0
            for antenna_index = 1:7
                for l = 1:6
                    cell_index = outer_cell_index(macro_cell_of_user, l);
                    if cell_index ~= 0
                        if attribute(cell_index, antenna_index, rb) ~= macro_cell_of_user
                            %干渉は１つ前のサブフレームで割り当てられたユーザを使う
                            power_macro = power_macro + signal_power_new(cell_index, UE_comb(sub_flame-1), macro_cell_of_user, antenna_index, (rb-1) * 12 + sc);
                        end
                    end
                end          
            end
        end

        %自セル内信号電力計算
        desired_signal = (desired_signal_amplitude)^2;

        %干渉なしテスト
        %power_macro = 0;

        SINR = SINR + (desired_signal)/(N_A*10^( noise / 10 ) + power_macro);
        throughput_est_sc(macro_cell_of_user, sc) = log2(1 + SINR);
    end
end


        