%% Prompt for interest region
global wkdir col1 col2 rowCrop1 rowCrop2;
imsbkg = rgb2gray(imread(strcat('./',wkdir,'/frames/frame1.png')));

figint = figure
imshow(imsbkg);
title('Select object region');
rect = getrect;

col1 = rect(1);
col2 = col1+rect(3);

rowCrop1 = rect(2);
rowCrop2 = rowCrop1+rect(4);
close all

gui;