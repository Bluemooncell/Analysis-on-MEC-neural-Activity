function score = borderScoreCalculation(ratemap, binSize)

fields = find_fields2(ratemap,binSize);

if fields.number_of_fields > 0
    maxfieldcov = fields.coverage.perimeter.max_one_field;
    fdist = fields.weighted_firing_distance;
    score = (maxfieldcov-2*fdist)/(maxfieldcov+2*fdist);
else
    score = -1.1;
end

