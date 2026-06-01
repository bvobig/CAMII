function res = mttb_light(file,wstep,wlen)
% Computes the MTTB analysis.
% mttb_light(filename) computes the analysis of file filename
% mttb_light(filename,wstep) wstep specifies how fast the sliding window moves.
% Default value wstep = 1 (in seconds)
% mttb_light(filename,wstep,wlen): wlen specifies the window length.
% Default value wlen = 6 (in seconds)

if nargin < 2
    wstep = 1;
end
if nargin < 3
    wlen = 6;
end

nmat=sortrows(readmidi(file));
mc=mchannels(nmat);
nm1=getmidich(nmat,mc(1));
if length(mc)==1
    disp(['Data found on 1 channel only!']);
    nm2=[];
else
    nm2=getmidich(nmat,mc(2));
end
if length(mc)>2
    disp(['Data found on ' num2str(length(mc)) ' channels!']);
    disp('First 2 channels analyzed.');
end

tmin=0; %max(onset(handles.nmat,'sec')+dur(handles.nmat,'sec'))*handles.tmin;
tmax=max(onset(nmat,'sec')+dur(nmat,'sec')); %*handles.tmax;
res.t_end = (tmin:wstep:tmax)';
res.t_start = res.t_end - wlen;
res.dens1=mymovewindow(nm1,wlen,wstep,tmin,tmax,'sec','nnotes')/wlen; 
res.dur1=mymovewindow(nm1,wlen,wstep,tmin,tmax,'sec','duraccent','dur','mean'); 
res.meanp1=mymovewindow(nm1,wlen,wstep,tmin,tmax,'sec','pitch','mean');
res.stdp1=mymovewindow(nm1,wlen,wstep,tmin,tmax,'sec','pitch','std');
res.meanv1=mymovewindow(nm1,wlen,wstep,tmin,tmax,'sec','velocity','mean');
res.art1=mymovewindow(nm1,wlen,wstep,tmin,tmax,'sec','myarticulation');
ryt1=mymovewindow(nm1,wlen,wstep,tmin,tmax,'sec','mypulsesalience');
res.ac1=ryt1(:,1);
res.tempo1=ryt1(:,2); 
res.ton1=mymovewindow(nm1,wlen,wstep,tmin,tmax,'sec','maxkkcc'); 
res.maj1=mymovewindow(nm1,wlen,wstep,tmin,tmax,'sec','majorkkcc'); 
res.min1=mymovewindow(nm1,wlen,wstep,tmin,tmax,'sec','minorkkcc'); 
res.dis1=dissonance3(nm1,1,wlen,wstep,tmin,tmax)'; 
res.sil1=silence(nm1,nm1,5,2);

if size(nm2,2)>0
	res.dens2=mymovewindow(nm2,wlen,wstep,tmin,tmax,'sec','nnotes')/wlen;
    res.dur2=mymovewindow(nm2,wlen,wstep,tmin,tmax,'sec','duraccent','dur','mean');
	res.meanp2=mymovewindow(nm2,wlen,wstep,tmin,tmax,'sec','pitch','mean');
    res.stdp2=mymovewindow(nm2,wlen,wstep,tmin,tmax,'sec','pitch','std');
    res.meanv2=mymovewindow(nm2,wlen,wstep,tmin,tmax,'sec','velocity','mean');
    res.art2=mymovewindow(nm2,wlen,wstep,tmin,tmax,'sec','myarticulation'); 
    ryt2=mymovewindow(nm2,wlen,wstep,tmin,tmax,'sec','mypulsesalience');
    res.ac2=ryt2(:,1);
    res.tempo2=ryt2(:,2); 
    res.ton2=mymovewindow(nm2,wlen,wstep,tmin,tmax,'sec','maxkkcc'); 
    res.maj2=mymovewindow(nm2,wlen,wstep,tmin,tmax,'sec','majorkkcc'); 
    res.min2=mymovewindow(nm2,wlen,wstep,tmin,tmax,'sec','minorkkcc'); 
    res.dis2=dissonance3(nm2,1,wlen,wstep,tmin,tmax)'; 
    res.sil1=silence(nm1,nm2,5,2);
    res.sil2=silence(nm2,nm1,5,2);
    
    syn=intermovewindow(nm1,nm2,wlen,wstep,tmin,tmax,'sec','interpulsesalience');
    res.sync=syn(:,1);
    res.syntempo=syn(:,2);
end

% ac1 = nan(151,length(res.t_end));
% for i = 1:length(res.t_end)
%     t = res.t_end(i);
%     x = onsetwindow(nm1,t-wlen,t,'sec');
%     [~,ac1(:,i)] = mypulsesalience(x);
% end
% figure,imagesc(ac1)
% ac2 = nan(151,length(res.t_end));
% for i = 1:length(res.t_end)
%     t = res.t_end(i);
%     x = onsetwindow(nm2,t-wlen,t,'sec');
%     [~,ac2(:,i)] = mypulsesalience(x);
% end
% figure,imagesc(ac2)

% segment.dens1 = segment(dens1);