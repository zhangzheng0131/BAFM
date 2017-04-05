function [model, param] = initBACF(img, pos, target_sz)

model = {};
param = readParam();
%% calculate parameters
% whether resize image not consist with BACF code
% This should before everything
t = sqrt(prod(target_sz));
if  t >= param.lowResize && t<param.upResize
    resize_image = true;
    resize_scale = 2;
elseif sqrt(prod(target_sz))>=param.upResize
    resize_image = true;
    resize_scale = 4;
else
    resize_image = false;
    resize_scale = 1;
end

param.resize_image= resize_image;
param.resize_scale= resize_scale;

if resize_image
    img = imresize(img,1/resize_scale);
    pos = floor(pos / resize_scale);
    target_sz = floor(target_sz / resize_scale);
end

model.firstImg = img;
%% 

s_filt_sz = floor(target_sz);
sz = floor(target_sz * (1 + param.padding));
if param.features.colorProbHoG || param.features.greyHoG
    s_filt_sz=floor(s_filt_sz / param.features.cell_size);
    b_filt_sz=floor(sz / param.features.cell_size);
else
    param.features.cell_size = 1;
end
output_sigma = sqrt(prod(s_filt_sz)) * param.output_sigma_factor;% /param.features.cell_size;

cos_window = hann(b_filt_sz(1)) *hann(b_filt_sz(2))';	
% step =2;
% w1 = cos(linspace(-pi/step, pi/step, sz(1)));
% w2 = cos(linspace(-pi/step, pi/step, sz(2)));
% cos_window = w1' * w2;


[rs, cs] = ndgrid((1:b_filt_sz(1)) - floor(b_filt_sz(1)/2), (1:b_filt_sz(2)) - floor(b_filt_sz(2)/2));
y = exp(-0.5 / output_sigma^2 * (rs.^2 + cs.^2));
y = circshift(y, fix(s_filt_sz/2));
yf = fftvec(y(:), b_filt_sz);


model.yf = yf;%fft2(gaussian_shaped_labels(output_sigma, sz));

param.window_sz = sz;
% param.output_sigma = output_sigma;

param.cos_window = cos_window;
param.features.sz = b_filt_sz;

%create model



%% initialization of first image
patch = getPatch(img,pos,sz, sz);
if size(patch,3)==1
    param.features.colorProb=0;
    param.features.colorProbHoG=0;
    param.features.colorName = 0;
end
% param.features = updateFeatures(patch, param.features);
rawdata = prepareData(patch, param.features);
data = calculateFeatures(rawdata, param.features,param.cos_window);

% patch = (double(patch) / 255) - 0.5;  %normalize to range -0.5 .. 0.5
%     out = powerNormalise(double(out));
% data = cos_window .* data;  %apply cosine window


MMx = prod(b_filt_sz);

Nchannel = size(data,3);
ZX = zeros(MMx, Nchannel);
ZZ = zeros(MMx, Nchannel);

ini_imgs = reshape(data,[MMx Nchannel]);%get_ini_perturbation(data, 8);



ECFimageF = fftvec(ini_imgs, b_filt_sz);

ZX = ZX + bsxfun(@times, conj(ECFimageF), yf);
ZZ = ZZ + bsxfun(@times, conj(ECFimageF), ECFimageF);


df = zeros(prod(b_filt_sz), Nchannel);
sf = zeros(prod(b_filt_sz), Nchannel);
Ldsf  = zeros(prod(b_filt_sz), Nchannel);
  


[df,sf, Ldsf, mu] = ECF(yf, b_filt_sz, Nchannel, s_filt_sz, param.term, 1, param.ADMM_iteration, sf, df, Ldsf,ZZ,ZX, param.debug,param);


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