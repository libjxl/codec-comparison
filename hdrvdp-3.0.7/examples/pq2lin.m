function im_lin = pq2lin(im_pq)
% Transforms a PQ-encoded image into an image with absolute linear colour values (accrding to Rec. 2100).
%
% im_lin = pq2lin(im_pq)
%
% im_pq - a PQ-encoded image (HxWx3), the values are in the range 0-1
% im_lim - an image with linear colour values in the range 0.005 to 10000 


%hdrIn(hdrIn<0) = 0;

% The maximum allowed value for PQ is 10000 for HDR frames
Lmax = 10000;

n    = 0.15930175781250000;
m    = 78.843750000000000;	
c1   = 0.83593750000000000;	
c2   = 18.851562500000000;	
c3   = 18.687500000000000;	


im_t = max(im_pq,0).^(1/m);

im_lin = Lmax * (max( im_t-c1, 0 )./(c2-c3*im_t)).^(1/n);


end
