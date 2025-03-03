function channel_response_freq = add_TDL_A_fading(band_width)
%% Variables:
num_rb = 100;
num_sc_in_rb = 12;
num_sc = num_rb * num_sc_in_rb;     % # of total subcarriers
sampling = 1/band_width ;
delay_spread = 30*10^-9;
normalized_delay = [ 0 0.3819 0.4025 0.5868 0.4610 0.5375 0.6708 0.5750 0.7618 1.5375 1.8978 2.2242 2.1718 2.4942 2.5119 3.0582 4.0810 4.4579 4.5695 4.7966 5.0066 5.3043 9.6586 ];
delay = delay_spread * normalized_delay  ;
sampling_value = fix(delay/sampling);
k_dB = [-13.4 0 -2.2 -4 -6 -8.2 -9.9 -10.5 -7.5 -15.9 -6.6 -16.7 -12.4 -15.2 -10.8 -11.3 -12.7 -16.2 -18.3 -18.9 -16.6 -19.9 -29.7 ];
k = 10.^(k_dB/10) ;
amplitude_normalized = 1/sqrt(sum(k));
%% Add Rayleigh Fading:
channel_response_time = zeros(1, num_sc);
channel_response_freq = zeros(1, num_sc);

for value =1:numel(sampling_value)
    channel_response_time(1, sampling_value(value)+1) = channel_response_time(1, sampling_value(value)+1) + sqrt(k(value)) * (1/sqrt(2).*( randn(1) + 1i*randn(1) ))*amplitude_normalized;
end

% calculate frequency:
 channel_response_freq(1, :) = fft( channel_response_time(1, :) );

end