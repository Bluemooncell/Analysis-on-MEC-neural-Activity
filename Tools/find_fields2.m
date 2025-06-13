
function fields = find_fields2(map, binsize)
%map=clean_matrix(map,20);
%map=interpolate_border_nans(map);


bins=100;

% Interpolate map to have bins
[ly,lx] = size(map);
l = min(lx,ly);
[X,Y] = meshgrid(1:lx,1:ly);
[X0,Y0] = meshgrid(1:l/bins:lx,1:l/bins:ly);
Z0 = interp2(X,Y,map,X0,Y0);
% Interpolate values for the NaNs at the border
Z0 = interpolate_border_nans(Z0);

% Max rate
mx = max(map(:));
threshold = 0.3 * mx;
sy = size(Z0,1);
sx = size(Z0,2);


field_num=0;

[max_val_y, max_pos_y_list] = max(Z0);
[~, max_pos_x] = max(max_val_y);
max_pos_y = max_pos_y_list(max_pos_x);

ZAll = Z0;
ZDeleted = zeros(sy,sx);

while(max(Z0(:))>threshold)
    field_num=field_num+1;

    ZAux = zeros(sy,sx);
    ZAux(isnan(Z0)) = nan;
    ZAux(max_pos_y, max_pos_x) = Z0(max_pos_y ,max_pos_x);
    mark = 0;
    count = 0;
    above_thresh=Z0>threshold;
    while(mark==0)
        mark=1;
        Zxp=[zeros(sy,1), ZAux(1:end,1:end-1)];
        Zxm=[ZAux(1:end,2:end), zeros(sy,1)];
        Zyp=[zeros(1,sx); ZAux(1:end-1,1:end)];
        Zym=[ZAux(2:end,1:end); zeros(1,sx)];

        aux=above_thresh.*(((Zxp>0)+(Zxm>0)+(Zym>0)+(Zyp>0))>0);
        mapold=ZAux;
        ZAux(aux>0)=Z0(aux>0);
        if(nansum(ZAux(:)-mapold(:))>0)
            mark=0;
        end
        count=count+1;
    end

    ZDeleted=ZDeleted+ZAux;
%    Z0=Z0-ZAux;
    Z0=ZAll-ZDeleted;

    [max_val_y, max_pos_y_list]=max(Z0);
    [~, max_pos_x]=max(max_val_y);
    max_pos_y=max_pos_y_list(max_pos_x);


    if(sum(ZAux(:)>0)<200*lx*ly*binsize^2/(sx*sy))
        field_num=field_num-1;
    else
         maps{field_num}=ZAux;
    end

    if(field_num==0)
        mx=max(Z0(:));
        threshold=0.3*mx;

        Z0=Z0+ZAux;
    end
end



fields.number_of_fields = field_num;

if exist('maps','var')
    fields.coverage = field_coverage2(maps);
    fields.weighted_firing_distance = weighted_firing_distance(maps ,binsize*lx/sx)/(l*binsize);
    fields.maps = maps;
else
    coverage.perimeter.max_one_field = 0;
    fields.coverage = coverage;
    fields.weighted_firing_distance = 0;
end
