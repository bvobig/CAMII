function data = coranalysis(raw,cor,step,col);
%function data = coranalysisraw,cor,step,col);
% input parameters:
%   RAW = result of a prior improanalysis
%   COR = length of cross-correlation windows in samples
%   STEP = relative step between successive cross-correlation windows
%   COL (optional, default=0) = output color
%       0 = color output for screen
%       1 = b/w output for printout
%

warning off
if nargin<4 col=0; end
N=12;
nwin=1;
win=0;
for i=1:N
    win=win+1;
    subplot(N,nwin,win)
    corr = crosscors(raw(:,i,1)',raw(:,i,2)',cor,floor(cor*step));
    data(:,i) = [initiate(corr);imitate(corr);integrate(corr);integrateall(corr)];
end


function res = integrateall(id)
% compute the integration factor of the imitation diagram id.
mm = [];
for i=1:size(id,2)
    value = id(:,i);
    value = value(~isnan(value));
    m = max(value);
    if ~isnan(m)
        m = max(m,0);
        mm = [mm m];
    end
end
%figure
%plot(mm)
%figure
res = mean(mm);





%%%%%%%%%%%%%%%%%%%%%


function res = initiate(id)
% compute the initiation factor of the imitation diagram id.
y = size(id,1);
%newid = id(ceil(y/2):y,:);
%newid = newid(~isnan(newid));
%newid = newid(newid>=0);
%res = mean(newid);
mm = [];
for i=1:size(id,2)
    half = id(ceil(y/2):y,i);
    half = half(~isnan(half));
    m = max(half);
    if ~isnan(m)
        m = max(m,0);
        mm = [mm m];
    end
end
%figure
%plot(mm)
res = mean(mm);


function res = imitate(id)
% compute the imitation factor of the imitation diagram id.
y = size(id,1);
%newid = id(1:floor(y/2),:);
%newid = newid(~isnan(newid));
%newid = newid(newid>=0);
%res = mean(newid);
mm = [];
for i=1:size(id,2)
    half = id(1:floor(y/2),i);
    half = half(~isnan(half));
    m = max(half);
    if ~isnan(m)
        m = max(m,0);
        mm = [mm m];
    end
end
%figure
%plot(mm)
res = mean(mm);


function res = integrate(id)
% compute the integration factor of the imitation diagram id.
y = size(id,1);
idp = [0:(y-1)/2]/floor((y-1)/2);
sigma = .5/40; %standard deviation of .5 sec.
half = exp(-idp.^2/2/sigma^2);
if mod(size(id,1),2) == 0
    mask = [half(end:-1:1), half]; %* ones(size(id));
else
    mask = [half(end:-1:2), half]; %* ones(size(id));
end
%newid = id .* mask;
%newid = newid(~isnan(newid));
%newid = newid(newid>=0);
%res = mean(newid)/mean(mask(:));
mm = [];
for i=1:size(id,2)
    half = id(:,i).*mask';
    half = half(~isnan(half));
    m = max(half);
    if ~isnan(m)
        m = max(m,0);
        mm = [mm m];
    end
end
%figure
%plot(mm)
%figure
res = mean(mm);