function keysomanim2(nmat, wlen, step);
% keysomanim(nmat, <wlen>, <step>);
% Animation using the KEYSOM function
%
% Input arguments:
%	NMAT = notematrix
%	WLEN (optional) = window length in beats (default = 6)
%	STEP (optional) =window step in beats (default = 0.5)
%
% References:
%	Toiviainen, P. & Krumhansl, C. L. (2003). Measuring and modeling 
%	real-time responses to music: the dynamics of tonality induction. 
%	Perception, 32(6), 741-766.
%
%	Krumhansl, C. L., & Toiviainen, P. (2001) Tonal cognition. 
%	In R. J. Zatorre & I. Peretz (Eds.), The Biological Foundations of Music. 
%	Annals of the New York Academy of Sciences. 
%	New York, NY: New York Academy of Sciences, 77-91.
%
%	Change History :
% 	Date		Time	Prog	Note
% 	16.2.2003	23:55	PT	Created under MATLAB 5.3 (Macintosh)
%© Part of the MIDI Toolbox Software Package, Copyright © 2002, University of Jyväskylä, Finland
% See License.txt

if nargin<3 step = 0.5; end
if nargin<2 wlen = 6; end
mch = mchannels(nmat);
nm1=getmidich(nmat,mch(1));
nm2=getmidich(nmat,mch(2));

ob = onsetsecs(nmat);
ob1 = onsetsecs(nm1);
ob2 = onsetsecs(nm2);

for t = 0:step:ob(end)
	nmw1 = onsetwindow(nm1,t-wlen,t,'sec');
	nmw2 = onsetwindow(nm2,t-wlen,t,'sec');
	subplot(1,2,1), keysom(nmw1);
	title(strcat('Channel 1; Secs: ',num2str(t,'%.2f')),'FontSize', 16,'FontName','Times')
	subplot(1,2,2), keysom(nmw2);
	title(strcat('Channel 2; Secs: ',num2str(t,'%.2f')),'FontSize', 16,'FontName','Times')
	pause (0);
end

