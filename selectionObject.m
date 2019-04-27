
    function selectionObject(I,Ibw)
        figure;
        imshow(I);
        title(['Objects ordered by selected object and category']);

        labeled = bwlabel(Ibw,4);
        stats = regionprops(labeled,'Eccentricity','Area','Centroid','BoundingBox','Perimeter','MinorAxisLength');
        eccentricities = [stats.Eccentricity];
        idxOfCoins = find(eccentricities);
        statsObj = stats(idxOfCoins);
        BBcolors = [1,1,1];
        arrayOfBounds = derivateBoundaries(Ibw);
        arrayOfSharps = calculateSharpness(Ibw);
        for idx = 1 : numel(idxOfCoins)
            h=drawBBandCentroid(idx,statsObj,BBcolors);
            %event on click
            set(h,'buttondownfcn',{@selectObject,idx,stats,I,Ibw,arrayOfBounds,arrayOfSharps});
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

function [sharpness]=estimate_sharpness(G)
    [Gx, Gy]=gradient(G);
    S=sqrt(Gx.*Gx+Gy.*Gy);
    sharpness=sum(sum(S))./(numel(Gx));
end

function selectObject(~,~,idx,stats,I,Ibw, arrayOfBounds,arrayOfSharps)
    clf('reset');
    [labeled, numObjects] = bwlabel(Ibw,4);
    subplot(2,numObjects,[1 numObjects]), imshow(I);
    myui(I,Ibw,idx, arrayOfBounds,arrayOfSharps);
    title(['Objects ordered by selected object and category']);

    eccentricities = [stats.Eccentricity];
    idxOfCoins = find(eccentricities);
    statsObj = stats(idxOfCoins);
    BBcolors = [1,1,1];

    for idy = 1 : numel(idxOfCoins)
        if(idx == idy)
            BBcolors = [0,0,0];

        else
            BBcolors = [1,1,1];
        end
        h = drawBBandCentroid(idy,statsObj,BBcolors);
        set(h,'buttondownfcn',{@selectObject,idy,stats,I,Ibw, arrayOfBounds,arrayOfSharps});
    end
end

    function h = drawBBandCentroid(point,statsObj,BBcolors)
        text(statsObj(point).Centroid(1),statsObj(point).Centroid(2),'x','color','black','HorizontalAlignment', 'center','VerticalAlignment', 'middle','FontSize',15);
        thisBB = statsObj(point).BoundingBox;
        h = rectangle('Position',[thisBB(1)-thisBB(3)*0.025,thisBB(2)-thisBB(4)*0.025,thisBB(3)*1.05,thisBB(4)*1.05],'EdgeColor',BBcolors,'FaceColor', [0 0 0 0.01]);
    end


    function myui(I,Ibw,idx, arrayOfBounds,arrayOfSharps)
        bg = uibuttongroup('Visible','off',...
            'Position',[0 0 .1 1],...
            'SelectionChangedFcn',{@bselection,I,Ibw,idx, arrayOfBounds,arrayOfSharps});

        % Create three radio buttons in the button group.
        r1 = uicontrol(bg,'Style','radiobutton',...
            'String','Perimeter',...
            'Position',[10 450 100 30],...
            'HandleVisibility','off');

        r2 = uicontrol(bg,'Style','radiobutton',...
            'String','Area',...
            'Position',[10 350 100 30],...
            'HandleVisibility','off');

        r3 = uicontrol(bg,'Style','radiobutton',...
            'String','Roundness',...
            'Position',[10 250 100 30],...
            'HandleVisibility','off');
        
        r4 = uicontrol(bg,'Style','radiobutton',...
            'String','Sharpness',...
            'Position',[10 150 100 30],...
            'HandleVisibility','off');

        % Make the uibuttongroup visible after creating child objects.
        bg.Visible = 'on';
        
        set(bg,'selectedobject',[]);
    end
    

    
    function bselection(~,event,I,Ibw,idx, arrayOfBounds,arrayOfSharps)
        
        [labeled, numObjects] = bwlabel(Ibw,4);
        stats = regionprops(labeled,'Eccentricity','Area','Centroid','BoundingBox','Perimeter','MinorAxisLength');
        switch event.NewValue.String
            case 'Perimeter'
                ordered = orderSelect([stats(:).Perimeter], stats(idx).Perimeter);
            case 'Area'
                ordered = orderSelect([stats(:).Area], stats(idx).Area); 
            case 'Sharpness'
                ordered = orderSelect(arrayOfSharps,arrayOfSharps(idx));
            case 'Roundness'
                ordered = orderSelect(arrayOfBounds,arrayOfBounds(idx));
        end
        disp(ordered);
        statsObj = stats(ordered);   
        for idy = 1 : numel(ordered) 
            thisBlobsBoundingBox = statsObj(idy).BoundingBox;  
            subImage = imcrop(I, thisBlobsBoundingBox);
            subplot(2,numObjects,numObjects+idy), imshow(subImage);
        end
    end
    
    function distanceArray = orderSelect(array,value)
        distanceArray = [];
        for i = 1 : numel(array)
            diff = abs(array(i)-value);
            distanceArray = [distanceArray,diff];   
        end
        [~,distanceArray] = sort(distanceArray);       
    end
