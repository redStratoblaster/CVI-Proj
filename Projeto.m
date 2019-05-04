function Projeto()
    clear all, close all
    threshold = 125;
    minArea = 50;

    imgOriginal = imread('MATERIAL/database/Moedas3.jpg');

    % Feature Enhancing
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
end


function Information(imgOriginal, imgProcessed)
    imshow(imgOriginal);
    stats1 = regionprops(bwlabel(imgProcessed,8),...
                        'Eccentricity',...
                        'Area',...
                        'Centroid',...
                        'BoundingBox',...
                        'Perimeter',...
                        'MinorAxisLength');
    objectButtons(stats1, imgOriginal, imgProcessed);
    objIndex = find([stats1.Area] > 1000);
    sz = size(objIndex); 
    totalAmount = getCoinValue(imgOriginal, 0);
    
    titleLine1 = strcat('Number of objects:',num2str(sz(2)),...
        '    Amount of money:',num2str(totalAmount),'€');
    titleLine3 = 'Click on a region to see information.';
    title(titleLine1);
    xlabel(titleLine3);
    interface(-1, imgOriginal, imgProcessed, stats1);
end

function objectButtons(stats1, imgOriginal, imgProcessed)
    objIndex = find([stats1.Area] > 1000);
    for i = 1 : numel(objIndex)
        box1 = InitDraw(i,objIndex,stats1, [1 0 0], [1 0 0 0.2]);
        set(box1,'buttondownfcn',{@ShowInfo,i,objIndex,imgOriginal,imgProcessed,stats1});
    end
end

function box1 = InitDraw(i,objIndex,stats,edgeColor,faceColor)
    statsObj = stats(objIndex);
    boundingBoxI = statsObj(i).BoundingBox;
    box1 = rectangle('Position',...
              [boundingBoxI(1),...
               boundingBoxI(2),...
               boundingBoxI(3),...
               boundingBoxI(4)],...
              'EdgeColor',edgeColor,...
              'FaceColor',faceColor);
    text(statsObj(i).Centroid(1),...
         statsObj(i).Centroid(2),...
         'X',...
         'color','red',...
         'HorizontalAlignment','center',...
         'VerticalAlignment','middle',...
         'FontSize',12);
end

function ShowInfo(~,~,i,objIndex,imgOriginal, imgProcessed, stats)
    clf('reset');
    imshow(imgOriginal);
    interface(i, imgOriginal,imgProcessed, stats);
    statsObj = stats(objIndex);
    xlabel('Click on a region to see information.');
    for index = 1 : numel(objIndex)
        if(index == i)
            
            title(['"X" mark the centroids, Perimeter: ', num2str(statsObj(i).Perimeter),...
                   ', Eccentricity: ', num2str(statsObj(i).Eccentricity),...
                   ' and Area: ', num2str(statsObj(i).Area)]);
            
            boundingBoxI = statsObj(i).BoundingBox;
            rectangle('Position',...
            [boundingBoxI(1),...
             boundingBoxI(2),...
             boundingBoxI(3),...
             boundingBoxI(4)],...
            'EdgeColor',[0 1 0],...
            'FaceColor',[0 1 0 0.2]);
        else            
            x1 = statsObj(i).Centroid(1);
            x2 = statsObj(index).Centroid(1);
            y1 = statsObj(i).Centroid(2);
            y2 = statsObj(index).Centroid(2);
            x=[x1,x2];
            y=[y1,y2];
            line(x,y,'Color','green','LineStyle','-');
            distance = num2str(sqrt((x2-x1)^2+(y2-y1)^2));
            
            text(statsObj(index).Centroid(1),...
                 statsObj(index).Centroid(2)-13,...
                 'Distance:',...
                 'color','black',...
                 'HorizontalAlignment', 'center',...
                 'VerticalAlignment', 'middle',...
                 'FontSize',12);
             
             text(statsObj(index).Centroid(1),...
                 statsObj(index).Centroid(2)+13,...
                 distance,...
                 'color','black',...
                 'HorizontalAlignment', 'center',...
                 'VerticalAlignment', 'middle',...
                 'FontSize',12);
             
        end
        box2 = InitDraw(index,objIndex,stats, [1 0 0], [1 0 0 0.2]);
        set(box2,'buttondownfcn',{@ShowInfo,index,objIndex,imgOriginal, imgProcessed,stats});
    end
end

function showOrder(imgProcessed, orderArray, stats, type)
   if(strcmp(type, 'Sharpness'))
       [B,L] = bwboundaries(imgProcessed,'noholes');
       stats1 = regionprops(L,'Area','Centroid','Image','Eccentricity', 'BoundingBox');
       objIndex = find([stats1.Eccentricity]);
       statsObj1 = stats1(objIndex);
       for k = 1:length(B)
           sharpness = estimateSharpness(statsObj1(k).Image);
           indexValue = find(orderArray == sharpness);
           % display the results
           boundingBoxI = statsObj1(k).BoundingBox;
           metric_string = sprintf('%d',indexValue);
           text(boundingBoxI(1)+(boundingBoxI(3)/2)-5,...
           boundingBoxI(2)+(boundingBoxI(4)/2)-20,...
               metric_string,...
               'Color','green',...
               'FontSize',15,...
               'FontWeight','bold');
       end 
   else
       objIndex = find([stats.Perimeter]);
       for index = 1 : numel(objIndex)
           statsObj = stats(index);
           if(strcmp(type,'Perimeter'))
            indexValue = find(orderArray == statsObj.Perimeter);
            % display the results
            boundingBoxI = statsObj.BoundingBox;
            metric_string = sprintf('%d',indexValue);
            text(boundingBoxI(1)+(boundingBoxI(3)/2)-5,...
           boundingBoxI(2)+(boundingBoxI(4)/2)-20,...
               metric_string,...
               'Color','green',...
               'FontSize',15,...
               'FontWeight','bold');
           end
           if(strcmp(type,'Area'))
            indexValue = find(orderArray == statsObj.Area);
            % display the results
            boundingBoxI = statsObj.BoundingBox;
            metric_string = sprintf('%d',indexValue);
            text(boundingBoxI(1)+(boundingBoxI(3)/2)-5,...
           boundingBoxI(2)+(boundingBoxI(4)/2)-20,...
               metric_string,...
               'Color','green',...
               'FontSize',15,...
               'FontWeight','bold');
           end  
       end
    end
end
function derivatives(imgOriginal, imgProcessed)
    derivativesFigure = figure;

    [boundaries,labeledMatrix] = bwboundaries(imgProcessed,'noholes');

    panel = uipanel('Parent',derivativesFigure,'BorderType','none'); 
    panel.Title = 'Derivative of the objects boundaries '; 
    panel.TitlePosition = 'centertop'; 
    panel.FontSize = 14;
    panel.FontWeight = 'bold';

    z=1; % to help printing subplots in correct order
    for i=1:length(boundaries)    

        [row, col] = find(labeledMatrix==i);
        croppedLabel = imcrop(imgOriginal,[(min(col)-10) (min(row)-10) ...
            (max(col)-min(col)+10) (max(row)-min(row)+10)]);

        figure(derivativesFigure);
        subplot(4,4,(z),'Parent',panel), imshow(croppedLabel);
        title(['Object id: ' num2str(i)]);

        % Find boundaries.
        boundaries = bwboundaries(labeledMatrix==i);
        for k = 1 : size(boundaries, 1)
          kBoundary = boundaries{k}; 
          % Get Xx.
          deltaX = kBoundary(:,2);
          % Get Yy.
          deltaY = kBoundary(:,1);
          dy = [];
          for m = 2:size(deltaX)
                % derivate
                dy = [dy, deltaX(m)-deltaX(m-1)/deltaY(m)-deltaY(m-1)];
                m = m + 1;
          end
          subplot(4,4,(z+1),'Parent',panel), plot(dy);
        end    
        z=z+2;    
    end
    set(gcf,'units','normalized','outerposition',[0 0 1 1])
end

function orderCircularities(imgProcessed, orderedArray, stats, circularities)
    hold on
    for i = 1:length(circularities)
      index = find(orderedArray == circularities(i));
      statsObj = stats(i);
      boundingBoxI = statsObj.BoundingBox;
       metric_string = sprintf('%d',index);
       text(boundingBoxI(1)+(boundingBoxI(3)/2)-5,...
           boundingBoxI(2)+(boundingBoxI(4)/2)-20,...
           metric_string,...
           'Color','green',...
           'FontSize',15,...
           'FontWeight','bold');
    end    
end

% metric.
function [sharpness]=estimateSharpness(G)
    [Gx, Gy]=gradient(G);
    S=sqrt(Gx.*Gx+Gy.*Gy);
    sharpness=sum(sum(S))./(numel(Gx));
end

 function interface(i,imgOriginal,imgProcessed, stats)
        bg = uibuttongroup('Visible','off',...
            'Position',[0 0 .15 1],...
            'SelectionChangedFcn',{@interfaceHandler,i,imgOriginal,imgProcessed,stats});
        
        uicontrol(bg,'Style','radiobutton',...
            'String','Order by Perimeter',...
            'Position',[10 450 200 30],...
            'HandleVisibility','off');

        uicontrol(bg,'Style','radiobutton',...
            'String','Order by Area',...
            'Position',[10 400 200 30],...
            'HandleVisibility','off');

        uicontrol(bg,'Style','radiobutton',...
            'String','Order by Circularity',...
            'Position',[10 350 200 30],...
            'HandleVisibility','off');
        
        uicontrol(bg,'Style','radiobutton',...
            'String','Order by Sharpness',...
            'Position',[10 300 200 30],...
            'HandleVisibility','off');
        
        uicontrol(bg,'Style','radiobutton',...
            'String','Amount of Money',...
            'Position',[10 250 200 30],...
            'HandleVisibility','off');
        
        uicontrol(bg,'Style','radiobutton',...
            'String','Derivative',...
            'Position',[10 200 200 30],...
            'HandleVisibility','off');
 
        uicontrol(bg,'Style','radiobutton',...
            'String','Order from selected object',...
            'Position',[10 150 200 30],...
            'HandleVisibility','off');
        
        uicontrol(bg,'Style','radiobutton',...
            'String','Heatmap',...
            'Position',[10 50 200 30],...
            'HandleVisibility','off');
        
        uicontrol(bg,'Style','radiobutton',...
            'String','Reset',...
            'Position',[10 0 100 30],...
            'HandleVisibility','off');

        % Make the uibuttongroup visible after creating child objects.
        bg.Visible = 'on';
        set(bg,'selectedobject',[]);
 end
 
 function clearScreen(imgOriginal,imgProcessed, stats, titleString)
        clf('reset');
        imshow(imgOriginal);
        interface(-1,imgOriginal,imgProcessed, stats);
        objectButtons(stats, imgOriginal, imgProcessed);
        title(titleString);
        xlabel('Click on a region to see information.');
 end
 
 function interfaceHandler(~,event,i,imgOriginal,imgProcessed, stats)
        switch event.NewValue.String
            case 'Order by Perimeter'
                clearScreen(imgOriginal,imgProcessed, stats, 'Objects ordered by Perimeter');
                orderedArray = sort([stats(:).Perimeter]); 
                showOrder(imgProcessed, orderedArray, stats, 'Perimeter');
            case 'Order by Area'
                clearScreen(imgOriginal,imgProcessed, stats, 'Objects ordered by Area');
                orderedArray = sort([stats(:).Area]); 
                showOrder(imgProcessed, orderedArray, stats, 'Area');
            case 'Order by Circularity'
                circularity = calculateCircularity(imgProcessed);
                clearScreen(imgOriginal,imgProcessed, stats, 'Objects ordered by Circularity');
                orderedArray = sort(circularity);
                orderCircularities(imgProcessed, orderedArray, stats, circularity);
            case 'Order by Sharpness'
                clearScreen(imgOriginal,imgProcessed, stats, 'Objects ordered by Sharpness');
                arraySharpness = calculateSharpness(imgProcessed);
                orderedArray = sort(arraySharpness);
                showOrder(imgProcessed, orderedArray, stats, 'Sharpness');
            case 'Derivative'
                clearScreen(imgOriginal,imgProcessed, stats, 'Objects boundary derivate');
                derivatives(imgOriginal, imgProcessed);
            case 'Amount of Money'
                clearScreen(imgOriginal,imgProcessed, stats, 'Amount of money');
                getCoinValue(imgOriginal,1);
            case 'Order from selected object'
                if(i == -1)
                    title('Select a region first!');
                else
                    clearScreen(imgOriginal, imgProcessed, stats, 'Select the criteria for ordering')                
                    orderObjects(i, imgOriginal,imgProcessed);
                end
            case 'Heatmap'
                clearScreen(imgOriginal,imgProcessed, stats, 'Heatmap');
                heatmap(imgOriginal, imgProcessed);
            case 'Reset'
                 clf('reset');
                 Information(imgOriginal, imgProcessed) 
        end

 end
    
 
function coinAmount = getCoinValue(img, total)
    [centers,radius] = imfindcircles(img,[40 90], 'Sensitivity',0.9);
    coinAmount = 0;
    for i = 1 : numel(radius)
        switch true
            case 54< radius(i) && radius(i)< 57
                coinAmount = coinAmount + 0.01;
                coinValue = 0.01;
            case 64< radius(i) && radius(i)< 67
                coinAmount = coinAmount + 0.02;
                coinValue = 0.02;
            case 72< radius(i) && radius(i)< 76
                coinAmount = coinAmount + 0.05;   
                coinValue = 0.05;
            case 67< radius(i) && radius(i)< 72
                coinAmount = coinAmount + 0.1;
                coinValue = 0.1;
            case 76< radius(i) && radius(i)< 79
                coinAmount = coinAmount + 0.20;
                coinValue = 0.2;
            case 83< radius(i) && radius(i)< 86
                coinAmount = coinAmount + 0.50;
                coinValue = 0.5;
            case 79< radius(i) && radius(i)< 83
                coinAmount = coinAmount + 1;
                coinValue = 1;
            case 87< radius(i) && radius(i)< 92
                coinAmount = coinAmount + 2;
                coinValue = 2;
        end   
        if(total)
            text(centers(i,1),centers(i,2)-20,[num2str(coinValue),'€'],...
                'color','green','HorizontalAlignment', 'center',...
                'VerticalAlignment', 'middle','FontSize',15,'FontWeight','bold');
            titleLine1 = strcat('Amount of money:',num2str(coinAmount),'€');
            title(titleLine1);
        end
    end
end


function orderObjects(i,imgOriginal,imgProcessed)
    circularity = calculateCircularity(imgProcessed);
    arraySharpness = calculateSharpness(imgProcessed);
    stats = regionprops(bwlabel(imgProcessed,8),...
                        'Eccentricity',...
                        'Area',...
                        'Centroid',...
                        'BoundingBox',...
                        'Perimeter');
    
    objIndex = find([stats.Area] > 1000);
    objStats = stats(objIndex);
    selectObject(i,stats, imgOriginal, imgProcessed, circularity, arraySharpness);
   
end

function selectObjectCallback(~,~,clickedIndex,stats,imgOriginal,imgProcessed, circularities, sharpnesses)
    selectObject(clickedIndex,stats,imgOriginal,imgProcessed, circularities, sharpnesses);
end

function selectObject(clickedIndex,stats,imgOriginal,imgProcessed, circularities, sharpnesses)
    clf('reset');

    [labeled, numObjects] = bwlabel(imgProcessed,4);

    title('Objects ordered according to their similarity with the clicked object.');
    subplot(numObjects,2,[1 numObjects]), 
    imshow(imgOriginal);
    
    objIndex = find([stats.Area] > 1000);
    statsObj = stats(objIndex);

    for i = 1 : numel(objIndex)

        if(clickedIndex == i)
            BBcolors = [0,0,0];
        else
            BBcolors = [1,0,0];
        end

        box1 = InitDraw(i, objIndex, statsObj, BBcolors, [1 0 0 0.2]);
        set(box1,...
            'buttondownfcn',...
            {@selectObjectCallback,...
            i,...
            stats,...
            imgOriginal,...
            imgProcessed,...
            circularities,...
            sharpnesses});
    end

    buttons = uibuttongroup('Visible','off',...
            'Position',[0 0 .1 1],...
            'SelectionChangedFcn',...
            {@selectionHandler,...
            imgOriginal,...
            imgProcessed,...
            clickedIndex,...
            circularities,...
            sharpnesses});

    r1 = uicontrol(buttons,'Style','radiobutton',...
        'String','Perimeter',...
        'Position',[10 450 100 30],...
        'HandleVisibility','off');

    r2 = uicontrol(buttons,'Style','radiobutton',...
        'String','Area',...
        'Position',[10 350 100 30],...
        'HandleVisibility','off');

    r3 = uicontrol(buttons,'Style','radiobutton',...
        'String','Circularity',...
        'Position',[10 250 100 30],...
        'HandleVisibility','off');
    
    r4 = uicontrol(buttons,'Style','radiobutton',...
        'String','Sharpness',...
        'Position',[10 150 100 30],...
        'HandleVisibility','off');
    
    r5 = uicontrol(buttons,'Style','radiobutton',...
        'String','Back',...
        'Position',[10 50 100 30],...
        'HandleVisibility','off');

    % Make the uibuttongroup visible after creating child objects.
    buttons.Visible = 'on';
    
    set(buttons,'selectedobject',[]);

end


function selectionHandler(~, event, imgOriginal, imgProcessed, clickedIndex, circularities, sharpnesses)
    
    [labeled, numObjects] = bwlabel(imgProcessed,8);
    stats = regionprops(labeled,...
                'Eccentricity',...
                'Area',...
                'Centroid',...
                'BoundingBox',...
                'Perimeter');

    switch event.NewValue.String
        case 'Perimeter'
            orderedArray = sortArray([stats(:).Perimeter], stats(clickedIndex).Perimeter);
        case 'Area'
            orderedArray = sortArray([stats(:).Area], stats(clickedIndex).Area);
        case 'Circularity'
            orderedArray = sortArray(circularities,circularities(clickedIndex)); 
        case 'Sharpness'
            orderedArray = sortArray(sharpnesses,sharpnesses(clickedIndex));
        case 'Back'
            clf('reset');
            Information(imgOriginal, imgProcessed);
            return;
    end

    statsObj = stats(orderedArray);   
    for i = 1 : numel(orderedArray) 
        box = statsObj(i).BoundingBox;  
        croppedImg = imcrop(imgOriginal, box);
        subplot(2,numObjects,numObjects+i), imshow(croppedImg);
    end

end


function circularities = calculateCircularity(imgProcessed)
    [boundaries,labeledMatrix] = bwboundaries(imgProcessed,'noholes');
    stats2 = regionprops(labeledMatrix,'Area','Centroid','BoundingBox');
    circularities = [];
    
    hold on
    for i = 1:length(boundaries)
      plot(boundaries{i}(:,2), boundaries{i}(:,1), 'r', 'LineWidth', 1)
    
      boundary = boundaries{i};
      delta_sq = diff(boundary).^2;    
      perimeter = sum(sqrt(sum(delta_sq,2)));

      area = stats2(i).Area;
      circularity = 4*pi*area/perimeter^2;
      
      circularities = [circularities, circularity];

      boundingBoxI = stats2(i).BoundingBox;
      text(boundingBoxI(1)+(boundingBoxI(3)/2)-20,...
           boundingBoxI(2)+(boundingBoxI(4)/2)-20,...
           sprintf('%2.2f',circularity),...
           'Color','red',...
           'FontSize',15,...
           'FontWeight','bold');
    end    
end


% Gives an array containing all the sharpness values for the regions  
function sharpnesses = calculateSharpness(imgProcessed)
    [B,L] = bwboundaries(imgProcessed,'holes');
    stats = regionprops(L,'Area','Centroid','Image','Eccentricity');
    objIndex = find([stats.Area] > 1000);
    statsObj = stats(objIndex);
    sharpnesses = [];
    
    for i = 1:length(B)
        % Estimate sharpness using the gradient magnitude.
        % sum of all gradient norms / number of pixels give us the sharpness
        % metric.
        sharpness = estimateSharpness(statsObj(i).Image);
        sharpnesses = [sharpnesses, sharpness];
    end
end


function sortedIndexes = sortArray(array,value)
    deltaArray = [];
    for i = 1 : numel(array)
        diff = abs(array(i)-value);
        deltaArray = [deltaArray,diff];
        disp(deltaArray);   
    end
    [~,sortedIndexes] = sort(deltaArray);       
end



% Ordered by the last clicked
function heatmap(imgOriginal,imgProcessed)
    clf('reset');
    
    [labels num] = bwlabel(imgProcessed,8);
    stats = regionprops(labels,'Area','BoundingBox', 'Centroid');
    
    objIndex = find([stats.Area] > 1000);
    
    statsObj = stats(objIndex);

    imshow(mat2gray(labels)); title('Heatmap');
    colors = colormap(jet(18));

    for i = 1 : numel(objIndex)
        box1 = InitDraw(i, objIndex, stats, [0 0 0 0], [0 0 0 0.01]);
        set(box1,'buttondownfcn',{@ClickEvent,i,objIndex,imgOriginal,imgProcessed,stats});
    end

end


function ClickEvent(~,~,clickedIndex,objIndex,imgOriginal,imgProcessed,stats)
    clf('reset');
    
    clickHistory = [];
    for i = 1 : numel(objIndex)
        if(objIndex(i) == clickedIndex) 
            last = objIndex(i);
        else
            clickHistory = [clickHistory objIndex(i)];
        end
    end
    clickHistory = [clickHistory last];

    % for example
    % if clicked in object nº1
    % clickHistory is [2 3 4 5 6 1]
    % when remapping labels the should be 1 - the earliest to 6 - the latest
    % so, what we want is to change:
    % 1 2 3 4 5 6
    % with:
    % 6 1 2 3 4 5

    [originalIndexes,sortedIndexes] = sort(clickHistory);
    [lb num]= bwlabel(imgProcessed,8);
    lb = changem(lb,sortedIndexes,originalIndexes);

    imshow(mat2gray(lb)); title('Heatmap');
    colors = colormap(jet(18));

    for i = 1 : numel(clickHistory)
        box1 = InitDraw(i, clickHistory, stats, [0 0 0 0], [1 1 1 0.01]);
        set(box1,'buttondownfcn',{@ClickEvent,clickHistory(i),clickHistory,imgOriginal,imgProcessed,stats});
    end


    bg = uibuttongroup('Visible','off',...
            'Position',[0 0 .15 1],...
            'SelectionChangedFcn',{@interfaceHandler,clickedIndex,imgOriginal,imgProcessed,stats});
        
    uicontrol(bg,'Style','radiobutton',...
            'String','Reset',...
            'Position',[10 0 100 30],...
            'HandleVisibility','off');

    bg.Visible = 'on';
    set(bg,'selectedobject',[]);

end
