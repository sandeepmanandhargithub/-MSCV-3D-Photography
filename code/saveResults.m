%% save results
global points3d wkdir H R K lpos camO trans;

allpoints = points3d';
lp = allpoints(find(allpoints(:,3)>0),:);
p3D = lp(find(lp(:,3)<1000),:);
p3D = p3D - repmat(mean(p3D), length(p3D), 1); % zero mead data
fid = fopen(strcat(wkdir,'/p3D.txt'),'wt');
for ii = 1:size(p3D,1)
    fprintf(fid,'%g\t',p3D(ii,:));
    fprintf(fid,'\n');
end
fclose(fid)
 save(strcat(wkdir,'/data3d.mat'),'points3d');
save(strcat(wkdir,'/sceneInfo.mat'),'H','R', 'K', 'lpos','camO','trans');