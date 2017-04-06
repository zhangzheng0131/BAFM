function [model,param] = updateBACF(img,pos,target_sz,model,param)


b_filt_sz = model.b_filt_sz;
cropIm = getPatch(img,pos,param.window_sz, param.window_sz);
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

end