 function M=interpolate_border_nans(M0)
M=M0;
M(1:end,1) = clean_nans(M0(1:end,1));
M(1:end,end) = clean_nans(M0(1:end,end));
M(1,1:end) = clean_nans(M0(1,1:end));
M(end,1:end) = clean_nans(M0(end,1:end));
 end