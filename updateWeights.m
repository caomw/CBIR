% features -> (featureTypeCnt x 5) cell
% query -> (featureTypeCnt x 1) cell
% feedback -> (N x 1) vector
function features = updateWeights(features, query, feedback, N, distType, ftInds)

if nargin < 6
    error('Missing argument!');
end

featTypeCnt = length(ftInds);
interWeights = cell2mat(features(ftInds,5));

% Find the closest N images using all features
allInds = getClosestImages(features, query, N, distType, ftInds);

for i=1:featTypeCnt
    % Get the index the feature has in the features structure
    k = ftInds(i);
    
    featVecs = features{k,2};
    
    % Find the closest N images using only a single feature
    inds = getClosestImages(features(k,:), query(k), N, distType, 1);
    
    % Get the feature vectors of the images the user marked as relevant
    relevantFeatVecs = featVecs(allInds(feedback > 0), :);
    
    intraWeights = features{k,4};
    
    % If at least one correct image other than the query is returned
    if size(relevantFeatVecs, 1) > 1 
        % Compute the intra-weights as 1/sigma and normalize them
        intraWeights = intraWeights ./ (std(relevantFeatVecs) + eps);
        intraWeights = intraWeights / sum(intraWeights);
        features{k,4} = intraWeights;
    end
    
    for j=1:N
        % If the samples found by all features includes the sample found by this feature alone
        if ~isempty(find(inds == allInds(j), 1))
            % Add the score given by the user to the weight
            interWeights(i) = interWeights(i) + feedback(j);
        end
    end
    
    % Clamp the min inter-weight value at 0
    interWeights(i) = max(interWeights(i), eps);
end

% Normalize the inter-weights
interWeights = interWeights / sum(interWeights);

% Update the inter-weigts
features(ftInds,5) = num2cell(interWeights);

end

