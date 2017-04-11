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


[rsp, posRsp] = get_rsp((double(cropIm)), model.df, model.s_filt_sz, model.b_filt_sz); %gcf
param.display_rsp={};
param.display_rsp{1}=fftshift(rsp);
pos = pos + param.features.cell_size * posRsp * model.currentScaleFactor;

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