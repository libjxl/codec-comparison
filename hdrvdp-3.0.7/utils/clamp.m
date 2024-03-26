function Y = clamp( X, minV, maxV )
% CLAMP restricts values of 'X' to be within the range from 'min' to 'max'.
%
% Y = clamp( X, minV, maxV )
%  
% (C) Rafal Mantiuk <mantiuk@gmail.com>
% This is an experimental code for internal use. Do not redistribute.

Y = max(min(X,maxV),minV);

% if( isa( X, 'single' ) )
%   Y(X<min) = single(min);
%   Y(X>max) = single(max);
% else
%   Y(X<min) = double(min);
%   Y(X>max) = double(max);    
% end

end
