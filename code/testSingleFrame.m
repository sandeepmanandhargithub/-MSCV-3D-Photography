
%% Compute shadow plane PI
ims = rgb2gray(imread(strcat('./',wkdir,'/frames/frame100.png')));
imsbkg = rgb2gray(imread(strcat('./',wkdir,'/frames/frame1.png')));
theims = imsbkg - ims;

%[shadowP1, shadowP2, otherPoints] = theShadowEdge(theims, 200, 400, 50, 300);
[shadowP1, shadowP2, otherPoints] = shadowEdges(ims, imsbkg, 30, 200, 400, 50, 300, 1)
                                    
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

%% Plot shadow plane

set(0, 'currentfigure', goodplot3d);
plot3([shadowP1_w(1) shadowP2_w(1)], [shadowP1_w(2) shadowP2_w(2)],[shadowP1_w(3) shadowP2_w(3)], '--k');
plot3([lpos(1) shadowP1_w(1) shadowP2_w(1)], [lpos(2) shadowP1_w(2) shadowP2_w(2)],[lpos(3) shadowP1_w(3) shadowP2_w(3)], 'g');
plot3([lpos(1) shadowP2_w(1)], [lpos(2) shadowP2_w(2) ],[lpos(3) shadowP1_w(3) ], 'g');

fill3([lpos(1) shadowP1_w(1) shadowP2_w(1)], [lpos(2) shadowP1_w(2) shadowP2_w(2)],[lpos(3) shadowP1_w(3) shadowP2_w(3)], 'g');

gpos = (lpos + shadowP1_w + shadowP2_w)/3;
plot3([gpos(1) gpos(1)+normal2Pi(1)*200], [gpos(2) gpos(2)+normal2Pi(2)*200],[gpos(3) gpos(3)+normal2Pi(3)*200], 'b');
 
 %% Get 3d points for this frame
 
 for j = 1:length(otherPoints)
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

    answer_w = A\b
    set(0, 'currentfigure', goodplot3d);
    plot3(answer_w(1), answer_w(2),answer_w(3),'.k');
 end

