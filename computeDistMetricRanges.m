% Computes the ranges of each distance metric on the dataset and returns their mean and std for normalization purposes
function features = computeDistMetricRanges(features, distType)

[featTypeCnt, propCnt] = size(features);

for i=1:featTypeCnt
    D = pdist2(features{i,2},features{i,2}, distType);
    mu = mean(D(:));
    sigma = std(D(:));
    
    features{i,propCnt+1} = [mu; sigma];
end

end

