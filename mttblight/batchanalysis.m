function stat = batchanalysis(wlen,col,input,graphaddress,cor,step);
%function stat = batchanalysis(<wlen>,<col>,<input>,<graphaddress>,<cor>,<step>);
% input parameters:
%   WLEN = length of analysis window in secs
%   COL (optional, default=0) = output color
%       0 = color output for screen
%       1 = b/w output for printout
%   INPUT (optional) = name of a statistical file (.stat) used as a reference for the analysis
%   GRAPHADDRESS (optional, default=current folder('.')) = address of the folder where to save the graphs
%   COR (optional, default=0) = length of cross-correlation windows in samples. if 0, imitation are not computed.
%   STEP (optional, default=1) = relative step between successive cross-correlation windows.

warning off
if nargin<1
    wlen=6; disp('Window length set to 6 secs.');
end
if nargin<2
    col=0;
end
if nargin<3
    input=0;
end
if nargin<4
    graphaddress='.';
end
if nargin<5
    cor=0;
end
if nargin<6
    step=1;
end

oldstat = computestat(input,wlen);

address = cd;
files = dir;
stat=[];
j=0;
for i = 1:size(files,1)
    name = files(i).name;
    nm = readmidi(name);
    if size(nm,1)>0
        fprintf(1, 'Analysing %s ...\n', name);
        %figure
        analysis = myimproanalysis(nm,wlen,0,max(onset(nm,'sec')),col,oldstat);
        j=j+1;
        filename{j}=name;
        raw{j}=analysis.raw;
        if (col>-1)
            cd(graphaddress)
            saveas(gcf,[name '.tif']);
            cd(address)
        end
        if cor
            if length(mchannels(nm))==2
                corres = coranalysis(analysis.raw,cor,step,col);
                newstat = [analysis.stat(:,1,2) analysis.stat(:,1,1) analysis.stat(:,2,2) analysis.stat(:,2,1) [corres'; NaN(2,4)]]';
                stat = [stat [newstat(1:end-10) newstat(end-6:end-5)]'];
                if (col>-1)
                    cd(graphaddress)
                    saveas(gcf,[name '.imit.tif']);
                    cd(address)
                end
            else
                newstat = [analysis.stat(:,1,2) analysis.stat(:,1,1) analysis.stat(:,2,2) analysis.stat(:,2,1) zeros(size(analysis.stat,1),4)]';
                stat = [stat [newstat(1:end-10) newstat(end-6:end-5)]'];
            end
        else
            newstat1 = [analysis.stat(:,1,1) analysis.stat(:,2,1)]';
            newstat2 = [analysis.stat(:,1,2) analysis.stat(:,2,2)]';
            stat(:,j,1) = newstat1(:);
            stat(:,j,2) = newstat2(:);
        end
    end
end
if j
    if cor
        fid = fopen('total.stat','wt');
        fprintf(fid,'parameters av_dens_c av_dens_t var_dens_c var_dens_t init_dens imit_dens intg_dens int2_dens av_dur_c av_dur_t var_dur_c var_dur_t init_dur imit_dur intg_dur int2_dur av_meanp_c av_meanp_t var_meanp_c var_meanp_t init_meanp imit_meanp intg_meanp int2_meanp av_stdp_c av_stdp_t var_stdp_c var_stdp_t init_stdp imit_stdp intg_stdp int2_stdp av_meanv_c av_meanv_t var_meanv_c var_meanv_t init_meanv imit_meanv intg_meanv int2_meanv av_ac_c av_ac_t var_ac_c var_ac_t init_ac imit_ac intg_ac int2_ac av_tempo_c av_tempo_t var_tempo_c var_tempo_t init_tempo imit_tempo intg_tempo int2_tempo av_ton_c av_ton_t var_ton_c var_ton_t init_ton imit_ton intg_ton int2_ton av_art_c av_art_t var_art_c var_art_t init_art imit_art intg_art int2_art av_dis_c av_dis_t var_dis_c var_dis_t init_dis imit_dis intg_dis int2_dis av_maj_c av_maj_t var_maj_c var_maj_t init_maj imit_maj intg_maj int2_maj av_min_c av_min_t var_min_c var_min_t init_min imit_min intg_min int2_min av_sync var_sync av_syntempo var_syntempo sil_c sil_t wlen');
        for i=1:j
            fprintf(fid,'\n%s',filename{i});
            for k=1:size(stat,1)
                fprintf(fid,' %f',stat(k,i));
            end
        end
        fprintf(1, 'Results saved in total.stat\n');
        fclose(fid);
    else
        fid = fopen('individual.stat','wt');
        fprintf(fid,'parameters av_dens var_dens av_dur var_dur av_meanp var_meanp av_stdp var_stdp av_meanv var_meanv av_ac var_ac av_tempo var_tempo av_ton var_ton av_art var_art av_dis var_dis av_maj var_maj av_min var_min mean+var_sync mean+var_syntempo sil wlen');
        for i=1:j
            if max(stat(:,:,2)>0)
                fprintf(fid,'\n%s',filename{i});
                for k=1:size(stat,1)
                    fprintf(fid,' %f',stat(k,i,2));
                end
            end
            fprintf(fid,'\n%s',filename{i});
            for k=1:size(stat,1)
                fprintf(fid,' %f',stat(k,i));
            end
        end
        if max(stat(:,:,2)>0)
            fprintf(fid,'\naverage1');
            for k=1:size(stat,1)
                fprintf(fid,' %f',mean_isan(stat(k,1:j,2)));
            end
            fprintf(fid,'\naverage2');
            for k=1:size(stat,1)
                fprintf(fid,' %f',mean_isan(stat(k,1:j)));
            end
        else
            fprintf(fid,'\naverage');
            for k=1:size(stat,1)
                fprintf(fid,' %f',mean_isan(stat(k,1:j,1)));
            end
        end
        fclose(fid);

        fid1 = fopen('client.raw','wt');
        for i=1:j
            fprintf(fid1,'%s\n',filename{i});
            for k=1:size(raw{i},2)
                for l=1:size(raw{i},1)
                    fprintf(fid1,'%f ',raw{i}(l,k,2));
                end
            fprintf(fid1,'\n');
            end
        end
        fclose(fid1);
        if max(stat(:,:,2)>0)
            fid2 = fopen('therapist.raw','wt');
            for i=1:j
                fprintf(fid2,'%s\n',filename{i});
                for k=1:size(raw{i},2)
                    for l=1:size(raw{i},1)
                        fprintf(fid2,'%f ',raw{i}(l,k,1));
                    end
                fprintf(fid2,'\n');
                end
            end
            fclose(fid2);
        end

        fprintf(1, 'Results saved in individual.stat\n');
    end
else
    fprintf(1, 'No MIDI file in this folder.\n');
end