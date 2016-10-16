function feedback = generateFeedback(labels,inds,correctLabel,N)

% Generate the feedback automatically
feedback = zeros(N,1);

for j = 1:N
    if labels{inds(j),1} == correctLabel
        feedback(j) = feedback(j) + 3;
    else
        feedback(j) = feedback(j) - 3;
    end
end

end