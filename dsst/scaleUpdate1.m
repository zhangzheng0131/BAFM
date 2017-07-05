function [ param,model ] = scaleUpdate( img,pos,param,model,isInit )
%SCALEUPDATE 此处显示有关此函数的摘要
%   此处显示详细说明
    
%create a new feature projection matrix
[xs_pca, xs_npca] = get_scale_subwindow(img, pos, param.base_target_sz, ...
    model.currentScaleFactor*param.scaleSizeFactors, param.scale_model_sz);

if isInit
    model.s_num = xs_pca;
else
    model.s_num = (1 - param.interp_factor) * model.s_num + param.interp_factor * xs_pca;

end;


bigY = model.s_num;
bigY_den = xs_pca;
param.max_scale_dim=0;
if param.max_scale_dim
    [scale_basis, ~] = qr(bigY, 0);
    [scale_basis_den, ~] = qr(bigY_den, 0);
else
    [U,~,~] = svd(bigY,'econ');
    scale_basis = U;
    %scale_basis = U(:,1:s_num_compressed_dim);
    [scale_basis_den,~,~ ] = svd(bigY_den,'econ');
end
model.scale_basis = scale_basis';

%create the filter update coefficients
sf_proj = fft(feature_projection_scale([],model.s_num,model.scale_basis,param.scale_window),[],2);
model.sf_num = bsxfun(@times,model.ysf,conj(sf_proj));

xs = feature_projection_scale(xs_npca,xs_pca,scale_basis_den',param.scale_window);
xsf = fft(xs,[],2);
new_sf_den = sum(xsf .* conj(xsf),1);

if isInit
    
    model.sf_den = new_sf_den;
else
    model.sf_den = (1 - param.interp_factor) * model.sf_den + param.interp_factor * new_sf_den;

end;

 

end

