%% Plot results
global points3d;
close all;
plot3dSetup;
gca


hold on
goodptidx = find(points3d(3,:)>3);
goodpoints = points3d(:,goodptidx); 


set(0, 'currentfigure', goodplot3d);
plot3(goodpoints(1,:), goodpoints(2,:),goodpoints(3,:),'.k','markersize', 1); %% no loops

figure
plot3(goodpoints(1,:), goodpoints(2,:),goodpoints(3,:),'.k','markersize', 1); %% no loops
axis equal