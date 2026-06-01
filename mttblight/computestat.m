function oldstat = computestat(input, wlen);

if nargin<2
    wlen = 0;
end
oldstat.dens = 0;
oldstat.dur = 0;
oldstat.meanp = 0;
oldstat.stdp = 0;
oldstat.meanv = 0;
oldstat.ac = 0;
oldstat.ton = 0;
oldstat.maj = 0;
oldstat.min = 0;
oldstat.art = 0;
oldstat.tempo = 0;
oldstat.dis = 0;
oldstat.sync = 0;
oldstat.syntempo = 0;if input
    fid = fopen(input,'rt');
    if fid
        %if and(wlen>0, fscanf(fid,'%i') ~= wlen)
        %    disp('Statistical file with different window length.');
        %else
            fscanf(fid,'%s',1);
            inputype = fscanf(fid,'%s',1);
            if strcmp(inputype,'av_dens_c')
                fscanf(fid,'%s', 101);
                inputmat = [];
                %i=0;
                while fscanf(fid,'%s',1)
                    line = fscanf(fid,'%f', [101 1]); %102?
                    %if i<10 line' end
                    %i = i+1
                    inputmat = [inputmat; 0 line'];
                end
                oldstat.players = 2;
                oldstat.dens.mean = mean_isan(inputmat(:,2));
                oldstat.dens.std = sqrt(mean(inputmat(:,4)));
                oldstat.dur.mean = mean(inputmat(:,10));
                oldstat.dur.std = sqrt(mean_isan(inputmat(:,12)));
                oldstat.meanp.mean = mean_isan(inputmat(:,18));
                oldstat.meanp.std = sqrt(mean_isan(inputmat(:,20)));
                oldstat.stdp.mean = mean_isan(inputmat(:,26));
                oldstat.stdp.std = sqrt(mean_isan(inputmat(:,28)));
                oldstat.meanv.mean = mean_isan(inputmat(:,34));
                oldstat.meanv.std = sqrt(mean_isan(inputmat(:,36)));
                oldstat.ac.mean = mean_isan(inputmat(:,42));
                oldstat.ac.std = sqrt(mean_isan(inputmat(:,44)));
                oldstat.tempo.mean = mean_isan(inputmat(:,50));
                oldstat.tempo.std = sqrt(mean_isan(inputmat(:,52)));  
                oldstat.ton.mean = mean_isan(inputmat(:,58));
                oldstat.ton.std = sqrt(mean_isan(inputmat(:,60)));
                oldstat.art.mean = mean_isan(inputmat(:,66));
                oldstat.art.std = sqrt(mean_isan(inputmat(:,68)));
                oldstat.dis.mean = mean_isan(inputmat(:,74));
                oldstat.dis.std = sqrt(mean_isan(inputmat(:,76)));
                oldstat.maj.mean = mean_isan(inputmat(:,82));
                oldstat.maj.std = sqrt(mean_isan(inputmat(:,84)));
                oldstat.min.mean = mean_isan(inputmat(:,90));
                oldstat.min.std = sqrt(mean_isan(inputmat(:,92)));
                oldstat.sync.mean = mean_isan(inputmat(:,98));
                oldstat.sync.std = sqrt(mean_isan(inputmat(:,99)));
                oldstat.syntempo.mean = mean_isan(inputmat(:,100));
                oldstat.syntempo.std = sqrt(mean_isan(inputmat(:,101)));               
            else
                if strcmp(inputype,'av_dens')
                    fscanf(fid,'%s', 27);
                    inputmat = [];
                    name = fscanf(fid,'%s',1);
                    while name
                        line1 = fscanf(fid,'%f', [28 1]);
                        line1'
                        name2 = fscanf(fid,'%s',1)
                        if strcmp(name2,name)
                            line2 = fscanf(fid,'%f', [28 1]);
                            line2'
                            inputmat = [inputmat; 0 line1' line2(end-3) line2(end-2)];
                            name = fscanf(fid,'%s',1);
                        else
                            inputmat = [inputmat; 0 line1' NaN NaN];
                            name = name2;
                        end
                    end
                    oldstat.players = 2; %unused
                    oldstat.dens.mean = mean_isan(inputmat(:,2));
                    oldstat.dens.std = sqrt(mean_isan(inputmat(:,3)));
                    oldstat.dur.mean = mean_isan(inputmat(:,4));
                    oldstat.dur.std = sqrt(mean_isan(inputmat(:,5)));
                    oldstat.meanp.mean = mean_isan(inputmat(:,6));
                    oldstat.meanp.std = sqrt(mean_isan(inputmat(:,7)));
                    oldstat.stdp.mean = mean_isan(inputmat(:,8));
                    oldstat.stdp.std = sqrt(mean_isan(inputmat(:,9)));
                    oldstat.meanv.mean = mean_isan(inputmat(:,10));
                    oldstat.meanv.std = sqrt(mean_isan(inputmat(:,11)));
                    oldstat.ac.mean = mean_isan(inputmat(:,12));
                    oldstat.ac.std = sqrt(mean_isan(inputmat(:,13)));
                    oldstat.tempo.mean = mean_isan(inputmat(:,14));
                    oldstat.tempo.std = sqrt(mean_isan(inputmat(:,15)));
                    oldstat.ton.mean = mean_isan(inputmat(:,16));
                    oldstat.ton.std = sqrt(mean_isan(inputmat(:,17)));
                    oldstat.art.mean = mean_isan(inputmat(:,18));
                    oldstat.art.std = sqrt(mean_isan(inputmat(:,19)));
                    oldstat.dis.mean = mean_isan(inputmat(:,20));
                    oldstat.dis.std = sqrt(mean_isan(inputmat(:,21)));
                    oldstat.maj.mean = mean_isan(inputmat(:,22));
                    oldstat.maj.std = sqrt(mean_isan(inputmat(:,23)));
                    oldstat.min.mean = mean_isan(inputmat(:,24));
                    oldstat.min.std = sqrt(mean_isan(inputmat(:,25)));
                    oldstat.sync.mean = mean_isan(inputmat(1:2:size(inputmat,1),26));
                    oldstat.sync.std = sqrt(mean_isan(inputmat(2:2:size(inputmat,1),26)));
                    oldstat.syntempo.mean = mean_isan(inputmat(1:2:size(inputmat,1),27));
                    oldstat.syntempo.std = sqrt(mean_isan(inputmat(2:2:size(inputmat,1),27)));
                else
                    disp('Not suitable statistical file.');
                end
            %end
        end
    else
        disp('Cannot find input statistical file.');
    end
end