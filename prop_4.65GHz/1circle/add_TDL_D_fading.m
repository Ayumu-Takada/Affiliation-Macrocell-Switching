function channel_response_freq = add_TDL_D_fading( band_width)
%% Variables:
num_rb = 100;
num_sc_in_rb = 12;
num_sc = num_rb * num_sc_in_rb;     % # of total subcarriers
sampling = 1/band_width ;
delay_spread = 30*10^-9;
normalized_delay = [ 0 0 0.035 0.612 1.363 1.405 1.804 2.596 1.775 4.042 7.937 9.424 9.708 12.525 ];
delay = delay_spread * normalized_delay  ;
sampling_value = fix(delay/sampling);
k_dB = [-0.2 -13.5 -18.8 -21 -22.8 -17.9 -20.1 -21.9 -22.9 -27.8 -23.6 -24.8 -30.0 -27.7 ];
k = 10.^(k_dB/10);
amplitude_normalized = 1/sqrt(sum(k));
%% Add Rician Fading:
channel_response_time = zeros(1, num_sc);
channel_response_freq = zeros(1, num_sc);

for value =1:numel(sampling_value)
    if value == 1
        channel_response_time(1, sampling_value(value)+1) = sqrt(k(value)) * exp( -1i*2*pi*rand(1) )*amplitude_normalized ;
    else
        channel_response_time(1, sampling_value(value)+1) = channel_response_time(1, sampling_value(value)+1) + sqrt(k(value)) * (1/sqrt(2).*( randn(1) + 1i*randn(1) ))*amplitude_normalized;
    end
end

% calculate frequency:
channel_response_freq(1, :) = fft( channel_response_time(1, :) );

end