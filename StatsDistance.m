function StatsDistance(imgOriginal, imgProcessed)
    figure;
    imshow(imgOriginal);
    
% Para o 1, 2 e 3:
    stats1 = regionprops(bwlabel(imgProcessed,8),...
                        'Eccentricity',...
                        'Area',...
                        'Centroid',...
                        'BoundingBox',...
                        'Perimeter',...
                        'MinorAxisLength');

    objIndex = find([stats1.Area] > 1000);
    sz = size(objIndex);    
    for i = 1 : numel(objIndex)
        box1 = InitDraw(i,objIndex,stats1);
        set(box1,'buttondownfcn',{@ShowInfo,i,objIndex,imgOriginal,imgProcessed,stats1});
    end
    
    
% Para o 4:
    boundsArray = [];
    boundsArray = derivateBoundaries(imgProcessed);
    title(['Number of objects in the image: ', num2str(sz(2)),...
        '. Click on a region to see its stats.']);
% para o 5
    interface(imgOriginal, imgProcessed, stats1);
end

function box = InitDraw(i,objIndex,stats)
    statsObj = stats(objIndex);
    boundingBoxI = statsObj(i).BoundingBox;
    box = rectangle('Position',...
              [boundingBoxI(1),...
               boundingBoxI(2),...
               boundingBoxI(3),...
               boundingBoxI(4)],...
              'EdgeColor',[1 0 0],...
              'FaceColor',[1 0 0 0.2]);
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
    interface(imgOriginal,imgProcessed, stats);
    statsObj = stats(objIndex);
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
            line(x,y,'Color','red','LineStyle','--');
            distance = num2str(sqrt((x2-x1)^2+(y2-y1)^2));
            
            text(statsObj(index).Centroid(1),...
                 statsObj(index).Centroid(2)-13,...
                 ['Distance:'],...
                 'color','black',...
                 'HorizontalAlignment', 'center',...
                 'VerticalAlignment', 'middle',...
                 'FontSize',11);
             
             text(statsObj(index).Centroid(1),...
                 statsObj(index).Centroid(2)+13,...
                 [distance],...
                 'color','black',...
                 'HorizontalAlignment', 'center',...
                 'VerticalAlignment', 'middle',...
                 'FontSize',11);
             
        end
        box2 = InitDraw(index,objIndex,stats);
        set(box2,'buttondownfcn',{@ShowInfo,index,objIndex,imgOriginal, imgProcessed,stats});
    end
end

function showOrder(imgProcessed, orderArray, stats, type)
   if(strcmp(type, 'Sharpness'))
       [B,L] = bwboundaries(imgProcessed,'noholes');
       stats1 = regionprops(L,'Area','Centroid','Image','Eccentricity', 'BoundingBox');
       idxOfCoins = find([stats1.Eccentricity]);
       statsObj1 = stats1(idxOfCoins);
       for k = 1:length(B)
           sharpness=estimate_sharpness(statsObj1(k).Image);
           indexValue = find(orderArray == sharpness);
           % display the results
           boundingBoxI = statsObj1(k).BoundingBox;
           metric_string = sprintf('%d',indexValue);
           text(boundingBoxI(1),...
               boundingBoxI(2),...
               metric_string,...
               'Color','black',...
               'FontSize',12,...
               'FontWeight','bold');
       end 
   else
       objIndex = find([stats.Perimeter]);
       for index = 1 : numel(objIndex)
           statsObj = stats(index);
           if(strcmp(type,'Perimiter'))
            indexValue = find(orderArray == statsObj.Perimeter);
            % display the results
            boundingBoxI = statsObj.BoundingBox;
            metric_string = sprintf('%d',indexValue);
            text(boundingBoxI(1),...
               boundingBoxI(2),...
               metric_string,...
               'Color','black',...
               'FontSize',12,...
               'FontWeight','bold');
           end
           if(strcmp(type,'Area'))
            indexValue = find(orderArray == statsObj.Area);
            % display the results
            boundingBoxI = statsObj.BoundingBox;
            metric_string = sprintf('%d',indexValue);
            text(boundingBoxI(1),...
               boundingBoxI(2),...
               metric_string,...
               'Color','black',...
               'FontSize',12,...
               'FontWeight','bold');
           end  
       end
    end
end

function bounds = derivateBoundaries(imgProcessed)
    [boundaries,labeledMatrix] = bwboundaries(imgProcessed,'holes');
    stats2 = regionprops(labeledMatrix,'Area','Centroid');
    threshold = 0.94;
    bounds = [];
    
    hold on
    for i = 1:length(boundaries)
      plot(boundaries{i}(:,2), boundaries{i}(:,1), 'r', 'LineWidth', 2)
    
      % obtain (X,Y) boundary coordinates corresponding to label 'k'
      boundary = boundaries{i};

      % compute a simple estimate of the object's perimeter
      delta_sq = diff(boundary).^2;    
      perimeter = sum(sqrt(sum(delta_sq,2)));

      % obtain the area calculation corresponding to label 'k'
      area = stats2(i).Area;

      % compute the roundness metric
      metric = 4*pi*area/perimeter^2;
      
      bounds = [bounds, metric];

      % display the results
      metric_string = sprintf('%2.2f',metric);

      % mark objects above the threshold with a black circle
      if metric > threshold
        centroid = stats2(i).Centroid;
        plot(centroid(1),centroid(2),'ko');
      end

      text(boundary(1,2),...
           boundary(1,1),...
           metric_string,...
           'Color','black',...
           'FontSize',12,...
           'FontWeight','bold');
    end    
end

function bounds = derivateOrdered(imgProcessed, orderedArray, stats)
    [boundaries,labeledMatrix] = bwboundaries(imgProcessed,'holes');
    stats2 = regionprops(labeledMatrix,'Area','Centroid');
    threshold = 0.94;
    bounds = [];
    
    hold on
    for i = 1:length(boundaries)
      plot(boundaries{i}(:,2), boundaries{i}(:,1), 'r', 'LineWidth', 2)
    
      % obtain (X,Y) boundary coordinates corresponding to label 'k'
      boundary = boundaries{i};

      % compute a simple estimate of the object's perimeter
      delta_sq = diff(boundary).^2;    
      perimeter = sum(sqrt(sum(delta_sq,2)));

      % obtain the area calculation corresponding to label 'k'
      area = stats2(i).Area;

      % compute the roundness metric
      metric = 4*pi*area/perimeter^2;
      
      index = find(orderedArray == metric)
      
      bounds = [bounds, metric];

      % display the results
      metric_string = index;
      
      statsObj = stats(i);
      boundingBoxI = statsObj.BoundingBox;
       metric_string = sprintf('%d',metric_string);
       text(boundingBoxI(1),...
           boundingBoxI(2),...
           metric_string,...
           'Color','black',...
           'FontSize',12,...
           'FontWeight','bold');
    end    
end


function arraySharpness = calculateSharpness(imgProcessed)
    [B,L] = bwboundaries(imgProcessed,'noholes');
    stats = regionprops(L,'Area','Centroid','Image','Eccentricity');
    idxOfCoins = find([stats.Eccentricity]);
    statsObj = stats(idxOfCoins);
    arraySharpness = [];
    
    % loop over the boundaries
    for k = 1:length(B)
      sharpness=estimate_sharpness(statsObj(k).Image);
      arraySharpness = [arraySharpness, sharpness];
    end
end


% metric.
function [sharpness]=estimate_sharpness(G)
    [Gx, Gy]=gradient(G);
    S=sqrt(Gx.*Gx+Gy.*Gy);
    sharpness=sum(sum(S))./(numel(Gx));
end

 function interface(imgOriginal,imgProcessed, stats)
        bg = uibuttongroup('Visible','off',...
            'Position',[0 0 .1 1],...
            'SelectionChangedFcn',{@bselection,imgOriginal,imgProcessed,stats});
        %TODO mudar a balda pq ta igual a do tiago
        % Create three radio buttons in the button group.
        r1 = uicontrol(bg,'Style','radiobutton',...
            'String','Order by Perimeter',...
            'Position',[10 800 100 30],...
            'HandleVisibility','off');

        r2 = uicontrol(bg,'Style','radiobutton',...
            'String','Order by Area',...
            'Position',[10 700 100 30],...
            'HandleVisibility','off');

        r3 = uicontrol(bg,'Style','radiobutton',...
            'String','Order by Circularity',...
            'Position',[10 600 100 30],...
            'HandleVisibility','off');
        
        r4 = uicontrol(bg,'Style','radiobutton',...
            'String','Order by Sharpness',...
            'Position',[10 500 100 30],...
            'HandleVisibility','off');
        
        r5 = uicontrol(bg,'Style','radiobutton',...
            'String','Derivative',...
            'Position',[10 400 100 30],...
            'HandleVisibility','off');
        
        r5 = uicontrol(bg,'Style','radiobutton',...
            'String','Reset',...
            'Position',[10 100 100 30],...
            'HandleVisibility','off');

        % Make the uibuttongroup visible after creating child objects.
        bg.Visible = 'on';
        
        set(bg,'selectedobject',[]);
 end
    
 function bselection(~,event,imgOriginal,imgProcessed, stats)

        switch event.NewValue.String
            case 'Order by Perimeter'
                 orderedArray = sort([stats(:).Perimeter]); 
                 showOrder(imgProcessed, orderedArray, stats, 'Perimiter');
            case 'Order by Area'
                 orderedArray = sort([stats(:).Area]); 
                 showOrder(imgProcessed, orderedArray, stats, 'Area');
            case 'Order by Circularity'
                 boundries = derivateBoundaries(imgProcessed);
                 orderedArray = sort(boundries);
                 derivateOrdered(imgProcessed, orderedArray, stats);
            case 'Order by Sharpness'
                 arraySharpness = calculateSharpness(imgProcessed);
                 orderedArray = sort(arraySharpness);
                 showOrder(imgProcessed, orderedArray, stats, 'Sharpness');
            case 'Derivative'
                 derivateBoundaries(imgProcessed);
            case 'Reset'
                 clf('reset');
                 StatsDistance(imgOriginal, imgProcessed)
                 
        end

    end
