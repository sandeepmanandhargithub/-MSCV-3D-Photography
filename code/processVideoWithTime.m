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

%col1 = 240;
%col2 = 440;

%% Get shadow edges for each frame
display('Getting shadow edges for each frame');
shadowP1s = zeros(3,N);
shadowP2s = zeros(3,N);
imsbkg = frames(:,:,1);

%rowCrop1 = 50;
%rowCrop2 = 400;

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

for i = 1:N        
    [shadowP1, shadowP2] = shadowEdges(frames(:,:,i), imsbkg, shadowWidth, col1, col2, rowCrop1, rowCrop2,0);

    if (isempty(shadowP1) || isempty(shadowP2)) % check if shadow exists in this frame
        shadowP1 = zeros(3,1);
        shadowP2 = zeros(3,1);
    end
    
    shadowP1s(:,i) = shadowP1;
    shadowP2s(:,i) = shadowP2;
end


%% Get shadow time for every pixel
display('Getting shadow time for each pixel');
Imax = max(frames,[],3);
Imin = min(frames,[],3);
Ishadow = (double(Imax)+double(Imin))/2;

ts = zeros(m,n);

for i=1:m
    for j=col1:col2 %m
        Iprofile = squeeze(frames(i,j,:));
        threshVal = Ishadow(i,j);        
        [idx,interpIdx] = crossing(Iprofile-threshVal,1:N);
        ts(i,j) = interpIdx(1);
    end
end

%% Computing shadow plane for each point and all the rest
display('Interpolating shadow plane and triangulating');
points3d = [];
pinvH = pinv(H);
h = waitbar(0,'Triangulating...');
for i=1:m
    waitbar(i/m, h, 'Triangulating...');
    for j=col1:col2
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Get time-interpolated shadow points
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        t = ts(i,j);
        tprev = floor(t);
        tnext = ceil(t);
        
        if (t~=tprev)

            tvec = [tprev tnext];
            p1vec = [shadowP1s(2,tprev) shadowP1s(2,tnext)]; % only contains row info
            p2vec = [shadowP2s(2,tprev) shadowP2s(2,tnext)]; % only contains row info

            if min([p1vec p2vec])==0
                continue
            end

            p1row = interp1(tvec,p1vec,t);
            p2row = interp1(tvec,p2vec,t);
        else
            p1row = shadowP1s(2,tprev);
            p2row = shadowP2s(2,tprev);
        end

        shadowP1 = [col1; p1row; 1];
        shadowP2 = [col2; p2row; 1];

        %%%%%%%%%%%%%%%%%%%%%%
        % Compute shadow plane
        %%%%%%%%%%%%%%%%%%%%%%
        shadowP1_w = pinvH*shadowP1;
        shadowP1_w = shadowP1_w./shadowP1_w(end);
        shadowP2_w = pinvH*shadowP2;
        shadowP2_w = shadowP2_w./shadowP2_w(end);
        shadowP1_w(3) = 0; shadowP2_w(3) = 0;

        % 3 points of THE SHADOW plane retrieved so far
        % lpos, shadowP1_w and shadowP2_w
        vecLSP1 = shadowP1_w - lpos; % vector from light to shadow point 1
        vecLSP2 = shadowP2_w - lpos; % vector from light to shadow point 2
        normal2Pi = cross(vecLSP1, vecLSP2);
        normal2Pi = normal2Pi/norm(normal2Pi);
        
        %%%%%%%%%%%%%%%%%%%%%%
        % Perform triangulation
        %%%%%%%%%%%%%%%%%%%%%%
        dirvec_w = getdirectionVector([j;i;1], K, R);
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
%        set(0, 'currentfigure', goodplot3d);
%        plot3(answer_w(1), answer_w(2),answer_w(3),'.k');

        points3d = [points3d, answer_w];       
        
%         figure
%         imshow((double(frames(:,:,tprev))+double(frames(:,:,tnext)))/2,[]);
%         hold on;
%         plot(shadowP1(1),shadowP1(2),'or');
%         plot(shadowP2(1),shadowP2(2),'or');
%         plot(j,i,'or');
%     
    end
end

%% Load gui again
gui

