%%オーバーラップシングルユーザ割り当て
clear;
trial = 0;
trial_start = 0;
num_trial = trial - trial_start + 1;
time_indicator = TimeIndicator("3user200m",num_trial);
time_indicator.start();
for rng_value = trial_start:trial
    rng(rng_value);
    num_macro_cell = 19;
    num_users = 3;                   % # of users
    distance = 200;                   %distance between BSs
    num_scheduling_users = 1;
    num_selected_antenna = 1;
    d_LOS = 36;

    %% Model parameters:
    
    num_cell = 7;                       % # of cell
    num_outer_macro = 6;                % # of cell around central cell
    overlap_cell = 19;                  % # of overlapping cell

    num_rb = 100;                        % # of resource blocks in 1 OFDM symbol
    num_sc_in_rb = 12;                  % # of subcarriers in resource blocks
    num_sc = num_rb * num_sc_in_rb;     % # of total subcarriers

    band_per_rb = 60*12*10^3;             % frequency band range for each rb (Hz)
    band = band_per_rb * num_rb;        % total frequency band
    f_c = 4.65;                         % carrier frequency
    
    shadowing_ave = 0;
    shadowing_var = 4;
    rnd = -174;                         % Reciever Noise Density
    N_f = 9;                            % Noise Figure (dB)
    noise_power = rnd + 10*log10( band ) + N_f;
    eirp = 0 + 20;
    eirp_sc = 10*log10(10^(eirp/10)/num_sc_in_rb);  %送信電力
    time_interval = 420;
    num_sub_flame = time_interval/7;
    cumulative_throughput = zeros(num_macro_cell, num_users, num_sub_flame);
    cumulative_throughput_all = zeros(num_macro_cell, num_users);
    % throughput = zeros(1,time_interval);
    cumulative_throughput_first = ones(num_macro_cell, num_users);
    UE_comb = zeros(num_macro_cell, num_rb, num_sub_flame);
    UE_comb_selected = zeros(num_macro_cell, num_rb, num_sub_flame);
    %CoMP_count = zeros(num_sub_flame,num_rb);
    antenna_candidate_decided = zeros(19, 7, 100);
    change_count = zeros(num_rb, num_sub_flame);
    % % 状態数と行動数の定義（例として）
    % num_states = 2^18;
    % num_actions = 20;
    beta = 0;
    gammma = 1;


    %% Create coordinates for each BS:
    antenna_coordinates = create_bs_coordinate( distance );
    

    %% Create Coordinates for each user:
     user_coordinates = zeros(num_users, num_macro_cell);
     micro_belong_user = zeros(num_macro_cell,num_users);               %micro cell number(up to 7*19) that user belong
     
     for macro_cell = 1:num_macro_cell
        [user_coordinates(:, macro_cell),user_placements] = create_user_coordinates( antenna_coordinates, num_users, distance );  %output the user's location in macro cell and # of micro cell that user belongs 
        for user = 1:num_users
            micro_belong_user(macro_cell,user) = user_placements(user)  ;%+ (macro_cell-1)*7; %output cell number that the user locate in system 
        end
     end
    
     
     micro_index = zeros(num_macro_cell,overlap_cell);
     %反時計回りにナンバリング
     micro_index(1,:) = [1 2 3 4 5 6 7 11 12 19 20 27 28 30 35 37 38 45 46];
     micro_index(2,:) = [8 9 10 11 12 13 14 53 62 61 21 20 2 7 45 44 130 129 54 ];
     micro_index(3,:) = [15 16 17 18 19 20 21 60 69 68 77 76 23 28 3 2  11 10 61 ];
     micro_index(4,:) = [22 23 24 25 26 27 28 18 76 75 84 83 86 91 31 30 4 3 19  ];
     micro_index(5,:) = [29 30 31 32 33 34 35 4 27 26 91 90 93 98 101 100 39 38 5 ];
     micro_index(6,:) = [36 37 38 39 40 41 42 46 6 5 35 34 100 105 108 107 116 115 47 ];
     micro_index(7,:) = [43 44 45 46 47 48 49 130 13 12 7 6 37 42 115 114 123 122 131 ];
     micro_index(8,:) = [50 51 52 53 54 55 56 0 0 0 63 62 9 14 129 128 0 0 0];
     micro_index(9,:) = [57 58 59 60 61 62 63 0 0 0 70 69 16 21 10 9 53 52 0];
     micro_index(10,:) = [64 65 66 67 68 69 70 0 0 0 0 0 72 77 17 16 60 59 0];
     micro_index(11,:) = [71 72 73 74 75 76 77 67 0 0 0 0 79 84 24 23 18 17 68];
     micro_index(12,:) = [78 79 80 81 82 83 84 74 0 0 0 0 0 0 87 86 25 24 75];
     micro_index(13,:) = [85 86 87 88 89 90 91 25 83 82 0 0 0 0 94 93 32 31 26];
     micro_index(14,:) = [92 93 94 95 96 97 98 32 90 89 0 0 0 0 0 0 102 101 33];
     micro_index(15,:) = [99 100 101 102 103 104 105 39 34 33 98 97 0 0 0 0 109 108 40];
     micro_index(16,:) = [106 107 108 109 110 111 112 116 41 40 105 104 0 0 0 0 0 0 117];
     micro_index(17,:) = [113 114 115 116 117 118 119 123 48 47 42 41 107 112 0 0 0 0 124];
     micro_index(18,:) = [120 121 122 123 124 125 126 0 132 131 49 48 114 119 0 0 0 0 0];
     micro_index(19,:) = [127 128 129 130 131 132 133 0 55 54 14 13 44 49 122 121 0 0 0 ];
     

     outer_micro_index = zeros(num_cell*num_macro_cell,num_cell-1);
     % 隣接セルマクロセル番号
     outer_micro_index(1,:)=[2 3 4 5 6 7];
     outer_micro_index(2,:)=[1 3 7 11 12 20];
     outer_micro_index(3,:)=[1 2 4 19 20 28];
     outer_micro_index(4,:)=[1 3 5 27 28 30];
     outer_micro_index(5,:)=[1 4 6 30 35 38];
     outer_micro_index(6,:)=[1 5 7 37 38 46];
     outer_micro_index(7,:)=[1 2 6 12 45 46];
     outer_micro_index(8,:)=[9 10 11 12 13 14];
     outer_micro_index(9,:)=[8 10 14 53 54 62];
     outer_micro_index(10,:)=[8 9 11 21 61 62];
     outer_micro_index(11,:)=[2 8 10 12 20 21];
     outer_micro_index(12,:)=[2 7 8 11 13 45];
     outer_micro_index(13,:)=[8 12 14 44 45 130];
     outer_micro_index(14,:)=[8 9 13 54 129 130];
     outer_micro_index(15,:)=[16 17 18 19 20 21];
     outer_micro_index(16,:)=[15 17 21 60 61 69];
     outer_micro_index(17,:)=[15 16 18 68 69 77];
     outer_micro_index(18,:)=[15 17 19 76 77 23];
     outer_micro_index(19,:)=[3 15 18 20 23 28];
     outer_micro_index(20,:)=[2 3 11 15 19 21];
     outer_micro_index(21,:)=[10 11 15 16 20 61];
     outer_micro_index(22,:)=[23 24 25 26 27 28];
     outer_micro_index(23,:)=[18 19 22 24 28 76];
     outer_micro_index(24,:)=[22 23 25 75 76 84];
     outer_micro_index(25,:)=[22 24 26 83 84 86];
     outer_micro_index(26,:)=[22 25 27 31 86 91];
     outer_micro_index(27,:)=[4 22 26 28 30 31];
     outer_micro_index(28,:)=[3 4 19 22 23 27];
     outer_micro_index(29,:)=[30 31 32 33 34 35];
     outer_micro_index(30,:)=[4 5 27 29 31 35];
     outer_micro_index(31,:)=[26 27 29 30 32 91];
     outer_micro_index(32,:)=[29 31 33 90 91 93];
     outer_micro_index(33,:)=[29 32  34 93 98 101];
     outer_micro_index(34,:)=[29 33 35 100 101 39];
     outer_micro_index(35,:)=[5 29 30 34 38 39];
     outer_micro_index(36,:)=[37 38 39 40 41 42];
     outer_micro_index(37,:)=[6 36 38 42 46 47];
     outer_micro_index(38,:)=[5 6 35 36 37 39];
     outer_micro_index(39,:)=[34 35 36 38 40 100];
     outer_micro_index(40,:)=[36 39 41 100 105 108];
     outer_micro_index(41,:)=[36 40 42 107 108 116];
     outer_micro_index(42,:)=[36 37 41 115 116 47];
     outer_micro_index(43,:)=[44 45 46 47 48 49];
     outer_micro_index(44,:)=[13 43 45 49 130 131];
     outer_micro_index(45,:)=[7 12 13 43 44 46];
     outer_micro_index(46,:)=[6 7 37 43 45 47];
     outer_micro_index(47,:)=[37 42 43 46 48 115];
     outer_micro_index(48,:)=[43 47 49 114 115 123];
     outer_micro_index(49,:)=[43 44 48 122 123 131];
     outer_micro_index(50,:)=[51 52 53 54 55 56];
     outer_micro_index(51,:)=[50 52 56 0 0 0];
     outer_micro_index(52,:)=[50 51 53 63 0 0];
     outer_micro_index(53,:)=[9 50 52 54 62 63];
     outer_micro_index(54,:)=[9 14 50 53 55 129];
     outer_micro_index(55,:)=[50 54 56 128 129 0];
     outer_micro_index(56,:)=[50 51 55 0 0 0];
     outer_micro_index(57,:)=[58 59 60 61 62 63];
     outer_micro_index(58,:)=[57 59 63 0 0 0];
     outer_micro_index(59,:)=[57 58 60 70 0 0];
     outer_micro_index(60,:)=[16 57 59 61 69 70];
     outer_micro_index(61,:)=[10 16 21 57 60 62];
     outer_micro_index(62,:)=[9 10 53 57 61 63];
     outer_micro_index(63,:)=[52 53 57 58 62 0];
     outer_micro_index(64,:)=[65 66 67 68 69 70];
     outer_micro_index(65,:)=[64 66 70 0 0 0];
     outer_micro_index(66,:)=[64 65 67 0 0 0];
     outer_micro_index(67,:)=[64 66 68 72 0 0];
     outer_micro_index(68,:)=[17 64 67 69 72 77];
     outer_micro_index(69,:)=[16 17 60 64 68 70];
     outer_micro_index(70,:)=[59 60 64 65 69 0];
     outer_micro_index(71,:)=[72 73 74 75 76 77];
     outer_micro_index(72,:)=[67 68 71 73 77 0];
     outer_micro_index(73,:)=[71 72 74 0 0 0];
     outer_micro_index(74,:)=[71 73 75 79 0 0];
     outer_micro_index(75,:)=[24 71 74 76 79 84];
     outer_micro_index(76,:)=[18 23 24 71 75 77];
     outer_micro_index(77,:)=[17 18 68 71 72 76];
     outer_micro_index(78,:)=[79 80 81 82 83 84];
     outer_micro_index(79,:)=[74 75 78 80 84 0];
     outer_micro_index(80,:)=[78 79 81 0 0 0];
     outer_micro_index(81,:)=[78 80 82 0 0 0];
     outer_micro_index(82,:)=[78 81 83 87 0 0];
     outer_micro_index(83,:)=[25 78 82 84 86 87];
     outer_micro_index(84,:)=[24 25 75 78 79 83];
     outer_micro_index(85,:)=[86 87 88 89 90 91];
     outer_micro_index(86,:)=[25 26 83 85 87 91];
     outer_micro_index(87,:)=[82 83 85 86 88 0];
     outer_micro_index(88,:)=[85 87 89 0 0 0];
     outer_micro_index(89,:)=[85 88 90 94 0 0];
     outer_micro_index(90,:)=[32 85 89 91 93 94];
     outer_micro_index(91,:)=[26 31 32 85 86 90];
     outer_micro_index(92,:)=[93 94 95 96 97 98];
     outer_micro_index(93,:)=[32 33 90 92 94 98];
     outer_micro_index(94,:)=[89 90 92 93 95 0];
     outer_micro_index(95,:)=[92 94 96 0 0 0];
     outer_micro_index(96,:)=[92 95 97 0 0 0];
     outer_micro_index(97,:)=[92 96 98 102 0 0];
     outer_micro_index(98,:)=[33 92 93 97 101 102];
     outer_micro_index(99,:)=[100 101 102 103 104 105];
     outer_micro_index(100,:)=[34 39 40 99 101 105];
     outer_micro_index(101,:)=[33 34 98 99 102 100];
     outer_micro_index(102,:)=[97 98 99 101 103 0];
     outer_micro_index(103,:)=[99 102 104 0 0 0];
     outer_micro_index(104,:)=[99 103 105 109 0 0];
     outer_micro_index(105,:)=[40 99 100 104 108 109];
     outer_micro_index(106,:)=[107 108 109 110 111 112];
     outer_micro_index(107,:)=[41 106 108 112 116 117];
     outer_micro_index(108,:)=[40 41 105 106 107 109];
     outer_micro_index(109,:)=[104 105 106 108 110 0];
     outer_micro_index(110,:)=[106 109 111 0 0 0];
     outer_micro_index(111,:)=[106 110 112 0 0 0];
     outer_micro_index(112,:)=[106 107 111 117 0 0];
     outer_micro_index(113,:)=[114 115 116 117 118 119];
     outer_micro_index(114,:)=[48 113 115 119 123 124];
     outer_micro_index(115,:)=[42 47 48 113 114 116];
     outer_micro_index(116,:)=[41 42 107 113 115 117];
     outer_micro_index(117,:)=[107 112 113 116 118 0];
     outer_micro_index(118,:)=[113 117 119 0 0 0];
     outer_micro_index(119,:)=[113 114 118 124 0 0];
     outer_micro_index(120,:)=[121 122 123 124 125 126];
     outer_micro_index(121,:)=[120 122 126 132 0 0];
     outer_micro_index(122,:)=[49 120 121 123 131 132];
     outer_micro_index(123,:)=[48 49 114 120 122 124];
     outer_micro_index(124,:)=[114 119 120 123 125 0];
     outer_micro_index(125,:)=[120 124 126 0 0 0];
     outer_micro_index(126,:)=[120 121 125 0 0 0];
     outer_micro_index(127,:)=[128 129 130 131 132 133];
     outer_micro_index(128,:)=[55 127 129 133 0 0];
     outer_micro_index(129,:)=[14 54 55 127 128 130];
     outer_micro_index(130,:)=[13 14 44 127 129 131];
     outer_micro_index(131,:)=[44 49 122 127 130 132];
     outer_micro_index(132,:)=[121 122 127 131 133 0];
     outer_micro_index(133,:)=[127 128 132 0 0 0];


    % 各セルの絶対座標
    d = distance;
    r = (d/2) / cos( pi/6 );    % cell radius

    % 反時計回りにマクロセルセル中央座標を決定
    origin_points = [ 0, ...
                      -3*r + 2*d*1i, ...
                      -(9/2)*r - (1/2)*d*1i, ...
                      -(3/2)*r - (5/2)*d*1i, ...
                      3*r - 2*d*1i, ...
                      (9/2)*r + (1/2)*d*1i, ...
                      (3/2)*r + (5/2)*d*1i, ...
                      (-3*r + 2*d*1i)+(-3*r + 2*d*1i), ...
                      (-3*r + 2*d*1i)+(-(9/2)*r - (1/2)*d*1i), ...
                      (-(9/2)*r - (1/2)*d*1i)+(-(9/2)*r - (1/2)*d*1i), ...
                      (-(9/2)*r - (1/2)*d*1i)+(-(3/2)*r - (5/2)*d*1i), ...
                      (-(3/2)*r - (5/2)*d*1i)+(-(3/2)*r - (5/2)*d*1i), ...
                      (-(3/2)*r - (5/2)*d*1i)+(3*r - 2*d*1i), ...
                      (3*r - 2*d*1i)+(3*r - 2*d*1i), ...
                      (3*r - 2*d*1i)+((9/2)*r + (1/2)*d*1i), ...
                      ((9/2)*r + (1/2)*d*1i)+((9/2)*r + (1/2)*d*1i), ...
                      ((9/2)*r + (1/2)*d*1i)+((3/2)*r + (5/2)*d*1i), ...
                      ((3/2)*r + (5/2)*d*1i)+((3/2)*r + (5/2)*d*1i), ...
                      ((3/2)*r + (5/2)*d*1i)+(-3*r + 2*d*1i)];
    %ユーザーの絶対値
    user_coordinates_abs = origin_points + user_coordinates(1:num_users , :);
    %アンテナの絶対値
    antenna_coordinates_abs = zeros(num_macro_cell, num_cell);
    %アンテナとユーザーの距離（１マクロの２ユーザーと３マクロセルの４アンテナ（ミクロセル）の距離）
    d_from_bs = zeros(num_macro_cell, num_users, num_macro_cell, num_cell);
    
    %アンテナの絶対座標計算
    for macro_cell = 1:num_macro_cell
        for cell = 1:num_cell
            antenna_coordinates_abs(macro_cell, cell) = origin_points(macro_cell) + antenna_coordinates(cell);
        end
    end

    %ユーザーとアンテナの距離計算
    for macro_cell_of_user = 1:num_macro_cell
        for user = 1:num_users
            for macro_cell_of_micro_cell = 1:num_macro_cell
                for cell = 1:num_cell
                    d_from_bs(macro_cell_of_user, user, macro_cell_of_micro_cell, cell) =...
                        abs(user_coordinates_abs(user, macro_cell_of_user) - antenna_coordinates_abs(macro_cell_of_micro_cell, cell));
                end
            end
        end
    end
    %アンテナとユーザーの距離（三次元拡張）
    d_from_bs_3d = sqrt(d_from_bs.^2 + 8.5^2.*ones(num_macro_cell, num_users, num_macro_cell, num_cell));
    %伝搬損失
    plr = zeros(num_macro_cell, num_users, num_macro_cell, num_cell);
    %チャネル推定
    fading_channel_freq = zeros(num_macro_cell, num_users, num_macro_cell, overlap_cell, num_sc);
    
    % アンテナからユーザのチャネルがLOSとなる確率
    P_LOS = zeros(num_macro_cell, num_users, num_macro_cell, num_cell);
    % ユーザ-アンテナ間がLOSのとき1となる配列
    one_LOS = zeros(num_macro_cell, num_users, num_macro_cell, num_cell);
    
    %チャネルがレイリーかライシアンかを決定
    for macro_cell_of_user = 1:num_macro_cell
        for user = 1:num_users
            for macro_cell_of_micro_cell = 1:num_macro_cell
                for cell = 1:num_cell
                    d_ij = d_from_bs_3d(macro_cell_of_user, user, macro_cell_of_micro_cell, cell);
                    P_LOS(macro_cell_of_user, user, macro_cell_of_micro_cell, cell) = min(18/d_ij, 1)*(1-exp(-d_ij/d_LOS)) + exp(-d_ij/d_LOS);
                    if P_LOS(macro_cell_of_user, user, macro_cell_of_micro_cell, cell) > rand
                        one_LOS(macro_cell_of_user, user, macro_cell_of_micro_cell, cell) = 1;
                        fading_channel_freq(macro_cell_of_user, user, macro_cell_of_micro_cell, cell, :) = add_TDL_D_fading(band);
                    else
                        fading_channel_freq(macro_cell_of_user, user, macro_cell_of_micro_cell, cell, :) = add_TDL_A_fading(band);
                    end
                end
            end
        end
    end
    
    
    
    %信号電力（サブキャリア毎に算出）
    signal_power = zeros(num_macro_cell, num_users, num_macro_cell, num_cell, num_sc);
    %信号電力推定（リソースブロック毎に算出（12サブキャリア分の信号電力を平均））
    signal_power_est = zeros(num_macro_cell, num_users, num_macro_cell, num_cell, num_rb);
%   signal_power_antenna_select = zeros(num_users, num_cell, num_macro_cell, num_rb);

    for macro_cell_of_user = 1:num_macro_cell
        for user = 1:num_users
            for macro_cell_of_micro_cell = 1:num_macro_cell
                for cell = 1:num_cell
                    if one_LOS(macro_cell_of_user, user, macro_cell_of_micro_cell, cell) == 1
                        plr(macro_cell_of_user, user, macro_cell_of_micro_cell, cell) = 22.0*log10(d_from_bs_3d(macro_cell_of_user, user, macro_cell_of_micro_cell, cell)) + 28.0 + 20*log10(f_c);
                        const = 10^( sqrt(shadowing_var)*randn(1,1) / 10 ) * 10.^(( eirp_sc  - plr(macro_cell_of_user, user, macro_cell_of_micro_cell, cell) ) / 10);
                    else
                        plr(macro_cell_of_user, user, macro_cell_of_micro_cell, cell) = 36.7*log10(d_from_bs_3d(macro_cell_of_user, user, macro_cell_of_micro_cell, cell)) + 22.7 + 26*log10(f_c);
                        const = 10^( sqrt(shadowing_var)*randn(1,1) / 10 ) * 10.^(( eirp_sc  - plr(macro_cell_of_user, user, macro_cell_of_micro_cell, cell) ) / 10);
                    end
                    for sc = 1:num_sc
                        signal_power(macro_cell_of_user, user, macro_cell_of_micro_cell, cell, sc) = ...
                            const * ( abs( fading_channel_freq(macro_cell_of_user, user, macro_cell_of_micro_cell, cell, sc) ).^2 );         
                    end                    
                    for rb = 1:num_rb
                        signal_power_est(macro_cell_of_user, user, macro_cell_of_micro_cell, cell, rb) = mean(signal_power(macro_cell_of_user, user, macro_cell_of_micro_cell, cell, (rb-1)*(num_sc_in_rb)+1 : num_sc_in_rb*rb ));
                    end
                end
            end
        end
    end

    %引数の順番に注意
    signal_power_new = zeros(num_macro_cell,num_users,num_macro_cell,overlap_cell,num_sc);
    signal_power_antenna = zeros(num_macro_cell,num_users,overlap_cell,num_rb);
        
        
    %サブキャリア毎のアンテナとユーザー間の電力算出
    for sc = 1:num_sc
        for macro_of_user = 1:num_macro_cell
            for user = 1:num_users
                for macro_of_micro = 1:num_macro_cell
                    for cell =1:num_cell
                         signal_power_new(macro_of_user,user,macro_of_micro, cell,sc) = signal_power(macro_of_user,user,macro_of_micro,cell,sc);
                    end
                end
            end
        end
    end
    
    %リソースブロック毎のアンテナとユーザー間の電力算出
    for rb = 1:num_rb
        for macro_cell = 1:num_macro_cell
            for user = 1:num_users
                for cell =1:num_cell
                     signal_power_antenna(macro_cell, user, cell, rb) = signal_power_est(macro_cell, user, macro_cell, cell, rb);
                end
            end
        end
    end
    
    
    %% 制御セルの周りのセルを定義
    num_control_cell = 19;                                       % # of control cell
    num_outer_cell = 6;                                          % # of cell around control cell
    outer_cell_index = zeros(num_control_cell, num_outer_cell);  % cell number around control cell
    
    outer_cell_index(1, :) = [2,3,4,5,6,7];
    outer_cell_index(2, :) = [8,9,3,1,7,19];
    outer_cell_index(3, :) = [9,10,11,4,1,2];
    outer_cell_index(4, :) = [3,11,12,13,5,1];
    outer_cell_index(5, :) = [1,4,13,14,15,6];
    outer_cell_index(6, :) = [7,1,5,15,16,17];
    outer_cell_index(7, :) = [19,2,1,6,17,18];
    outer_cell_index(8, :) = [0 0 9 2 19 0];
    outer_cell_index(9, :) = [0 0 10 3 2 8];
    outer_cell_index(10, :) = [0 0 0 11 3 9];
    outer_cell_index(11, :) = [10 0 0 12 4 3];
    outer_cell_index(12, :) = [11 0 0 0 13 4];
    outer_cell_index(13, :) = [4 12 0 0 14 5];
    outer_cell_index(14, :) = [5 13 0 0 0 15];
    outer_cell_index(15, :) = [6 5 14 0 0 16];
    outer_cell_index(16, :) = [17 6 15 0 0 0];
    outer_cell_index(17, :) = [18 7 6 16 0 0];
    outer_cell_index(18, :) = [0 19 7 17 0 0];
    outer_cell_index(19, :) = [0 8 2 7 18 0];
    
    ratio = 0;
    
    %% スループット計算 
    throughput_EST_PF = zeros(num_cell, num_sub_flame, num_rb);
    throughput_PF = zeros(time_interval, num_rb);
    
    %% アンテナ選択
    %該当マクロセルにおけるユーザーの組合せ
    combination = zeros(num_users,num_macro_cell);            
    %ユーザーの組合せ
    for macro_cell = 1:num_macro_cell
        combination((1:nchoosek(num_users,num_scheduling_users)),macro_cell) =  nchoosek(1:num_users,num_scheduling_users);
    end
    
    %% ここからサブフレームの概念を入れたコード
    for sub_flame = 1:num_sub_flame
        %% 自セル内の干渉のみを考慮したUE割り当て（各マクロセルのスループット最大）
        for rb = 1:num_rb
            for macro_cell = 1:num_macro_cell
                %% 自セル内の干渉のみを考慮した推定スループットにより割り当てるUE組み合わせを探索
                % 外部からの干渉の値は前のサブフレームのアンテナを引き継ぎ，干渉を計算
                % cumulative値が0のUEを優先して割り当てる[0のUEの中でスループットが高くなるUEを割り当てる]
                cumulative_throughput_temp = cumulative_throughput_all(macro_cell,:);
                zero_judge = all(cumulative_throughput_all(macro_cell,:));      %0があるとき０を，ないとき１を返す
                zero_user_num = 0;
                zero_user = 0;

                if zero_judge == 1  % 0UEなし
                    combination_temp = combination(:,macro_cell);
                    num_users_temp = numel(combination_temp(:));
                else % 0UE存在
                    zero_user_array = find(~cumulative_throughput_temp);
                    zero_user_num = numel(zero_user_array);
                    if zero_user_num ~= 1 % 0UE複数
                        combination_temp = combination(:,macro_cell);
                        num_users_temp = numel(combination_temp(:));
                        removal_line = zeros(1, num_users_temp);
                        count = 0;
                        for UE_index = 1:num_users
                            if cumulative_throughput_temp(UE_index) ~= 0
                                for combination_index = 1:num_users
                                   if combination_temp(combination_index) == UE_index
                                       count = count + 1;
                                       removal_line(count) = combination_index;
                                   end
                                end
                            end
                        end
                        removal_line(removal_line==0) = [];
                        combination_temp(removal_line) = [];
                        num_users_temp = numel(combination_temp(:));
                    else % 0UEは１人だけ
                        zero_user = zero_user_array;
                        combination_temp = combination(:,macro_cell);
                        num_users_temp = numel(combination_temp(:));
                        removal_line = zeros(1, num_users_temp);
                        count = 0;
                        for combination_index = 1:num_users
                           if combination_temp(combination_index) ~= zero_user_array
                               count = count + 1;
                               removal_line(count) = combination_index;
                           end
                        end
                        removal_line(removal_line==0) = [];
                        combination_temp(removal_line) = [];
                        num_users_temp = numel(combination_temp(:));
                    end
                end
                ratio_max = 0;
                [attribute, ~] = Antenna_select(macro_cell, origin_points, antenna_coordinates_abs(:,:), rb, d);
                for UE_comb_index = 1:num_users_temp
                    UE_comb(macro_cell, rb, sub_flame) = UE_comb_index;

                    [ throughput_est_sc ] = calculate_estimated_throughput_single_PF(signal_power_new, macro_cell, noise_power, outer_cell_index, attribute, rb, squeeze(UE_comb(:, rb, :)), sub_flame);
                    throughput_EST_sc = sum(throughput_est_sc(macro_cell));

                    % 累積と瞬時の比率
                    ratio = 1;
                    if zero_judge == 0 && zero_user_num > 1
                        normalization_value = 1;
                            ratio = 1 + ( throughput_EST_sc) / (( cumulative_throughput_first(macro_cell, combination_temp(UE_comb(macro_cell, rb, sub_flame))))/normalization_value);
                    elseif zero_judge == 0 && zero_user_num == 1
                        normalization_value = num_rb * (sub_flame - 1);
                        if combination_temp(UE_comb(macro_cell, rb, sub_flame)) == zero_user
                            ratio = 1 + ( throughput_EST_sc) / (( cumulative_throughput_first(macro_cell, combination_temp(UE_comb(macro_cell, rb, sub_flame))))/normalization_value);
                        else
                            ratio = 1 + ( throughput_EST_sc) / (( cumulative_throughput_all(macro_cell, combination_temp(UE_comb(macro_cell, rb, sub_flame))))/normalization_value);
                        end
                    elseif zero_judge == 1
                        normalization_value = num_rb * (sub_flame - 1);
                        ratio = ( throughput_EST_sc) / (( cumulative_throughput_all(macro_cell, combination_temp(UE_comb(macro_cell, rb, sub_flame))))/normalization_value);
                    end

                    if ratio > ratio_max
                        ratio_max = ratio;
                        for comb_index = 1:num_users
                            if combination_temp(UE_comb(macro_cell, rb, sub_flame)) == combination(comb_index, macro_cell)
                                comb_index_according_to_combination = comb_index;
                            end
                        end
                        UE_comb(macro_cell, rb, sub_flame) = comb_index_according_to_combination;
                        UE_comb_selected(macro_cell, rb, sub_flame) = UE_comb(macro_cell, rb, sub_flame);
                        throughput_EST_PF(macro_cell, sub_flame, rb) = throughput_EST_sc; % セル数で正規化
                    end
                end
                UE_comb(macro_cell,rb,sub_flame) = UE_comb_selected(macro_cell,rb,sub_flame);
            end
        end
            
        %% 推定に基づいたUE割り当てに従って実際にallocationを行う（アンテナ選択は変わらない）
        %表
        attribute_first = zeros(19, 7,100);       
        attribute_after = zeros(19, 7, 100);
        attribute_after_next = zeros(19, 7, 100);
        attribute_decided = zeros(19, 7, 100);
     
        for rb = 1:num_rb
            %全探索                
            throughput_SC = zeros(19,12);
            
            num_change = 1;%1回転
            for change_index = 1:num_change
                if change_index == 1
                    [attribute, ~] = Antenna_select(1, origin_points, antenna_coordinates_abs(:,:), rb, d);
                    attribute_decided(:, :, rb) = attribute(:, :, rb);
                end

                macro_cell = 1;
                next_macro_cell = 1;
                for change_macro_cell = 1:19 %1周
                    macro_cell = next_macro_cell;
                    %滑らかにマクロセル移動
                    if macro_cell == 7
                        next_macro_cell = 19;
                    elseif macro_cell == 19
                        next_macro_cell = 8;
                    else
                        next_macro_cell = macro_cell + 1;
                    end                  
                    [~, antenna_candidate] = Antenna_select(macro_cell, origin_points, antenna_coordinates_abs(:,:), rb, d);
                    [~, antenna_candidate_next] = Antenna_select(next_macro_cell, origin_points, antenna_coordinates_abs(:,:), rb, d);

                    defference_circle1 = 0;
                    defference_circle2 = 0;
                    max_circle1 = 0;
                    max_circle2 = 0;
                    max_decided = 0;
                    attribute(:, :, rb) = attribute_decided(:, :, rb);
                    attribute_first(:, :, rb) = attribute(:, :, rb);
                    for i = 1:19
                        for k = 1:7
                            if antenna_candidate(i, k, rb) == macro_cell                              
                                %マクロセルiのピコセルkの帰属をmacro_cellに変更
                                throughput_SC_before = zeros(1, 1);
                                throughput_SC_after = zeros(1, 1);
                                throughput_SC_before_next = zeros(19, 12);
                                attribute(i, k, rb) = macro_cell;
                                attribute_after(:, :, rb) = attribute(:, :, rb);
                                for macro_cell_index = 1:19
                                    throughput_SC_before_temp = FullSearch(signal_power_new, macro_cell_index, noise_power, outer_cell_index, attribute_first, rb, squeeze(UE_comb(:, rb, :)), sub_flame);
                                    throughput_SC_before = throughput_SC_before + sum(throughput_SC_before_temp(macro_cell_index, :));
                                end
                                % %1つ目の変更ピコセルが帰属していたマクロセルを決定
                                % macro_cell_af_change = find(outer_cell_index(macro_cell, :) == i);
                                % %帰属を変える前の当該マクロセルと帰属を変更するピコセルの所属するマクロセルのスループット
                                % throughput_SC_before_1 = FullSearch(signal_power_new, macro_cell, noise_power, outer_cell_index, attribute_first, rb, squeeze(UE_comb(:, rb, :)), sub_flame);
                               
                                % if outer_cell_index(macro_cell, macro_cell_af_change) ~= 0
                                %     throughput_SC_before_2 = FullSearch(signal_power_new, outer_cell_index(macro_cell, macro_cell_af_change), noise_power, outer_cell_index, attribute_first, rb, squeeze(UE_comb(:, rb, :)), sub_flame);
                                % end
                                % if macro_cell_af_change == 1
                                %     if outer_cell_index(macro_cell, 6) ~= 0
                                %         throughput_SC_before_3 = FullSearch(signal_power_new, outer_cell_index(macro_cell, 6), noise_power, outer_cell_index, attribute_first, rb, squeeze(UE_comb(:, rb, :)), sub_flame);
                                %     end
                                % else
                                %     if outer_cell_index(macro_cell, macro_cell_af_change-1) ~= 0
                                %         throughput_SC_before_3 = FullSearch(signal_power_new, outer_cell_index(macro_cell, macro_cell_af_change-1), noise_power, outer_cell_index, attribute_first, rb, squeeze(UE_comb(:, rb, :)), sub_flame);
                                %     end
                                % end
                                % if macro_cell_af_change == 6
                                %     if outer_cell_index(macro_cell, 1) ~= 0
                                %         throughput_SC_before_4 = FullSearch(signal_power_new, outer_cell_index(macro_cell, 1), noise_power, outer_cell_index, attribute_first, rb, squeeze(UE_comb(:, rb, :)), sub_flame);
                                %     end
                                % else
                                %     if outer_cell_index(macro_cell, macro_cell_af_change+1) ~= 0
                                %         throughput_SC_before_4 = FullSearch(signal_power_new, outer_cell_index(macro_cell, macro_cell_af_change+1), noise_power, outer_cell_index, attribute_first, rb, squeeze(UE_comb(:, rb, :)), sub_flame);
                                %     end
                                % end
                                % 
                                % %帰属を変える前の4つのマクロセルのスループットの和
                                % if macro_cell_af_change == 1
                                %     if outer_cell_index(macro_cell, macro_cell_af_change) ~= 0 && outer_cell_index(macro_cell, 6) ~= 0 && outer_cell_index(macro_cell, macro_cell_af_change+1) ~= 0
                                %         throughput_SC_before(macro_cell, :) = throughput_SC_before_1(macro_cell,:) + throughput_SC_before_2(outer_cell_index(macro_cell, macro_cell_af_change),:) + throughput_SC_before_3(outer_cell_index(macro_cell, 6),:) + throughput_SC_before_4(outer_cell_index(macro_cell, macro_cell_af_change+1),:);
                                %     % elseif outer_cell_index(macro_cell, l) == 0 && outer_cell_index(macro_cell, 6) ~= 0 && outer_cell_index(macro_cell, l+1) ~= 0
                                %     %     throughput_SC_before(macro_cell, :) = throughput_SC_before_1(macro_cell,:) + throughput_SC_before_3(outer_cell_index(macro_cell, 6),:) + throughput_SC_before_4(outer_cell_index(macro_cell, l+1),:);
                                %     elseif outer_cell_index(macro_cell, macro_cell_af_change) ~= 0 && outer_cell_index(macro_cell, 6) == 0 && outer_cell_index(macro_cell, macro_cell_af_change+1) ~= 0
                                %         throughput_SC_before(macro_cell, :) = throughput_SC_before_1(macro_cell,:) + throughput_SC_before_2(outer_cell_index(macro_cell, macro_cell_af_change),:) + throughput_SC_before_4(outer_cell_index(macro_cell, macro_cell_af_change+1),:);
                                %     elseif outer_cell_index(macro_cell, macro_cell_af_change) ~= 0 && outer_cell_index(macro_cell, 6) ~= 0 && outer_cell_index(macro_cell, macro_cell_af_change+1) == 0
                                %         throughput_SC_before(macro_cell, :) = throughput_SC_before_1(macro_cell,:) + throughput_SC_before_2(outer_cell_index(macro_cell, macro_cell_af_change),:) + throughput_SC_before_3(outer_cell_index(macro_cell, 6),:);
                                %     %elseif outer_cell_index(macro_cell, l) == 0 && outer_cell_index(macro_cell, 6) == 0 && outer_cell_index(macro_cell, l+1) ~= 0
                                %     %   throughput_SC_before(macro_cell, :) = throughput_SC_before_1(macro_cell,:) + throughput_SC_before_4(outer_cell_index(macro_cell, l+1),:);
                                %     %elseif outer_cell_index(macro_cell, l) == 0 && outer_cell_index(macro_cell, 6) ~= 0 && outer_cell_index(macro_cell, l+1) == 0
                                %     %    throughput_SC_before(macro_cell, :) = throughput_SC_before_1(macro_cell,:) + throughput_SC_before_3(outer_cell_index(macro_cell, 6),:);
                                %     %elseif outer_cell_index(macro_cell, l) ~= 0 && outer_cell_index(macro_cell, 6) == 0 && outer_cell_index(macro_cell, l+1) == 0
                                %     %    throughput_SC_before(macro_cell, :) = throughput_SC_before_1(macro_cell,:) + throughput_SC_before_2(outer_cell_index(macro_cell, l),:);
                                %     end
                                % 
                                % elseif macro_cell_af_change == 6
                                %     if outer_cell_index(macro_cell, macro_cell_af_change) ~= 0 && outer_cell_index(macro_cell, macro_cell_af_change-1) ~= 0 && outer_cell_index(macro_cell, 1) ~= 0
                                %         throughput_SC_before(macro_cell, :) = throughput_SC_before_1(macro_cell,:) + throughput_SC_before_2(outer_cell_index(macro_cell, macro_cell_af_change),:) + throughput_SC_before_3(outer_cell_index(macro_cell, macro_cell_af_change-1),:) + throughput_SC_before_4(outer_cell_index(macro_cell, 1),:);
                                %     %elseif outer_cell_index(macro_cell, l) == 0 && outer_cell_index(macro_cell, l-1) ~= 0 && outer_cell_index(macro_cell, 1) ~= 0
                                %     %    throughput_SC_before(macro_cell, :) = throughput_SC_before_1(macro_cell,:) + throughput_SC_before_3(outer_cell_index(macro_cell, l-1),:) + throughput_SC_before_4(outer_cell_index(macro_cell, 1),:);
                                %     elseif outer_cell_index(macro_cell, macro_cell_af_change) ~= 0 && outer_cell_index(macro_cell, macro_cell_af_change-1) == 0 && outer_cell_index(macro_cell, 1) ~= 0
                                %         throughput_SC_before(macro_cell, :) = throughput_SC_before_1(macro_cell,:) + throughput_SC_before_2(outer_cell_index(macro_cell, macro_cell_af_change),:) + throughput_SC_before_4(outer_cell_index(macro_cell, 1),:);
                                %     elseif outer_cell_index(macro_cell, macro_cell_af_change) ~= 0 && outer_cell_index(macro_cell, macro_cell_af_change-1) ~= 0 && outer_cell_index(macro_cell, 1) == 0
                                %         throughput_SC_before(macro_cell, :) = throughput_SC_before_1(macro_cell,:) + throughput_SC_before_2(outer_cell_index(macro_cell, macro_cell_af_change),:) + throughput_SC_before_3(outer_cell_index(macro_cell, macro_cell_af_change-1),:);
                                %     %elseif outer_cell_index(macro_cell, l) == 0 && outer_cell_index(macro_cell, l-1) == 0 && outer_cell_index(macro_cell, 1) ~= 0
                                %     %    throughput_SC_before(macro_cell, :) = throughput_SC_before_1(macro_cell,:) + throughput_SC_before_4(outer_cell_index(macro_cell, 1),:);
                                %     %elseif outer_cell_index(macro_cell, l) == 0 && outer_cell_index(macro_cell, l-1) ~= 0 && outer_cell_index(macro_cell, 1) == 0
                                %     %    throughput_SC_before(macro_cell, :) = throughput_SC_before_1(macro_cell,:) + throughput_SC_before_3(outer_cell_index(macro_cell, l-1),:);
                                %     %elseif outer_cell_index(macro_cell, l) ~= 0 && outer_cell_index(macro_cell, l-1) == 0 && outer_cell_index(macro_cell, 1) == 0
                                %     %    throughput_SC_before(macro_cell, :) = throughput_SC_before_1(macro_cell,:) + throughput_SC_before_2(outer_cell_index(macro_cell, l),:);
                                %     end
                                % 
                                % else
                                %     if outer_cell_index(macro_cell, macro_cell_af_change) ~= 0 && outer_cell_index(macro_cell, macro_cell_af_change-1) ~= 0 && outer_cell_index(macro_cell, macro_cell_af_change+1) ~= 0
                                %         throughput_SC_before(macro_cell, :) = throughput_SC_before_1(macro_cell,:) + throughput_SC_before_2(outer_cell_index(macro_cell, macro_cell_af_change),:) + throughput_SC_before_3(outer_cell_index(macro_cell, macro_cell_af_change-1),:) + throughput_SC_before_4(outer_cell_index(macro_cell, macro_cell_af_change+1),:);
                                %     %elseif outer_cell_index(macro_cell, l) == 0 && outer_cell_index(macro_cell, l-1) ~= 0 && outer_cell_index(macro_cell, l+1) ~= 0
                                %     %    throughput_SC_before(macro_cell, :) = throughput_SC_before_1(macro_cell,:) + throughput_SC_before_3(outer_cell_index(macro_cell, l-1),:) + throughput_SC_before_4(outer_cell_index(macro_cell, l+1),:);
                                %     elseif outer_cell_index(macro_cell, macro_cell_af_change) ~= 0 && outer_cell_index(macro_cell, macro_cell_af_change-1) == 0 && outer_cell_index(macro_cell, macro_cell_af_change+1) ~= 0
                                %         throughput_SC_before(macro_cell, :) = throughput_SC_before_1(macro_cell,:) + throughput_SC_before_2(outer_cell_index(macro_cell, macro_cell_af_change),:) + throughput_SC_before_4(outer_cell_index(macro_cell, macro_cell_af_change+1),:);
                                %     elseif outer_cell_index(macro_cell, macro_cell_af_change) ~= 0 && outer_cell_index(macro_cell, macro_cell_af_change-1) ~= 0 && outer_cell_index(macro_cell, macro_cell_af_change+1) == 0
                                %         throughput_SC_before(macro_cell, :) = throughput_SC_before_1(macro_cell,:) + throughput_SC_before_2(outer_cell_index(macro_cell, macro_cell_af_change),:) + throughput_SC_before_3(outer_cell_index(macro_cell, macro_cell_af_change-1),:);
                                %     %elseif outer_cell_index(macro_cell, l) == 0 && outer_cell_index(macro_cell, l-1) == 0 && outer_cell_index(macro_cell, l+1) ~= 0
                                %     %    throughput_SC_before(macro_cell, :) = throughput_SC_before_1(macro_cell,:) + throughput_SC_before_4(outer_cell_index(macro_cell, l+1),:);
                                %     %elseif outer_cell_index(macro_cell, l) == 0 && outer_cell_index(macro_cell, l-1) ~= 0 && outer_cell_index(macro_cell, l+1) == 0
                                %     %    throughput_SC_before(macro_cell, :) = throughput_SC_before_1(macro_cell,:) + throughput_SC_before_3(outer_cell_index(macro_cell, l-1),:);
                                %     %elseif outer_cell_index(macro_cell, l) ~= 0 && outer_cell_index(macro_cell, l-1) == 0 && outer_cell_index(macro_cell, l+1) == 0
                                %     %    throughput_SC_before(macro_cell, :) = throughput_SC_before_1(macro_cell,:) + throughput_SC_before_2(outer_cell_index(macro_cell, l),:);
                                %     end
                                % end
                                
                                % %1つ目のピコセルの帰属を変更
                                for macro_cell_index = 1:19
                                    throughput_SC_after_temp = FullSearch(signal_power_new, macro_cell_index, noise_power, outer_cell_index, attribute_after, rb, squeeze(UE_comb(:, rb, :)), sub_flame);
                                    throughput_SC_after = throughput_SC_after + sum(throughput_SC_after_temp(macro_cell_index, :));
                                end
                                % throughput_SC_after_1 = FullSearch(signal_power_new, macro_cell, noise_power, outer_cell_index, attribute_after, rb, squeeze(UE_comb(:, rb, :)), sub_flame);
                                % %macro_cell_second_af_change = find(outer_cell_index(macro_cell_af_change, :) == i_next);
                                % if outer_cell_index(macro_cell, macro_cell_af_change) ~= 0
                                %     throughput_SC_after_2 = FullSearch(signal_power_new, outer_cell_index(macro_cell, macro_cell_af_change), noise_power, outer_cell_index, attribute_after, rb, squeeze(UE_comb(:, rb, :)), sub_flame);
                                % end
                                % if macro_cell_af_change == 1
                                %     if outer_cell_index(macro_cell, 6) ~= 0
                                %         throughput_SC_after_3 = FullSearch(signal_power_new, outer_cell_index(macro_cell, 6), noise_power, outer_cell_index, attribute_after, rb, squeeze(UE_comb(:, rb, :)), sub_flame);
                                %     end
                                % else
                                %     if outer_cell_index(macro_cell, macro_cell_af_change-1) ~= 0
                                %         throughput_SC_after_3 = FullSearch(signal_power_new, outer_cell_index(macro_cell, macro_cell_af_change-1), noise_power, outer_cell_index, attribute_after, rb, squeeze(UE_comb(:, rb, :)), sub_flame);
                                %     end
                                % end
                                % if macro_cell_af_change == 6
                                %     if outer_cell_index(macro_cell, 1) ~= 0
                                %         throughput_SC_after_4 = FullSearch(signal_power_new, outer_cell_index(macro_cell, 1), noise_power, outer_cell_index, attribute_after, rb, squeeze(UE_comb(:, rb, :)), sub_flame);
                                %     end
                                % else
                                %     if outer_cell_index(macro_cell, macro_cell_af_change+1) ~= 0
                                %         throughput_SC_after_4 = FullSearch(signal_power_new, outer_cell_index(macro_cell, macro_cell_af_change+1), noise_power, outer_cell_index, attribute_after, rb, squeeze(UE_comb(:, rb, :)), sub_flame);
                                %     end
                                % end
                                % 
                                % %帰属を変えた後の２つのマクロセルのスループットの和
                                % if macro_cell_af_change == 1
                                %     if outer_cell_index(macro_cell, macro_cell_af_change) ~= 0 && outer_cell_index(macro_cell, 6) ~= 0 && outer_cell_index(macro_cell, macro_cell_af_change+1) ~= 0
                                %         throughput_SC_after(macro_cell, :) = throughput_SC_after_1(macro_cell,:) + throughput_SC_after_2(outer_cell_index(macro_cell, macro_cell_af_change),:) + throughput_SC_after_3(outer_cell_index(macro_cell, 6),:) + throughput_SC_after_4(outer_cell_index(macro_cell, macro_cell_af_change+1),:);
                                %     %elseif outer_cell_index(macro_cell, l) == 0 && outer_cell_index(macro_cell, 6) ~= 0 && outer_cell_index(macro_cell, l+1) ~= 0
                                %     %    throughput_SC_after(macro_cell, :) = throughput_SC_after_1(macro_cell,:) + throughput_SC_after_3(outer_cell_index(macro_cell, 6),:) + throughput_SC_after_4(outer_cell_index(macro_cell, l+1),:);
                                %     elseif outer_cell_index(macro_cell, macro_cell_af_change) ~= 0 && outer_cell_index(macro_cell, 6) == 0 && outer_cell_index(macro_cell, macro_cell_af_change+1) ~= 0
                                %         throughput_SC_after(macro_cell, :) = throughput_SC_after_1(macro_cell,:) + throughput_SC_after_2(outer_cell_index(macro_cell, macro_cell_af_change),:) + throughput_SC_after_4(outer_cell_index(macro_cell, macro_cell_af_change+1),:);
                                %     elseif outer_cell_index(macro_cell, macro_cell_af_change) ~= 0 && outer_cell_index(macro_cell, 6) ~= 0 && outer_cell_index(macro_cell, macro_cell_af_change+1) == 0
                                %         throughput_SC_after(macro_cell, :) = throughput_SC_after_1(macro_cell,:) + throughput_SC_after_2(outer_cell_index(macro_cell, macro_cell_af_change),:) + throughput_SC_after_3(outer_cell_index(macro_cell, 6),:);
                                %     %elseif outer_cell_index(macro_cell, l) == 0 && outer_cell_index(macro_cell, 6) == 0 && outer_cell_index(macro_cell, l+1) ~= 0
                                %     %    throughput_SC_after(macro_cell, :) = throughput_SC_after_1(macro_cell,:) + throughput_SC_after_4(outer_cell_index(macro_cell, l+1),:);
                                %     %elseif outer_cell_index(macro_cell, l) == 0 && outer_cell_index(macro_cell, 6) ~= 0 && outer_cell_index(macro_cell, l+1) == 0
                                %     %    throughput_SC_after(macro_cell, :) = throughput_SC_after_1(macro_cell,:) + throughput_SC_after_3(outer_cell_index(macro_cell, 6),:);
                                %     %elseif outer_cell_index(macro_cell, l) ~= 0 && outer_cell_index(macro_cell, 6) == 0 && outer_cell_index(macro_cell, l+1) == 0
                                %     %    throughput_SC_after(macro_cell, :) = throughput_SC_after_1(macro_cell,:) + throughput_SC_after_2(outer_cell_index(macro_cell, l),:);
                                %     end
                                % 
                                % elseif macro_cell_af_change == 6
                                %     if outer_cell_index(macro_cell, macro_cell_af_change) ~= 0 && outer_cell_index(macro_cell, macro_cell_af_change-1) ~= 0 && outer_cell_index(macro_cell, 1) ~= 0
                                %         throughput_SC_after(macro_cell, :) = throughput_SC_after_1(macro_cell,:) + throughput_SC_after_2(outer_cell_index(macro_cell, macro_cell_af_change),:) + throughput_SC_after_3(outer_cell_index(macro_cell, macro_cell_af_change-1),:) + throughput_SC_after_4(outer_cell_index(macro_cell, 1),:);
                                %     %elseif outer_cell_index(macro_cell, l) == 0 && outer_cell_index(macro_cell, l-1) ~= 0 && outer_cell_index(macro_cell, 1) ~= 0
                                %     %    throughput_SC_after(macro_cell, :) = throughput_SC_after_1(macro_cell,:) + throughput_SC_after_3(outer_cell_index(macro_cell, l-1),:) + throughput_SC_after_4(outer_cell_index(macro_cell, 1),:);
                                %     elseif outer_cell_index(macro_cell, macro_cell_af_change) ~= 0 && outer_cell_index(macro_cell, macro_cell_af_change-1) == 0 && outer_cell_index(macro_cell, 1) ~= 0
                                %         throughput_SC_after(macro_cell, :) = throughput_SC_after_1(macro_cell,:) + throughput_SC_after_2(outer_cell_index(macro_cell, macro_cell_af_change),:) + throughput_SC_after_4(outer_cell_index(macro_cell, 1),:);
                                %     elseif outer_cell_index(macro_cell, macro_cell_af_change) ~= 0 && outer_cell_index(macro_cell, macro_cell_af_change-1) ~= 0 && outer_cell_index(macro_cell, 1) == 0
                                %         throughput_SC_after(macro_cell, :) = throughput_SC_after_1(macro_cell,:) + throughput_SC_after_2(outer_cell_index(macro_cell, macro_cell_af_change),:) + throughput_SC_after_3(outer_cell_index(macro_cell, macro_cell_af_change-1),:);
                                %     %elseif outer_cell_index(macro_cell, l) == 0 && outer_cell_index(macro_cell, l-1) == 0 && outer_cell_index(macro_cell, 1) ~= 0
                                %     %    throughput_SC_after(macro_cell, :) = throughput_SC_after_1(macro_cell,:) + throughput_SC_after_4(outer_cell_index(macro_cell, 1),:);
                                %     %elseif outer_cell_index(macro_cell, l) == 0 && outer_cell_index(macro_cell, l-1) ~= 0 && outer_cell_index(macro_cell, 1) == 0
                                %     %    throughput_SC_after(macro_cell, :) = throughput_SC_after_1(macro_cell,:) + throughput_SC_after_3(outer_cell_index(macro_cell, l-1),:);
                                %     %elseif outer_cell_index(macro_cell, l) ~= 0 && outer_cell_index(macro_cell, l-1) == 0 && outer_cell_index(macro_cell, 1) == 0
                                %     %    throughput_SC_after(macro_cell, :) = throughput_SC_after_1(macro_cell,:) + throughput_SC_after_2(outer_cell_index(macro_cell, l),:);
                                %     end
                                % 
                                % else
                                %     if outer_cell_index(macro_cell, macro_cell_af_change) ~= 0 && outer_cell_index(macro_cell, macro_cell_af_change-1) ~= 0 && outer_cell_index(macro_cell, macro_cell_af_change+1) ~= 0
                                %         throughput_SC_after(macro_cell, :) = throughput_SC_after_1(macro_cell,:) + throughput_SC_after_2(outer_cell_index(macro_cell, macro_cell_af_change),:) + throughput_SC_after_3(outer_cell_index(macro_cell, macro_cell_af_change-1),:) + throughput_SC_after_4(outer_cell_index(macro_cell, macro_cell_af_change+1),:);
                                %     %elseif outer_cell_index(macro_cell, l) == 0 && outer_cell_index(macro_cell, l-1) ~= 0 && outer_cell_index(macro_cell, l+1) ~= 0
                                %     %    throughput_SC_after(macro_cell, :) = throughput_SC_after_1(macro_cell,:) + throughput_SC_after_3(outer_cell_index(macro_cell, l-1),:) + throughput_SC_after_4(outer_cell_index(macro_cell, l+1),:);
                                %     elseif outer_cell_index(macro_cell, macro_cell_af_change) ~= 0 && outer_cell_index(macro_cell, macro_cell_af_change-1) == 0 && outer_cell_index(macro_cell, macro_cell_af_change+1) ~= 0
                                %         throughput_SC_after(macro_cell, :) = throughput_SC_after_1(macro_cell,:) + throughput_SC_after_2(outer_cell_index(macro_cell, macro_cell_af_change),:) + throughput_SC_after_4(outer_cell_index(macro_cell, macro_cell_af_change+1),:);
                                %     elseif outer_cell_index(macro_cell, macro_cell_af_change) ~= 0 && outer_cell_index(macro_cell, macro_cell_af_change-1) ~= 0 && outer_cell_index(macro_cell, macro_cell_af_change+1) == 0
                                %         throughput_SC_after(macro_cell, :) = throughput_SC_after_1(macro_cell,:) + throughput_SC_after_2(outer_cell_index(macro_cell, macro_cell_af_change),:) + throughput_SC_after_3(outer_cell_index(macro_cell, macro_cell_af_change-1),:);
                                %     %elseif outer_cell_index(macro_cell, l) == 0 && outer_cell_index(macro_cell, l-1) == 0 && outer_cell_index(macro_cell, l+1) ~= 0
                                %     %    throughput_SC_after(macro_cell, :) = throughput_SC_after_1(macro_cell,:) + throughput_SC_after_4(outer_cell_index(macro_cell, l+1),:);
                                %     %elseif outer_cell_index(macro_cell, l) == 0 && outer_cell_index(macro_cell, l-1) ~= 0 && outer_cell_index(macro_cell, l+1) == 0
                                %     %    throughput_SC_after(macro_cell, :) = throughput_SC_after_1(macro_cell,:) + throughput_SC_after_3(outer_cell_index(macro_cell, l-1),:);
                                %     %elseif outer_cell_index(macro_cell, l) ~= 0 && outer_cell_index(macro_cell, l-1) == 0 && outer_cell_index(macro_cell, l+1) == 0
                                %     %    throughput_SC_after(macro_cell, :) = throughput_SC_after_1(macro_cell,:) + throughput_SC_after_2(outer_cell_index(macro_cell, l),:);
                                %     end
                                % end
                                %ピコセルの帰属をを1つ変更した状態でもう1つ変更していく
                                %max_circle2 = -inf;
                                %macro_cellに隣接するマクロセルのピコセルの帰属を変更する               
                                %[~, antenna_candidate_next] = Antenna_select(macro_cell_af_change, origin_points, antenna_coordinates_abs(:,:), rb, d);
                                %defference_circle2 = 0;
                                
                                for i_next = 1:19
                                    for k_next = 1:7
                                        if antenna_candidate_next(i_next, k_next, rb) == next_macro_cell
                                            throughput_SC_after_next = zeros(1, 1);
                                            attribute(i_next, k_next, rb) = next_macro_cell;
                                            attribute_after_next(:, :, rb) = attribute(:, :, rb);
                                            
                                            % %2つ目の変更ピコセルが帰属していたマクロセルを決定
                                            % macro_cell_af_change_next = find(outer_cell_index(next_macro_cell, :) == i_next);
                                            % %2つ目のピコセルの帰属を変更(before)
                                            % throughput_SC_before_1_next = FullSearch(signal_power_new, next_macro_cell, noise_power, outer_cell_index, attribute_after, rb, squeeze(UE_comb(:, rb, :)), sub_flame);
                                            % %macro_cell_second_af_change = find(outer_cell_index(macro_cell_af_change, :) == i_next);
                                            % if outer_cell_index(next_macro_cell, macro_cell_af_change_next) ~= 0
                                            %     throughput_SC_before_2_next = FullSearch(signal_power_new, outer_cell_index(next_macro_cell, macro_cell_af_change_next), noise_power, outer_cell_index, attribute_after, rb, squeeze(UE_comb(:, rb, :)), sub_flame);
                                            % end
                                            % if macro_cell_af_change_next == 1
                                            %     if outer_cell_index(next_macro_cell, 6) ~= 0
                                            %         throughput_SC_before_3_next = FullSearch(signal_power_new, outer_cell_index(next_macro_cell, 6), noise_power, outer_cell_index, attribute_after, rb, squeeze(UE_comb(:, rb, :)), sub_flame);
                                            %     end
                                            % else
                                            %     if outer_cell_index(next_macro_cell, macro_cell_af_change_next-1) ~= 0
                                            %         throughput_SC_before_3_next = FullSearch(signal_power_new, outer_cell_index(next_macro_cell, macro_cell_af_change_next-1), noise_power, outer_cell_index, attribute_after, rb, squeeze(UE_comb(:, rb, :)), sub_flame);
                                            %     end
                                            % end
                                            % if macro_cell_af_change_next == 6
                                            %     if outer_cell_index(next_macro_cell, 1) ~= 0
                                            %         throughput_SC_before_4_next = FullSearch(signal_power_new, outer_cell_index(next_macro_cell, 1), noise_power, outer_cell_index, attribute_after, rb, squeeze(UE_comb(:, rb, :)), sub_flame);
                                            %     end
                                            % else
                                            %     if outer_cell_index(next_macro_cell, macro_cell_af_change_next+1) ~= 0
                                            %         throughput_SC_before_4_next = FullSearch(signal_power_new, outer_cell_index(next_macro_cell, macro_cell_af_change_next+1), noise_power, outer_cell_index, attribute_after, rb, squeeze(UE_comb(:, rb, :)), sub_flame);
                                            %     end
                                            % end
                                            % 
                                            % %帰属を変えた後の２つのマクロセルのスループットの和
                                            % if macro_cell_af_change_next == 1
                                            %     if outer_cell_index(next_macro_cell, macro_cell_af_change_next) ~= 0 && outer_cell_index(next_macro_cell, 6) ~= 0 && outer_cell_index(next_macro_cell, macro_cell_af_change_next+1) ~= 0
                                            %         throughput_SC_before_next(next_macro_cell, :) = throughput_SC_before_1_next(next_macro_cell,:) + throughput_SC_before_2_next(outer_cell_index(next_macro_cell, macro_cell_af_change_next),:) + throughput_SC_before_3_next(outer_cell_index(next_macro_cell, 6),:) + throughput_SC_before_4_next(outer_cell_index(next_macro_cell, macro_cell_af_change_next+1),:);
                                            %     %elseif outer_cell_index(macro_cell, l) == 0 && outer_cell_index(macro_cell, 6) ~= 0 && outer_cell_index(macro_cell, l+1) ~= 0
                                            %     %    throughput_SC_after(macro_cell, :) = throughput_SC_after_1(macro_cell,:) + throughput_SC_after_3(outer_cell_index(macro_cell, 6),:) + throughput_SC_after_4(outer_cell_index(macro_cell, l+1),:);
                                            %     elseif outer_cell_index(next_macro_cell, macro_cell_af_change_next) ~= 0 && outer_cell_index(next_macro_cell, 6) == 0 && outer_cell_index(next_macro_cell, macro_cell_af_change_next+1) ~= 0
                                            %         throughput_SC_before_next(next_macro_cell, :) = throughput_SC_before_1_next(next_macro_cell,:) + throughput_SC_before_2_next(outer_cell_index(next_macro_cell, macro_cell_af_change_next),:) + throughput_SC_before_4_next(outer_cell_index(next_macro_cell, macro_cell_af_change_next+1),:);
                                            %     elseif outer_cell_index(next_macro_cell, macro_cell_af_change_next) ~= 0 && outer_cell_index(next_macro_cell, 6) ~= 0 && outer_cell_index(next_macro_cell, macro_cell_af_change_next+1) == 0
                                            %         throughput_SC_before_next(next_macro_cell, :) = throughput_SC_before_1_next(next_macro_cell,:) + throughput_SC_before_2_next(outer_cell_index(next_macro_cell, macro_cell_af_change_next),:) + throughput_SC_before_3_next(outer_cell_index(next_macro_cell, 6),:);
                                            %     %elseif outer_cell_index(macro_cell, l) == 0 && outer_cell_index(macro_cell, 6) == 0 && outer_cell_index(macro_cell, l+1) ~= 0
                                            %     %    throughput_SC_after(macro_cell, :) = throughput_SC_after_1(macro_cell,:) + throughput_SC_after_4(outer_cell_index(macro_cell, l+1),:);
                                            %     %elseif outer_cell_index(macro_cell, l) == 0 && outer_cell_index(macro_cell, 6) ~= 0 && outer_cell_index(macro_cell, l+1) == 0
                                            %     %    throughput_SC_after(macro_cell, :) = throughput_SC_after_1(macro_cell,:) + throughput_SC_after_3(outer_cell_index(macro_cell, 6),:);
                                            %     %elseif outer_cell_index(macro_cell, l) ~= 0 && outer_cell_index(macro_cell, 6) == 0 && outer_cell_index(macro_cell, l+1) == 0
                                            %     %    throughput_SC_after(macro_cell, :) = throughput_SC_after_1(macro_cell,:) + throughput_SC_after_2(outer_cell_index(macro_cell, l),:);
                                            %     end
                                            % 
                                            % elseif macro_cell_af_change_next == 6
                                            %     if outer_cell_index(next_macro_cell, macro_cell_af_change_next) ~= 0 && outer_cell_index(next_macro_cell, macro_cell_af_change_next-1) ~= 0 && outer_cell_index(next_macro_cell, 1) ~= 0
                                            %         throughput_SC_before_next(next_macro_cell, :) = throughput_SC_before_1_next(next_macro_cell,:) + throughput_SC_before_2_next(outer_cell_index(next_macro_cell, macro_cell_af_change_next),:) + throughput_SC_before_3_next(outer_cell_index(next_macro_cell, macro_cell_af_change_next-1),:) + throughput_SC_before_4_next(outer_cell_index(next_macro_cell, 1),:);
                                            %     %elseif outer_cell_index(macro_cell, l) == 0 && outer_cell_index(macro_cell, l-1) ~= 0 && outer_cell_index(macro_cell, 1) ~= 0
                                            %     %    throughput_SC_after(macro_cell, :) = throughput_SC_after_1(macro_cell,:) + throughput_SC_after_3(outer_cell_index(macro_cell, l-1),:) + throughput_SC_after_4(outer_cell_index(macro_cell, 1),:);
                                            %     elseif outer_cell_index(next_macro_cell, macro_cell_af_change_next) ~= 0 && outer_cell_index(next_macro_cell, macro_cell_af_change_next-1) == 0 && outer_cell_index(next_macro_cell, 1) ~= 0
                                            %         throughput_SC_before_next(next_macro_cell, :) = throughput_SC_before_1_next(next_macro_cell,:) + throughput_SC_before_2_next(outer_cell_index(next_macro_cell, macro_cell_af_change_next),:) + throughput_SC_before_4_next(outer_cell_index(next_macro_cell, 1),:);
                                            %     elseif outer_cell_index(next_macro_cell, macro_cell_af_change_next) ~= 0 && outer_cell_index(next_macro_cell, macro_cell_af_change_next-1) ~= 0 && outer_cell_index(next_macro_cell, 1) == 0
                                            %         throughput_SC_before_next(next_macro_cell, :) = throughput_SC_before_1_next(next_macro_cell,:) + throughput_SC_before_2_next(outer_cell_index(next_macro_cell, macro_cell_af_change_next),:) + throughput_SC_before_3_next(outer_cell_index(next_macro_cell, macro_cell_af_change_next-1),:);
                                            %     %elseif outer_cell_index(macro_cell, l) == 0 && outer_cell_index(macro_cell, l-1) == 0 && outer_cell_index(macro_cell, 1) ~= 0
                                            %     %    throughput_SC_after(macro_cell, :) = throughput_SC_after_1(macro_cell,:) + throughput_SC_after_4(outer_cell_index(macro_cell, 1),:);
                                            %     %elseif outer_cell_index(macro_cell, l) == 0 && outer_cell_index(macro_cell, l-1) ~= 0 && outer_cell_index(macro_cell, 1) == 0
                                            %     %    throughput_SC_after(macro_cell, :) = throughput_SC_after_1(macro_cell,:) + throughput_SC_after_3(outer_cell_index(macro_cell, l-1),:);
                                            %     %elseif outer_cell_index(macro_cell, l) ~= 0 && outer_cell_index(macro_cell, l-1) == 0 && outer_cell_index(macro_cell, 1) == 0
                                            %     %    throughput_SC_after(macro_cell, :) = throughput_SC_after_1(macro_cell,:) + throughput_SC_after_2(outer_cell_index(macro_cell, l),:);
                                            %     end
                                            % 
                                            % else
                                            %     if outer_cell_index(next_macro_cell, macro_cell_af_change_next) ~= 0 && outer_cell_index(next_macro_cell, macro_cell_af_change_next-1) ~= 0 && outer_cell_index(next_macro_cell, macro_cell_af_change_next+1) ~= 0
                                            %         throughput_SC_before_next(next_macro_cell, :) = throughput_SC_before_1_next(next_macro_cell,:) + throughput_SC_before_2_next(outer_cell_index(next_macro_cell, macro_cell_af_change_next),:) + throughput_SC_before_3_next(outer_cell_index(next_macro_cell, macro_cell_af_change_next-1),:) + throughput_SC_before_4_next(outer_cell_index(next_macro_cell, macro_cell_af_change_next+1),:);
                                            %     %elseif outer_cell_index(macro_cell, l) == 0 && outer_cell_index(macro_cell, l-1) ~= 0 && outer_cell_index(macro_cell, l+1) ~= 0
                                            %     %    throughput_SC_after(macro_cell, :) = throughput_SC_after_1(macro_cell,:) + throughput_SC_after_3(outer_cell_index(macro_cell, l-1),:) + throughput_SC_after_4(outer_cell_index(macro_cell, l+1),:);
                                            %     elseif outer_cell_index(next_macro_cell, macro_cell_af_change_next) ~= 0 && outer_cell_index(next_macro_cell, macro_cell_af_change_next-1) == 0 && outer_cell_index(next_macro_cell, macro_cell_af_change_next+1) ~= 0
                                            %         throughput_SC_before_next(next_macro_cell, :) = throughput_SC_before_1_next(next_macro_cell,:) + throughput_SC_before_2_next(outer_cell_index(next_macro_cell, macro_cell_af_change_next),:) + throughput_SC_before_4_next(outer_cell_index(next_macro_cell, macro_cell_af_change_next+1),:);
                                            %     elseif outer_cell_index(next_macro_cell, macro_cell_af_change_next) ~= 0 && outer_cell_index(next_macro_cell, macro_cell_af_change_next-1) ~= 0 && outer_cell_index(next_macro_cell, macro_cell_af_change_next+1) == 0
                                            %         throughput_SC_before_next(next_macro_cell, :) = throughput_SC_before_1_next(next_macro_cell,:) + throughput_SC_before_2_next(outer_cell_index(next_macro_cell, macro_cell_af_change_next),:) + throughput_SC_before_3_next(outer_cell_index(next_macro_cell, macro_cell_af_change_next-1),:);
                                            %     %elseif outer_cell_index(macro_cell, l) == 0 && outer_cell_index(macro_cell, l-1) == 0 && outer_cell_index(macro_cell, l+1) ~= 0
                                            %     %    throughput_SC_after(macro_cell, :) = throughput_SC_after_1(macro_cell,:) + throughput_SC_after_4(outer_cell_index(macro_cell, l+1),:);
                                            %     %elseif outer_cell_index(macro_cell, l) == 0 && outer_cell_index(macro_cell, l-1) ~= 0 && outer_cell_index(macro_cell, l+1) == 0
                                            %     %    throughput_SC_after(macro_cell, :) = throughput_SC_after_1(macro_cell,:) + throughput_SC_after_3(outer_cell_index(macro_cell, l-1),:);
                                            %     %elseif outer_cell_index(macro_cell, l) ~= 0 && outer_cell_index(macro_cell, l-1) == 0 && outer_cell_index(macro_cell, l+1) == 0
                                            %     %    throughput_SC_after(macro_cell, :) = throughput_SC_after_1(macro_cell,:) + throughput_SC_after_2(outer_cell_index(macro_cell, l),:);
                                            %     end
                                            % end
                                            % 
                                            % %2つ目のピコセルの帰属を変更
                                            for macro_cell_index = 1:19
                                                throughput_SC_after_next_temp = FullSearch(signal_power_new, macro_cell_index, noise_power, outer_cell_index, attribute_after_next, rb, squeeze(UE_comb(:, rb, :)), sub_flame);
                                                throughput_SC_after_next = throughput_SC_after_next + sum(throughput_SC_after_next_temp(macro_cell_index, :));
                                            end
                                            % throughput_SC_after_1_next = FullSearch(signal_power_new, next_macro_cell, noise_power, outer_cell_index, attribute_after_next, rb, squeeze(UE_comb(:, rb, :)), sub_flame);
                                            % %macro_cell_second_af_change = find(outer_cell_index(macro_cell_af_change, :) == i_next);
                                            % if outer_cell_index(next_macro_cell, macro_cell_af_change_next) ~= 0
                                            %     throughput_SC_after_2_next = FullSearch(signal_power_new, outer_cell_index(next_macro_cell, macro_cell_af_change_next), noise_power, outer_cell_index, attribute_after_next, rb, squeeze(UE_comb(:, rb, :)), sub_flame);
                                            % end
                                            % if macro_cell_af_change_next == 1
                                            %     if outer_cell_index(next_macro_cell, 6) ~= 0
                                            %         throughput_SC_after_3_next = FullSearch(signal_power_new, outer_cell_index(next_macro_cell, 6), noise_power, outer_cell_index, attribute_after_next, rb, squeeze(UE_comb(:, rb, :)), sub_flame);
                                            %     end
                                            % else
                                            %     if outer_cell_index(next_macro_cell, macro_cell_af_change_next-1) ~= 0
                                            %         throughput_SC_after_3_next = FullSearch(signal_power_new, outer_cell_index(next_macro_cell, macro_cell_af_change_next-1), noise_power, outer_cell_index, attribute_after_next, rb, squeeze(UE_comb(:, rb, :)), sub_flame);
                                            %     end
                                            % end
                                            % if macro_cell_af_change_next == 6
                                            %     if outer_cell_index(next_macro_cell, 1) ~= 0
                                            %         throughput_SC_after_4_next = FullSearch(signal_power_new, outer_cell_index(next_macro_cell, 1), noise_power, outer_cell_index, attribute_after_next, rb, squeeze(UE_comb(:, rb, :)), sub_flame);
                                            %     end
                                            % else
                                            %     if outer_cell_index(next_macro_cell, macro_cell_af_change_next+1) ~= 0
                                            %         throughput_SC_after_4_next = FullSearch(signal_power_new, outer_cell_index(next_macro_cell, macro_cell_af_change_next+1), noise_power, outer_cell_index, attribute_after_next, rb, squeeze(UE_comb(:, rb, :)), sub_flame);
                                            %     end
                                            % end
                                            % 
                                            % %帰属を変えた後の２つのマクロセルのスループットの和
                                            % if macro_cell_af_change_next == 1
                                            %     if outer_cell_index(next_macro_cell, macro_cell_af_change_next) ~= 0 && outer_cell_index(next_macro_cell, 6) ~= 0 && outer_cell_index(next_macro_cell, macro_cell_af_change_next+1) ~= 0
                                            %         throughput_SC_after_next(next_macro_cell, :) = throughput_SC_after_1_next(next_macro_cell,:) + throughput_SC_after_2_next(outer_cell_index(next_macro_cell, macro_cell_af_change_next),:) + throughput_SC_after_3_next(outer_cell_index(next_macro_cell, 6),:) + throughput_SC_after_4_next(outer_cell_index(next_macro_cell, macro_cell_af_change_next+1),:);
                                            %     %elseif outer_cell_index(macro_cell, l) == 0 && outer_cell_index(macro_cell, 6) ~= 0 && outer_cell_index(macro_cell, l+1) ~= 0
                                            %     %    throughput_SC_after(macro_cell, :) = throughput_SC_after_1(macro_cell,:) + throughput_SC_after_3(outer_cell_index(macro_cell, 6),:) + throughput_SC_after_4(outer_cell_index(macro_cell, l+1),:);
                                            %     elseif outer_cell_index(next_macro_cell, macro_cell_af_change_next) ~= 0 && outer_cell_index(next_macro_cell, 6) == 0 && outer_cell_index(next_macro_cell, macro_cell_af_change_next+1) ~= 0
                                            %         throughput_SC_after_next(next_macro_cell, :) = throughput_SC_after_1_next(next_macro_cell,:) + throughput_SC_after_2_next(outer_cell_index(next_macro_cell, macro_cell_af_change_next),:) + throughput_SC_after_4_next(outer_cell_index(next_macro_cell, macro_cell_af_change_next+1),:);
                                            %     elseif outer_cell_index(next_macro_cell, macro_cell_af_change_next) ~= 0 && outer_cell_index(next_macro_cell, 6) ~= 0 && outer_cell_index(next_macro_cell, macro_cell_af_change_next+1) == 0
                                            %         throughput_SC_after_next(next_macro_cell, :) = throughput_SC_after_1_next(next_macro_cell,:) + throughput_SC_after_2_next(outer_cell_index(next_macro_cell, macro_cell_af_change_next),:) + throughput_SC_after_3_next(outer_cell_index(next_macro_cell, 6),:);
                                            %     %elseif outer_cell_index(macro_cell, l) == 0 && outer_cell_index(macro_cell, 6) == 0 && outer_cell_index(macro_cell, l+1) ~= 0
                                            %     %    throughput_SC_after(macro_cell, :) = throughput_SC_after_1(macro_cell,:) + throughput_SC_after_4(outer_cell_index(macro_cell, l+1),:);
                                            %     %elseif outer_cell_index(macro_cell, l) == 0 && outer_cell_index(macro_cell, 6) ~= 0 && outer_cell_index(macro_cell, l+1) == 0
                                            %     %    throughput_SC_after(macro_cell, :) = throughput_SC_after_1(macro_cell,:) + throughput_SC_after_3(outer_cell_index(macro_cell, 6),:);
                                            %     %elseif outer_cell_index(macro_cell, l) ~= 0 && outer_cell_index(macro_cell, 6) == 0 && outer_cell_index(macro_cell, l+1) == 0
                                            %     %    throughput_SC_after(macro_cell, :) = throughput_SC_after_1(macro_cell,:) + throughput_SC_after_2(outer_cell_index(macro_cell, l),:);
                                            %     end
                                            % 
                                            % elseif macro_cell_af_change_next == 6
                                            %     if outer_cell_index(next_macro_cell, macro_cell_af_change_next) ~= 0 && outer_cell_index(next_macro_cell, macro_cell_af_change_next-1) ~= 0 && outer_cell_index(next_macro_cell, 1) ~= 0
                                            %         throughput_SC_after_next(next_macro_cell, :) = throughput_SC_after_1_next(next_macro_cell,:) + throughput_SC_after_2_next(outer_cell_index(next_macro_cell, macro_cell_af_change_next),:) + throughput_SC_after_3_next(outer_cell_index(next_macro_cell, macro_cell_af_change_next-1),:) + throughput_SC_after_4_next(outer_cell_index(next_macro_cell, 1),:);
                                            %     %elseif outer_cell_index(macro_cell, l) == 0 && outer_cell_index(macro_cell, l-1) ~= 0 && outer_cell_index(macro_cell, 1) ~= 0
                                            %     %    throughput_SC_after(macro_cell, :) = throughput_SC_after_1(macro_cell,:) + throughput_SC_after_3(outer_cell_index(macro_cell, l-1),:) + throughput_SC_after_4(outer_cell_index(macro_cell, 1),:);
                                            %     elseif outer_cell_index(next_macro_cell, macro_cell_af_change_next) ~= 0 && outer_cell_index(next_macro_cell, macro_cell_af_change_next-1) == 0 && outer_cell_index(next_macro_cell, 1) ~= 0
                                            %         throughput_SC_after_next(next_macro_cell, :) = throughput_SC_after_1_next(next_macro_cell,:) + throughput_SC_after_2_next(outer_cell_index(next_macro_cell, macro_cell_af_change_next),:) + throughput_SC_after_4_next(outer_cell_index(next_macro_cell, 1),:);
                                            %     elseif outer_cell_index(next_macro_cell, macro_cell_af_change_next) ~= 0 && outer_cell_index(next_macro_cell, macro_cell_af_change_next-1) ~= 0 && outer_cell_index(next_macro_cell, 1) == 0
                                            %         throughput_SC_after_next(next_macro_cell, :) = throughput_SC_after_1_next(next_macro_cell,:) + throughput_SC_after_2_next(outer_cell_index(next_macro_cell, macro_cell_af_change_next),:) + throughput_SC_after_3_next(outer_cell_index(next_macro_cell, macro_cell_af_change_next-1),:);
                                            %     %elseif outer_cell_index(macro_cell, l) == 0 && outer_cell_index(macro_cell, l-1) == 0 && outer_cell_index(macro_cell, 1) ~= 0
                                            %     %    throughput_SC_after(macro_cell, :) = throughput_SC_after_1(macro_cell,:) + throughput_SC_after_4(outer_cell_index(macro_cell, 1),:);
                                            %     %elseif outer_cell_index(macro_cell, l) == 0 && outer_cell_index(macro_cell, l-1) ~= 0 && outer_cell_index(macro_cell, 1) == 0
                                            %     %    throughput_SC_after(macro_cell, :) = throughput_SC_after_1(macro_cell,:) + throughput_SC_after_3(outer_cell_index(macro_cell, l-1),:);
                                            %     %elseif outer_cell_index(macro_cell, l) ~= 0 && outer_cell_index(macro_cell, l-1) == 0 && outer_cell_index(macro_cell, 1) == 0
                                            %     %    throughput_SC_after(macro_cell, :) = throughput_SC_after_1(macro_cell,:) + throughput_SC_after_2(outer_cell_index(macro_cell, l),:);
                                            %     end
                                            % 
                                            % else
                                            %     if outer_cell_index(next_macro_cell, macro_cell_af_change_next) ~= 0 && outer_cell_index(next_macro_cell, macro_cell_af_change_next-1) ~= 0 && outer_cell_index(next_macro_cell, macro_cell_af_change_next+1) ~= 0
                                            %         throughput_SC_after_next(next_macro_cell, :) = throughput_SC_after_1_next(next_macro_cell,:) + throughput_SC_after_2_next(outer_cell_index(next_macro_cell, macro_cell_af_change_next),:) + throughput_SC_after_3_next(outer_cell_index(next_macro_cell, macro_cell_af_change_next-1),:) + throughput_SC_after_4_next(outer_cell_index(next_macro_cell, macro_cell_af_change_next+1),:);
                                            %     %elseif outer_cell_index(macro_cell, l) == 0 && outer_cell_index(macro_cell, l-1) ~= 0 && outer_cell_index(macro_cell, l+1) ~= 0
                                            %     %    throughput_SC_after(macro_cell, :) = throughput_SC_after_1(macro_cell,:) + throughput_SC_after_3(outer_cell_index(macro_cell, l-1),:) + throughput_SC_after_4(outer_cell_index(macro_cell, l+1),:);
                                            %     elseif outer_cell_index(next_macro_cell, macro_cell_af_change_next) ~= 0 && outer_cell_index(next_macro_cell, macro_cell_af_change_next-1) == 0 && outer_cell_index(next_macro_cell, macro_cell_af_change_next+1) ~= 0
                                            %         throughput_SC_after_next(next_macro_cell, :) = throughput_SC_after_1_next(next_macro_cell,:) + throughput_SC_after_2_next(outer_cell_index(next_macro_cell, macro_cell_af_change_next),:) + throughput_SC_after_4_next(outer_cell_index(next_macro_cell, macro_cell_af_change_next+1),:);
                                            %     elseif outer_cell_index(next_macro_cell, macro_cell_af_change_next) ~= 0 && outer_cell_index(next_macro_cell, macro_cell_af_change_next-1) ~= 0 && outer_cell_index(next_macro_cell, macro_cell_af_change_next+1) == 0
                                            %         throughput_SC_after_next(next_macro_cell, :) = throughput_SC_after_1_next(next_macro_cell,:) + throughput_SC_after_2_next(outer_cell_index(next_macro_cell, macro_cell_af_change_next),:) + throughput_SC_after_3_next(outer_cell_index(next_macro_cell, macro_cell_af_change_next-1),:);
                                            %     %elseif outer_cell_index(macro_cell, l) == 0 && outer_cell_index(macro_cell, l-1) == 0 && outer_cell_index(macro_cell, l+1) ~= 0
                                            %     %    throughput_SC_after(macro_cell, :) = throughput_SC_after_1(macro_cell,:) + throughput_SC_after_4(outer_cell_index(macro_cell, l+1),:);
                                            %     %elseif outer_cell_index(macro_cell, l) == 0 && outer_cell_index(macro_cell, l-1) ~= 0 && outer_cell_index(macro_cell, l+1) == 0
                                            %     %    throughput_SC_after(macro_cell, :) = throughput_SC_after_1(macro_cell,:) + throughput_SC_after_3(outer_cell_index(macro_cell, l-1),:);
                                            %     %elseif outer_cell_index(macro_cell, l) ~= 0 && outer_cell_index(macro_cell, l-1) == 0 && outer_cell_index(macro_cell, l+1) == 0
                                            %     %    throughput_SC_after(macro_cell, :) = throughput_SC_after_1(macro_cell,:) + throughput_SC_after_2(outer_cell_index(macro_cell, l),:);
                                            %     end
                                            % end
        
                                           %スループットの比較
                                            defference_circle2 = throughput_SC_after_next - throughput_SC_before;
                                            if defference_circle2 > max_decided
                                                max_decided = defference_circle2;
                                                attribute_decided(:, :, rb) = attribute_after(:, :, rb);
                                            end             
                                            %if sum(throughput_SC_after_next(next_macro_cell, :)) > sum(throughput_SC_before_next(next_macro_cell, :))
                             %  i
                             % k
                             % i_next
                             % k_next
                             % max_circle2
                                            % if defference_circle2 > max_circle2
                                            %     max_circle2 = defference_circle2;
                                            % end

                                            defference_circle1 = throughput_SC_after - throughput_SC_before;
                             %                max_circle1 = beta*defference_circle1 + gammma*max_circle2;
                                            if defference_circle1 > max_decided
                                                max_decided = defference_circle1;
                                                attribute_decided(:, :, rb) = attribute_after(:, :, rb);                
                                            end
                                            %attributeの初期化
                                            attribute(:, :, rb) = attribute_after(:, :, rb);                           
                                        end
                                    end
                                end
                                % defference_circle1 = sum(throughput_SC_after(macro_cell, :)) - sum(throughput_SC_before(macro_cell, :));
                                % max_circle1 = beta*defference_circle1 + gammma*max_circle2;
                                % if max_circle1 > max_decided
                                %     max_decided = max_circle1;
                                %     attribute_decided(:, :, rb) = attribute_after(:, :, rb);
                                %     temp_throughput_SC = throughput_SC_after_1(macro_cell, :);
                                %     throughput_SC(macro_cell, :) = temp_throughput_SC;
                                %     %next_macro_cell_af_change = outer_cell_index(macro_cell, macro_cell_af_change);
                                % end
                                %attributeの初期化
                                attribute(:, :, rb) = attribute_first(:, :, rb);
                            end
                        end
                    end
% for macro_cell_index = 1:19
%     temp_throughput_SC = FullSearch(signal_power_new, macro_cell_index, noise_power, outer_cell_index, attribute_decided, rb, squeeze(UE_comb(:, rb, :)), sub_flame);
%     throughput_SC(macro_cell_index, :) = temp_throughput_SC(macro_cell_index, :);
% end                    
                end
            end
            
            [attribute, ~] = Antenna_select(macro_cell, origin_points, antenna_coordinates_abs(:,:), rb, d);
            change_count(rb, sub_flame) = nnz(attribute(:, :, rb) ~= attribute_decided(:, :, rb));

            for macro_cell = 1:19
                temp_throughput_SC = FullSearch(signal_power_new, macro_cell, noise_power, outer_cell_index, attribute_decided, rb, squeeze(UE_comb(:, rb, :)), sub_flame);
                throughput_SC(macro_cell, :) = temp_throughput_SC(macro_cell, :);
            end
            throughput_sc = zeros(1, num_macro_cell); % 瞬時スループットに相当する 
            for k = 1:num_macro_cell
                throughput_sc(k) = sum(throughput_SC(k, :))/12; % subcarrier数で正規化
                cumulative_throughput(k, combination(UE_comb(k, rb, sub_flame), k), sub_flame) = cumulative_throughput(k, combination(UE_comb(k, rb, sub_flame), k), sub_flame) + throughput_sc(k);
                cumulative_throughput_all(k, combination(UE_comb(k, rb, sub_flame), k)) = cumulative_throughput_all(k, combination(UE_comb(k, rb, sub_flame), k)) + throughput_sc(k);                    
                throughput_PF((sub_flame-1)*7+1:sub_flame*7, rb) = sum(throughput_sc)/7; % セル数で正規化
            end
        end
        cumulative_throughput(:, :, sub_flame) = 7*cumulative_throughput(:, :, sub_flame);    % チャネルの時変動がないので7シンボル分割り当てればそのまま7倍
    end
    cumulative_throughput_all(:,:) = 7*cumulative_throughput_all(:,:);

    %% 値の保存
    clear_name = {'signal_power','signal_power_new','signal_power_antenna_select','signal_power_antenna','signal_power_est',...
         'plr','plr_antenna_select','plr_est','antenna_priority','antenna_ex','antenna_selection_PF','cumulative_throughput_temp','cumulative_throughput_actual',...
         'fading_channel_freq','P_LOS','one_LOS','d_from_bs','d_from_bs_3d','UE_comb_selected','combination','throughput_SC_1','throughput_SC_2''antenna_search_first',...
         'antenna_search_second','antenna_selection_if','Flag_antenna_if','Flag_antenna_second_used',...
         'Flag_antenna_third_used','Flag_antenna_used','throughput_EST_PF','throughput_PF','UE_comb','antenna_selection_1','antenna_selection_2','antenna_selection_3'};

    clear (clear_name{:});

    file = num2str(rng_value);
    
    saveDirStr = (['result/proposed_choosebetter_4.65GHz/',num2str(num_users),'user']);
    save([saveDirStr, '/',...
        'result_d',num2str(distance),...
        '_rng',...
        file, '.mat'])
    
   time_indicator.lap()
end
