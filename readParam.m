%
%coded by Li, Yang

function param = readParam()

param={};

%set parameters
param.visualization=1;
param.debug = 0;


param.ADMM_iteration = 2;
param.search_area_scale =4;
param.filter_size = 1.2;
param.output_sigma_factor = 1/16;

param.ini_imgs=8;
param.etha = .0125;
param.upResize = 100;
param.lowResize = 50;
param.term = 1e-6;

param.lambda = 0.001;
param.slambda = 1e-2;
param.beta = 10;
param.mu=1;
param.maxMu=1000;

%% CCOT tricks
param.search_area_shape = 'square';
param.min_image_sample_size = 200^2;   % Minimum area of image samples
param.max_image_sample_size = 300^2;   % Maximum area of image samples

param.fix_model_size = 80^2;

%% color settings
param.inner_padding = 0.2; 
param.n_bins = 2^5; 
param.learning_rate_pwp = 0.04;
param.merge_method = 'const_factor';
%param.merge_factor = 0;

param.merge_factor = 0.5;


% 
% %% here is nsamf parameters
% 

% 
% param.kernel_type = 'linear'; 
% param.padding = 1.5;  %extra area surrounding the target
% param.lambda = 1e-4;  %regularization
% param.output_sigma_factor = 0.1;  %spatial bandwidth 
% 
% param.interp_factor = 0.01;
param.features.colorUpdateRate = 0.01;
        
      
types = {'greyHoG','grey'};%,'colorName''greyHoG','grey','colorProb','colorProbHoG','lbp'  ,'greyProb'
param.features.types=types;
param.features.hog_orientations = 9;
param.features.nbin =10;
param.features.cell_size = 4;

temp = load('w2crs');
param.features.w2c = temp.w2crs;
param.features.colorTransform = makecform('srgb2lab');
param.features.interPatchRate = 0.3;

param.features.grey=0;
param.features.greyHoG=0;
param.features.colorProb=0;
param.features.colorProbHoG=0;
param.features.colorName=0;
param.features.greyProb=0;
param.features.lbp=0;


for i=1:numel(types)
   switch types{i}
       case 'grey'
           param.features.grey=1;
       case 'greyHoG'
           param.features.greyHoG=1;
       case 'colorProb'
           param.features.colorProb=1;
       case 'colorProbHoG'
           param.features.colorProbHoG=1;
       case 'colorName'
           param.features.colorName=1;
       case 'greyProb'
           param.features.greyProb=1;
       case 'lbp'   
           param.features.lbp=1;
   end
    
end

%% use DSST scale
% DSST default settings
% params.number_of_scales = 17;           % number of scale levels
% params.number_of_interp_scales = 33;    % number of scale levels after interpolation
% params.scale_model_factor = 1.0;        % relative size of the scale sample
% params.scale_step = 1.02;               % Scale increment factor (denoted "a" in the paper)
% params.scale_model_max_area = 512;      % the maximum size of scale examples
% params.s_num_compressed_dim = 'MAX';    % number of compressed scale feature dimensions
% params.scale_sigma_factor = 1/16;

param.nScales = 17;
param.nScalesInterp = 33;
param.scale_step = 1.02;
param.scale_sigma_factor = 1/16;
param.scale_model_factor = 1.0;
param.scale_model_max_area = 512;
param.s_num_compressed_dim = 'MAX';
param.interp_factor = 0.025;

param.search_size = [1 0.985 0.99 0.995 1.005 1.01 1.015];%


end