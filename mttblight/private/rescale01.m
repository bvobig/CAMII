function y = rescale01(x)
% function y = rescale01(x)
%
% Comment: Auxiliary function that resides in private directory
a1 = x-(min(x));
y = a1/(max(a1));
