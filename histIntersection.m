function D2 = histIntersection(ZI, ZJ)

N = size(ZJ,1);
D2 = zeros(N,1);

for i=1:N
    B = ZJ(i,:);

    sumZ = sum(ZI);
    sumB = sum(B);

    D2(i) = sum(min(ZI,B)) / min(sumZ,sumB);    
end

end