function mm = rotmat45(m,MAXLAG,reso);

% MAXLAG = maximum lag between templates
% Number of rows in matrix MM is thus 2*MAXLAG+1

if size(m,1)<3
    if size(m,1)==0
        m = zeros(3,3);
    elseif size(m,1)==1
        m = m * ones(3,3);
    elseif size(m,1)==2
        m = [m(1,1) m(1,1) m(1,2) m(1,2); m(1,1) m(1,1) m(1,2) m(1,2); m(2,1) m(2,1) m(2,2) m(2,2); m(2,1) m(2,1) m(2,2) m(2,2)];
    end
end
[X Y]=meshgrid(1:size(m,2),1:size(m,1));

XX=repmat(-(-MAXLAG:reso:MAXLAG)'/2,1,length(1:reso:size(m,2)))+repmat(1:reso:size(m,2),length(-MAXLAG:reso:MAXLAG),1);
YY=repmat((-MAXLAG:reso:MAXLAG)'/2,1,length(1:reso:size(m,2)))+repmat(1:reso:size(m,2),length(-MAXLAG:reso:MAXLAG),1);
mm=interp2(X,Y,m,XX,YY,'cubic');