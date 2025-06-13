function [covered, norm] = wall_field(map)

ly = size(map,1);
aux = NaN(ly,1);

for j = 1:ly
    a = find(isfinite(map(j,:)),1,'first');
    if ~isempty(a)
        aux(j) = map(j,a);
    end
end

norm = sum(isfinite(aux));
covered = nansum(aux>0);