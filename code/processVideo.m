 %% Load images
display('loading images');
global wkdir col1 col2 rowCrop1 rowCrop2 H R K lpos camO points3d;
files = dir(strcat(wkdir,'/frames/*.png'));

N = length(files);

im = rgb2gray(imread(strcat('./',wkdir,'/frames/frame1.png')));

[m,n]=size(im);

frames=zeros(m,n,N);

for i=1:N
    im =rgb2gray(imread(strcat('./',wkdir,'/frames/',strcat('frame',num2str(i),'.png'))));
    frames(:,:,i) =  im;
end

%% Process every frame

points3d = [];

display('working very hard to process all frames');

imsbkg = rgb2gray(imread(strcat('./',wkdir,'/frames/frame1.png')));
h = waitbar(0,'Triangulating...');

% Estimate shadow width
midFrame = frames(:,:,floor(N*2/3));
%figure
%imshow(midFrame,[])
shadowVec = midFrame(rowCrop1:rowCrop2,col1);
%figure
%plot(shadowVec);
shadowLevel = (max(shadowVec)-min(shadowVec))/2 + min(shadowVec);
[ind] = crossing(shadowVec-shadowLevel);

if (length(ind)==2)
    shadowWidth = ind(2)-ind(1);
    display(strcat('shadow width: ', num2str(shadowWidth)));
else
    shadowWidth = ceil(m/10); % default value
    display('shadow width not detected, using default value');
end

if shadowWidth>m/4
    shadowWidth = ceil(m/10); % default value
    display('shadow width not detected, using default value');
end

for i = 2:N        
    waitbar(i/N, h, 'Triangulating...');

   % Compute shadow plane PI
    %ims = imread('../theframe.jpg');
    
    theims = double(imsbkg) - double(frames(:,:,i));
    %theims = medfilt2(double(rgb2gray(imsbkg))) - medfilt2(double(rgb2gray(frames(:,:,i))));
    %theims = frames(:,:,i)-frames{i-1};

    %[shadowP1, shadowP2, otherPoints] = theShadowEdge(theims, col1, col2, rowCrop1, rowCrop2);
    [shadowP1, shadowP2, otherPoints] = shadowEdges(frames(:,:,i), imsbkg, shadowWidth, col1, col2, rowCrop1, rowCrop2,1);
                                                 
    if (isempty(shadowP1)==1 || isempty(shadowP2)==1) % check if shadow exists in this frame
        continue
    end

    
    shadowP1_w = pinv(H)*shadowP1;
    shadowP1_w = shadowP1_w./shadowP1_w(end);
    shadowP2_w = pinv(H)*shadowP2;
    shadowP2_w = shadowP2_w./shadowP2_w(end);
    shadowP1_w(3) = 0; shadowP2_w(3) = 0;

    % 3 points of THE SHADOW plane retrieved so far
    % lpos, shadowP1_w and shadowP2_w
    vecLSP1 = shadowP1_w - lpos; % vector from light to shadow point 1
    vecLSP2 = shadowP2_w - lpos; % vector from light to shadow point 2
    normal2Pi = cross(vecLSP1, vecLSP2);
    normal2Pi = normal2Pi/norm(normal2Pi);


    for j = 1:size(otherPoints,2)
        dirvec_w = getdirectionVector(otherPoints(:,j), K, R);
        A = [];
        b = [];
        answer_w = [];
        % Add the two eqs corresponding to projection ray
        p1 = camO;    
        abc = dirvec_w;
        A(1,:) = [1/abc(1) -1/abc(2) 0];
        A(2,:) = [1/abc(1)  0 -1/abc(3)];

        b(1) = [1/abc(1)*p1(1) - 1/abc(2)*p1(2)];
        b(2) = [1/abc(1)*p1(1) - 1/abc(3)*p1(3)];

        % Add the PI eq

        A(3,:) = [normal2Pi(1) normal2Pi(2) normal2Pi(3)];
        b(3) = normal2Pi'*lpos;

        b = b';

        answer_w = A\b;
        %set(0, 'currentfigure', goodplot3d);
        %plot3(answer_w(1), answer_w(2),answer_w(3),'.k');

        points3d = [points3d, answer_w];
    end    
end

% goodptidx = find(points3d(3,:)>23);
% goodpoints = points3d(:,goodptidx);
% 
% goodptidx = find(goodpoints(3,:)<26);
% goodpoints = goodpoints(:,goodptidx);

%for i=1:length(goodpoints)
%    set(0, 'currentfigure', goodplot3d);
%    plot3(goodpoints(1,i), goodpoints(2,i),goodpoints(3,i),'.k');
%end

% x = goodpoints(1,:);
% y = goodpoints(2,:);
% z = goodpoints(3,:);
% 
% tri = delaunay(x,y);
% h = trisurf(tri, x, y, z);
% 
% axis equal
% xnodes = 0:.00125:1;
% ynodes = xnodes;
% [zg,xg,yg] = gridfit(x,y,z,xnodes,ynodes,'tilesize',...
% 120,'overlap',0.25);
% surf(xg,yg,zg)
% shading interp
% colormap(jet(256))
% camlight right
% lighting phong
% title 'Tiled gridfit'
% 
% view([0 0 pi/2])