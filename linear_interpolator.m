function y_int = linear_interpolator(y, x)

if length(y) ~= 2, error('y must have length 2.'); end;
if x < 0 || x > 1, error('x must be from the interval [0, 1].'); end;

y_int = (1-x)*y(1) + x*y(2);