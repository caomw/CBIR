function eHist = edgeHistogram(I)

    % Set whether global histogram data will be appended to the resulting feature vector
    includeGlobals = 0; 

    if size(I,3) > 1
        I = rgb2gray(I);
    end
    
    % Define the filters for the 5 types of edges
    f = zeros(2,2,5);
    f(:,:,1) = [1 -1; 1 -1]; % vertical
    f(:,:,2) = [1 1; -1 -1]; % horizontal
    f(:,:,3) = [sqrt(2) 0; 0 -sqrt(2)]; % 45
    f(:,:,4) = [0 sqrt(2); -sqrt(2) 0]; % 135
    f(:,:,5) = [2 -2; -2 2]; % n
    
    edgeTh = 11; % Edge threshold
    
    [h, w] = size(I);
     
    gf = fspecial('gaussian', 11, 1.5);
    I = imfilter(I, gf);
      
    fI = zeros(h,w,5);
    for i = 1:5
        fI(:,:,i) = imfilter(I, f(:,:,i));
    end
    
    % Find the maximum values among the 3rd dimension to use them as indices later
    [fI, fMax] = max(fI, [], 3);
    
    fMax(fI < edgeTh) = 0; 
   
%     eI = edge(I, 'canny', [], 1.5);
%     fMax = fMax.*eI;
    
    
    % Compute the subimage size
    sW = floor(w/4);
    sH = floor(h/4);
    
    % Compute the image block size
    bS = floor(sqrt(w*h/1100));
    
    % Image block size should be even
    if mod(bS,2) ~= 0
        bS = bS - 1;
    end
    
    % Compute the amount of blocks in each sub image
    hCnt = floor(sH/bS);
    wCnt = floor(sW/bS);
    
    eHist = zeros(5,4,4);

    for i = 1:4
        for j = 1:4       
            % Compute the start and end indices of the image block
            hSt = (i-1)*sH + 1;
            hEnd = hSt + sH - 1;

            wSt = (j-1) * sW + 1;
            wEnd = wSt + sW - 1;

            sI = fMax(hSt:hEnd, wSt:wEnd);
            h = hist(sI(:), 0:5);

            eHist(:,j,i) = h(2:6);
        end
    end
    
    % Normalize all histograms according to the number of image blocks in each sub image
    eHist = eHist(:)' / (hCnt*wCnt);
            
    % If requested, create the global and semi-global histograms and add them to the result
    if includeGlobals > 0
        inds = repmat(1:5, 16, 1);
        gHist = accumarray(inds(:), eHist) * 5; % 5 is for compansating for the small number of its bins when computing distances
        eHist = [eHist gHist'/16];
    end
    
    eHist = histNormalize(eHist);
    
    