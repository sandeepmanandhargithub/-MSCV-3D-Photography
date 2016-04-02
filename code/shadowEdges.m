function [shadowP1, shadowP2, otherPoints] = shadowEdges(ims, imsbkg, shadowWidth, col1, col2, upperCrop, bottomCrop, otherptsflag)

%figure
%imshow(ims)

col12 = [col1 col2];

otherPoints = ones(3,col2-col1-1);

if size(ims,3) == 3
    ims = rgb2gray(ims);
end

if size(imsbkg,3) == 3
    imsbkg = rgb2gray(imsbkg);
end

% Substract background
deltaims = double(imsbkg)-double(ims);
%figure
%subplot(121)
%imshow(deltaims,[])

% Get binary image using threshold
threshims = deltaims<80;
threshims(1:upperCrop,:) = 1;
threshims(bottomCrop:end,:) = 1;
%subplot(122)
%imshow(threshims)

shadowPts=[];

if (otherptsflag==1)
    range = col1:col2;
else
    range = col1:col2;
end

for i=1:length(range)
    col = range(i);
    % Get rough shadow position using binary image
    colvec = threshims(:,col);

    [idx]=find(colvec==0);
    row = max(idx); % rough shadow position

    % Get shadow profile around rough shadow position
    rowsh = row-floor(shadowWidth/2);
    shadowProfile = ims(max(rowsh-shadowWidth,1):min(rowsh+shadowWidth,size(ims,1)),col);

    % Find refined shadow position
    maxVal = max(shadowProfile);
    minVal = min(shadowProfile);
    zeroCrossing = double(maxVal-minVal)/2;
    shiftedProfile = double(shadowProfile)-zeroCrossing;
    %figure
    %plot(shiftedProfile,'.')

    [ind, pos] = crossing(shiftedProfile,max(rowsh-shadowWidth,1):min(rowsh+shadowWidth,size(ims,1)));
    if numel(pos)==2
        row = pos(2);

        shadowPts = [shadowPts [col;row;1]];
    end
end

if length(shadowPts>2)
    
shadowP1=shadowPts(:,1);
shadowP2=shadowPts(:,end);
otherPoints = shadowPts(:,2:end-1);

else
    
    shadowP1 = [];
    shadowP2 = [];
    otherPoints = [];
end




