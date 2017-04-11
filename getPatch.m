function patch = getPatch(img,pos,tmp_sz, window_sz,currentSize)
    if prod(tmp_sz == window_sz) ==1 && currentSize==1
        [~,~,patch] = get_subwindow(img,pos,window_sz);
    else
        if prod(tmp_sz == window_sz) ==1
            
            patch = get_subwindowDSST(img, pos, window_sz, currentSize);
        else
            param0 = [pos(2), pos(1), tmp_sz(2)/window_sz(2), 0,...
                        tmp_sz(1)/window_sz(2)/(window_sz(1)/window_sz(2)),0];
            param0 = affparam2mat(param0); 
            patch = uint8(warpimg(double(img), param0, window_sz));
        end
    end
end

function [yys xxs out] = get_subwindow(im, pos, sz)
%GET_SUBWINDOW Obtain sub-window from image, with replication-padding.
%   Returns sub-window of image IM centered at POS ([y, x] coordinates),
%   with size SZ ([height, width]). If any pixels are outside of the image,
%   they will replicate the values at the borders.
%
%   The subwindow is also normalized to range -0.5 .. 0.5, and the given
%   cosine window COS_WINDOW is applied (though this part could be omitted
%   to make the function more general).
%
%   Jo? F. Henriques, 2012
%   http://www.isr.uc.pt/~henriques/

if isscalar(sz),  %square sub-window
    sz = [sz, sz];
end

xs = floor(pos(2)) + (1:sz(2)) - floor(sz(2)/2);
xxs  = xs;
ys = floor(pos(1)) + (1:sz(1)) - floor(sz(1)/2);
yys = ys;

%check for out-of-bounds coordinates, and set them to the values at
%the borders
xs(xs < 1) = 1;
ys(ys < 1) = 1;
xs(xs > size(im,2)) = size(im,2);
ys(ys > size(im,1)) = size(im,1);

%extract image
out = im(ys, xs, :);
% step = 2;
% % 	cos_window = hann(size(out, 1)) * hann(size(out,2))';
% w1 = cos(linspace(-pi/step, pi/step, size(out, 1)));
% w2 = cos(linspace(-pi/step, pi/step, size(out, 2)));
% cos_window = w1' * w2;

% %pre-process window
% out = (double(out) / 255) - 0.5;  %normalize to range -0.5 .. 0.5
% %     out = powerNormalise(double(out));
% out = cos_window .* out;  %apply cosine window

end


function [im_patch] = get_subwindowDSST(im, pos, model_sz, currentScaleFactor)

if isscalar(model_sz)
    model_sz = [model_sz, model_sz];
end

patch_sz = floor(model_sz * currentScaleFactor);

%make sure the size is not to small
if patch_sz(1) < 1
    patch_sz(1) = 2;
end;
if patch_sz(2) < 1
    patch_sz(2) = 2;
end;


xs = floor(pos(2)) + (1:patch_sz(2)) - floor(patch_sz(2)/2);
ys = floor(pos(1)) + (1:patch_sz(1)) - floor(patch_sz(1)/2);

%check for out-of-bounds coordinates, and set them to the values at
%the borders
xs(xs < 1) = 1;
ys(ys < 1) = 1;
xs(xs > size(im,2)) = size(im,2);
ys(ys > size(im,1)) = size(im,1);

%extract image
im_patch = im(ys, xs, :);

%resize image to model size
% im_patch = imresize(im_patch, model_sz, 'bilinear');
im_patch = mexResize(im_patch, model_sz, 'auto');
% 
% % compute non-pca feature map
% out_npca = [];
% 
% % compute pca feature map
% temp_pca = fhog(single(im_patch),4);
% temp_pca(:,:,32) = cell_grayscale(im_patch,4);
% 
% out_pca = reshape(temp_pca, [size(temp_pca, 1)*size(temp_pca, 2), size(temp_pca, 3)]);
end


