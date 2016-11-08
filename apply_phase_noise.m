function [ frame_with_phase_noise, theta_n ] = apply_phase_noise( Frame )

% Create phase noise
theta_n = zeros(1, length(Frame));
theta_n(1) = 2*pi*rand(1);
sigmaDeltaTheta = 0.001;
for i = 2 : length(Frame)
   theta_n(i) = mod(theta_n(i-1) + sigmaDeltaTheta*randn,2*pi);
end

% Apply phase noise and put it back to TX signal
frame_with_phase_noise = Frame.*exp(1j*theta_n);

end

