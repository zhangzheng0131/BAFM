function [model,param] = updateBACF(img,pos,target_sz,currentScaleFactor,model,param)


b_filt_sz = model.b_filt_sz;
cropIm = getPatch(img,pos,param.window_sz, param.window_sz,currentScaleFactor);
% cropIm = (double(cropIm) / 255) - 0.5;  %normalize to range -0.5 .. 0.5
%     out = powerNormalise(double(out));
% x = param.cos_window .* cropIm;  %apply cosine window


cropIm = prepareData(cropIm, param.features);
x = calculateFeatures(cropIm, param.features,param.cos_window);

MMx = prod(b_filt_sz);
Nchannel = size(x,3);

x = reshape(x,[MMx Nchannel]);%get_ini_perturbation(data, 8);

xf = fftvec(x, b_filt_sz);
model.ZX = ((1-param.etha) * model.ZX) + (param.etha *  conj(xf) .* model.yf);
model.ZZ = ((1-param.etha) * model.ZZ) + (param.etha * conj(xf) .* xf);
[df sf Ldsf mu] = ECF(model.yf, b_filt_sz, 1, model.s_filt_sz, param.term, 1,...
    param.ADMM_iteration, model.sf, model.df, model.Ldsf,model.ZZ,model.ZX, param.debug,param);
model.df=df;
model.sf=sf;
model.Ldsf=Ldsf;
model.last_pos=pos;
model.last_target_sz = target_sz;

model.currentScaleFactor = currentScaleFactor;

if param.nScales >0
       %% update
    
    %create a new feature projection matrix
    [xs_pca, xs_npca] = get_scale_subwindow(img, pos, param.base_target_sz, ...
        model.currentScaleFactor*param.scaleSizeFactors, param.scale_model_sz);


    model.s_num = (1 - param.interp_factor) * model.s_num + param.interp_factor * xs_pca;


    bigY = model.s_num;
    bigY_den = xs_pca;

    if param.max_scale_dim
        [scale_basis, ~] = qr(bigY, 0);
        [scale_basis_den, ~] = qr(bigY_den, 0);
    else
        [U,~,~] = svd(bigY,'econ');
        scale_basis = U(:,1:s_num_compressed_dim);
    end
    model.scale_basis = scale_basis';

    %create the filter update coefficients
    sf_proj = fft(feature_projection_scale([],model.s_num,model.scale_basis,param.scale_window),[],2);
    model.sf_num = bsxfun(@times,model.ysf,conj(sf_proj));

    xs = feature_projection_scale(xs_npca,xs_pca,scale_basis_den',param.scale_window);
    xsf = fft(xs,[],2);
    new_sf_den = sum(xsf .* conj(xsf),1);


    model.sf_den = (1 - param.interp_factor) * model.sf_den + param.interp_factor * new_sf_den;

 
    
end
end