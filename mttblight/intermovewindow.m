function y = intermovewindow(nmat1,nmat2,wlength,wstep,tmin,tmax,timetype,varargin)
% Windowed analysis of notematrix using a specified function
% Applies function defined in VARARGIN to a series of windowed note matrices
% using window length WLENGTH and step WSTEPs across NMAT1 and NMAT2
%
% Input arguments: 
%	NMAT1 and NMAT2 = notematrices
%	WLENGTH = window length in seconds
%	WSTEP = window step size in seconds
%	TIMETYPE = time representation, 'beat' (default) or 'sec' 
%	VARARGIN = function (string) or functions
%
% Output: 
%	Y = output of the function VARARGIN (or nested function FUNC2(FUNC1) etc.) %		applied to NMAT
%
% Example 1: Find maximal key correlation within a 3-second window -
%      that is moved by 1.5 seconds at a time - of NMAT
%      y = movewindow(nmat,3,1.5,'sec','maxkkcc');%% Example 2: Find average key velocity within a 6-second window -%		that is moved by 2 seconds at a time - of NMAT%		y = movewindow(nmat,6,2,'velocity','mean');

if or(isempty(nmat1),isempty(nmat2)) return; end
if strcmp(timetype, 'sec')~=1 & strcmp(timetype, 'beat')~=1
   disp(['Unknown timetype:' timetype])
   disp('Accepted timeformats are ''sec'' or ''beat''! ')
   return
end

if strcmp('sec',timetype)
   os1=onset(nmat1,'sec');
   ds1 = dur(nmat1,'sec');
   os2=onset(nmat2,'sec');
   ds2 = dur(nmat2,'sec');
else
   os1=onset(nmat1);
   ds1 = dur(nmat1);
   os2=onset(nmat2);
   ds2 = dur(nmat2);
end

y= [];
for t = tmin:wstep:tmax
   x1 = onsetwindow(nmat1,t-wlength,t,timetype);
   x2 = onsetwindow(nmat2,t-wlength,t,timetype);
   for f=1:length(varargin)
      if or(isempty(x1), isempty(x2)) % Return empty for empty matrix
         z=[NaN NaN];
      else
         z = feval(varargin{f},x1,x2);
         x=z;
      end
   end
   y = [y;z];
end
