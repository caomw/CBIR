function cHist = colorHistogram(image)

    % rph = 0 or rph is omitted -> Course Partition Histogram (8+2+2 bins)
    % rph = 1 -> Refine Partition Histogram (8x2x2 bins)
    rph = 0;

    image = rgb2hsv(image);

    % split image into h, s & v planes
    c1 = image(:, :, 1);
    c2 = image(:, :, 2);
    c3 = image(:, :, 3);

    % Specify the number of quantization levels.
    numBin1 = 8;
    numBin2 = 2;
    numBin3 = 2;

    % Max values for each channel
    max1 = 1;
    max2 = 1;
    max3 = 1;

    if (rph == 0)
        % Create CPH histogram
        ranges1 = linspace(0, max1, numBin1+1);
        ranges2 = linspace(0, max2, numBin2+1);
        ranges3 = linspace(0, max3, numBin3+1);

        % Endpoint of the range will be another bin that needs to be ignored
        ranges1(numBin1+1) = 1000;
        ranges2(numBin2+1) = 1000;
        ranges3(numBin3+1) = 1000;

        hist1 = histc(c1(:),ranges1)';
        hist2 = histc(c2(:),ranges2)';
        hist3 = histc(c3(:),ranges3)';

        cHist = [hist1(1:numBin1) hist2(1:numBin2) hist3(1:numBin3)];
    else
        % Create RPH histogram
        cHist = zeros(numBin1, numBin2, numBin3);

        for row = 1:size(c1, 1)
            for col = 1 : size(c1, 2)

                ind1 = int16(floor( numBin1 * c1(row, col) / (max1 + eps) )) + 1;
                ind2 = int16(floor( numBin2 * c2(row, col) / (max2 + eps) )) + 1;
                ind3 = int16(floor( numBin3 * c3(row, col) / (max3 + eps) )) + 1;

                cHist(ind1, ind2, ind3) = cHist(ind1, ind2, ind3) + 1;
            end
        end 
    end

    cHist = histNormalize(cHist(:)');
