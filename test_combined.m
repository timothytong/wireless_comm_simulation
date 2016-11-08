clear;
close all;

% Oversampling factor
os_factor = 4;

% SNR
SNR = 10;
noAntenna = 3;

% Interpolator type
interpolator_type = 'linear';

% transmitter
load task4
signal = signal';
data_length = prod(image_size) * 8 / 2; % Number of QPSK data symbols
noframes = size(signal,1); 
symbolsperframe = data_length/noframes;

rxsymbols = zeros(noframes,symbolsperframe);

% Loop through all frames
for k=1:noframes
   
    [Frame, theta_n] = apply_phase_noise(signal(k,:));
    chanFrame = apply_rayleigh_fading(Frame, noAntenna);
    noiseFrame = awgn(chanFrame, SNR);
    
    [~, cc_rxsymbols] = diversityreceiver(noiseFrame, os_factor, noAntenna, symbolsperframe, 'mrc');
    
    [start_idx, theta, ~] = frame_sync(cc_rxsymbols, os_factor);
    data_idxInit = start_idx;
    
    [payload_data, theta_hat] = timing_phase_correction(cc_rxsymbols, data_length, start_idx, os_factor, theta, 'linear');
    
    rxsymbols(k,:) = payload_data;
end

combined_rxsymbols = reshape(rxsymbols.',1,noframes*symbolsperframe);

rxbitstream = demapper(combined_rxsymbols); % Demap Symbols
image_decoder(rxbitstream,image_size) % Decode Image

% Plot phase
figure(1),
plot(theta_hat)
hold on
plot(theta_n(data_idxInit:os_factor:end), '-r')
a = axis;
a(3:4) = [0,2*pi];
axis(a)
set(gca,'ytick',0:pi/4:2*pi)
grid on;

