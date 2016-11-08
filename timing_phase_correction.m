function [rx_pt_corrected, theta_hat] = timing_phase_correction(rx_symbols, noSymbols, start_idx, os_factor, i_theta, interpolator_type)
% Simulate the reception of a signal frame with timing delays and phase offsets
%
%   input -----------------------------------------------------------------
%   
%       o rx_symbols : (1 x [noSymbols]) matrix containing signal data points
%       o os_factor  : integer, oversample rate
%       o noAntenna  : integer, number of antennas (channels)
%       o noSymbols  : integer, number of symbols supposed to be in this specific frame
%       o option     : string, option to estimate channel gain h, either "max" to pick the path
%                      with the largest channel gain or "mrc" to employ maximum ratio combiner.
%
%   output ----------------------------------------------------------------
%
%       o rxsymbols  : (1 x noSymbols) signal data stream with channel gain compensated.
%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

eps_hat = zeros(noSymbols, 1);     % Estimate of the timing error
theta_hat = zeros(noSymbols, 1);   % Estimate of the carrier phase
theta_hat(1) = i_theta;
rx_pt_corrected = zeros(noSymbols, 1);

% Loop over the data symbols with estimation and correction of the timing
% error and phase
for k = 1 : noSymbols
    
    % timing estimator
    eps_hat(k) = timing_estimator(rx_symbols(start_idx : start_idx + os_factor - 1));
    opt_sampling_inst = eps_hat(k) * os_factor;
    
    switch interpolator_type
        case 'none'
            rx_pt_corrected(k) = rx_symbols(start_idx + round(opt_sampling_inst));
            
        case 'linear'
            y = rx_symbols(start_idx + floor(opt_sampling_inst) : start_idx + floor(opt_sampling_inst) + 1);
            rx_pt_corrected(k) = linear_interpolator(y, opt_sampling_inst - floor(opt_sampling_inst));
            
        case 'cubic'
            y = rx_symbols(start_idx + floor(opt_sampling_inst) - 1 : start_idx + floor(opt_sampling_inst) + 2);
            rx_pt_corrected(k) = cubic_interpolator(y, opt_sampling_inst - floor(opt_sampling_inst));
            
        otherwise
            error('Unknown interpolator_type.');
    end
    
    % Phase estimation    
    % Apply viterbi-viterbi algorithm
    deltaTheta = 1/4*angle(-rx_pt_corrected(k)^4) + pi/2*(-1:4);
    
    % Unroll phase
    [~, ind] = min(abs(deltaTheta - theta_hat(k)));
    theta = deltaTheta(ind);
    
    % Lowpass filter phase
    theta_hat(k+1) = mod(0.01*theta + 0.99*theta_hat(k), 2*pi);
    
    % Phase correction
    rx_pt_corrected(k) = rx_pt_corrected(k) * exp(-1j * theta_hat(k+1));   % ...and rotate the current symbol accordingly
    
    start_idx = start_idx + os_factor;
end
end