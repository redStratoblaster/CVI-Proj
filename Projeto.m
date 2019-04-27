

% 1 - Number of objects in the image
% 2 - Visualization centroid, perimeter and area
% 3 - Relative distance of the objects
% 4 - Derivative of the objects boundary
% 5 - Ordering the objects depending on the area, perimeter, circularity or 
% sharpness
% 6 - Compute the amount of money
% 7 - From a user selection of given object (the user should select one object,
% generate a figure that shows an ordered list of objcets, i.e. from the
% most similar to the less similar of the chosen object. The similarity
% criteria can be one of the previously computed features in point 5.
% 8 - Provide a heatmap of the image contents, where the hot color is (are) the
% object(s) of interest: The object may be selected by the user; The user
% may select several objects. Under this situation, several hot colors
% should be displayed for the previously selected objects.


clear all, close all
threshold = 125;
minArea = 50;

imgOriginal = imread('MATERIAL/database/Moedas4.jpg');

% PREPROCESSING

imgR = imgOriginal(:,:,1);
BW = imgR >= threshold;
se = strel('disk', 7);

BW = imerode(BW,se);
BW = imdilate(BW,strel('disk',4));
BW = imopen(BW,strel('disk',10));
BW = imdilate(BW,strel('disk',5));
BW = imerode(BW,strel('disk',4));
BW = imopen(BW,strel('disk',11));
imgProcessed = BW;

figure; 
Information(imgOriginal, imgProcessed);

