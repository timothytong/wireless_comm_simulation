function [start_idx, rxsymbols] = diversityreceiver(signal, os_factor, noAntenna, noSymbols, channel_est_opt)

% Simulate the reception of a signal frame over multiple channels (antennas)
%
%   input -----------------------------------------------------------------
%   
%       o signal              : (noAntenna x [noSymbols]) matrix containing signal data points
%       o os_factor           : integer, oversample rate
%       o noAntenna           : integer, number of antennas (channels)
%       o noSymbols           : integer, number of symbols supposed to be in this specific frame
%       o channel_est_opt     : string, option to estimate channel gain h, 
%                               either "max" to pick the path with the largest channel 
%                               gain or "mrc" to employ maximum ratio combiner.
%
%   output ----------------------------------------------------------------
%
%       o start_idx           : integer, start of correct signal index
%       o rxsymbols           : (1 x [noSymbols]) signal data stream with channel gain compensated.
%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
noFilterTap = 6;
match_filtered_signal = zeros(noAntenna, max(size(signal)) + 2*noFilterTap);

h_hat = zeros(noAntenna, 1);

for i = 1:noAntenna
    filtered_rx_signal = matched_filter(signal(i,:), os_factor, noFilterTap); % 6 is a good value for the one-sided RRC length (i.e. the filter has 13 taps in total)
    match_filtered_signal(i, :) = filtered_rx_signal;
    % Frame synchronization
    [start_idx, theta, mag] = frame_sync(filtered_rx_signal.', os_factor); % Index of the first data symbol
    
    % h_hat is our ESTIMATE of channel gain h, Magnitude * delay offset,
    % both estimated in the frame_sync function.
    h_hat(i) = exp(1i*theta) * mag;
end

switch channel_est_opt
    case 'max'
        % PART 2 - Just the maximum
        [h_filter, idx] = max(h_hat);

        % rx = h * tx (+n) we need tx.
        rxsymbols = match_filtered_signal(idx, :) / h_filter;
    
    case 'mrc'
        % PART 3 - MRC
        w = conj(h_hat) ./ abs(h_hat);
        rxsymbols = sum(bsxfun(@times, match_filtered_signal, w), 1);
        
    otherwise
        error('Invalid channel gain estimation option. Options avail: max, mrc')
end

end