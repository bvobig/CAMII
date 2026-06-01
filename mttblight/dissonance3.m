function r = dissonance3(nm,m,w,wstep,tmin,tmax);
% returns estimated dissonance of music represented as NM 
% using a piano sound and taking into consideration a short-term memory of size m seconds.

    p = pitch(nm);
    f = midi2hz(p);
    fp = f * (1:6);
    o = onset(nm, 'sec');
    d = dur(nm, 'sec');
    off = o + d;
    v = velocity(nm)./127;
    vp = v * power(0.8,(0:5));
    d = [o, zeros(size(o,1),1)];
    for i = 1:size(o,1)
        x = 0;
        mp = [];
        for j = i-1:-1:1
            if o(i) - off(j) <= m
                if isempty(find(mp == p(j)))
                    mp = [mp, p(j)];
                    for k = 1:6
                        for l = 1:6
                            if (m == 0)
                                x = x + exp((o(j)-o(i))/tau(p(j))) * plomp(fp(i,k),fp(j,l)) * vp(i,k)*vp(j,l);
                            else
                                x = x + (1 - max(o(i)-off(j),0)/m) * exp((o(j)-o(i))/tau(p(j))) * plomp(fp(i,k),fp(j,l)) * vp(i,k)*vp(j,l);
                            end
                        end
                    end
                end
            end
        end
        if isempty(mp)
            d(i,2) = 0;
        else
            d(i,2) = x;
        end
    end
    i = 0;
    if 1
        for t = tmin:wstep:tmax
            s = 0;
            n = 0;
            i = i+1;
            for j = 1:size(o,1)
                if and (t > o(j), t - o(j) <= w)
                    s = s + d(j,2);
                    n = n + 1;
                end
            end
            if n == 0
                r(i) = NaN;
            else
                r(i) = s/n;
            end
        end
    end
return;


function tc = tau(p);
% returns time constants for amplitude envelope decay for pitches P
% THIS HAS TO BE CHECKED

	tc = 0.8 + (0.8-0.57)*(32-p)/(84-32); % crude approximation based on amplitude envelope analysis of pitches 32, 60, and 84
return;


function pd = plomp(f1, f2);
% returns the dissonance of two pure tones at frequencies f1 & f2 Hz
% according to the Plomp-Levelt curve (see Sethares)
    b1 = 3.5;
    b2 = 5.75;
    xstar = .24;
    s1 = .021;
    s2 = 19;
    s = xstar / (s1 * min(f1,f2) + s2 );
    pd = exp(-b1*s*abs(f2-f1)) - exp(-b2*s*abs(f2-f1));
return