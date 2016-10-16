function cooc  = coocMatrix(I)
    
    I = rgb2gray(I);
    d = 1;
    cooc = graycomatrix(I, 'GrayLimits', [], 'NumLevels', 6, 'Offset', [0 d; -d d; -d 0; -d -d] );
    cooc = cooc(:)';
end