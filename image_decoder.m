function image_decoder(b, image_size)
% IMAGE_DECODER - Decodes a bit stream into an image with
% a given fixed size and display it.
%    image_decoder(b, image_size)
%    
%    Arguments:
%      b:          (vector) bit stream of length=8*height*width
%      image_size: (vector) [height, width] size of the image
% 
% Author(s): unknown
% Copyright (c) 2011 RWTH.


% Convert the bit stream "b" into an image and display it.
% The vector "image_size" of length 2 contains the dimensions 
% (in pixels) of the image (height x width)

% error handling
if length(b) ~= 8 * prod(image_size)
  error('Input vector has wrong size.')
end

% convert to uint8
b1 = reshape(b, 8, length(b)/8).';
image = bi2de(b1);

% reshape into image format
image = reshape(image, image_size(2), image_size(1)).';

% displax image
imageview(image);

return
