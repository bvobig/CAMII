function y = mymovewindow2(nmat,wlength,wstep,tmin,tmax,timetype)

if isempty(nmat) return; end
if strcmp(timetype, 'sec')~=1 & strcmp(timetype, 'beat')~=1
   disp(['Unknown timetype:' timetype])
   disp('Accepted timeformats are ''sec'' or ''beat''! ')
   return
end

y= [];
for t = tmin:wstep:tmax
   x = onsetwindow(nmat,t-wlength,t,timetype);
   z = 0;
   for i = 1:size(x,1)
       ti = x(i,6);
       z = z + 1 - (t - ti)/wlength;
   end
   y = [y;z/wlength*2];
end
