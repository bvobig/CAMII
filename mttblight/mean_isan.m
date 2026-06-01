function res = mean_isan(a)

%remove NaNs and compute the mean

b = a(~isnan(a));
%if size(b,3)==1
    res = mean(b);
%else
%    interm = zeros(size(b,3))
%    for i = 1:size(b,3)
%        interm(i) = mean(:,:,i);
%    end
%    res = mean(interm);
%end