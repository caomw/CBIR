% fTypes = {'colorMoments' 'colorHistogram' 'colorAutoCorrelogram' 'edgeHistogram' 'coocMatrix'};
% normParams = {[meanVec1; stdVec1]; [meanVec2; stdVec2]}
function features = extractFeatures(imgPath, fTypes, normParams)

if nargin < 3
   normParams = [];
end

I = imread(imgPath);

features = cell(length(fTypes),1); 

% Extract each feature requested
for i = 1:length(fTypes)
    fVec = feval(fTypes{i}, I);
    
    % Normalize if the required params are given
    if ~isempty(normParams)
        params = normParams{i};
        mu = params(1,:);
        sigma = params(2,:);

        % Set the sigmas for the columns with constant values to 1 to prevent 0/0 operation (and perform a 0/1 instead) 
        zeroInds = fVec == mu;
        sigma(zeroInds) = 1;
        
        fVec = (fVec - mu) ./ (sigma*3);
    end
    
    features{i} = fVec; 
end

end