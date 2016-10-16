% input: image to be analyzed
% output: 1x6 vector containing the 2 first color moments from each channel
function cMoments = colorMoments(image)

% Extract color channels
R = double(image(:, :, 1));
G = double(image(:, :, 2));
B = double(image(:, :, 3));

% Compute the first three color moments from each channel
meanR = mean(R(:));
stdR  = std(R(:));
skewnessR = skewness(R(:));
meanG = mean(G(:));
stdG  = std(G(:));
skewnessG = skewness(G(:));
meanB = mean(B(:));
stdB  = std(B(:));
skewnessB = skewness(B(:));

cMoments = [meanR stdR meanG stdG meanB stdB skewnessR skewnessB skewnessG];

end