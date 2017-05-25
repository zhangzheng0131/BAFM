function [pos,target_sz,currentScaleFactor, param] = trackBACF(img,model,param)

pos = model.last_pos;
b_filt_sz = model.b_filt_sz;
x = getPatch(img,pos,param.window_sz, param.window_sz,model.currentScaleFactor);


cropIm = prepareData(x, param.features);
cropIm = calculateFeatures(cropIm, param.features,param.cos_window);


% cropIm = (double(cropIm) / 255) - 0.5;  %normalize to range -0.5 .. 0.5
%     out = powerNormalise(double(out));
% cropIm = param.cos_window .* cropIm;  %apply cosine window

% 
param.display={};
param.display{1}=x;

% param.display{2}=cropIm(:,:,3);
MMx = prod(b_filt_sz);
Nchannel = size(cropIm,3);

cropIm = reshape(cropIm,[MMx Nchannel]);%get_ini_perturbation(data, 8);


[rsp, ~] = get_rsp((double(cropIm)), model.df, model.s_filt_sz, model.b_filt_sz); %gcf

response_cf = fftshift(rsp);

% response_cf = mexResize(response_cf, [size(x,1) size(x,2)], 'auto');

[likelihood_map] = getColourMap(x, model.bg_hist, model.fg_hist, param.n_bins, param.grayscale_sequence);
% (TODO) in theory it should be at 0.5 (unseen colors shoud have max entropy)
likelihood_map(isnan(likelihood_map)) = 0;

% each pixel of response_pwp loosely represents the likelihood that
% the target (of size norm_target_sz) is centred on it
response_pwp = getCenterLikelihood(likelihood_map,floor(param.base_target_sz));

response_pwp = mexResize(response_pwp,[floor(size(response_pwp,1)/4) floor(size(response_pwp,2)/4)],'auto');

response_pwp = fillzeros(response_pwp,size(response_cf));

response = mergeResponses(response_cf, response_pwp, param.merge_factor, param.merge_method);

sz=size(response);
response = circshift(response, fix(sz/2));

% [x, y] = find(response == max(response(:)),1);
% posRsp = [x y];
% posRsp =  posRsp- ((1+size(response))/2);%.*param.features.cell_size;



[vert_delta, horiz_delta] = find(response ==max(response(:)), 1);
if vert_delta > sz(1) / 2,  %wrap around to negative half-space of vertical axis
    vert_delta = vert_delta - sz(1);
end
if horiz_delta > sz(2) / 2,  %same for horizontal axis
    horiz_delta = horiz_delta - sz(2);
end
%%since we aligment the true sample in y[1,1]
posRsp = [vert_delta-1, horiz_delta-1];

param.display_rsp={};
param.display_rsp{1}=response_cf;
param.display_rsp{2}=response_pwp;
pos = pos + param.features.cell_size * posRsp * model.currentScaleFactor;
% pos = pos + posRsp * model.currentScaleFactor;
%% for debug
% rspTmp = rsp(posRsp(1)-floor(s_filt_sz(1)/2):posRsp(1)+floor(s_filt_sz(1)/2), ...
% posRsp(2)-floor(s_filt_sz(2)/2):posRsp(2)+floor(s_filt_sz(2)/2));
% 
% imTmp = cropIm(posRsp(1)-floor(s_filt_sz(1)/2):posRsp(1)+floor(s_filt_sz(1)/2), ...
%             posRsp(2)-floor(s_filt_sz(2)/2):posRsp(2)+floor(s_filt_sz(2)/2));

% [row, col] = find(rsp == max(rsp(:)), 1);
% pos = pos  + (posRsp- floor(b_filt_sz/2)).*param.features.cell_size;

% if resize_image
%     dis= sqrt(sum((pos*resize_scale - ground_truth(frame,:)*resize_scale).^2));
% else
%     dis= sqrt(sum((pos - ground_truth(frame,:)).^2));
% end;

%% scale search
if param.nScales > 0

    %create a new feature projection matrix
    [xs_pca, xs_npca] = get_scale_subwindow(img,pos,param.base_target_sz,...
        model.currentScaleFactor*param.scaleSizeFactors,param.scale_model_sz);

    xs = feature_projection_scale(xs_npca,xs_pca,model.scale_basis,param.scale_window);
    xsf = fft(xs,[],2);

    scale_responsef = sum(model.sf_num .* xsf, 1) ./ (model.sf_den + param.slambda);

    interp_scale_response = ifft( resizeDFT(scale_responsef, param.nScalesInterp), 'symmetric');

    recovered_scale_index = find(interp_scale_response == max(interp_scale_response(:)), 1);
    %set the scale
    currentScaleFactor = model.currentScaleFactor * param.interpScaleFactors(recovered_scale_index);
    %adjust to make sure we are not to large or to small
    if currentScaleFactor < param.min_scale_factor
        currentScaleFactor = param.min_scale_factor;
    elseif currentScaleFactor > param.max_scale_factor
        currentScaleFactor = param.max_scale_factor;
    end
end

target_sz = floor(param.base_target_sz * currentScaleFactor);



end


function res = fillzeros(im,sz)

res = zeros(sz);

msz = floor((sz - size(im))/2);

res(msz(1):msz(1)+size(im,1)-1, msz(2):msz(2)+size(im,2)-1) = im;


end