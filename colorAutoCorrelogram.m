function  result = colorAutoCorrelogram(I)

D = [1 3 5 7];

% Quantize the image
R = I(:,:,1);
G = I(:,:,2);
B = I(:,:,3);

R_BITS = 2;
G_BITS = 2;
B_BITS = 2;

colorCnt = 2^R_BITS * 2^G_BITS * 2^B_BITS;

R1 = bitshift(R,-(8-R_BITS));
G1 = bitshift(G,-(8-G_BITS));
B1 = bitshift(B,-(8-B_BITS));

I = R1 + G1*2^R_BITS + B1*2^R_BITS*2^B_BITS;

dCnt = length(D);

result = zeros(colorCnt,dCnt);

% Generate all possible indices in the given image
s = size(I);
[r,c] = meshgrid(1:s(1),1:s(2));
r = r(:);
c = c(:);

for k = 1:dCnt
    
    d = D(k); 
    oI = computeOffsetIndices(d);
    oCnt = size(oI,1);

    temp = zeros(colorCnt,1);
    
    % For each possible offset from a point given the distances
    for i = 1:oCnt 
        % Compute the histogram by taking into account only a single offset and accumulate the results
        offset = oI(i,:);
        temp = temp + GLCMATRIX(I,r,c,offset,colorCnt);
    end

    hc = zeros(colorCnt,1);

    for j = 0:colorCnt-1
        hc(j+1) = numel(I(I == j));
    end

    temp = temp ./ (hc+eps);
    result(:,k) = temp/(8*d);
end

result = result(:)';
end

function os = computeOffsetIndices(d)
    [r,c] = meshgrid(-d:d,-d:d);
    r = r(:);
    c = c(:);
    os = [r c];
    good = max(abs(r),abs(c)) == d;
    os = os(good,:);
end

function out = GLCMATRIX(I,r,c,offset,nl)
    s = size(I);
    r2 = r+offset(1);
    c2 = c+offset(2);
    
    good = c2>=1 & c2<=s(2) & r2>=1 & r2<=s(1);
   
    Index = [r c r2 c2];
    Index = Index(good,:);

    v1 = I(sub2ind(s,Index(:,1),Index(:,2)));
    v2 = I(sub2ind(s,Index(:,3),Index(:,4)));

    good = v1 == v2;
    v1 = v1(good,:);
    
    if isempty(v1)
        out = zeros(nl,1);
    else
        out = accumarray(v1(:,1)+1,1,[nl 1]);
    end
end