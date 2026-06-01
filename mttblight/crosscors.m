function R = crosscors(x,y,k,s)
% Effect: compute the crosscorrelations between each possible segments of size k
% of sequences x and y.
%
% Input arguments:
%	x = the first sequence
%   y = the second sequence
%   k = the size of the segments
%   s = the step between successive segments
%
% Output:
%   the matrix of crosscorrelations

if nargin==3 s=1; end
lx = length(x);
ly = length(y);
z = zeros(ceil((lx-k+1)/s),ceil((ly-k+1)/s));
xxan = x(~isnan(x));
yyan = y(~isnan(y));
amplimax = max(max(xxan)-min(yyan), max(yyan)-min(xxan));
for i = 0:ceil((lx-k+1)/s)-1
        %i / (ceil((lx-k+1)/s)-1) * 100
    for j = 0:ceil((ly-k+1)/s)-1
        xan = x(s*i+1:s*i+k);
        xan = xan(~isnan(xan));
        yan = y(s*j+1:s*j+k);
        yan = yan(~isnan(yan));
        xt = x(s*i+1:s*i+k) - mean(xan);
        yt = y(s*j+1:s*j+k) - mean(yan);
        for l = 1:size(xt,2)
            if isnan(xt(l))
                xt(l) = 0;
            end
        end
        for l = 1:size(yt,2)
            if isnan(yt(l))
                yt(l) = 0;
            end
        end
        xn = xt*xt';
        yn = yt*yt';
        %nx = xan * xan';
        %ny = yan * yan';
        if or(or(xn == 0, isnan(xn)), or(yn == 0, isnan(yn)))
            %if and(or(xn == 0, isnan(xn)), or(yn == 0, isnan(yn)))
            %    z(i+1,j+1) = 1;
            %else
                z(i+1,j+1) = 0;
            %end
        else
            z(i+1,j+1)= xt*yt' / sqrt(xn) / sqrt(yn) * (1 - (abs(mean(xan) - mean(yan))/amplimax))^3; 
            if xn > yn %nx > ny
                z(i+1,j+1) = z(i+1,j+1) * (sqrt(yn)/sqrt(xn)); %* (sqrt(ny)/sqrt(nx));
            else
                z(i+1,j+1) = z(i+1,j+1) * (sqrt(xn)/sqrt(yn)); %* (sqrt(nx)/sqrt(ny));    
            end
        end
    end
end
%figure
%imagesc(z, [0.5 1]);
MAXLAG = 20/s;
Tmin = 0;
R = rotmat45(z, MAXLAG,.1);
%imagesc(R, [0 1]);
%set(gca,'XTick',1:ceil(size(R,2)/10):size(R,2))
%;XStep = round((lx+k)/25);
%;set(gca,'XTickLabel',Tmin+(1-k)/2:XStep:Tmin+lx-1+(k-1)/2)
%set(gca,'XTickLabel',Tmin:round((lx-1)/10):Tmin+lx-1)
%set(gca,'YTick',1:floor(size(R,1)/2)-1:size(R,1))
%set(gca,'YTickLabel',MAXLAG*s:-MAXLAG*s:-MAXLAG*s)