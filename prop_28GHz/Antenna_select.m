function [attribute, antenna_candidate] = Antenna_select(macro_cell_of_user, origin_points, antenna_coordinates_abs, rb, d)
%マクロセルに隣接する12個のピコセルの集合を取り出す

    attribute = zeros(19, 7, 100);
    for cell_index = 1:19
        for antenna_index = 1:7
            attribute(cell_index, antenna_index, rb) = cell_index;
        end
    end


    %最も遠い隣接ピコセルの距離=2*d
    l = 2*d+1;

    %中心から距離l以内のセルを格納
    antenna_candidate = zeros(19, 7, 100);
    for i = 1:19
        for k = 1:7
            if i ~= macro_cell_of_user
                if l >= abs(antenna_coordinates_abs(i, k) - origin_points(macro_cell_of_user))
                    antenna_candidate(i, k, rb) = macro_cell_of_user;
                end
            end
        end
    end
end