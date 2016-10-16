load 1000;
distType = 'cityblock';

dataCnt = size(labels, 1);
featTypeCnt = size(features,1);
classLabels = unique(cell2mat(labels(:,1)));
classCnt = length(classLabels);

ftInds = 1:featTypeCnt;

labelsVec = cell2mat(labels(:,1));
features = resetWeights(features, ftInds);

results = zeros(classCnt,11);
maps = zeros(1,10);

for i = 1:dataCnt 
    
    sFeatures = cell(featTypeCnt,1); 
    correctLabel = labelsVec(i);
  
    % Exract the data related to the a single sample from the features structure
    for j = 1:featTypeCnt
        featVecs = features{j,2};
        sFeatures{j} =  featVecs(i,:);
    end

    % Find the 100 closest samples to the current sample
    inds = getClosestImages(features, sFeatures, 100, distType, ftInds);
          
    % Compute the precisions for each N 
   for k = 1:10
       N = k*10;
       for j = 1:N
            if labelsVec(inds(j)) == correctLabel
                results(correctLabel,k) = results(correctLabel,k) + 1;
            end
       end
   end
end

% Complete the precision computation
for k = 1:10
    for i = 1:classCnt
        sampleCnt = sum(labelsVec == i);
        results(i,k) = results(i,k) / (sampleCnt*k*10);
        results(i,11) = sampleCnt;
    end
    
    maps(k) = sum(results(:,k) .* results(:,11)) / sum(results(:,11));
end

