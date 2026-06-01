function impropca(data);
isnann =sum(isnan(data),2)>0;

for k=1:size(data,2)
   data(find(~isnann),k)=data(find(~isnann),k)/mean(data(find(~isnann),k));
end
[l,q,c]=pca(data(find(~isnann),:));
l
cc = NaN*ones(size(c,1),size(data,1));
cc(:,find(~isnann))=c;
clf
CH1=1:(size(cc,2)/2);
CH2=((size(cc,2)/2)+1):size(cc,2);

subplot(1,2,1)
plot(cc(1,CH1),cc(2,CH1),'b-'); hold on
plot(cc(1,CH1(1)),cc(2,CH1(1)),'bo');
for k=10:10:length(CH1)
    plot(cc(1,k),cc(2,k),'bo');
    text(cc(1,k),cc(2,k),num2str(k));
end
hold off

subplot(1,2,2)
plot(cc(1,CH2),cc(2,CH2),'r-'); hold on
plot(cc(1,CH2(1)),cc(2,CH2(1)),'ro');
for k=10:10:length(CH1)
    plot(cc(1,k+length(CH1)),cc(2,k+length(CH1)),'ro');
    text(cc(1,k+length(CH1)),cc(2,k+length(CH1)),num2str(k));
end
hold off



drawnow
hold off
