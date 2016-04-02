d = load('wkdir'+data3d.mat);
fid = fopen('my3Ddata.txt','wt');
for ii = 1:size(A,1)
    fprintf(fid,'%g\t',A(ii,:));
    fprintf(fid,'\n');
end
fclose(fid)