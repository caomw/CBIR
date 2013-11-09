% Returns the indices of the N images closest to the given query image along with the distance values
function [dists, inds] = getClosestImages(dataset, queryVector, N, distType)

mDists = {'euclidean', 'seuclidean', 'cityblock', 'minkowski', 'chebychev', 'mahalanobis', 'cosine', 'correlation', 'hamming'};

ind = find(ismember(mDists, distType));

if ind > 0
   [dists, inds] = pdist2(dataset, queryVector, distType, 'Smallest', N);
else
    disp('INVALID DISTANCE MEASURE');
end
