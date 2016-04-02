function [shadowP1, shadowP2, otherPoints] = theShadowEdge(ims, col1, col2, upperCrop, bottomCrop)

if size(ims,3) == 3
    ims = rgb2gray(ims);
end

otherPoints = ones(3,col2-col1-1);

threshIm = ims<80;


threshIm(1:upperCrop,:) = 1;
threshIm(bottomCrop:end,:) = 1;


col1vec = threshIm(:,col1);
%figure
%imshow(threshIm)
%plot(col1vec);

[idx]=find(col1vec==0);
if size(idx,1)==0
    shadowP1 = [];
else
    shadowP1 = [ col1;max(idx);1];
end

col2vec = threshIm(:,col2);
%figure
%plot(col2vec);

[idx]=find(col2vec==0);
 if size(idx,1)==0
     shadowP2 = [];
 else
    shadowP2 = [col2;max(idx);1];
 end

%threshIm(1,:) = 0;
for i=1:length(otherPoints)
    colvec = threshIm(:,col1+i);
    [idx]=find(colvec==0);
    shadowP = [ col1+i;max(idx);1];    
    if size(idx,1)~=0
        otherPoints(:,i) = shadowP;    
    end
end

% 
% figure,
% imshow(threshIm);
% hold on;
% plot(shadowP1(2), shadowP1(1), 'or');
% plot(shadowP2(2), shadowP2(1), 'or');

