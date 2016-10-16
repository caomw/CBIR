function features = resetWeights(features, ftInds)

featTypeCnt = length(ftInds);
for i=1:featTypeCnt
    % Get the index the feature has in the features structure
    k = ftInds(i);

    % Set the initial and intra-weights and the inter-weight 
    featVecSize = size(features{k,2}, 2);
    features{k,4} = ones(1,featVecSize) / featVecSize;
    features{k,5} = 1/featTypeCnt;
end