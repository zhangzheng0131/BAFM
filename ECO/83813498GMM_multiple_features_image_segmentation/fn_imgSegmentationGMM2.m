function [I_segm, I_posterior, I_max_posterior, ll] = fn_imgSegmentationGMM2(imagename, imageext, C, max_iteration, Rep, display_option)

% INPUT
% imagename: the filename of the image discarding the extension
% imageext: the extension of the image, e.g., '.jpg', '.bmp', etc.
% C: the desired number of class labels
% max_iteration: the maximum number of iteration for EM algorithm
% Rep: the number of repetitions for EM to run
% display_option: display the segmentation results if equals to 'yes', and not displaying otherwise.
% 
% OUTPUT
% I_segm: Nrow by Ncol matrix each element is the MAP class label
% I_posterior: Nrow by Ncol by C cube matrix represent the posterior for each class for each label
% I_max_posterior: Nrow by Ncol matrix each element is the maximum posterior value corresponding to I_segm
% ll: the log-likelihood of the results

% Example
% C = 7;
% max_iteration = 100;
% Rep = 8;
% display_option = 'yes';
% [I_segm, I_posterior, I_max_posterior, ll] = fn_imgSegmentationGMM2(imagename, imageext, C, max_iteration, Rep, display_option)



% import an image
img_org = imread([imagename,imageext]);
Ncol = size(img_org,2);
Nrow = size(img_org,1);

img_RGB = double(img_org); % converted to double precision
img_sRGB = double(img_RGB)/255; % standardized RGB
img_gRGB = img_RGB./repmat(sum(img_RGB,3),[1 1 size(img_RGB,3)]); % generalized RGB

% Gray scale feature
img_gray = rgb2gray(img_org);
img_sgray = double(img_gray)/255;

% ========== CIELuv ==========
img_Luv = colorspace(['Luv<-RGB'],img_sRGB);  % Convert to Luv
img_sLuv = img_Luv;
img_sLuv(:,:,1) = img_Luv(:,:,1)/100; % range of L is 0 to 100
img_sLuv(:,:,2) = (img_Luv(:,:,2)+100)/(100+100); % range of a depends on the image, so I set it at -100 to +100
img_sLuv(:,:,3) = (img_Luv(:,:,3)+100)/(100+100); % range of b depends on the image, so I set it at -100 to +100
img_sLuv(img_sLuv > 1) = 1; img_sLuv(img_sLuv < 0) = 0;
I_sLuv = reshape(img_sLuv(:),Ncol*Nrow,[]); % align the image pixels by NxD, N: # of pixels in the image
% =============================


% CIELab ------ normalize the color pixel
img_Lab = colorspace(['Lab<-RGB'],img_sRGB);  % Convert to Lab
img_sLab = img_Lab;
img_sLab(:,:,1) = img_Lab(:,:,1)/100; % range of L is 0 to 100
img_sLab(:,:,2) = (img_Lab(:,:,2)+100)/(100+100); % range of a depends on the image, so I set it at -100 to +100
img_sLab(:,:,3) = (img_Lab(:,:,3)+100)/(100+100); % range of b depends on the image, so I set it at -100 to +100
img_sLab(img_sLab > 1) = 1; img_sLab(img_sLab < 0) = 0;
I_sLab = reshape(img_sLab(:),Ncol*Nrow,[]); % align the image pixels by NxD, N: # of pixels in the image

% ========== generalized CIE Lab ======================================
sum_I_sLab = sum(I_sLab,2);
sum_I_sLab(sum_I_sLab==0) = 1e-6;
I_gsLab = I_sLab./repmat(sum_I_sLab,1,3);
img_gsLab = reshape(I_gsLab, [Nrow Ncol 3]);


% ============= create pixel location ===============
[xI,yI] = meshgrid(1:Ncol,1:Nrow); 
sxI = xI/max(xI(:)); % standardized x coordinate
syI = yI/max(yI(:)); % standardized y coordinate
% figure; imagesc(sxI); daspect([1 1 1]); % 4test
% figure; imagesc(syI); daspect([1 1 1]); % 4test
% =============================

% ========== Texton bank of filters ==========
load Texton49x49x48; % The texton is stored in Texton, a 49 x 49 x 48 3D martix
response_Texton = zeros(size(img_RGB,1),size(img_RGB,2),size(Texton,3));

for j = 1:size(Texton,3) % pick a filter to use 1-48
    Texton_patch = Texton(:,:,j);
    [row_Texton_patch col_Texton_patch] = size(Texton_patch);
    half_patch = ceil((row_Texton_patch-1)/2); % assume texton patch is symmetric
    R=conv2(double(img_gray),Texton_patch,'full'); % Full convolution
    response_Texton(:,:,j) = R( (half_patch+1):(end-half_patch) , (half_patch+1):(end-half_patch)); % adjust the size
end
% =============================

% ============= compose feature matrix ===============
featureMat = nan*zeros(Nrow,Ncol,100);

featureMat(:,:,[1:3]) = img_gRGB;
featureMat(:,:,[4:6]) = img_sLuv;
featureMat(:,:,[7:9]) = img_gsLab;
featureMat(:,:,10) = sxI;
featureMat(:,:,11) = syI;
% featureMat(:,:,12) = img_sgray;

% tmp_cnt = 1;
% for j = 13:(13+48-1)
%     featureMat(:,:,j) = response_Texton(:,:,tmp_cnt);
%     tmp_cnt = tmp_cnt + 1;
% end
% =============================
featureMat = featureMat(:,:,~isnan(squeeze(sum(sum(featureMat,1),2))));


[I_segm, I_posterior, I_max_posterior, ll] = fn_GMMSegforImg(featureMat, C, max_iteration, Rep);

if strcmp(display_option,'yes') == 1
figure; imagesc(I_segm); daspect([1 1 1]); set(gca,'xtick',[]); set(gca,'ytick',[]);
figure; imagesc(I_max_posterior); daspect([1 1 1]); set(gca,'xtick',[]); set(gca,'ytick',[]);
figure; imagesc(I_posterior(:,:,1:3)); daspect([1 1 1]); set(gca,'xtick',[]); set(gca,'ytick',[]);
disp(['The log-likelihood is ',num2str(ll)]);
end


