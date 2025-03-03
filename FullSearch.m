function [throughput_SC] = FullSearch( signal_power_new, macro_cell_of_user, noise, outer_cell_index, attribute, rb, UE_combinations, sub_flame)

% throughput_SC = zeros(19,12);
    UE_comb = UE_combinations(macro_cell_of_user, :);
  
    for sc = 1:12
        power_macro = 0;
        desired_signal_amplitude = 0;
        desired_signal = 0;
        SINR = 0;
        N_A = 0;

        %©ƒZƒ‹“àM†U•‚Ì˜aŒvZ
        for cell_index = 1:19
            for antenna_index = 1:7
                if attribute(cell_index, antenna_index, rb) == macro_cell_of_user
                    desired_signal_amplitude = desired_signal_amplitude + sqrt(signal_power_new(macro_cell_of_user, UE_comb(sub_flame), cell_index, antenna_index, (rb-1) * 12 + sc));
                    N_A = N_A + 1;
                end
            end
        end

        %Š±ÂŒvZ
        for antenna_index = 1:7
            for l = 1:6
                cell_index = outer_cell_index(macro_cell_of_user, l);
                if cell_index ~= 0
                    if attribute(cell_index, antenna_index, rb) ~= macro_cell_of_user
                        power_macro = power_macro + signal_power_new(cell_index, UE_comb(sub_flame), macro_cell_of_user, antenna_index, (rb-1) * 12 + sc);
                    end
                end
            end          
        end
        %©ƒZƒ‹“àM†“d—ÍŒvZ
        desired_signal = (desired_signal_amplitude)^2;

        SINR = (desired_signal)/(N_A*10^( noise / 10 ) + power_macro);
        throughput_SC(macro_cell_of_user, sc) = log2(1 + SINR);
    end
end