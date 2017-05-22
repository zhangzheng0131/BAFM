function [ model ] = optimizeFilters( img, pos, currentScaleFactor, param,model, isInit )
%OPTIMIZEFILTERS 此处显示有关此函数的摘要
%   此处显示详细说明


%% update

b_filt_sz = model.b_filt_sz;
patch = getPatch(img,pos,param.window_sz, param.window_sz,currentScaleFactor);
rawdata = prepareData(patch, param.features);
x = calculateFeatures(rawdata, param.features,param.cos_window);
% % patch = (double(patch) / 255) - 0.5;  %normalize to range -0.5 .. 0.5
% %     out = powerNormalise(double(out));
% % data = cos_window .* data;  %apply cosine window
% 
MMx = prod(b_filt_sz);
Nchannel = size(x,3);

x = reshape(x,[MMx Nchannel]);%get_ini_perturbation(data, 8);

xf = fftvec(x, b_filt_sz);
if isInit
    model.ZX = bsxfun(@times, conj(xf), model.yf);
    model.ZZ = bsxfun(@times, conj(xf), xf);
    model.X = xf;
    model.df = zeros(prod(b_filt_sz), Nchannel);
    model.sf = zeros(prod(b_filt_sz), Nchannel);
    model.Ldsf  = zeros(prod(b_filt_sz), Nchannel);
  
else
    tmp = bsxfun(@times, conj(xf), model.yf);
    model.ZX = ((1-param.etha) * model.ZX) + (param.etha *  tmp);
    model.ZZ = ((1-param.etha) * model.ZZ) + (param.etha * conj(xf) .* xf);
    model.X = ((1-param.etha) * model.X) + (param.etha * xf);
end

[model.df, model.sf, model.Ldsf, mu] = ECF(model.yf, b_filt_sz, Nchannel,...
    model.s_filt_sz, param.term, 1,param.ADMM_iteration, model.sf, model.df,...
    model.Ldsf,model.ZZ,model.ZX, param.debug,param,model);

%% Init color map

[model.bg_hist, model.fg_hist] = updateHistModel(model.new_pwp_model,...
    patch, model.bg_area, model.fg_area, round(model.last_target_sz),...
    param.norm_bg_area, param.n_bins, param.grayscale_sequence,...
     model.bg_hist,model.fg_hist,param.learning_rate_pwp);



end

