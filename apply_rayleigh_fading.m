function [ frame_with_rayleigh ] = apply_rayleigh_fading( Frame, noAntenna )

% Apply Rayleigh Fading Channel
channel_gains = randn(noAntenna,1)+1i*randn(noAntenna,1);
frame_with_rayleigh = channel_gains * Frame;

end

