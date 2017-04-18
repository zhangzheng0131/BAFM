
%---------------------------------------------------
%   Calculating dense HoG features
%   Multi-Channel Correlation Filters : ICCV'13
%   author    : Hamed Kiani
%   date      : 30 June 2014
%---------------------------------------------------

%   Note: a dense HoG can be found at the follwoing paper:

%   Cat Head Detection - How to Effectively Exploit Shape
%   and Texture Features (sec. 3.1).

%   We added two normalization steps, cell-wise and block-wise to get
%   mid-level features.

% Inputs:
%       im          : input imagein gray level
%       nbins       : the number of HoG bins, e.g. 5
%       cell_size   : cell size for cell based normalization, e.g. [5 5]
%       block_size  : block size for block based normalization, e.g. [3 3]




% output
%       G :  an h*w*nbins matrix, where h and w are the height and width of
%       the input image and nbins is the number of HoG bins.



function G = calc_hog(im, nbins, cell_size, block_size)


dx = [-1 0 1];
dy = dx';

im = double(im)/255;

%   image gradient in x- and y- direction.
Gx = imfilter(im, dx);
Gy = imfilter(im, dy);

%   initializing the G matrix by zeros.
G = zeros(size(im,1), size(im,2), nbins);

%   gradient orientation
%   theta : [-pi ... pi]
theta = atan2(Gy, Gx);

%   orientation bins
%   theta : [0 ... pi], unsigned
theta(find(theta<0)) = theta(find(theta<0)) + pi;
B = round((theta./pi)*(nbins-1))+1;
for i=1:nbins
    G(:,:,i) =  (B==i);
end;

%   V : image magnitude
V = sqrt((Gx.*Gx) + (Gy.*Gy));

%   assigning each channel the magnitudes according to the bins.
%   Initial forming of dense HoG without block and cell normalization.
%   This is exactly what the following paper does:
%   Cat Head Detection - How to Effectively Exploit Shape
%   and Texture Features (sec. 3.1).

for i=1:nbins
    G(:,:,i) =  G(:,:,i).*V;
end;

%   cell-wise normalization
V = imfilter(V, ones(cell_size)/prod(cell_size), 'conv');

V(find(V<0)) = 0;
V = 1.0 ./ (V + 0.1);

for i=1:nbins
    G(:,:,i) =  imfilter(G(:,:,i), ones(cell_size)/prod(cell_size),'conv');
    G(find(G(:,:,i))<0, i) = 0;
    G(:,:,i) =   G(:,:,i) .* V;
end;

%   block-wise normalization using L2-norm
Gsum = imfilter(sum(G.*G,3), ones(block_size),'conv');
Gsum(find(Gsum<0)) = 0;
Gsum = sqrt(Gsum);

for i=1:nbins
    G(:,:,i) =  G(:,:,i)./(Gsum + 0.1);    
end;
end