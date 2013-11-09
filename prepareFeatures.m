%fTypes = {'colorMoments' 'colorHistogram' 'colorAutoCorrelogram' 'edgeHistogram'};
function [features, labels] = prepareFeatures(path, fTypes)

% Get the list of all subdirectories in the given path
d = dir(path);
isub = [d.isdir]; 
d = {d(isub).name};
d(ismember(d,{'.','..'})) = [];

% Each directory name different label
lblCnt = numel(d);

% Create the structures that will hold the feature matrices and their labels for each feature type
features = cell(length(fTypes), 2);
labels = cell(2000, 2);

for i = 1:length(fTypes)
    features{i,1} = fTypes(i);
    features{i,2} = [];
end

imgCnt = 0;

% Loop through all subdirectories
for i=1:lblCnt
    % Get the list of all images in the subdirectory
    imgDir = [path '/' d{i}];   
    files = dir([imgDir '/*.jpg']);
    
    for j=1:size(files,1)
        imgPath = [imgDir '/' files(j).name];
        I = imread(imgPath);
        
        sprintf('Processing file: %s', files(j).name)
        
        % Extract each feature requested and append the resulting vectors to the relevant matrices
        for k = 1:length(fTypes)
            fVec = feval(fTypes{k}, I);
            features{k,2} = [features{k,2}; fVec]; 
        end
        
        imgCnt = imgCnt + 1;
        labels{imgCnt,1} = str2double(d(i));
        labels{imgCnt,2} = imgPath;
    end
end

% If the given path is an image and not a directory, directly compute the features from it and then return
if exist(path,'dir') == 0
    I = imread(path);
    % Extract each feature requested and append the resulting vectors to the relevant matrices
    for k = 1:length(fTypes)
        fVec = feval(fTypes{k}, I);
        features{k,2} = [features{k,2}; fVec]; 
    end
    imgCnt = 1;
end

% Trim the labels vector because it was allocated too large at the start
labels = labels(1:imgCnt,:);