function b = demapper(a)
% Convert noisy QPSK symbols into a bit vector. Hard decisions.

a = a(:); % Make sure "a" is a column vector

b = [real(a) imag(a)] > 0;

% Convert the matrix "b" to a vector, reading the elements of "b" rowwise.
b = b.';
b = b(:);

b = double(b); % Convert data type from logical to double
end