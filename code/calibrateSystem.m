%% Clear workspace and close figures
close all;
clc;

%% Set working dir
global wkdir;
 wkdir = uigetdir;%();inputdlg('Please enter the project folder name');
% wkdir = wkdir{1};

%% Get checkerboard corners

% choose 4 points from the mouse input
% [X1,Y1] = H*[X2;Y2]
%
% [X1;Y1]: image coordinates
% [X2;Y2]: world coordinates

sqSize = 30;

y_w = [0;sqSize*7;sqSize*7;0];
x_w = [0;0;sqSize*5;sqSize*5];

im = imread(strcat('./',wkdir,'/lamp',num2str(1),'.jpg'));

imshow(im);
hold on;
x_im = []; y_im = [];

for i=1:4 % 4 mouse clicks
title(strcat('Select point ',num2str(i)));
[x,y] = ginput(1);
plot(x, y, 'or');
x_im = [x_im;x]; y_im = [y_im;y];
end
hold off;
close all;

%% Solve H from world and image points
global H ;
minusones = -1.*ones(length(x_w),1);
zeroz = zeros(length(x_w),3);
ax = [-x_w -y_w minusones zeroz x_im.*x_w x_im.*y_w x_im];
ay = [zeroz -x_w -y_w minusones y_im.*x_w y_im.*y_w y_im];
h = [ax;ay];

[U S V] = svd(h);
H = reshape(V(:,9), 3, 3)';

%% Verify H

figure,
imshow(im);
title('H verification: select a point on the grid');
[px_im, py_im] = ginput(1);
hold on;
plot(px_im, py_im, 'ob');
p_im = [px_im;py_im;1];
p_w = pinv(H)*p_im;
p_w = p_w./p_w(end)

uiwait(msgbox(strcat('Clicked point (x,y): ',num2str(p_w(1)),', ',num2str(p_w(2))),'H verification','modal'));

close all;

%% Get the pin shadow coords for lamp calibration
f = figure;
shadowTip = {};
pinCenter = {};

for n= 1:3
    i = imread(strcat('./',wkdir,'/lamp',num2str(n),'.jpg'));
    imshow(i);
    hold on;
    % get shadow tip point
    title('click on shadow tip');
    [pointx,pointy] = ginput(1);
    plot(pointx, pointy, 'ob');
    shadowTip{n} = pinv(H)*[pointx;pointy;1];
    shadowTip{n} = shadowTip{n}./shadowTip{n}(end);
    
    % get pin base center
    title('click on pin base center');
    [pointx,pointy] = ginput(1);
    plot(pointx, pointy, 'ob');
    pinCenter{n} = pinv(H)*[pointx;pointy;1];
    pinCenter{n} = pinCenter{n}./pinCenter{n}(end);
end
close all;
%% Prepare variables for lamp calibration
pinHeight = 28;

pinTip = pinCenter;
for i = 1:3
    shadowTip{i}(3) = 0; 
    pinCenter{i}(3) = 0; % not really used afterwards
    pinTip{i}(3) = pinHeight;
end

%% Lamp calibration
A = [];
b = [];
for i = 1:3
    p1 = shadowTip{i};
    p2 = pinTip{i};
    abc = p2 - p1;
    A(i,:) = [1/abc(1) -1/abc(2) 0];
    A(i+1,:) = [1/abc(1)  0 -1/abc(3)];
    
    b(i) = [1/abc(1)*p1(1) - 1/abc(2)*p1(2)];
    b(i+1) = [1/abc(1)*p1(1) - 1/abc(3)*p1(3)];
end
b = b';
global lpos;
lpos = A\b;
close all;
%% R|t from H
%
global R K camO;
global trans;
K = [ 5.2378659235426358e+02,  0.,  2.9419076820814161e+02;
      0,   5.2378659235426358e+02, 2.3455532482091851e+02; 
      0., 0., 1. ];
% H = K*[R|t]
% [R|t] = K^-1*H

Rtprime = inv(K)*H;
r1 = Rtprime(:,1);
r2 = Rtprime(:,2);
trans = Rtprime(:,3);

n1 = norm(r1);
n2 = norm(r2);
scale = (n1+n2)/2;
r1 = r1/scale;
r2 = r2/scale;
trans = trans/scale;
r3 = cross(r1,r2);

Q = [r1 r2 r3]; % a bad version of R

% Refine R using Zhang apdx C

[U S V] = svd(Q);
R = U*eye(3)*V'; % good R

Rt = [R trans];
Rt = [Rt; 0 0 0 1];

camO = -R'*trans;


%% Try to find projection ray from image point

% figure,
% imshow(ims);
% title('H verification');
% [px_im, py_im] = ginput(1);
% hold on;
% plot(px_im, py_im, 'ob');
% p_im = [px_im;py_im;1];
% 
% dirvec = pinv(K)*p_im;
% 
% dirvec = dirvec/norm(dirvec)*500;
% 
% dirvec_w = R'*dirvec; % rotated only
% % Test projection ray by plotting
% 
% set(0, 'currentfigure', goodplot3d);
% plot3([camO(1) camO(1)+dirvec_w(1)],[camO(2) camO(2)+dirvec_w(2)],[camO(3) camO(3)+dirvec_w(3)],'m');

%% Load gui again
gui

