

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

imgOriginal = imread('MATERIAL/database/Moedas3.jpg');
%figure, imshow(imgOriginal); title('Original');

% PREPROCESSING

imgR = imgOriginal(:,:,1);
figure, imshow(imgR);
BW = imgR >= threshold;
se = strel('disk', 7);

BW = imerode(BW,se);
BW = imdilate(BW,strel('disk',4));
BW = imopen(BW,strel('disk',10));
BW = imdilate(BW,strel('disk',5));
BW = imerode(BW,strel('disk',4));
BW = imopen(BW,strel('disk',11));
imgProcessed = BW;
figure, imshow(imgProcessed); title('Fecho');

% 1- Count number of objects in the scene
%[lb num]= bwlabel(BW);
%figure, imshow(imgOriginal); title(['1- Number of objects: ', num2str(num)]);

% 1- Count number of objects in the scene
% 2- Visualization centroid, perimeter and area 
% 3 - Relative distance of the objects
% 4 - Derivative over the boundaries
StatsDistance(imgOriginal, imgProcessed);

% 7
selectionObject(imgOriginal, imgProcessed);

% figure,
% subplot(2,3,5); imshow(histeq(lb,10000)); title('Labels');
% subplot(2,3,1); imshow(mat2gray(lb)); title('Labels BW');
% colors = colormap(jet(9));
% subplot(2,3,2); imshow(ind2rgb(lb,colors)); title('Labels');
% stats = regionprops(lb);
% areas = [stats.Area];
% [dummy indM] = max(areas);
% imgBr = (lb == indM);
% subplot(2,3,3); imshow(imgBr); title('Maior �rea');
% subplot(2,3,4); imshow(img.*uint8(imgBr)); title('C�rebro');
% 
% areas = [];
% for k=1 : num
%     areas = [areas length(find(lb==k))]
% end
% [ val ind] = max(areas)
% 
% num; 

%[labeledImage, numberOfObject] = bwlabel(BW3); regionProps =
%regionprops(labeledImage, 'Area', 'Centroid', 'Perimeter', 'FilledImage');
%inds = find([regionProps.Area]>minArea);

% ind;
