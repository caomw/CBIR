% Prepares the dataset
function [features, labels] = prepareDataset(path, fTypes)

if nargin < 2
    error('Missing argument!');
end

% Get the list of all subdirectories in the given path
d = dir(path);
isub = [d.isdir]; 
d = {d(isub).name};
d(ismember(d,{'.','..'})) = [];

% Each directory name different label
lblCnt = numel(d);

% Create the structures that will hold the feature matrices and their labels for each feature type
% features{i,1} = featureName
% features{i,2} = featureMat
% features{i,3} = [mu; sigma]
% features{i,4} = intraWeights
% features{i,5} = interWeight

features = cell(length(fTypes), 5);  
labels = cell(2000, 2);

for i = 1:length(fTypes)
    features{i,1} = fTypes{i};
    features{i,2} = [];    
end

imgCnt = 0;

% Loop through all subdirectories
for i=1:lblCnt
    fprintf('Processing class %d...\n', i);
    tic;
     
    % Get the list of all images in the subdirectory
    imgDir = [path '/' d{i}];   
    files = dir([imgDir '/*.jpg']);
    
    for j=1:size(files,1)
        imgPath = [imgDir '/' files(j).name];

        % fprintf('Processing file: %s\n', files(j).name);
        
        % Extract each feature requested 
        tempFeats = extractFeatures(imgPath, fTypes);
        
        % Append the resulting vectors to the relevant matrices
        for k = 1:length(fTypes)
            features{k,2} = [features{k,2}; tempFeats{k}]; 
        end
        
        % Store the image label, along with the image path
        imgCnt = imgCnt + 1;
        labels{imgCnt,1} = str2double(d(i));
        labels{imgCnt,2} = imgPath;
    end
    elapsedTime = toc;
    fprintf('Processing time for class %d was %.2f seconds. ETA : %.2f seconds\n', i, elapsedTime, elapsedTime*(lblCnt-i));
end

% Perform z normalization on the dataset
for i=1:length(fTypes)
    [features{i,2}, mu, sigma] = zscore(features{i,2});
    features{i,2} = features{i,2} / 3;
    
    % Save the mean and std values for later usage
    features{i,3} = [mu; sigma]; 
    
    % Set the initial and intra-weights and the inter-weight 
    featRowCnt = size(features{i,2}, 2);
    features{i,4} = ones(1,featRowCnt) / featRowCnt;
    features{i,5} = 1/length(fTypes);
end

% Trim the labels vector because it was allocated too large at the start
labels = labels(1:imgCnt,:);

disp('Processing complete');

