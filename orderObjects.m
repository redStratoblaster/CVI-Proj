
    function orderObjects(imgOriginal,imgProcessed)
        title('Click on an object and select a criteria to order their similarity');
        figure;
        imshow(imgOriginal);
        
        stats = regionprops(bwlabel(imgProcessed,8),...
                            'Eccentricity',...
                            'Area',...
                            'Centroid',...
                            'BoundingBox',...
                            'Perimeter',...
                            'MinorAxisLength');
        objIndex = find([stats.Area] > 1000);
        objStats = stats(objIndex);
        for i = 1 : numel(objIndex)
            box = InitDraw(i,objIndex,objStats,[1 0 0]);
            set(box,...
                'buttondownfcn',...
                {@selectObject,...
                 i,...
                 stats,...
                 imgOriginal,...
                 imgProcessed,...
                 derivateBoundaries(imgProcessed),...
                 calculateSharpness(imgProcessed)});
        end
    end

    function box = InitDraw(i,objIndex,stats,edgeColor)
        statsObj = stats(objIndex);
        boundingBoxI = statsObj(i).BoundingBox;
        box = rectangle('Position',...
                  [boundingBoxI(1),...
                   boundingBoxI(2),...
                   boundingBoxI(3),...
                   boundingBoxI(4)],...
                  'EdgeColor',edgeColor,...
                  'FaceColor',[1 0 0 0.2]);
        text(statsObj(i).Centroid(1),...
             statsObj(i).Centroid(2),...
             'X',...
             'color','red',...
             'HorizontalAlignment','center',...
             'VerticalAlignment','middle',...
             'FontSize',12);
    end
    
    function arrayBoundaries = derivateBoundaries(imgProcessed)
        [boundaries,labeledMatrix] = bwboundaries(imgProcessed,'noholes');
        stats2 = regionprops(labeledMatrix,'Area','Centroid','BoundingBox');
        threshold = 0.94;
        arrayBoundaries = [];
        
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
          
          arrayBoundaries = [arrayBoundaries, metric];
    
          % display the results
          metric_string = sprintf('%2.2f',metric);
    
          % mark objects above the threshold with a black circle
          if metric > threshold
            centroid = stats2(i).Centroid;
            plot(centroid(1),centroid(2),'ko');
          end
         
          boundingBoxI = stats2(i).BoundingBox;
          text(boundingBoxI(1)+(boundingBoxI(3)/2)-20,...
               boundingBoxI(2)+(boundingBoxI(4)/2)-20,...
               metric_string,...
               'Color','red',...
               'FontSize',15,...
               'FontWeight','bold');
        end    
    end

    % Gives an array containing all the sharpness values for the regions  
    function arraySharpness = calculateSharpness(imgProcessed)
        [B,L] = bwboundaries(imgProcessed,'holes');
        stats = regionprops(L,'Area','Centroid','Image','Eccentricity');
        objIndex = find([stats.Area] > 1000);
        statsObj = stats(objIndex);
        arraySharpness = [];
        
        for i = 1:length(B)
            % Estimate sharpness using the gradient magnitude.
            % sum of all gradient norms / number of pixels give us the sharpness
            % metric.
            [Gx, Gy] = gradient(statsObj(i).Image);
            S = sqrt(Gx.*Gx+Gy.*Gy);
            sharpness = sum(sum(S))./(numel(Gx));
            arraySharpness = [arraySharpness, sharpness];
        end
    end


function selectObject(~,~,clickedIndex,stats,imgOriginal,imgProcessed, boundaries, sharpnesses)
    clf('reset');

    [labeled, numObjects] = bwlabel(imgProcessed,4);

    title(['Objects ordered by selected object and category']);
    subplot(numObjects,2,[1 numObjects]), 
    imshow(imgOriginal);

    interface(imgOriginal, imgProcessed, clickedIndex, boundaries, sharpnesses);
    
    objIndex = find([stats.Area] > 1000);
    statsObj = stats(objIndex);

    for i = 1 : numel(objIndex)
        if(clickedIndex == i)
            BBcolors = [0,0,0];
        else
            BBcolors = [1,0,0];
        end
        box = InitDraw(i, objIndex, statsObj, BBcolors);
        set(box,...
            'buttondownfcn',...
            {@selectObject,...
            i,...
            stats,...
            imgOriginal,...
            imgProcessed,...
            boundaries,...
            sharpnesses});
    end
end




    function interface(imgOriginal,imgProcessed,clickedIndex, arrayOfBounds,arrayOfSharps)
        buttons = uibuttongroup('Visible','off',...
                'Position',[0 0 .1 1],...
                'SelectionChangedFcn',...
                {@bselection,...
                imgOriginal,...
                imgProcessed,...
                clickedIndex,...
                arrayOfBounds,...
                arrayOfSharps});

        % Create three radio buttons in the button group.
        r1 = uicontrol(buttons,'Style','radiobutton',...
            'String','Perimeter',...
            'Position',[10 450 100 30],...
            'HandleVisibility','off');

        r2 = uicontrol(buttons,'Style','radiobutton',...
            'String','Area',...
            'Position',[10 350 100 30],...
            'HandleVisibility','off');

        r3 = uicontrol(buttons,'Style','radiobutton',...
            'String','Roundness',...
            'Position',[10 250 100 30],...
            'HandleVisibility','off');
        
        r4 = uicontrol(buttons,'Style','radiobutton',...
            'String','Sharpness',...
            'Position',[10 150 100 30],...
            'HandleVisibility','off');

        % Make the uibuttongroup visible after creating child objects.
        buttons.Visible = 'on';
        
        set(buttons,'selectedobject',[]);
    end
    

    
    function bselection(~,event,imgOriginal,imgProcessed,clickedIndex, arrayOfBounds,arrayOfSharps)
        
        [labeled, numObjects] = bwlabel(imgProcessed,8);
        stats = regionprops(labeled,...
                    'Eccentricity',...
                    'Area',...
                    'Centroid',...
                    'BoundingBox',...
                    'Perimeter',...
                    'MinorAxisLength');

        switch event.NewValue.String
            case 'Perimeter'
                ordered = orderSelect([stats(:).Perimeter], stats(clickedIndex).Perimeter);
            case 'Area'
                ordered = orderSelect([stats(:).Area], stats(clickedIndex).Area); 
            case 'Sharpness'
                ordered = orderSelect(arrayOfSharps,arrayOfSharps(clickedIndex));
            case 'Roundness'
                ordered = orderSelect(arrayOfBounds,arrayOfBounds(clickedIndex));
        end

        disp(ordered);
        statsObj = stats(ordered);   
        for i = 1 : numel(ordered) 
            box = statsObj(i).BoundingBox;  
            croppedImg = imcrop(imgOriginal, box);
            subplot(2,numObjects,numObjects+i), imshow(croppedImg);
        end
    end
    
    function sortedIndexes = orderSelect(array,value)
        distanceArray = [];
        for i = 1 : numel(array)
            diff = abs(array(i)-value);
            distanceArray = [distanceArray,diff];
            disp(distanceArray);   
        end
        [~,sortedIndexes] = sort(distanceArray);       
    end
