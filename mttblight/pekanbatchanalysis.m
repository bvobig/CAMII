function stat = pekanbatchanalysis(wlen,col,graphaddress);
%function stat = batchanalysis(<wlen>,<col>,<graphaddress>);
% input parameters:
%   WLEN = length of analysis window in secs
%   COL (optional, default=0) = output color
%       0 = color output for screen
%       1 = b/w output for printout
%   GRAPHADDRESS (optional, default=current folder('.')) = address of the folder where to save the graphs

warning off
if nargin<1
    wlen=6; disp('Window length set to 6 secs.');
end
if nargin<2
    col=0;
end
if nargin<3
    graphaddress='.';
end

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
        analysis = pekanimproanalysis(nm,wlen,0,max(onset(nm,'sec')),col);
        if (col>-1)
            cd(graphaddress)
            saveas(gcf,[name '.tif']);
            cd(address)
        end
        if not(isempty(analysis))
            j=j+1;
            filename{j}=name;
            stat(:,j) = analysis;
        end
    end
end
fid = fopen('individual.stat','wt');
fprintf(fid,'parameters av_dens var_dens mean_sync var_sync length');
for i=1:j
    fprintf(fid,'\n%s',filename{i});
    for k=1:size(stat,1)
        fprintf(fid,' %f',stat(k,i));
    end
end
fclose(fid);

fprintf(1, 'Results saved in individual.stat\n');