function coverage = field_coverage2(fields)
    coverage.perimeter.W = 0;
    coverage.perimeter.N = 0;
    coverage.perimeter.E = 0;
    coverage.perimeter.S = 0;
    coverage.area.total = 0;
    coverage.area.inside_area = 0;
    coverage.area.W = 0;
    coverage.area.E = 0;
    coverage.area.S = 0;
    coverage.area.N = 0;
    coverage.weighted_distance = 0;
if ~isempty(fields)
    coverage.perimeter.max_one_field = 0;

    for i=1:length(fields)

        aux_map = fields{i}(:,1:8);
        [covered,norm] = wall_field(aux_map);
        if(covered/norm>coverage.perimeter.max_one_field)
            coverage.perimeter.max_one_field = covered/norm;
        end

        aux_map=fields{i}(:,end:-1:end+1-8);
        [covered,norm]=wall_field(aux_map);
        if(covered/norm>coverage.perimeter.max_one_field)
            coverage.perimeter.max_one_field=covered/norm;
        end

        aux_map=fields{i}(1:8,:)';
        [covered,norm]=wall_field(aux_map);
        if(covered/norm>coverage.perimeter.max_one_field)
            coverage.perimeter.max_one_field=covered/norm;
        end

        aux_map=fields{i}(end:-1:end+1-8,:)';
        [covered,norm]=wall_field(aux_map);
        if(covered/norm>coverage.perimeter.max_one_field)
            coverage.perimeter.max_one_field=covered/norm;
        end
    end
end