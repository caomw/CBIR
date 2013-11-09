% input: image to be analyzed
% output: 1x6 vector containing the 2 first color moments from each channel
function cMoments = colorMoments(image)

% extract color channels
R = double(image(:, :, 1));
G = double(image(:, :, 2));
B = double(image(:, :, 3));

% compute 2 first color moments from each channel
meanR = mean( R(:) );
stdR  = std( R(:) );
meanG = mean( G(:) );
stdG  = std( G(:) );
meanB = mean( B(:) );
stdB  = std( B(:) );

cMoments = [meanR stdR meanG stdG meanB stdB];

cMoments = cMoments - min(cMoments);
cMoments = cMoments / max(cMoments);

end