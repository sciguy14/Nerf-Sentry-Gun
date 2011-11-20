function matches_out = threshold_matches(matches_in, threshold)
% Return all matches whose distances are below a threshold

[nrows, ncols] = size(matches_in);
current_col = 1;
matches_out = [];
for i = 1:ncols
    if matches_in(3,i) < threshold
        matches_out(1,current_col) = matches_in(1,i);
        matches_out(2,current_col) = matches_in(2,i);
        matches_out(3,current_col) = matches_in(3,i);
        current_col = current_col + 1;
    end
end
