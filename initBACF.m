function [model, param] = initBACF(img, pos, target_sz)

model = {};
param = readParam();
%% calculate parameters
% whether resize image not consist with BACF code
% This should before everything
t = sqrt(prod(target_sz));
if  t >= param.lowResize && t<param.upResize
    resize_image = false;
    resize_scale = 1;
elseif sqrt(prod(target_sz))>=param.upResize
    resize_image = false;
    resize_scale = 1;
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



search_area = prod(target_sz * param.search_area_scale);

if search_area > param.max_image_sample_size
    model.currentScaleFactor = sqrt(search_area / param.max_image_sample_size);
elseif search_area < param.min_image_sample_size
    model.currentScaleFactor = sqrt(search_area / param.min_image_sample_size);
else
    model.currentScaleFactor = 1.0;
end

% target size at the initial scale
target_sz = target_sz / model.currentScaleFactor;


% sz = floor(target_sz * (1 + param.padding));
%window size, taking padding into account
switch param.search_area_shape
    case 'proportional'
        sz = floor( target_sz * param.search_area_scale);     % proportional area, same aspect ratio as the target
    case 'square'
        sz = repmat(sqrt(prod(target_sz * param.search_area_scale)), 1, 2); % square area, ignores the target aspect ratio
    case 'fix_padding'
        sz = target_sz + sqrt(prod(target_sz * param.search_area_scale) + (target_sz(1) - target_sz(2))/4) - sum(target_sz)/2; % const padding
    case 'custom'
        sz = [target_sz(1)*2 target_sz(2)*4]; % for testing
end

if param.features.colorProbHoG || param.features.greyHoG
    param.features.cell_size = 4;
else
    param.features.cell_size = 1;
end
s_filt_sz = floor(target_sz*param.filter_size);
s_filt_sz=floor(s_filt_sz / param.features.cell_size);
b_filt_sz=floor(sz / param.features.cell_size);
output_sigma = sqrt(prod(s_filt_sz)) * param.output_sigma_factor;% /param.features.cell_size;

cos_window = hann(b_filt_sz(1)) *hann(b_filt_sz(2))';	
% step =2;
% w1 = cos(linspace(-pi/step, pi/step, sz(1)));
% w2 = cos(linspace(-pi/step, pi/step, sz(2)));
% cos_window = w1' * w2;


[rs, cs] = ndgrid((1:b_filt_sz(1)) - floor(b_filt_sz(1)/2), (1:b_filt_sz(2)) - floor(b_filt_sz(2)/2));
y = exp(-0.5 / output_sigma^2 * (rs.^2 + cs.^2));
y = circshift(y, -floor(b_filt_sz/2)+1);
assert(y(1,1) == 1)

yf = fftvec(y(:), b_filt_sz);


model.yf = yf;%fft2(gaussian_shaped_labels(output_sigma, sz));

param.window_sz = sz;
% param.output_sigma = output_sigma;

param.cos_window = cos_window;
param.features.sz = b_filt_sz;
param.base_target_sz = target_sz;
%create model
if size(img,3)==1
    param.features.colorProb=0;
    param.features.colorProbHoG=0;
    param.features.colorName = 0;
end
model.s_filt_sz=s_filt_sz;
model.b_filt_sz=b_filt_sz;


%% initialization of first image
% 
% [xf, alphaf] = calculateModel(data,model,param);
% 
% 
% model.model_alphaf = alphaf;
% model.model_xf = xf;

model = optimizeFilters( img, pos, model.currentScaleFactor, param,model, 1 );

%% scale
if param.nScales > 0
    
%     param.nScales = 17;
% param.nScalesInterp = 33;
% param.scale_step = 1.02;
% param.scale_sigma_factor = 1/16;
% param.scale_model_factor = 1.0;
% param.scale_model_max_area = 512;


    scale_sigma = param.nScalesInterp * param.scale_sigma_factor;
    
    scale_exp = (-floor((param.nScales-1)/2):ceil((param.nScales-1)/2)) * param.nScalesInterp/param.nScales;
    scale_exp_shift = circshift(scale_exp, [0 -floor((param.nScales-1)/2)]);
    
    interp_scale_exp = -floor((param.nScalesInterp-1)/2):ceil((param.nScalesInterp-1)/2);
    interp_scale_exp_shift = circshift(interp_scale_exp, [0 -floor((param.nScalesInterp-1)/2)]);
    
    param.scaleSizeFactors = param.scale_step .^ scale_exp;
    param.interpScaleFactors = param.scale_step .^ interp_scale_exp_shift;
    
    ys = exp(-0.5 * (scale_exp_shift.^2) /scale_sigma^2);
    model.ysf = single(fft(ys));
    param.scale_window = single(hann(size(model.ysf,2)))';
    
    %make sure the scale model is not to large, to save computation time
    if param.scale_model_factor^2 * prod(target_sz) > param.scale_model_max_area
        param.scale_model_factor = sqrt(param.scale_model_max_area/prod(target_sz));
    end
    
    %set the scale model size
    param.scale_model_sz = floor(target_sz * param.scale_model_factor);
    
    
    %force reasonable scale changes
    param.min_scale_factor = param.scale_step ^ ceil(log(max(5 ./ sz)) / log(param.scale_step));
    param.max_scale_factor = param.scale_step ^ floor(log(min([size(img,1)...
        size(img,2)] ./ target_sz)) / log(param.scale_step));
    
    param.max_scale_dim = strcmp(param.s_num_compressed_dim,'MAX');
    if param.max_scale_dim
        param.s_num_compressed_dim = length(param.scaleSizeFactors);
    else
        param.s_num_compressed_dim = params.s_num_compressed_dim;
    end
    
    %% update
    [ param,model ] = scaleUpdate( img,pos,param,model,1 );
    
end


%%
model.last_pos=pos;
model.last_target_sz = target_sz;





end