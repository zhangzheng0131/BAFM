function [model, param] = initBACF(img, pos, target_sz)

model = {};
param = readParam();
%% calculate parameters
% whether resize image not consist with BACF code
resize_image = (sqrt(prod(target_sz)) >= param.upResize);

s_filt_sz = floor(target_sz);
b_filt_sz = floor(target_sz * (1 + param.padding));
% if param.features.colorProbHoG || param.features.greyHoG
%     sz=floor(window_sz / param.features.cell_size);
% else
%     sz = window_sz;
%     param.features.cell_size = 1;
% end
output_sigma = sqrt(prod(s_filt_sz)) * param.output_sigma_factor;% /param.features.cell_size;

sz = b_filt_sz;
% cos_window = hann(sz(1)) *hann(sz(2))';	
step =2;
w1 = cos(linspace(-pi/step, pi/step, sz(1)));
w2 = cos(linspace(-pi/step, pi/step, sz(2)));
cos_window = w1' * w2;


[rs, cs] = ndgrid((1:sz(1)) - floor(sz(1)/2), (1:sz(2)) - floor(sz(2)/2));
y = exp(-0.5 / output_sigma^2 * (rs.^2 + cs.^2));
y = circshift(y, fix(s_filt_sz/2));
yf = fftvec(y(:), b_filt_sz);


model.yf = yf;%fft2(gaussian_shaped_labels(output_sigma, sz));

param.window_sz = b_filt_sz;
% param.output_sigma = output_sigma;
param.resize_image= resize_image;
param.cos_window = cos_window;
% param.features.sz = sz;

%create model

% if resize_image
%     img = imresize(img,0.5);
%     pos = floor(pos / 2);
%     target_sz = floor(target_sz / 2);
% 
% end

%% initialization of first image
patch = getPatch(img,pos,b_filt_sz, b_filt_sz);
% if size(patch,3)==1
%     param.features.colorProb=0;
%     param.features.colorProbHoG=0;
%     param.features.colorName = 0;
% end
% param.features = updateFeatures(patch, param.features);
% rawdata = prepareData(patch, param.features);
% data = calculateFeatures(rawdata, param.features,param.cos_window);

patch = (double(patch) / 255) - 0.5;  %normalize to range -0.5 .. 0.5
%     out = powerNormalise(double(out));
data = cos_window .* patch;  %apply cosine window

ini_imgs = get_ini_perturbation(data, 8);

MMx = prod(b_filt_sz);
ZX = zeros(MMx, 1);
ZZ = zeros(MMx, 1);


ECFimageF = fftvec(ini_imgs, b_filt_sz);

for n = 1:size(ini_imgs, 2)
    ZX = ZX + bsxfun(@times, conj(ECFimageF(:,n)), yf);
    ZZ = ZZ + bsxfun(@times, conj(ECFimageF(:,n)), ECFimageF(:,n));
end

df = zeros(prod(b_filt_sz), 1);
sf = zeros(prod(b_filt_sz), 1);
Ldsf  = zeros(prod(b_filt_sz), 1);
  


[df,sf, Ldsf, mu] = ECF(yf, b_filt_sz, 1, s_filt_sz, param.term, 1, param.ADMM_iteration, sf, df, Ldsf,ZZ,ZX, param.debug);


% 
% [xf, alphaf] = calculateModel(data,model,param);
% 
% 
% model.model_alphaf = alphaf;
% model.model_xf = xf;

model.df = df;
model.sf = sf;
model.Ldsf = Ldsf;


model.ZX = ZX;
model.ZZ = ZZ;
model.last_pos=pos;
model.last_target_sz = target_sz;
model.s_filt_sz=s_filt_sz;
model.b_filt_sz=b_filt_sz;




end