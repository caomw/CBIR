% features -> (featureTypeCnt x 5) cell
% labels -> (dataCount x 2) or (dataCount x 1) cell
% results -> (classCount x 3) -> results(:,1) = precisions, results(:,2) = recalls, results(:,3) = sampleCounts
function [results] = testPerformance(features, labels, N, distType, ftInds, feedbackCnt)

if nargin < 6
    error('Missing argument!');
end

dataCnt = size(labels, 1);
featTypeCnt = size(features,1);
classLabels = unique(cell2mat(labels(:,1)));
classCnt = length(classLabels);

labelsVec = cell2mat(labels(:,1));

results = zeros(classCnt,3);

for i = 1:dataCnt 
    
    sFeatures = cell(featTypeCnt,1); 
    correctLabel = labelsVec(i);
    
    features = resetWeights(features, ftInds);
    
    itrCnt = feedbackCnt + 1;

    while itrCnt > 0
        
        % Exract the data related to the a single sample from the features structure
        for j = 1:featTypeCnt
            featVecs = features{j,2};
            sFeatures{j} =  featVecs(i,:);
        end
        
        % Find the N closest samples to the current sample
        inds = getClosestImages(features, sFeatures, N, distType, ftInds);
    
        % Generate the feedback automatically
        feedback = generateFeedback(labels, inds, correctLabel, N);
        
        features = updateWeights(features, sFeatures, feedback, N, distType, ftInds);
        
        itrCnt = itrCnt - 1;
    end
       
    % Compute the precision 
    for j = 1:N
        if labelsVec(inds(j)) == correctLabel
            results(correctLabel,1) = results(correctLabel,1) + 1;
        end
    end
end

% Complete the precision computation
for i = 1:classCnt
    sampleCnt = sum(labelsVec == i);
    results(i,2) = results(i,1) / (sampleCnt*sampleCnt);
    results(i,1) = results(i,1) / (sampleCnt*N);
    results(i,3) = sampleCnt;
end

