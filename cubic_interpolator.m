function y_int = cubic_interpolator(y, x)

if length(y) ~= 4, error('y must have length 4.'); end;
if x < 0 || x > 1, error('x must be from the interval [0, 1].'); end;

c = 1/6 * [-1 3 -3 1 ; 3 -6 3 0 ; -2 -3 6 -1 ; 0 6 0 0] * y;
y_int = c(1) * x^3 + c(2) * x^2 + c(3) * x + c(4);