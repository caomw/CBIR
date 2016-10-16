% Returns the indices of the N images closest to the given query image along with the distance values
% features -> (featureTypeCnt x 5) cell
% query -> (featureTypeCnt x 1) cell
% N -> Number of images that will be retrieved
% ftInds -> Indices of the features that will be used during the computations, i.e. [1 3 4]
function inds = getClosestImages(features, query, N, distType, ftInds)

if nargin < 5
    error('Missing argument!');
end

mDists = {'euclidean', 'cityblock', 'minkowski', 'chebychev','cosine', 'hamming'};

ind = find(ismember(mDists, distType));

% Find the distance between the query vector and the vectors in the dataset, one feature at a time to include the weights 
if ind > 0
    
   featTypeCnt = length(ftInds);
   distCnt = size(features{1,2},1);
   
   dists = zeros(distCnt,1);
   
   for i=1:featTypeCnt 
       % Get the index the feature has in the features structure
       k = ftInds(i);
       
       % Use the intra-weights on the correspoing parts of the dataset and also on the query set
       weightedFeats = bsxfun(@times, features{k,2}, features{k,4});
       weightedQuery = query{k,1} .* features{k,4};
       
       % Compute the weighted distance vector (1 x sampleCnt)
       dists = dists + features{k,5} * pdist2(weightedFeats, weightedQuery, distType);
   end
   
   % Find the indices of the N samples closest to the query  
   [~, inds] = sort(dists,'ascend');
   inds = inds(1:N);
   
else
    disp('INVALID DISTANCE MEASURE');
end

