clear all;
close all;
fTypes = {'colorHistogram' 'edgeHistogram'};

if exist('test.mat','file') > 0
    load test.mat;
else
   [features labels] = prepareFeatures('images', fTypes); 
   save('test.mat','features','labels');
end

[fname, pthname] = uigetfile('*.jpg', 'Select the query image');
if (fname ~= 0)
    imgPath = strcat(pthname, fname);
    [f, ~] = prepareFeatures(imgPath, fTypes);
   
    % Concatenate all features for retrieval
    dataset = [];
    query = [];
    for i = 1:length(fTypes)
        dataset = [dataset features{i,2}];
        query = [query f{i,2}];
    end
    
    [dists, inds] = getClosestImages(dataset, query, 20, 'minkowski');
    
    % display query image
    queryImage = imread(imgPath);
    subplot(3, 7, 1);
    imshow(queryImage, []);
    title('Query Image', 'Color', [1 0 0]);

    % dispaly images returned by query
    for i = 1:length(inds)
        imgPath = labels{inds(i),2};
        I = imread(imgPath);
        subplot(3, 7, i+1);
        imshow(I, []);
    end
 
else
    return;
end