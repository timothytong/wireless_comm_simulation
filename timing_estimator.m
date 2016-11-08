function epsilon = timing_estimator(r_mf)
% This function takes four samples (corresponding to one data symbol) at a time and
% returns an estimate of the fractional timing error, normalized to the symbol duration
% (-0.5 < epsilon <= 0.5).
% The estimate is averaged over the whole data block, therefore this function only works
% for a constant timing error.
%
% Before processing a new data block, the memory should be freshly initialized with
% "clear timing_estimator"

if length(r_mf) ~= 4, error('timing_estimator: Input must have length 4.'); end

persistent x_cum;
if isempty(x_cum)
	x_cum = 0;
end

x = abs(r_mf).^2;
x_cum = x_cum + x(1) - x(3) - j*(x(2) - x(4));
epsilon = -1/(2*pi) * angle(x_cum);
