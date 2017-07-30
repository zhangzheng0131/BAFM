% ------ install colorspace convertor toolbox -----
toolbox_dir = './toolbox_colorspace';
original_folder = pwd;
eval(['cd ',toolbox_dir]);
mex colorspace.c;
%eval(['cd ',original_folder]);
cd('./../');
addpath(toolbox_dir);

% ---- user-defined parameters -----
imagename = '1_21_s';
imageext = '.bmp';
C = 6;
max_iteration = 100;
Rep = 1;
display_option = 'yes';
% --- prepare the image and segment it using GMM!
[I_segm, I_posterior, I_max_posterior, ll] = fn_imgSegmentationGMM2(imagename, imageext, C, max_iteration, Rep, display_option);
figure(1); print('-djpeg','-r100',['GMM_segm_result_class.jpg']);
figure(2); print('-djpeg','-r100',['GMM_segm_result_max_posterior.jpg']);
figure(3); print('-djpeg','-r100',['GMM_segm_result_posterior.jpg']);