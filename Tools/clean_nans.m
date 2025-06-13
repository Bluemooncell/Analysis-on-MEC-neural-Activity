
function Z=clean_nans(Z0)
X=1:length(Z0);
X0=X;
Zcopy=Z0;
aux=isnan(Z0);
X0(aux)=[];
Z0(aux)=[];
if(length(X0)>2)
    Z=interp1(X0,Z0,X,'spline','extrap');
else
    Z=Zcopy;
end
