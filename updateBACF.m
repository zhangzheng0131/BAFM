function [model,param] = updateBACF(img,pos,target_sz,model,param)


b_filt_sz = model.b_filt_sz;
cropIm = getPatch(img,pos,b_filt_sz, b_filt_sz);
cropIm = (double(cropIm) / 255) - 0.5;  %normalize to range -0.5 .. 0.5
%     out = powerNormalise(double(out));
x = param.cos_window .* cropIm;  %apply cosine window

xf = fftvec(x(:), b_filt_sz);
model.ZX = ((1-param.etha) * model.ZX) + (param.etha *  conj(xf) .* model.yf);
model.ZZ = ((1-param.etha) * model.ZZ) + (param.etha * conj(xf) .* xf);
[df sf Ldsf mu] = ECF(model.yf, b_filt_sz, 1, model.s_filt_sz, param.term, 1,...
    param.ADMM_iteration, model.sf, model.df, model.Ldsf,model.ZZ,model.ZX, param.debug,param);
model.df=df;
model.sf=sf;
model.Ldsf=Ldsf;

end