%% Verification plot
global R; global trans;
global H; global lpos;
global camO;
goodplot3d = figure;
% Plot world origin
plot3(0,0,0,'xc');
hold on
% Plot world axis
plot3([0 100],[0 0],[0 0],'r','LineWidth',2);
plot3([0 0],[0 100],[0 0],'g','LineWidth',2);
plot3([0 0],[0 0],[0 100],'b','LineWidth',2);

sqSize = 30;
for i=1:7
    plot3([(i-1)*sqSize (i-1)*sqSize],[0 6*sqSize],[0 0],'k')
end
for i=1:7
    plot3([0 6*sqSize],[(i-1)*sqSize (i-1)*sqSize],[0 0],'k')
end

% Plot world axis
plot3(camO(1),camO(2),camO(3),'or');

% Plot light source
plot3(lpos(1),lpos(2),lpos(3),'*y','markersize', 15);
plot3(lpos(1),lpos(2),lpos(3),'oy','markersize', 15);

% Plot camera axis
xcam = [100;0;0];
ycam = [0;100;0];
zcam = [0;0;100];

xworld=R'*xcam;
yworld=R'*ycam;
zworld=R'*zcam;

plot3([camO(1) camO(1)+xworld(1)],[camO(2) camO(2)+xworld(2)],[camO(3) camO(3)+xworld(3)],'r','LineWidth',2);
plot3([camO(1) camO(1)+yworld(1)],[camO(2) camO(2)+yworld(2)],[camO(3) camO(3)+yworld(3)],'g','LineWidth',2);
plot3([camO(1) camO(1)+zworld(1)],[camO(2) camO(2)+zworld(2)],[camO(3) camO(3)+zworld(3)],'b','LineWidth',2);

% plot pin1
%plot3([pinCenter{1}(1) pinTip{1}(1)],[pinCenter{1}(2) pinTip{1}(2)],[pinCenter{1}(3) pinTip{1}(3)],'r');

axis equal

%% Load gui again
gui
