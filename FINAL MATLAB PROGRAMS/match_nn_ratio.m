function matches = match_nn_ratio(descs1, descs2)
% Return a set of matches by finding the nearest neighbors of all 
% descriptors in descs1 in descs2.  This time, however, you will fill in 
% the distance as the ratio of the distance to the first nearest neighbor
% to the distance to the second nearest neighbor.
%
% On output, matches will be a 3-by-(num cols in descs1) matrix where each 
% column has an index of a descriptor in descs1, the index of the nearest 
% neighbor in descs2, and the distance between them.

[nrows1, ncols1] = size(descs1);
[nrows2, ncols2] = size(descs2);
matches = zeros(3,ncols1);

for i = 1:ncols1
    topIndexFound = 0;
    maxDistance = 9999999999999;
    secondDistance = 9999999999998;
    for j = 1:ncols2
        distance = 0;
        for k = 1:128
            a = descs1(k,i);
            b = descs2(k,j);
            distance = distance + (a-b)^2;
        end
        if distance < maxDistance
            secondDistance = maxDistance;
            maxDistance = distance;
            topIndexFound = j;
        elseif (distance < secondDistance) && (distance > maxDistance)
            secondDistance = distance;
        end
    end
    matches(1,i) = i;
    matches(2,i) = topIndexFound;
    matches(3,i) = maxDistance/secondDistance;
end  